:- module(read_file, [read_file/2]).

read_file(FileName, ConvertedData) :-
    open(FileName, read, Stream),
    read_stream(Stream, FileData),
    convert(FileData, ConvertedData), !,
    close(Stream).

% READING CURRENT LINE AND CONVERTING INTO CHARACTERS
read_stream(Stream, [CurrentLineCharacters | List]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_codes(Stream, Codes),
    atom_codes(CurrentLineCharacters, Codes),
    read_stream(Stream, List), !.

% END OF LINE
read_stream(Stream, []) :- at_end_of_stream(Stream).

% CONVERTS THE ATOMS TO NUMBERS IF ANY
convert([H|T], [H|R]) :-
    var(H), % If H is a variable, leave it unchanged
    convert(T, R).

convert([H|T], [N|R]) :-
    number(H), % If H is already a number, leave it unchanged
    N = H,
    convert(T, R).

convert([H|T], [N|R]) :-
    atom_chars(H, [First|_]), % Check if H starts with a capital letter
    char_type(First, upper),
    var(N), % Ensure N is a variable
    N = H, % Preserve the variable
    convert(T, R).

convert([H|T], [N|R]) :-
    atom_number(H, N), % Convert H to a number if it an atom representing a number
    convert(T, R).

convert([H|T], [Term|R]) :-
    atom(H), % If H is an atom, convert it to a term
    term_to_atom(Term, H),
    convert(T, R).

convert([], []).