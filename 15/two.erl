-module(two).
-compile(export_all).

mulvv(V1, V2) ->
    lists:sum([X * Y || {X,Y} <- lists:zip(V1, V2)]).

mulmv(Matrix, Vector) ->
    [H|T] = lists:foldl(fun(V, Acc) ->
                            case mulvv(V, Vector) of
                                Res when Res > 0 -> [Res] ++ Acc;
                                _ -> [0] ++ Acc
                            end
                        end, [], Matrix),
    case H =:= 500 of
        true -> lists:foldl(fun(X, Acc) -> X * Acc end, 1, T);
        _ -> -1
    end.


trans(Matrix) ->
    lists:foldl(fun(X, Acc) ->
                    lists:zipwith(fun(V1, V2) -> lists:reverse([V1] ++ V2) end, X, Acc)
                end,
                [[]||_ <- lists:seq(1, length(hd(Matrix)))], Matrix).

calc(List) ->
    Vectors = [[T, X, Y, Z] || T <- lists:seq(0, 100), X <- lists:seq(0, 100), Y <- lists:seq(0, 100), Z <- lists:seq(0, 100), T + X + Y + Z =:= 100],
    Matrix = trans(List),
    Tmp = lists:map(fun(V) -> mulmv(Matrix, V) end, Vectors),
    lists:foldl(fun(X, Acc) -> max(X, Acc) end, -1,  Tmp).

to_list(Strings) ->
    lists:map(fun(X) ->
                {match, MatchList} = re:run(X, "-?\\d+", [global]),
                lists:foldl(fun([{Start, Len}], Acc) ->
                                Acc ++ [list_to_integer(string:substr(X, Start + 1, Len))]
                            end, [], MatchList)
              end, Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(to_list(string:tokens(get_all_lines(Device), "\n"))).
