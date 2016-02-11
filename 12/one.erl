-module(one).
-compile(export_all).

add(X, Acc) ->
    case string:to_integer(X) of
        {error, _} -> Acc;
        {I, _} -> Acc + I
    end.

calc(String) ->
    L = string:tokens(String, ":,{}[]"),
    lists:foldl(fun add/2, 0, L).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:strip(io:get_line(Device, ""), right, $\n)).
