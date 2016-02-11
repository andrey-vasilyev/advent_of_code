-module(two).
-compile(export_all).

take_odd([]) -> [];
take_odd([X]) -> [X];
take_odd([X,_|T]) -> [X] ++ take_odd(T).

take_even([]) -> [];
take_even([_]) -> [];
take_even([_,X|T]) -> [X] ++ take_even(T).

calc(List) -> sets:size(calc(take_even(List), {0, 0}, calc(take_odd(List), {0, 0}, sets:new()))).

calc([], Pair, Set) -> sets:add_element(Pair, Set);
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
