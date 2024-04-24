:- module(file_reader, [read_file/2]).

% Predicate for reading a file and converting its contents
read_file(FileName, ConvertedData) :-
    % Open the file and read its contents
    open_file(FileName, Stream),
    read_lines(Stream, FileLines),
    close_file(Stream),
    % Convert atom elements to numbers if possible
    convert_atoms_to_numbers(FileLines, ConvertedData).

% Open the file and create a stream
open_file(FileName, Stream) :-
    open(FileName, read, Stream).

% Read lines from the stream and convert them to atoms
read_lines(Stream, [Line | RestLines]) :-
    % Read a line from the stream and convert it to an atom
    read_line(Stream, Line),
    % Recursively read the next line
    read_lines(Stream, RestLines).
read_lines(_, []). % Base case: end of stream

% Read a line from the stream and convert it to an atom
read_line(Stream, Atom) :-
    \+ at_end_of_stream(Stream), % Check if not at the end of the stream
    read_line_to_codes(Stream, Codes), % Read line as a list of character codes
    atom_codes(Atom, Codes), % Convert the codes to an atom
    !. % Cut to prevent backtracking
read_line(_, []). % Base case: end of stream

% Convert atom elements to numbers if possible
convert_atoms_to_numbers([Atom | RestAtoms], [Number | RestNumbers]) :-
    % Convert atom to number if possible
    atom_to_number_if_possible(Atom, Number),
    % Recursively convert the rest of the atoms
    convert_atoms_to_numbers(RestAtoms, RestNumbers).
convert_atoms_to_numbers([Atom | RestAtoms], [Atom | RestConverted]) :-
    % Leave the atom unchanged if it cannot be converted to a number
    convert_atoms_to_numbers(RestAtoms, RestConverted).
convert_atoms_to_numbers([], []). % Base case: empty list

% Convert atom to number if possible
atom_to_number_if_possible(Atom, Number) :-
    atom_number(Atom, Number), % Convert atom to number if possible
    !. % Cut to prevent backtracking
atom_to_number_if_possible(Atom, Atom). % Leave the atom unchanged if it cannot be converted
