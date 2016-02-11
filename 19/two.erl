-module(two).
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
    Indicies = lists:reverse(find_all(Str, To)),
    lists:foldl(fun(Idx, AccSet) ->
                    NewStr = string:substr(Str, 1, Idx - 1) ++ From ++ string:substr(Str, Idx + length(To)),
                    sets:add_element(NewStr, AccSet)
                end, sets:new(), Indicies).

bruteforce(_, Start, Targets, _, _) when length(Start) < length(hd(Targets)) -> impossible;
bruteforce(Dict, Start, Targets, Ets, Steps) ->
    case lists:member(Start, Targets) of
        true -> throw(Steps);
         _ ->   lists:foldl(fun(E, Acc1) ->
                    min(Acc1, lists:foldl(fun(NewStart, Acc2) ->
                        case ets:lookup(Ets, NewStart) of
                            [] -> case bruteforce(Dict, NewStart, Targets, Ets, Steps + 1) of
                                      impossible -> ets:insert(Ets, {NewStart, impossible}), Acc2;
                                      X -> ets:insert(Ets, {NewStart, min(X + 1, Acc2)}), min(X + 1, Acc2)
                                  end;
                            List -> min(hd(List), Acc2)
                        end
                    end, impossible, sets:to_list(myapply(E, Start))))
                end, impossible, Dict)
    end.

calc({Dict, Molecule}) ->
    {DictForE, TheDict} = lists:partition(fun({From, _}) -> From =:= "e" end, Dict),
    {_, Targets} = lists:unzip(DictForE),
    SortedDict = lists:sort(fun({_, B1}, {_, B2}) -> B2 =< B1 end, TheDict),

    % This is a hack. The bruteforce will look only for the first possible answer.
    % Luckily the first possbile answer is the correct one for the data given.
    %
    % A much faster (but not general) way to find the solution is here:
    % https://www.reddit.com/r/adventofcode/comments/3xflz8/day_19_solutions/cy4eju
    %
    try
        bruteforce(SortedDict, Molecule, Targets, ets:new(storage, ""), 1)
    catch
        throw:Steps -> Steps
    end.

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
