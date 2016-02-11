-module(one).
-compile(export_all).

sublists([], _) -> [[]];
sublists(List, 1) -> lists:map(fun(E) -> [E] end, List);
sublists(List, Len) ->
    lists:foldl(fun(Nth, Acc) ->
                    H = lists:nth(Nth, List),
                    Tails = sublists(lists:sublist(List, Nth + 1, length(List)), Len - 1),
                    [[H|T] || T <- Tails, length(T) =:= Len - 1] ++ Acc
                end, [], lists:seq(1, length(List))).

count(ListOfLists) ->
    lists:foldl(fun(List, Acc) ->
                    case lists:sum(List) =:= 150 of
                        true -> Acc + 1;
                        false -> Acc
                    end
                end, 0, ListOfLists).

calc(List) ->
    {_, SmallestNumOfElems} = lists:foldr(fun(_, {Sum, Num}) when Sum >= 150 -> {Sum, Num};
                                             (E, {Sum, Num}) -> {Sum + E, Num + 1}
                                          end, {0, 0}, lists:sort(List)),
    lists:foldl(fun(Num, Acc) ->
                    Acc + count(sublists(List, Num))
                end, 0, lists:seq(SmallestNumOfElems, length(List))).

to_list(Strings) ->
    lists:map(fun(X) -> list_to_integer(X) end, Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(to_list(string:tokens(get_all_lines(Device), "\n"))).
