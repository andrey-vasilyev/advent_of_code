-module(one).
-compile(export_all).

diag_number(Row, Column) -> Row + Column - 1.

arith_prog(N) -> N * (N + 1) div 2.

f(1, Acc) -> Acc;
f(X, Acc) -> f(X - 1, Acc * 252533 rem 33554393).

calc(Row, Column) ->
    Num = arith_prog(diag_number(Row, Column) - 1) + Column,
    f(Num, 20151125).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    InputLine = io:get_line(Device, ""),
    {match, MatchList} = re:run(InputLine, "[\\d]+", [global]),
    [Row, Column] = lists:map(fun([{Start, Len}]) ->
                                  list_to_integer(string:substr(InputLine, Start + 1, Len))
                              end, MatchList),
    calc(Row, Column).
