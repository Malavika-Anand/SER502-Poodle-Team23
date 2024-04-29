:- module(file_reader, [file_reader/2]).

file_reader(TokenFile, TokenizedData) :-
    open(TokenFile, read, Stream),
    stream_reader(Stream, DataInFile),
    convertedData(DataInFile, TokenizedData), !,
    close(Stream).

% READING CURRENT LINE AND CONVERTING INTO CHARACTERS
stream_reader(Stream, [CurrChar | RemChar]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_codes(Stream, Coder),
    atom_codes(CurrChar, Coder),
    stream_reader(Stream, RemChar), !.

% END OF LINE
stream_reader(Stream, []) :- at_end_of_stream(Stream).

% CONVERTS THE ATOMS TO NUMBERS IF ANY
convertedData([Head|Tail], [Head|RemNum]) :-
    var(Head), % If Head is a variable, leave it unchanged
    convertedData(Tail, RemNum).

convertedData([Head|Tail], [Num|RemNum]) :-
    number(Head), % If Head is already a number, leave it unchanged
    Num = Head,
    convertedData(Tail, RemNum).

convertedData([Head|Tail], [Num|RemNum]) :-
    atom_chars(Head, [First|_]), % Check if Head starts with a capital letter
    char_type(First, upper),
    var(Num), % Ensure Num is a variable
    Num = Head, % Preserve the variable
    convertedData(Tail, RemNum).

convertedData([Head|Tail], [Num|RemNum]) :-
    atom_number(Head, Num), % convertedData Head to a number if it an atom representing a number
    convertedData(Tail, RemNum).

convertedData([Head|Tail], [Term|RemNum]) :-
    atom(Head), % If Head is an atom, convertedData it to a term
    term_to_atom(Term, Head),
    convertedData(Tail, RemNum).

convertedData([], []).
