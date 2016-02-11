-module(one).
-compile(export_all).

calc([]) -> 0;
calc(Str) ->
    length([X || X <- Str, X == $(]) - length([X || X <- Str, X == $)]).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(io:get_line(Device, "")).
