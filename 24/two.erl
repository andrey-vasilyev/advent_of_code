-module(two).
-compile(export_all).

minlen(K, S, Numbers, _Ets)   when K > 0, S =:= 1, hd(Numbers) =:= 1 -> [[1]];
minlen(K, S, _Numbers, _Ets)  when K > 0, S =:= 1 -> [[]];
minlen(K, S, Numbers, _Ets)   when K =:= 1, S =:= hd(Numbers) -> [[S]];
minlen(K, _S, _Numbers, _Ets) when K =:= 1 -> [[]];
minlen(K, S, Numbers, Ets) ->
    Sublist = lists:sublist(Numbers, K),
    case lists:sum(Sublist) of
        Sum when Sum =:= S -> [Sublist];
        Sum when Sum < S -> [[]];
        _ -> case lists:member(S, Sublist) of
                 true -> [[S]];
                 false -> [{_, V1}] = ets:lookup(Ets, {K - 1, S}),
                          V2 = case ets:lookup(Ets, {K - 1, S - lists:nth(K, Numbers)}) of
                                  [{_, Y}] when Y =:= [[]] -> [[]];
                                  [{_, Y}] -> Y;
                                  [] -> [[]]
                               end,
                          if (V1 =:= [[]]) andalso (V2 =:= [[]]) -> [[]]
                           ; (V2 =:= [[]]) orelse (V1 =/= [[]] andalso (length(hd(V1)) < length(hd(V2)) + 1)) -> V1
                           ; (V1 =:= [[]]) orelse (V2 =/= [[]] andalso (length(hd(V2)) + 1 < length(hd(V1)))) ->
                                 lists:map(fun(L) -> L ++ [lists:nth(K, Numbers)] end, V2)
                           ; length(hd(V1)) =:= length(hd(V2)) + 1 ->
                                 lists:merge(V1, lists:map(fun(L) -> L ++ [lists:nth(K, Numbers)] end, V2))
                          end
             end
    end.

prod(List) -> lists:foldl(fun(X, Prod) -> X * Prod end, 1, List).

build_table(Height, Width, Numbers) ->
    lists:foldl(fun({K, S}, Acc) ->
                    ets:insert(Acc, {{K, S}, minlen(K, S, Numbers, Acc)}),
                    Acc
                end, ets:new(table, []),
                [{X, Y} || X <- lists:seq(1, Height), Y <- lists:seq(1, Width)]).

calc(Weights) ->
    Table = build_table(length(Weights), lists:sum(Weights) div 4, Weights),
    [{_, MinLen}] = ets:lookup(Table, {length(Weights), lists:sum(Weights) div 4}),
    lists:foldl(fun(L, Min) -> min(Min, prod(L)) end, max, MinLen).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(lists:reverse(lists:map(fun(X) -> list_to_integer(X) end, string:tokens(get_all_lines(Device), "\n")))).
