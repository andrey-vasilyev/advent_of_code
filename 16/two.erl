-module(two).
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

children(Aunt) when Aunt#aunt.children =:= 3 -> 1;
children(_) -> 0.
cats(Aunt) when is_integer(Aunt#aunt.cats), Aunt#aunt.cats > 7 -> 1;
cats(_) -> 0.
samoyeds(Aunt) when Aunt#aunt.samoyeds =:= 2 -> 1;
samoyeds(_) -> 0.
pomeranians(Aunt) when Aunt#aunt.pomeranians < 3 -> 1;
pomeranians(_) -> 0.
akitas(Aunt) when Aunt#aunt.akitas =:= 0 -> 1;
akitas(_) -> 0.
vizslas(Aunt) when Aunt#aunt.vizslas =:= 0 -> 1;
vizslas(_) -> 0.
goldfish(Aunt) when Aunt#aunt.goldfish < 5 -> 1;
goldfish(_) -> 0.
trees(Aunt) when is_integer(Aunt#aunt.trees), Aunt#aunt.trees > 3 -> 1;
trees(_) -> 0.
cars(Aunt) when Aunt#aunt.cars =:= 2 -> 1;
cars(_) -> 0.
perfumes(Aunt) when Aunt#aunt.perfumes =:= 1 -> 1;
perfumes(_) -> 0.

cmp(Aunt) ->
    children(Aunt) + cats(Aunt) + samoyeds(Aunt) + pomeranians(Aunt) +
    akitas(Aunt) + vizslas(Aunt) + goldfish(Aunt) + trees(Aunt) +
    cars(Aunt) + perfumes(Aunt) > 2.

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
