-module(two).
-compile(export_all).

-record(effect, {name, mana=0, damage=0, armor=0, turns=0}).
-record(pers, {name, hit_points, mana=0, damage=0, armor=0, effects=[]}).
-record(spell, {name, cost, mana=0, damage=0, heals=0, armor=0, turns=0}).

damage(Effects) -> lists:foldl(fun(E, Acc) -> E#effect.damage + Acc end, 0, Effects).

armor(Effects) -> lists:foldl(fun(E, Acc) -> E#effect.armor + Acc end, 0, Effects).

mana(Effects) -> lists:foldl(fun(E, Acc) -> E#effect.mana + Acc end, 0, Effects).

spells() ->
    [#spell{name="Magic Missle", cost=53,            damage=4                            },
     #spell{name="Drain",        cost=73,            damage=2,           heals=2         },
     #spell{name="Poison",       cost=173,           damage=3,                    turns=6},
     #spell{name="Shield",       cost=113,                     armor=7,           turns=6},
     #spell{name="Recharge",     cost=229, mana=101,                              turns=5}].

apply_effects(You, Boss) when You#pers.effects =:= [] -> {You, Boss};
apply_effects(You, Boss) ->
    Effects = lists:foldl(
        fun(E, Acc) when E#effect.turns > 0 ->
            lists:reverse([E#effect{turns=E#effect.turns - 1}] ++ Acc);
           (_, Acc) -> Acc
        end, [], You#pers.effects),
    {You#pers{effects=Effects, mana=You#pers.mana + mana(Effects), armor=armor(Effects)},
     Boss#pers{hit_points=Boss#pers.hit_points - damage(Effects)}}.

cast_spell(You, Boss, Spell) ->
    case Spell#spell.turns of
        X when X =:= 0 ->
             {You#pers{hit_points=You#pers.hit_points + Spell#spell.heals,
                       mana=You#pers.mana - Spell#spell.cost},
              Boss#pers{hit_points=Boss#pers.hit_points - Spell#spell.damage}};
        _ -> Effect = #effect{name=Spell#spell.name,
                              mana=Spell#spell.mana,
                              damage=Spell#spell.damage,
                              armor=Spell#spell.armor,
                              turns=Spell#spell.turns},
             {You#pers{mana=You#pers.mana - Spell#spell.cost,
                    effects=You#pers.effects ++ [Effect]},
              Boss}
    end.

total_mana(Spells) when Spells =:= none -> max;
total_mana(Spells) -> lists:foldl(fun(S, Sum) -> Sum + S#spell.cost end, 0, Spells).

allowed_spells(You, Spells) ->
    ActiveEffectNames = lists:foldl(fun(E, Acc) when E#effect.turns > 0 ->
                                        [E#effect.name] ++ Acc;
                                       (_, Acc) -> Acc
                                    end, [], You#pers.effects),
    [Spell || Spell <- Spells, not lists:member(Spell#spell.name, ActiveEffectNames)].

turn(_You, #pers{hit_points=BossHP}, _Spells, _Turn, CastedSpells, _MaxMana) when BossHP < 1 ->
    {win, CastedSpells};
turn(#pers{hit_points=YourHP, mana=YourMana}, _Boss, _Spells, _Turn, _CastedSpells, _MaxMana) when YourHP < 1; YourMana < 1 ->
    {lost, none};
turn(#pers{hit_points=YourHP}, _Boss, _Spells, Turn, _CastedSpells, _MaxMana) when Turn =:= you, YourHP < 2 ->
    {lost, none};
turn(You, Boss, Spells, Turn, CastedSpells, MaxMana) when Turn =:= you ->
    YouMinus1HP = You#pers{hit_points=You#pers.hit_points - 1},
    {AffectedYou, AffectedBoss} = apply_effects(YouMinus1HP, Boss),
    Outcomes = lists:map(fun(S) ->
                             case total_mana(CastedSpells) + S#spell.cost < MaxMana of
                                 true -> {NewY, NewB} = cast_spell(AffectedYou, AffectedBoss, S),
                                         turn(NewY, NewB, Spells, boss, CastedSpells ++ [S], MaxMana);
                                 _ -> {lost, none}
                             end
                         end, allowed_spells(AffectedYou, Spells)),
    GoodOutcomes = lists:filter(fun({Outcome, _}) -> Outcome =:= win end, Outcomes),
    case length(GoodOutcomes) > 0 of
        true -> {_, Res} = lists:foldl(fun({_, CS}, {Min, Result}) ->
                               case total_mana(CS) of
                                   X when X < Min -> {X, CS};
                                   _ -> {Min, Result}
                               end
                           end, {max, []}, GoodOutcomes),
                {win, Res};
        _ -> {lost, none}
    end;

turn(You, Boss, Spells, _Turn, CastedSpells, MaxMana) ->
    case total_mana(CastedSpells) >= MaxMana of
        true -> {lost, none};
        _ -> {AffectedYou, AffectedBoss} = apply_effects(You, Boss),
             case AffectedBoss#pers.hit_points > 0 of
                true -> BossDamage = max(1, AffectedBoss#pers.damage - AffectedYou#pers.armor),
                        NewYou = AffectedYou#pers{hit_points=AffectedYou#pers.hit_points - BossDamage},
                        turn(NewYou, AffectedBoss, Spells, you, CastedSpells, MaxMana);
                _ -> {win, CastedSpells}
            end
    end.

idx(E, [H|_]) when E =:= H -> 1;
idx(E, [_|T]) -> 1 + idx(E, T).

spell_sublists(N) when N =:= 1 -> lists:map(fun(X) -> [X] end, spells());
spell_sublists(N) ->
    [[H|T] || H <- spells(),
              T <- lists:filter(fun(L) ->
                  lists:all(fun(X) ->
                      idx(X, spells()) > idx(H, spells())
                  end, L)
              end, spell_sublists(N-1)),
              length(T) =:= N - 1].

calc(You, Boss) ->
    lists:foldl(fun(N, MinMana) ->
        Res = lists:foldl(fun(SubSpells, Min) ->
                 {_, CastedSpells} = turn(You, Boss, SubSpells, you, [], Min),
                 min(Min, total_mana(CastedSpells))
             end, MinMana, spell_sublists(N)),
        min(Res, MinMana)
    end, max, lists:seq(1,length(spells()))).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),

    [HP, D] = lists:map(fun(X) ->
                            list_to_integer(hd(lists:reverse(string:tokens(X, " "))))
              end, string:tokens(get_all_lines(Device), "\n")),

    You = #pers{name="you", hit_points=50, mana=500},
    Boss = #pers{name="boss", hit_points=HP, damage=D},

    calc(You, Boss).
