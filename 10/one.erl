-module(one).
-compile(export_all).

conv(Buf) -> [hd(Buf)] ++ integer_to_list(length(Buf)).

next(Char, {[], Res}) -> {[Char], Res};
next(Char, {[H|T], Res}) when Char =:= H -> {[Char] ++ [H] ++ T, Res};
next(Char, {Buf, Res}) -> {[Char], conv(Buf) ++ Res}.

calc(String, 0) -> length(String);
calc(String, Limit) ->
    {Buf, Res} = lists:foldl(fun next/2, {[], []}, String),
    calc(lists:reverse(conv(Buf) ++ Res), Limit - 1).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:strip(io:get_line(Device, ""), right, $\n), 40).
