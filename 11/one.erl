-module(one).
-compile(export_all).

incr(String, 0) -> incr(String, length(String));
incr(String, Nth) ->
    Value = lists:nth(Nth, String),
    case Value < $z of
        true -> lists:sublist(String, Nth - 1) ++
                [Value + 1] ++
                lists:sublist(String, Nth + 1, length(String) - Nth);
        false -> incr(lists:sublist(String, Nth - 1) ++
                 [$a] ++
                 lists:sublist(String, Nth + 1, length(String) - Nth), Nth - 1)
    end.

next(String) -> incr(String, length(String)).

three_incr(_, {_, _, true}) -> {true, true, true};
three_incr(Char, {false, false, _}) -> {Char, false, false};
three_incr(Char, {X, false, _}) when Char =:= X + 1 -> {X, Char, false};
three_incr(Char, {X, false, _}) when Char =/= X + 1 -> {Char, false, false};
three_incr(Char, {_, Y, _}) when Char =:= Y + 1 -> {true, true, true};
three_incr(Char, {_, Y, _}) when Char =/= Y + 1 -> {Char, false, false}.

check_three_incr(String) ->
    {_, _, Res} = lists:foldl(fun three_incr/2, {false, false, false}, String),
    Res.

check_no_iol(String) ->
    lists:all(fun(X) when X =/= $i, X =/= $o, X =/= $l -> true; (_) -> false end, String).

has_pair(_, {_, X}) when X > 1 -> {true, X};
has_pair(Cur, {Prev, X}) when Cur =:= Prev -> {false, X + 1};
has_pair(Cur, {_, X}) -> {Cur, X}.

check_pair(String) ->
    {_, Res} = lists:foldl(fun has_pair/2, {false, 0}, String),
    Res > 1.

is_good(String) ->
    check_three_incr(String) and check_no_iol(String) and check_pair(String).

calc(Passwd) ->
    NewPasswd = next(Passwd),
    case is_good(NewPasswd) of
        true -> NewPasswd;
        false -> calc(NewPasswd)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:strip(io:get_line(Device, ""), right, $\n)).
