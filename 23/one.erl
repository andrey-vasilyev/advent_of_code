-module(one).
-compile(export_all).

calc(Program) ->
    {_, B} = calc(0, 0, 1, Program),
    B.

calc(A, B, PC, Program) when PC < 1; PC > length(Program) -> {A, B};
calc(A, B, PC, Program) ->
    [Instruction|T] = string:tokens(lists:nth(PC, Program), " "),
    case Instruction of
        I when I =:= "hlf", hd(T) =:= "a" -> calc(A div 2, B, PC + 1, Program);
        I when I =:= "hlf" -> calc(A, B div 2, PC + 1, Program);

        I when I =:= "tpl", hd(T) =:= "a" -> calc(A * 3, B, PC + 1, Program);
        I when I =:= "tpl" -> calc(A, B * 3, PC + 1, Program);

        I when I =:= "inc", hd(T) =:= "a" -> calc(A + 1, B, PC + 1, Program);
        I when I =:= "inc" -> calc(A, B + 1, PC + 1, Program);

        I when I =:= "jmp" -> calc(A, B, PC + list_to_integer(hd(T)), Program);

        I when I =:= "jie", hd(hd(T)) =:= $a, A rem 2 =:= 0 ->
            calc(A, B, PC + list_to_integer(lists:nth(2, T)), Program);
        I when I =:= "jie", hd(hd(T)) =:= $b, B rem 2 =:= 0 ->
            calc(A, B, PC + list_to_integer(lists:nth(2, T)), Program);
        I when I =:= "jie" -> calc(A, B, PC + 1, Program);

        I when I =:= "jio", hd(hd(T)) =:= $a, A =:= 1 ->
            calc(A, B, PC + list_to_integer(lists:nth(2, T)), Program);
        I when I =:= "jio", hd(hd(T)) =:= $b, B =:= 1 ->
            calc(A, B, PC + list_to_integer(lists:nth(2, T)), Program);
        I when I =:= "jio" -> calc(A, B, PC + 1, Program)
    end.

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
