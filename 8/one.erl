-module(one).
-compile(export_all).

f(Char, {false, false, false, Len}) when Char =:= $\\ -> {$\\, false, false, Len};
f(Char, {$\\, false, false, Len}) when Char =:= $\\; Char =:= $" -> {false, false, false, Len + 1};
f(Char, {$\\, false, false, Len}) when Char =:= $x -> {$\\, $x, false, Len};
f(Char, {$\\, $x, false, Len}) -> {$\\, $x, Char, Len};
f(_, {$\\, $x, _, Len}) -> {false, false, false, Len + 1};
f([], {false, false, false, Len}) -> {false, false, false, Len};
f(_, {false, false, false, Len}) -> {false, false, false, Len + 1}.

process_str(String, Acc) ->
    X = string:len(String),
    {_, _, _, Y} = lists:foldl(fun f/2, {false, false, false, 0}, string:substr(String, 2, X - 2)),
    Acc + (X - Y).

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
