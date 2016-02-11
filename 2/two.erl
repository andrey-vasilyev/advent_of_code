-module(two).
-compile(export_all).

ribbon_len(Dim) ->
    [W, H, L] = lists:sort(lists:map(fun list_to_integer/1, string:tokens(Dim, "x"))),
    2 * (W + H) + W * H * L.

calc(Dimensions) ->
    lists:foldl(fun(X, Sum) -> X + Sum end, 0, lists:map(fun ribbon_len/1, Dimensions)).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
