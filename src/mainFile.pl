:- use_module(tokenReader).
:- use_module(parser).
:- use_module(interpreter).
:- use_module(library(ansi_term)).

main_prog(NameOfFile) :- 
    write("Reading Token File: "), nl,
    file_reader(NameOfFile, DataInFile),
    write("Contents of Token File: "), nl,
    write(DataInFile), nl,
    write("Parser Status: Started"), nl,   
    program(Tree, DataInFile, []),
    write("Parse Tree Generation: Generating"), nl,
    write("Parse Tree: "), nl, write(Tree), nl,
    write("Interpreter Status: Started"), nl,
    eval_program(Tree, UpdatedEnv), nl,
    write("Interpreter: Completed"), nl,
    write("Updated Environment: Updated"), nl, write(UpdatedEnv), nl.