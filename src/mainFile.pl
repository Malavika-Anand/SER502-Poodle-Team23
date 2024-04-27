:- use_module(tokenReader).
:- use_module(parser).
:- use_module(interpreter).
:- use_module(library(ansi_term)).

main_prog(NameOfFile) :- 
    write("Parser Status: "), ansi_format([bold, fg(blue)], 'Started', []), nl,   
    read_file(NameOfFile, DataInFile),
    write(DataInFile),nl,
    program(Tree, DataInFile, []),
    write("Parse Tree Generation: "), ansi_format([bold, fg(blue)], 'Done', []), nl,
    write("Parse Tree: "), nl, write(Tree), nl,
    write("Interpreter Status: "), ansi_format([bold, fg(blue)], 'Started', []), nl,
    eval_program(Tree, UpdatedEnv), nl,
    write("Interpreter: "), ansi_format([bold, fg(blue)], 'Successful', []), nl,
    write("Updated Environment: "), nl, write(UpdatedEnv), nl.
