-module(one).
-compile(export_all).

-record(aunt, {num,
               children,
               cats,
               samoyeds,
               pomeranians,
               akitas,
               vizslas,
               goldfish,
               trees,
               cars,
               perfumes}).

parse(List, Key) ->
    case lists:member(Key, List) of
        true ->
            Idx = string:str(List, [Key]),
            list_to_integer(hd(string:tokens(lists:nth(Idx + 1, List), ",")));
        _ -> undefined
    end.

cmp(Aunt) ->
    LookFor = tuple_to_list(#aunt{num=undefined, children=3, cats=7,
                                  samoyeds=2, pomeranians=3, akitas=0,
                                  vizslas=0, goldfish=5, trees=3,
                                  cars=2, perfumes=1}),
    lists:foldl(fun({A, B}, Acc) when A =:= B, A =/= undefined -> Acc + 1;
                   (_, Acc) -> Acc
                end, 0, lists:zip(LookFor, tuple_to_list(Aunt))) > 3.

calc(List) ->
    list_to_integer(hd((hd(lists:filter(fun cmp/1, List)))#aunt.num)).

to_list(Strings) ->
    lists:map(fun(X) ->
                [_|Tokens] = string:tokens(X, " "),
                Num = string:tokens(hd(Tokens), ":"),

                #aunt{num=Num, children=parse(Tokens, "children:"),
                      cats=parse(Tokens, "cats:"),
                      samoyeds=parse(Tokens, "samoyeds:"),
                      pomeranians=parse(Tokens, "pomeranians:"),
                      akitas=parse(Tokens, "akitas:"),
                      vizslas=parse(Tokens, "vizslas:"),
                      goldfish=parse(Tokens, "goldfish:"),
                      trees=parse(Tokens, "trees:"),
                      cars=parse(Tokens, "cars:"),
                      perfumes=parse(Tokens, "perfumes:")}
              end, Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(to_list(string:tokens(get_all_lines(Device), "\n"))).
