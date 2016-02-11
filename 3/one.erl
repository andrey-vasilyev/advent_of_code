-module(one).
-compile(export_all).

calc(List) -> calc(List, {0, 0}, sets:new()).

calc([], Pair, Set) -> sets:size(sets:add_element(Pair, Set));
calc([$^|T], {X, Y}, Set) ->
    calc(T, {X + 1, Y}, sets:add_element({X, Y}, Set));
calc([$v|T], {X, Y}, Set) ->
    calc(T, {X - 1, Y}, sets:add_element({X, Y}, Set));
calc([$<|T], {X, Y}, Set) ->
    calc(T, {X, Y - 1}, sets:add_element({X, Y}, Set));
calc([$>|T], {X, Y}, Set) ->
    calc(T, {X, Y + 1}, sets:add_element({X, Y}, Set)).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(io:get_line(Device, "")).
