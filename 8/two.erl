-module(two).
-compile(export_all).

f(Char, Acc) when Char =:= $\\ -> [$\\] ++ [$\\] ++ Acc;
f(Char, Acc) when Char =:= $" -> [$"] ++ [$\\] ++ Acc;
f(Char, Acc) -> [Char] ++ Acc.

process_str(String, Acc) ->
    X = string:len(String),
    Y = lists:foldl(fun f/2, "\"", String),
    Acc + (length(Y) + 1 - X).

calc(Strings) ->
    lists:foldl(fun process_str/2, 0, Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
