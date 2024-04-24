:- module(custom_file_reader, [read_custom_file/2]).

% read_custom_file/2 reads a file and converts its contents into a list of atoms.
% It takes the file name as input and returns the converted data.
read_custom_file(FileName, ConvertedData) :-
    % Open the file in read mode
    open_custom_file(FileName, Stream),
    % Read lines from the stream and convert them to a list of atoms
    read_custom_lines(Stream, FileData),
    % Close the stream
    close(Stream),
    % Convert atoms to numbers if possible
    convert_atoms_custom(FileData, ConvertedData).

% open_custom_file/2 opens a file and creates a stream.
open_custom_file(FileName, Stream) :-
    open(FileName, read, Stream).

% read_custom_lines/2 reads lines from the stream and converts them to a list of atoms.
read_custom_lines(Stream, [CurrentLineChars | RestChars]) :-
    % Check if not at the end of the stream
    \+ at_end_of_custom_stream(Stream),
    % Read a line from the stream and convert it to an atom
    read_line_to_codes(Stream, LineCodes),
    atom_codes(CurrentLineChars, LineCodes),
    % Recursively read the next line
    read_custom_lines(Stream, RestChars),
    !.

read_custom_lines(_, []). % Base case: end of stream

% at_end_of_custom_stream/1 checks if the stream is at the end.
at_end_of_custom_stream(Stream) :-
    at_end_of_stream(Stream).

% convert_atoms_custom/2 converts atom elements to numbers if possible.
convert_atoms_custom([Atom | RestAtoms], [Number | RestNumbers]) :-
    % Convert atom to number if possible
    atom_to_number_custom(Atom, Number),
    % Recursively convert the rest of the atoms
    convert_atoms_custom(RestAtoms, RestNumbers).
convert_atoms_custom([Atom | RestAtoms], [Atom | RestConverted]) :-
    % Leave the atom unchanged if it cannot be converted to a number
    convert_atoms_custom(RestAtoms, RestConverted).
convert_atoms_custom([], []). % Base case: empty list

% atom_to_number_custom/2 converts an atom to a number if possible.
atom_to_number_custom(Atom, Number) :-
    atom_number(Atom, Number),
    !. % Cut to prevent backtracking
atom_to_number_custom(Atom, Atom). % Leave the atom unchanged if it cannot be converted
