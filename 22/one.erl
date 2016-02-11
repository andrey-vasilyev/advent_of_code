-module(one).
-compile(export_all).

-record(effect, {name, mana=0, damage=0, armor=0, turns=0}).
-record(pers, {name, hit_points, mana=0, damage=0, armor=0, effects=[]}).
-record(spell, {name, cost, mana=0, damage=0, heals=0, armor=0, turns=0}).

damage(Effects) -> lists:foldl(fun(E, Acc) -> E#effect.damage + Acc end, 0, Effects).

armor(Effects) -> lists:foldl(fun(E, Acc) -> E#effect.armor + Acc end, 0, Effects).

mana(Effects) -> lists:foldl(fun(E, Acc) -> E#effect.mana + Acc end, 0, Effects).

apply_effects(You, Boss) ->
    Effects = lists:foldl(
        fun(E, Acc) when E#effect.turns > 0 ->
            lists:reverse([E#effect{turns=E#effect.turns - 1}] ++ Acc);
           (_, Acc) -> Acc
        end, [], You#pers.effects),
    {You#pers{effects=Effects,
              mana=You#pers.mana + mana(Effects),
              armor=armor(Effects)},
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
                              armor=element(7, Spell),
                              turns=Spell#spell.turns},
             {You#pers{mana=You#pers.mana - Spell#spell.cost,
                       effects=You#pers.effects ++ [Effect]},
              Boss}
    end.

total_mana([]) -> udef;
total_mana(Spells) -> lists:foldl(fun(S, Sum) -> Sum + S#spell.cost end, 0, Spells).

turn(_You, #pers{hit_points=BossHP}, _Spells, _Turn, CastedSpells, _MaxMana) when BossHP < 1 ->
    {win, CastedSpells};
turn(#pers{hit_points=YourHP, mana=YourMana}, _Boss, _Spells, _Turn, CastedSpells, _MaxMana) when YourHP < 1; YourMana < 1 ->
    {lost, CastedSpells};
turn(You, Boss, Spells, Turn, CastedSpells, MaxMana) when Turn =:= you ->
    {AffectedYou, AffectedBoss} = apply_effects(You, Boss),
    ActiveEffectNames = lists:map(fun(E) -> E#effect.name end, AffectedYou#pers.effects),
    AvailableSpells = [Spell || Spell <- Spells,
                                not lists:member(Spell#spell.name, ActiveEffectNames)],
    Outcomes = lists:map(fun(S) ->
                             {NewY, NewB} = cast_spell(AffectedYou, AffectedBoss, S),
                             turn(NewY, NewB, Spells, boss, CastedSpells ++ [S], MaxMana)
                         end, AvailableSpells),
    GoodOutcomes = lists:filter(fun({Outcome, _}) -> Outcome =:= win end, Outcomes),
    case length(GoodOutcomes) > 0 of
        true -> {_, Res} = lists:foldl(fun({_, CS}, {Min, Result}) ->
                               case total_mana(CS) of
                                   X when X < Min -> {X, CS};
                                   _ -> {Min, Result}
                               end
                           end, {max, []}, GoodOutcomes),
                {win, Res};
        _ -> {lost, []}
    end;

turn(You, Boss, Spells, _Turn, CastedSpells, MaxMana) ->
    case total_mana(CastedSpells) >= MaxMana of
        true -> {lost, []};
        _ ->
             {AffectedYou, AffectedBoss} = apply_effects(You, Boss),
             BossDamage = case AffectedBoss#pers.damage - AffectedYou#pers.armor of
                              X when X < 1 -> 1;
                              X -> X
                          end,
             NewYou = AffectedYou#pers{hit_points=AffectedYou#pers.hit_points - BossDamage},
             turn(NewYou, AffectedBoss, Spells, you, CastedSpells, MaxMana)
    end.

idx(E, [H|_]) when E =:= H -> 1;
idx(E, [_|T]) -> 1 + idx(E, T).

spell_sublists(N, Spells) when N =:= 1 -> lists:map(fun(X) -> [X] end, Spells);
spell_sublists(N, Spells) ->
    [[H|T] || H <- Spells,
              T <- lists:filter(fun(L) ->
                  lists:all(fun(X) ->
                      idx(X, Spells) > idx(H, Spells)
                  end, L)
              end, spell_sublists(N-1, Spells)),
              length(T) =:= N - 1].

calc(You, Boss, Spells) ->
    lists:foldl(fun(N, MinMana) ->
        Res = lists:foldl(fun(AllowedSpells, Min) ->
                 {_, CastedSpells} = turn(You, Boss, AllowedSpells, you, [], Min),
                 case total_mana(CastedSpells) of
                     TotalMana when TotalMana < Min -> TotalMana;
                     _ -> Min
                 end
             end, MinMana, spell_sublists(N, Spells)),
        case Res < MinMana of
            true -> Res;
            _ -> MinMana
        end
    end, max_mana, lists:seq(1,length(Spells))).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),

    You = #pers{name="you", hit_points=50, mana=500},

    [HP, D] = lists:map(fun(X) ->
                            list_to_integer(hd(lists:reverse(string:tokens(X, " "))))
              end, string:tokens(get_all_lines(Device), "\n")),

    Boss = #pers{name="boss", hit_points=HP, damage=D},

    Spells = [#spell{name="Magic Missle", cost=53,            damage=4},
              #spell{name="Drain",        cost=73,            damage=2,           heals=2},
              #spell{name="Poison",       cost=173,           damage=3,                    turns=6},
              #spell{name="Shield",       cost=113,                     armor=7,           turns=6},
              #spell{name="Recharge",     cost=229, mana=101,                              turns=5}],

    calc(You, Boss, Spells).
