-module(one).
-compile(export_all).

only_vowels(X, Acc) when X =:= $a; X =:= $e; X =:= $i; X =:= $o; X =:= $u -> [X] ++ Acc;
only_vowels(_, Acc) -> Acc.

check_vowels(String) ->
    length(lists:foldl(fun only_vowels/2, [], String)) > 2.

double(_, true) -> true;
double(X, []) -> [X];
double(X, [H|_]) when X =:= H -> true;
double(X, [_]) -> [X].

check_double(String) ->
    lists:foldl(fun double/2, [], String) =:= true.

check_sub(String) ->
    AB = string:str(String, "ab"),
    CD = string:str(String, "cd"),
    PQ = string:str(String, "pq"),
    XY = string:str(String, "xy"),
    if AB > 0; CD > 0; PQ > 0; XY > 0 -> false;
       true -> true
    end.

calc(Strings) ->
    length(lists:filter(fun check_sub/1, lists:filter(fun check_double/1, lists:filter(fun check_vowels/1, Strings)))).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
