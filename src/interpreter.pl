eval_program(prgm_node(P), LatestEnv) :- eval_cmd_list(P, [], LatestEnv).
    
eval_block(block_node(CommandList), Env, NewEnv) :- eval_cmd_list(CommandList, Env, NewEnv).

eval_cmd_list(cmd_list_node(Command, Commands), Env, NewEnv) :-
    eval_cmd(Command, Env, E1),
    eval_cmd_list(Commands, E1, NewEnv).

eval_cmd_list(cmd_node(Command), Env, NewEnv) :-
    eval_cmd(Command, Env, NewEnv).

/*eval_cmd(Command, Env, NewEnv) :- declration_assignment_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- print_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- if_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- if_else_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- if_elseif_else_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- forloop_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- whileloop_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- compact_forloop_command(Command,Env,NewEnv).
eval_cmd(Command, Env, NewEnv) :- list_command(Command,Env,NewEnv).*/

/* Eval Condition and Eval Comparisons */

%keeping the Env same throughout the expr evaluation
%brackets (Expression)
eval_expression(expr(E1), Env, Result) :- eval_expression(E1, Env, Result).
eval_expression(add(E1, E2), Env, Result) :- eval_expression(E1, Env, R1), eval_expression(E2, Env, R2), Result is R1+R2.
eval_expression(sub(E1, E2), Env, Result) :- eval_expression(E1, Env, R1), eval_expression(E2, Env, R2), Result is R1-R2.
eval_expression(mul(E1, E2), Env, Result) :- eval_expression(E1, Env, R1), eval_expression(E2, Env, R2), Result is R1*R2.
eval_expression(div(E1,E2), Env, Result) :- eval_expression(E1, Env, Numerator),
    eval_expression(E2, Env, Denominator),  \+ Denominator = 0, Result is Numerator / Denominator.
eval_expression(bool(B),_, B).
eval_expression(int(Value),_, Value).
eval_expression(float(Value),_, Value).
eval_expression(sting(Value),_, Value).
eval_expression(variable_name(Name),Env, Value) :- member((_,Name, Value),Env).

eval_expression(increment(VarName), Env, NewEnv) :- lookup(VarName, Env, Val), 
    													Value is Val+1, update(VarName, Value, Env, NewEnv).
eval_expression(decrement(VarName), Env, NewEnv) :- lookup(VarName, Env, Val), 
    													Value is Val-1, update(VarName, Value, Env, NewEnv).


%eval_expression(variable_name(Name), Env, Name) :- not(lookup(Name, _, Env)), string(Name).
eval_expression(bool_expr(E1, bool_op(Operator), E2), Env, Result) :-
    eval_expression(E1, Env, R1),
    eval_expression(E2, Env, R2),
    eval_bool(R1, Operator, R2, Result).

/*boolean evaluation*/
eval_bool(true, true).
eval_bool(false,true).

%@SHLOKA figure out how to incorporate !(Expression)
eval_bool(bool_not(X), Result) :- eval_bool(X, Result1), not(Result1,Result).

%AND, OR
eval_bool(true, &&, true, true).
eval_bool(true, &&, false, false).
eval_bool(false, &&, true, false).
eval_bool(fale, &&, false, false).
eval_bool(true, '||', true, true).
eval_bool(true, '||', false, true).
eval_bool(false, '||', true, true).
eval_bool(false, '||', false, false).


%comparisons
eval_comparison(Val1, >, Val2, true)  :- Val1 > Val2.
eval_comparison(Val1, >, Val2, false)  :- Val1=< Val2.
eval_comparison(Val1, <, Val2, true)  :- Val1 < Val2.
eval_comparison(Val1, <, Val2, false)  :- Val1 >= Val2.

%negates the bool
not(true, false).
not(false, true).

/*-------------------------ENV = [(DataType, VariableName, Value),(),()...]-----------------------------*/

/*Looks up the value of the provided variable name -> lookup(Var, Env, Value)*/
lookup(VarName,[(_,VarName,Value)|_],Value).
lookup(VarName,[H|Tail],Value) :- H \= (_,VarName,_), lookup(VarName,Tail,Value).
lookup(VarName,[],_Value) :- write(VarName), write(" not found"), fail.

/* Two kinds of update predicates with different parameters for 1. VarName = "dd"; 2. int VarName =1;*/
/* 1. update the Env with variable-value pairs provided -> update(Name, Value, Env, NewEnv) */
update(VarName, Value, [(bool, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- member(Value, [true,false]).
update(VarName, Value, [(int, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- integer(Value).
update(VarName, Value, [(float, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- float(Value).
update(VarName, Value, [(string, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- string(Value).
update(VarName, Value, [H|Tail], [H|UpdatedTail]) :- H \= (_,VarName,_), update(VarName, Value, Tail, UpdatedTail). 

/* 2. update(Type,VarName, Value, Env, NewEnv) */
update(Type,VarName, Value, [], [Type, VarName, Value]).
%should not allow to redine the same var twice, regardless of the type and Env remians the same
update(Type, VarName, Value, [(_, VarName, _)| Tail], [(Type, VarName, Value)| Tail]). %add error @Shloka
update(Type, VarName, Value, [H|Tail], [H|UpdatedTail]) :- H \= (_,VarName,_), update(Type, VarName, Value, Tail, UpdatedTail). 


/*  
    Things left to write: @Shloka
    Ternary operator 
    Error handling
    All commands
*/