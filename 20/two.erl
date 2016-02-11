-module(two).
-compile(export_all).

nextprime(Start, Cache) ->
    case ets:foldl(fun({Prime, _}, prime) when Start rem Prime =:= 0 -> notprime;
                      (_, notprime) -> notprime;
                      (_, _) -> prime
                   end, prime, Cache) of
         prime -> [{_, Num}] = ets:lookup(Cache, ets:last(Cache)),
                  ets:insert(Cache, {Start, Num + 1}),
                  Start;
         notprime -> nextprime(Start + 1, Cache)
    end.

factorize(N, Cache) ->
    case ets:lookup(Cache, N) of
        [_] -> [{N, 1}];
        [] -> dict:to_list(factorize(N, Cache, ets:first(Cache), dict:new()))
    end.

factorize(1, _, _, Acc) -> Acc;
factorize(N, Cache, P, Acc) ->
    case N rem P =:= 0 of
        false -> NextPrime = case ets:next(Cache, P) of
                                '$end_of_table' -> nextprime(P + 1, Cache);
                                X -> X
                             end,
                 factorize(N, Cache, NextPrime, Acc);
        true -> factorize(N div P, Cache, P, dict:update(P, fun(X) -> X + 1 end, 1, Acc))
    end.

get_divs(N, Cache) ->
    lists:foldl(fun({P, K}, Acc) ->
                    [X * Y || X <- Acc, Y <- [round(math:pow(P, Z)) || Z <- lists:seq(0, K)]]
                end, [1], factorize(N, Cache)).

num_of_presents(HouseNum, Cache) ->
    11 * lists:sum(lists:filter(fun(X) -> X * 50 >= HouseNum end, get_divs(HouseNum, Cache))).

calc(Limit) ->
    Ets = ets:new(cache, [ordered_set]),
    ets:insert(Ets, {2, 1}),
    run(Limit, {1, 11}, Ets).

run(Limit, {HouseNum, NumOfPresents}, _) when NumOfPresents >= Limit -> HouseNum;
run(Limit, {HouseNum, _}, Cache) ->
    run(Limit, {HouseNum + 1, num_of_presents(HouseNum + 1, Cache)}, Cache).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(list_to_integer(hd(string:tokens(get_all_lines(Device), "\n")))).
