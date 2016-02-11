-module(one).
-compile(export_all).

head([]) -> 0;
head(L) -> hd(L).

find_all(String, SubString) -> find_all(String, SubString, []).

find_all([], _, Acc) -> Acc;
find_all(String, SubString, Acc) ->
    Idx = string:str(String, SubString),
    case Idx > 0 of
        false -> Acc;
        true -> find_all(string:substr(String,
                                       Idx + 1,
                                       length(String)),
                         SubString,
                         [Idx + head(Acc)] ++ Acc)
    end.

myapply({From, To}, Str) ->
    Indicies = find_all(Str, From),
    lists:foldl(fun(Idx, AccSet) ->
                    NewStr = string:substr(Str, 1, Idx - 1) ++ To ++ string:substr(Str, Idx + length(From)),
                    sets:add_element(NewStr, AccSet)
                end, sets:new(), Indicies).

calc({Dict, Molecule}) ->
    sets:size(lists:foldl(fun(X, Set) ->
                              sets:union(Set, myapply(X, Molecule))
                          end, sets:new(), Dict)).

parse(Input) ->
    Molecule = lists:nth(length(Input), Input),
    D = lists:foldl(fun(E, Dict) ->
                        Tokens = string:tokens(E, " "),
                        Key = hd(Tokens),
                        Value = hd(lists:reverse(Tokens)),
                        [{Key, Value}] ++ Dict
                    end, [], lists:sublist(Input, length(Input) - 1)),
    {D, Molecule}.

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(parse(string:tokens(get_all_lines(Device), "\n"))).
