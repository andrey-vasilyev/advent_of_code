-module(two).
-compile(export_all).

-record(pers, {name, hit_points, damage, armor}).
-record(item, {name, cost, damage, armor}).
-record(store, {weapons, armor, rings}).

fight(_, #pers{hit_points=BossHP}) when BossHP =< 0 -> win;
fight(#pers{hit_points=YourHP}, _) when YourHP =< 0 -> lost;
fight(You, Boss) ->
    YourDamage = case You#pers.damage - Boss#pers.armor of
                     X when X =< 0 -> 1;
                     X -> X
                 end,
    BossDamage = case Boss#pers.damage - You#pers.armor of
                     Y when Y =< 0 -> 1;
                     Y -> Y
                 end,

    fight(You#pers{hit_points=(You#pers.hit_points - BossDamage)},
          Boss#pers{hit_points=(Boss#pers.hit_points - YourDamage)}).

cost(Weapon, Armor, Ring1, Ring2) -> Weapon#item.cost + Armor#item.cost + Ring1#item.cost + Ring2#item.cost.

brute_force(You, Boss, Store) ->
    Combs = [{W, A, R1, R2} || W <- lists:seq(1, length(Store#store.weapons)),
                               A <- lists:seq(1, length(Store#store.armor)),
                               R1 <- lists:seq(1, length(Store#store.rings)),
                               R2 <- lists:seq(1, length(Store#store.rings)),
                               R1 =/= R2],
    lists:foldl(fun({W, A, R1, R2}, {{AccW, AccA, AccR1, AccR2}, Max}) ->
        Weapon = lists:nth(W, Store#store.weapons),
        Armor  = lists:nth(A, Store#store.armor),
        Ring1  = lists:nth(R1, Store#store.rings),
        Ring2  = lists:nth(R2, Store#store.rings),
        case fight(You#pers{hit_points=You#pers.hit_points,
                            damage=Weapon#item.damage + Ring1#item.damage + Ring2#item.damage,
                            armor=Armor#item.armor + Ring1#item.armor + Ring2#item.armor},
                   Boss) of
            lost -> case cost(Weapon, Armor, Ring1, Ring2) of
                       X when X > Max -> {{W, A, R1, R2}, X};
                       _ -> {{AccW, AccA, AccR1, AccR2}, Max}
                   end;
            win -> {{AccW, AccA, AccR1, AccR2}, Max}
        end
    end, {{-1, -1, -1, -1}, 0}, Combs).

calc(You, Boss, Store) ->
    {{_Weapon, _Armor, _Ring1, _Ring2}, Max} = brute_force(You, Boss, Store),
%    {{Weapon, Armor, Ring1, Ring2}, Max} = brute_force(You, Boss, Store),
%    W = lists:nth(Weapon, Store#store.weapons),
%    A = lists:nth(Armor, Store#store.armor),
%    R1 = lists:nth(Ring1, Store#store.rings),
%    R2 = lists:nth(Ring2, Store#store.rings),
%    {{W#item.name, A#item.name, R1#item.name, R2#item.name}, Max}.
     Max.

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),

    You = #pers{name="you", hit_points=100, damage=0, armor=0},

    [HP, D, A] = lists:map(fun(X) ->
                                  list_to_integer(hd(lists:reverse(string:tokens(X, " "))))
                              end, string:tokens(get_all_lines(Device), "\n")),

    Boss = #pers{name="boss", hit_points=HP, damage=D, armor=A},

    Weapons = [#item{name="Dagger",     cost=8,   damage=4, armor=0},
               #item{name="Shortsword", cost=10,  damage=5, armor=0},
               #item{name="Warhammer",  cost=25,  damage=6, armor=0},
               #item{name="Longsword",  cost=40,  damage=7, armor=0},
               #item{name="Greataxe",   cost=74,  damage=8, armor=0}],

    Armor   = [#item{name="none",       cost=0,   damage=0, armor=0},
               #item{name="Leather",    cost=13,  damage=0, armor=1},
               #item{name="Chainmail",  cost=31,  damage=0, armor=2},
               #item{name="Splintmail", cost=53,  damage=0, armor=3},
               #item{name="Bandmail",   cost=75,  damage=0, armor=4},
               #item{name="Platemail",  cost=102, damage=0, armor=5}],

    Rings   = [#item{name="none",       cost=0,   damage=0, armor=0},
               #item{name="Damage +1",  cost=25,  damage=1, armor=0},
               #item{name="Damage +2",  cost=50,  damage=2, armor=0},
               #item{name="Damage +3",  cost=100, damage=3, armor=0},
               #item{name="Defense +1", cost=20,  damage=0, armor=1},
               #item{name="Defense +2", cost=40,  damage=0, armor=2},
               #item{name="Defense +3", cost=80,  damage=0, armor=3}],

    Store = #store{weapons=Weapons, armor=Armor, rings=Rings},

    calc(You, Boss, Store).
