-module(one).
-compile(export_all).

north(ListOfLists, Row, Col) -> lists:nth(Col, lists:nth(Row - 1, ListOfLists)).
northeast(ListOfLists, Row, Col) -> lists:nth(Col + 1, lists:nth(Row - 1, ListOfLists)).
east(ListOfLists, Row, Col) -> lists:nth(Col + 1, lists:nth(Row, ListOfLists)).
southeast(ListOfLists, Row, Col) -> lists:nth(Col + 1, lists:nth(Row + 1, ListOfLists)).
south(ListOfLists, Row, Col) -> lists:nth(Col, lists:nth(Row + 1, ListOfLists)).
southwest(ListOfLists, Row, Col) -> lists:nth(Col - 1, lists:nth(Row + 1, ListOfLists)).
west(ListOfLists, Row, Col) -> lists:nth(Col - 1, lists:nth(Row, ListOfLists)).
northwest(ListOfLists, Row, Col) -> lists:nth(Col - 1, lists:nth(Row - 1, ListOfLists)).

check_on(ListOfLists, Row, Col) ->
    Sum = north(ListOfLists, Row, Col) +
          northeast(ListOfLists, Row, Col) +
          east(ListOfLists, Row, Col) +
          southeast(ListOfLists, Row, Col) +
          south(ListOfLists, Row, Col) +
          southwest(ListOfLists, Row, Col) +
          west(ListOfLists, Row, Col) +
          northwest(ListOfLists, Row, Col),
   case (Sum =:= 2) orelse (Sum =:= 3) of
       true -> 1;
       false -> 0
   end.

check_off(ListOfLists, Row, Col) ->
    Sum = north(ListOfLists, Row, Col) +
          northeast(ListOfLists, Row, Col) +
          east(ListOfLists, Row, Col) +
          southeast(ListOfLists, Row, Col) +
          south(ListOfLists, Row, Col) +
          southwest(ListOfLists, Row, Col) +
          west(ListOfLists, Row, Col) +
          northwest(ListOfLists, Row, Col),
   case Sum =:= 3 of
       true -> 1;
       false -> 0
   end.

next(ListOfLists) ->
    lists:reverse(
      element(2,
              lists:foldl(fun(List, {Row, NewListOfLists}) when Row > 1, Row < length(ListOfLists) ->
                              {_, Tmp} = lists:foldl(fun(_, {Col, Acc}) when Col > 1, Col < length(List) ->
                                                         {Col + 1, [next(ListOfLists, Row, Col)] ++ Acc};
                                                        (E, {Col, Acc}) -> {Col + 1, [E] ++ Acc}
                                                     end, {1, []}, List),
                              {Row + 1, [lists:reverse(Tmp)] ++ NewListOfLists };
                              (List, {Row, NewListOfLists}) -> {Row + 1, [List] ++ NewListOfLists}
                          end, {1, []}, ListOfLists))).

next(ListOfLists, Row, Col) ->
    case lists:nth(Col, lists:nth(Row, ListOfLists)) of
        1 -> check_on(ListOfLists, Row, Col);
        0 -> check_off(ListOfLists, Row, Col)
    end.

count_on(ListOfLists) ->
    lists:sum(lists:map(fun(List) -> lists:sum(List) end, ListOfLists)).

calc(ListOfLists, 0) -> count_on(ListOfLists);
calc(ListOfLists, Iter) -> calc(next(ListOfLists), Iter - 1).

convert(ListOfLists) ->
    [lists:duplicate(length(hd(ListOfLists)) + 2, 0)] ++
    lists:map(fun(List) ->
                  [0] ++ lists:map(fun($.) -> 0; ($#) -> 1 end, List) ++ [0]
              end, ListOfLists) ++
    [lists:duplicate(length(hd(ListOfLists)) + 2, 0)].


get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(convert(string:tokens(get_all_lines(Device), "\n")), 100).
