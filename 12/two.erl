-module(two).
-compile(export_all).

fob(_, {_, Pos, stop}) -> {[], Pos, stop};
fob(Char, {[], Pos, _}) when Char =:= ${ -> {[], Pos - 1, stop};
fob(Char, {Stack, Pos, _}) when Char =:= $} -> {[Char] ++ Stack , Pos - 1, work};
fob(Char, {[_|T], Pos, _}) when Char =:= ${ -> {T, Pos - 1, work};
fob(_, {Stack, Pos, _}) -> {Stack, Pos - 1, work}.

find_opening_bracket(String) ->
    {_, Pos, _} = lists:foldr(fun fob/2, {[], length(String), work}, String),
    Pos.

fcb(_, {_, Pos, stop}) -> {[], Pos, stop};
fcb(Char, {[], Pos, _}) when Char =:= $} -> {[], Pos + 1, stop};
fcb(Char, {Stack, Pos, _}) when Char =:= ${ -> {[Char] ++ Stack , Pos + 1, work};
fcb(Char, {[_|T], Pos, _}) when Char =:= $} -> {T, Pos + 1, work};
fcb(_, {Stack, Pos, _}) -> {Stack, Pos + 1, work}.

find_closing_bracket(String) ->
    {_, Pos, _} = lists:foldl(fun fcb/2, {[], 1, work}, String),
    Pos.

remove_red(String) ->
    case string:str(String, ":\"red\"") of
        0 -> String;
        X -> remove_red(remove_red(String, X))
    end.

remove_red(String, X) ->
    Left = string:sub_string(String, 1, X),
    Right = string:sub_string(String, X + 1, length(String)),
    A = find_opening_bracket(Left),
    B = find_closing_bracket(Right) + X,
    string:concat(string:sub_string(String, 1, A), string:sub_string(String, B, length(String))).

add(X, Acc) ->
    case string:to_integer(X) of
        {error, _} -> Acc;
        {I, _} -> Acc + I
    end.

calc(String) ->
    L = string:tokens(remove_red(String), ":,{}[]"),
    lists:foldl(fun add/2, 0, L).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:strip(io:get_line(Device, ""), right, $\n)).
