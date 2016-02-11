-module(one).
-compile(export_all).

idx(E, [H|_]) when E =:= H -> 1;
idx(E, [_|T]) -> 1 + idx(E, T).

split(Weights) -> split(Weights, lists:sum(Weights) div 3).

split([], _Capacity) -> [[]];
split(_Weights, Capacity) when Capacity =:= 0 -> [[]];
split(Weights, Capacity) ->
    L = [[H|T] || H <- Weights,
                  T <- split(Weights -- [H], Capacity - H),
                  lists:all(fun(X) -> X > H end, T),
                  lists:sum(T) =:= Capacity - H],
    L.

triplets(ListOfLists) ->
    [[A, B, C] || A <- ListOfLists,
                  B <- lists:filter(fun(List1) ->
                                        lists:all(fun(X1) ->
                                                      not lists:member(X1, A)
                                                  end, List1)
                                    end, ListOfLists),
                  C <- lists:filter(fun(List2) ->
                                        lists:all(fun(X2) ->
                                                      (not lists:member(X2, A))
                                                       and (not lists:member(X2, B))
                                                  end, List2)
                                    end, ListOfLists),
                  idx(A, ListOfLists) < idx(B, ListOfLists),
                  idx(B, ListOfLists) < idx(C, ListOfLists)].

prod(List) -> lists:foldl(fun(X, Prod) -> X * Prod end, 1, List).

calc(Weights) ->
    Triplets = triplets(split(Weights)),
    MinLen = lists:foldl(fun([A, B, C], Min) ->
                             min(Min, min(length(A), min(length(B), length(C))))
                         end, max, Triplets),
    Filtered = lists:filter(fun([A, B, C]) when length(A) =:= MinLen;
                                                length(B) =:= MinLen;
                                                length(C) =:= MinLen -> true;
                               (_) -> false
                            end, Triplets),
    lists:foldl(fun(List, MinQE) ->
                    Smallest = lists:filter(fun(X) -> length(X) =:= MinLen end, List),
                    min(MinQE, lists:min(lists:map(fun prod/1, Smallest)))
                end, max, Filtered).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() ->
    {ok, Device} = file:open("input.txt", [read]),
    calc(lists:map(fun(X) -> list_to_integer(X) end, string:tokens(get_all_lines(Device), "\n"))).
