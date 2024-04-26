:- use_module(tokenReader).
:- use_module(parser).
:- use_module(interpreter).

main_prog(NameOfFile) :- 
    write("Parser Status: "), ansi_format([bold, fg(Blue)], 'Started', []), nl,
    read_file(NameOfFile, DataInFile),
    write(DataInFile), nl,
    program(Tree, DataInFile, []),
    write("Parse Tree Generation: "), ansi_format([bold, fg(Blue)], 'Done', []), nl,
    write(Tree), nl,
    write("Evaluator Status: "), ansi_format([bold, fg(Blue)], 'Started', []), nl,
    eval_program(Tree, UpdatedEnv), nl,
    write("Evaluator: "), ansi_format([bold, fg(Blue)], 'Successful', []), nl,
    write(UpdatedEnv), nl,
    halt.
