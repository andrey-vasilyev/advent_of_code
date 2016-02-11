-module(one).
-compile(export_all).

conv(String) ->
    case string:tokens(String, " ") of
        [Something] -> case string:to_integer(Something) of
                           {Res, []} -> {num_, Res};
                           {error,no_integer} -> {wire_, Something}
                       end;
        [_, Y] -> {not_, Y};
        [X, Y, Z] when Y =:= "AND", X =:= "1" -> {and_, 1, Z};
        [X, Y, Z] when Y =:= "AND" -> {and_, X, Z};
        [X, Y, Z] when Y =:= "OR" -> {or_, X, Z};
        [X, Y, Z] when Y =:= "LSHIFT" -> {lshift_, X, list_to_integer(Z)};
        [X, Y, Z] when Y =:= "RSHIFT" -> {rshift_, X, list_to_integer(Z)}
    end.

bin_16_not(Num) ->
    binary:decode_unsigned(list_to_binary(lists:map(fun(X) -> 255 - X end, binary:bin_to_list(<<Num:16>>)))).

calc(Ets, Wire) ->
    [{_,Value}] = ets:lookup(Ets, Wire),
    case Value of
        {wire_, W} -> calc(Ets, W);
        {num_, Num} -> Num;
        {not_, W} -> Res = bin_16_not(calc(Ets, W)), ets:insert(Ets, {Wire, {num_, Res}}), Res;
        {lshift_, W, Num} -> Res = calc(Ets, W) bsl Num, ets:insert(Ets, {Wire, {num_, Res}}), Res;
        {rshift_, W, Num} -> Res = calc(Ets, W) bsr Num, ets:insert(Ets, {Wire, {num_, Res}}), Res;
        {and_, 1, W} -> Res = 1 band calc(Ets, W), ets:insert(Ets, {Wire, {num_, Res}}), Res;
        {and_, X, Y} -> Res = calc(Ets, X) band calc(Ets, Y), ets:insert(Ets, {Wire, {num_, Res}}), Res;
        {or_, X, Y} -> Res = calc(Ets, X) bor calc(Ets, Y), ets:insert(Ets, {Wire, {num_, Res}}), Res
    end.

to_ets(Strings, Ets) ->
    lists:foldl(fun(X, E) ->
                  [Left, Right] = string:tokens(X, "->"),
                  ets:insert(E, {string:strip(Right), conv(Left)}),
                  E
              end, Ets, Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    Gates = string:tokens(get_all_lines(Device), "\n"),
    calc(to_ets(Gates, ets:new(elems, [])), "a").
