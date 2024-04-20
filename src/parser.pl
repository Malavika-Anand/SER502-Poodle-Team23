% start point
program(t_program(P)) --> command_list(P); block(P).

block(t_block(CommandList)) -->['{'], command_list(CommandList), ['}'].

% command list and commands
command_list(t_command_list(Command, CommandList)) -->command(Command),command_list(CommandList).
command_list(t_command(Command)) --> command(Command).

command(C) --> declration_assignment_command(C).

% declaration statements.
declration_assignment_command(t_declaration(Type, Name)) --> data_type(Type),variable_name(Name),[;].

declration_assignment_command(t_declaration(Name,Number)) --> variable_name(Name),[=],value(Number),[;].

declration_assignment_command(t_declaration(Type,Name,Number)) --> data_type(Type),variable_name(Name),[=], value(Number),[;].


% check the data type.
data_type(t_datatype(Head), [Head | T], T):- member(Head, [int, float, bool, string]).

% checks if the given variable is valid or not ?
variable_name(t_variable_name(Variable), [Variable | Tail], Tail) :- valid_variable(Variable).

% Predicate to check if a variable is valid
valid_variable(Variable) :-
    \+ not_keyword(Variable),
    atom_string(Variable, AtomString), % Convert to atom if its a string
    atom_chars(AtomString, Chars), % Split the variable into a list of characters
    special_characters(SpecialChars), % Get the list of special characters
    \+ contains_special(Chars, SpecialChars), % Check if the variable contains any special character
    \+ starts_with_underscore_or_digit(Chars),!. 
% if it is a keyword then false
not_keyword(Variable) :- (member(Variable, [int, float, bool, string, true, false, for,if, elseif, else, while])), write("variable is a keyword"),!.

% List of special characters
special_characters(['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '+', '=', '[', ']', '{', '}', ';', ':', '|', ',', '.', '/', '?', '<', '>']).

% Predicate to check if a list of characters contains any special character from the given list
contains_special(Chars, SpecialChars) :-
    member(SpecialChar, SpecialChars),
    member(SpecialChar, Chars),
     !,% Cut to prevent backtracking after displaying "fail"
    write('It contains special character so operation failed'), nl. % Display "fail" and newline

starts_with_underscore_or_digit([First|_]) :-
    member(First, ['_','0', '1', '2', '3', '4', '5', '6', '7', '8', '9']),!,write("first letter is _ or digit thats invalid"), nl.

% check if the values are align with the variable type .
value(Variable) -->
    integer_value(Variable) |
    float_value(Variable) |
    string_value(Variable) |
    boolean_value(Variable).

integer_value(t_integer(Variable), [Variable | Tail], Tail) :- integer(Variable).%  build Predicate to check if a variable is an integer
float_value(t_float(Variable), [Variable | Tail], Tail) :- float(Variable). % build in Predicate to check if a variable is a float
string_value(t_string(Variable), [Variable | Tail], Tail) :- string(Variable).%build in Predicate to check if a variable is a string
boolean_value(t_boolean(Value), [Value | Tail], Tail) :- member(Value, [true, false]).


