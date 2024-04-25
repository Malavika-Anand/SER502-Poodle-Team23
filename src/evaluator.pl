:- module(eval_program, [eval_program/2]).
%INTERPRETOR

eval_program(program(P), LatestEnv) :- eval_cmd_list(P, [], LatestEnv).
    
eval_block(block(CommandList), Env, NewEnv) :- eval_cmd_list(CommandList, Env, NewEnv).

eval_cmd_list(command(Command, Commands), Env, NewEnv) :-
    eval_cmd(Command, Env, E1),
    eval_cmd_list(Commands, E1, NewEnv).

eval_cmd_list(command(Command), Env, NewEnv) :-
    eval_cmd(Command, Env, NewEnv).

/* 
 * DECLARATION AND ASSIGNMENT COMMAND
 */
% a=5;
eval_cmd(assignment_exp(variable_name(VarName), E1),Env, NewEnv) :- 
                                    eval_expression(E1, Env, R1), 
                                    update(VarName, R1, Env, NewEnv).
%int a=5;
eval_cmd(declration_assignment_command(dataType(Type),variable_name(VarName), E1), Env, NewEnv) :- 
                                    eval_expression(E1, Env, R1), 
                                    update(Type, VarName, R1, Env, NewEnv).
%when declaration setting up default value which is empty @Shloka
%int a;
eval_cmd(declration_assignment_command(dataType(Type), variable_name(Name)), Env, NewEnv) :- get_default_value(Type, Env, Value), update(Type, Name, Value, Env, NewEnv).    								


/* 
 * PRINT COMMAND - eval_cmd(print(Expression), Env, Env)
 */ 
eval_cmd(print(Expression), Env, Env) :- eval_expression(Expression, Env, Result), write(Result), nl.

/* 
 * IF COMMAND - eval_cmd(if(cond,block), Env, NewEnv)
 */ 
eval_cmd(if_condition(Condition,Block), Env, NewEnv) :- eval_condition(Condition,Env,true), 
    								eval_block(Block, Env, NewEnv).
eval_cmd(if_condition(Condition,_Block), Env, Env) :- eval_condition(Condition,Env,false).

/* 
 * IF ELSE COMMAND - eval_cmd(if_else(cond,block1,block2), Env, NewEnv)
 */ 

eval_cmd(if_else_condition(Condition,Block1,_Block2), Env, NewEnv) :- eval_condition(Condition,Env,true),
    								eval_block(Block1, Env, NewEnv).
eval_cmd(if_else_condition(Condition,_Block1,Block2), Env, NewEnv) :- eval_condition(Condition,Env,false),
    								eval_block(Block2, Env, NewEnv).

/* 
 * IF ELSEIF ELSE COMMAND - eval_cmd(if_elseif_else(cond,block1,block2), Env, NewEnv)
 */ 

eval_cmd(if_elseif_condition(Condition, Block1,_ElIfCondition, _Block2, _Block3), Env, NewEnv) :- 
    						eval_condition(Condition,Env,true),
    						eval_block(Block1, Env, NewEnv).

eval_cmd(if_elseif_condition(Condition,_Block1, ElIfCondition, Block2,_Block3), Env, NewEnv) :-
    							eval_condition(Condition,Env,false),
    							eval_condition(ElIfCondition,Env,true), 
    							eval_block(Block2, Env, NewEnv).
    

eval_cmd(if_elseif_condition(Condition,_Block1, ElIfCondition, _Block2, Block3), Env, NewEnv) :-
    							eval_condition(Condition,Env,false),
    							eval_condition(ElIfCondition, Env,false),
    							eval_block(Block3,Env, NewEnv).


/*
 * WHILE COMMAND
 */
eval_cmd(while_command(Condition,_C), Env, Env) :- eval_condition(Condition,Env,false).
eval_cmd(while_command(Condition,Block), Env, NewEnv) :- eval_condition(Condition,Env,true),
    						eval_block(Block, Env, Env1),
    						eval_cmd(while(Condition,Block), Env1, NewEnv).


/*
 * FOR COMMAND
 */
eval_cmd(for_loop_command(_, Condition, _, _Block), Env, Env) :-
    eval_condition(Condition, Env, false).

eval_cmd(for_loop_command(Assignment, Condition, VariableIncDecExpr, Block), Env, NewEnv) :-
    eval_cmd(Assignment, Env, Env1),
    eval_condition(Condition, Env1, true),
    eval_block(Block, Env1, Env2),
    eval_inc_dec_expression(VariableIncDecExpr,Env2, Env3),
    %i created this eval because I cannot use the eval cmd as it will again eval assignment cmd
    eval_for_loop(Condition, VariableIncDecExpr, Block, Env3, NewEnv).

/*
 * COMPACT FORLOOP
 */

eval_cmd(compact_ForLoop_command(VarName, E1, E2, Block), Env, NewEnv) :- 
    eval_cmd(assignment(variable_name(VarName), E1), Env, Env1),
   	eval_condition(condition(E1, t_comparison_operator(>), E2), Env1, false),
    eval_for_loop(condition(VarName, <=, E2), pre_increment(VarName), Block, Env1, NewEnv).

eval_cmd(compact_ForLoop_command(VarName, E1, E2, Block), Env, NewEnv) :- 
    eval_cmd(assignment(variable_name(VarName), E1), Env, Env1),
   	eval_condition(condition(E1, t_comparison_operator(<), E2), Env1, false),
    eval_for_loop(condition(VarName, >=, E2), pre_decrement(VarName), Block, Env1, NewEnv).

/* LIST COMMAND */
/*eval_cmd(list(VarName, Values), Env, NewEnv) :-
    eval_values(Values, Env, List), 
    udpate(VarName, List, Env, NewEnv).

% Evaluate a list of values
eval_values([Value], Env, [EvalValue]) :-
    eval_expression(Value, Env, EvalValue). % Evaluate the single value

eval_values([Value|Tail], Env, [EvalValue|EvalRest]) :-
    eval_expression(Value, Env, EvalValue), % Evaluate the first value
    eval_values(Tail, Env, EvalRest). % Evaluate the rest of the values recursively

eval_values([], Env, []).*/

/* 
 * HELPER PREDICATES 
 */

eval_for_loop(Condition, VariableIncDecExpr, Block, Env, NewEnv) :-
     eval_condition(Condition, Env, true),
     eval_block(Block, Env, Env1),
	 eval_inc_dec_expression(VariableIncDecExpr,Env1, Env2),
	 eval_for_loop(Condition, VariableIncDecExpr, Block, Env2, NewEnv).

eval_for_loop(Condition, _VariableIncDec, _Block, Env, Env) :-
     eval_condition(Condition, Env, false).

eval_inc_dec_expression(pre_increment(variable_name(VarName)), Env, NewEnv) :- 
	eval_expression(increment(variable_name(VarName)), Env, NewEnv).

eval_inc_dec_expression(post_decrement(variable_name(VarName)), Env, NewEnv) :- 
	eval_expression(increment(variable_name(VarName)), Env, NewEnv).

eval_inc_dec_expression(pre_decrement(variable_name(VarName)), Env, NewEnv) :- 
	eval_expression(decrement(variable_name(VarName)), Env, NewEnv).

eval_inc_dec_expression(post_decrement(variable_name(VarName)), Env, NewEnv) :- 
	eval_expression(decrement(variable_name(VarName)), Env, NewEnv).		


/*
eval_cmd(Command, Env, NewEnv) :- list_command(Command,Env,NewEnv).
*/

/* 
 * Condition & Comparisons Evaluation
 */
eval_condition(condition(E1, Operator, E2), Env, Result) :-
    eval_expression(E1, Env, R1),
    eval_expression(E2, Env, R2),
    get_comparison_operator(Operator, Op),
    eval_comparison(R1, Op, R2, Result).

get_comparison_operator(comparison_operator(Operator), Operator).


%keeping the Env same throughout the expr evaluation
%brackets (Expression)
eval_expression(expression(E1), Env, Result) :- eval_expression(E1, Env, Result).
eval_expression(+(E1, E2), Env, Result) :- eval_expression(E1, Env, R1), eval_expression(E2, Env, R2), Result is R1+R2.
eval_expression(-(E1, E2), Env, Result) :- eval_expression(E1, Env, R1), eval_expression(E2, Env, R2), Result is R1-R2.
eval_expression(*(E1, E2), Env, Result) :- eval_expression(E1, Env, R1), eval_expression(E2, Env, R2), Result is R1*R2.
eval_expression(/(E1,E2), Env, Result) :- eval_expression(E1, Env, Numerator),
    eval_expression(E2, Env, Denominator),  \+ Denominator = 0, Result is Numerator / Denominator.
eval_expression(bool(B),_, B).
eval_expression(integer(Value),_, Value).
eval_expression(float(Value),_, Value).
eval_expression(string(Value),_, Value).
eval_expression(variable_name(VarName),Env, Value) :- member((_, VarName, Value),Env).
eval_expression(variable_name(VarName),Env, Value) :- \+ member((_, VarName, Value),Env), write("Ferf"), fail.


eval_expression(increment(variable_name(VarName)), Env, NewEnv) :- lookup(VarName, Env, Val), 
    								Value is Val+1, 
    								update(VarName, Value, Env, NewEnv).
eval_expression(decrement(variable_name(VarName)), Env, NewEnv) :- lookup(VarName, Env, Val), 
    								Value is Val-1, 
    								update(VarName, Value, Env, NewEnv).


%eval_expression(variable_name(Name), Env, Name) :- not(lookup(Name, _, Env)), string(Name).
%NOT - !!
eval_expression(boolean(logical_operator(Operator), E1), Env, Result) :-
    Operator = '!!',
    eval_expression(E1, Env, R1),
    not(R1, Result).

% AND - && , OR - ||
eval_expression(boolean(E1, logical_operator(Operator), E2), Env, Result) :-
    eval_expression(E1, Env, R1),
    eval_expression(E2, Env, R2),
    eval_bool(R1, Operator, R2, Result).

%ternary expression
eval_expression(ternary_expression(Condition, E1, _), Env, Result) :-
    eval_condition(Condition, Env, true),
    eval_expression(E1, Env, Result).

eval_expression(ternary_expression(Condition, _, E2), Env, Result) :-
    eval_condition(Condition, Env, false),
    eval_expression(E2, Env, Result).


/*boolean evaluation*/
%eval_bool(true, true).
%eval_bool(false,true).

%AND,OR
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
eval_comparison(Val1, >, Val2, false)  :- Val1 =< Val2.
eval_comparison(Val1, <, Val2, true)  :- Val1 < Val2.
eval_comparison(Val1, <, Val2, false)  :- Val1 >= Val2.
eval_comparison(Val1, >=, Val2, true)  :- Val1 >= Val2.
eval_comparison(Val1, >=, Val2, false)  :- Val1 < Val2.
eval_comparison(Val1, <=, Val2, true)  :- Val1 =< Val2.
eval_comparison(Val1, <=, Val2, false)  :- Val1 > Val2.
eval_comparison(Val1, ==, Val2, true)  :- Val1 =:= Val2.
eval_comparison(Val1, ==, Val2, false)  :- Val1 =\= Val2.
eval_comparison(Val1, "!!=", Val2, true)  :- Val1 =\= Val2.
eval_comparison(Val1, "!!=", Val2, false)  :- Val1 =:= Val2.

get_default_value(Type, _Env, Value) :- Type = int, Value is 0.
get_default_value(Type, _Env, Value) :- Type = float, Value is 0.0.
get_default_value(Type, _Env, Value) :- Type = string, Value = "".
get_default_value(Type, _Env, Value) :- Type = bool, Value=false.

%negates the bool
not(true, false).
not(false, true).

/*-------------------------ENV = [(DataType, VariableName, Value),(),()...]-----------------------------*/

/*Looks up the value of the provided variable name -> lookup(Var, Env, Value)*/
lookup(VarName,[(_,VarName,Value)|_],Value).
lookup(VarName,[H|Tail],Value) :- H \= (_ ,VarName,_), lookup(VarName,Tail,Value).
lookup(VarName,[],_Value) :- write(VarName), write(" not found"), fail.

/* Two kinds of update predicates with different parameters for 1. VarName = "dd"; 2. int VarName =1;*/
/* 1. update the Env with variable-value pairs provided -> update(Name, Value, Env, NewEnv) */
update(VarName,_Value,[],[]):-  write("the env is empty, cannot update "), write(VarName), fail.
update(VarName, Value, [(bool, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- member(Value, [true,false]).
%update(VarName, Value, [(int , VarName, _) | _], []):- integer(Value).
update(Name, Value, [(int , Name, _) | Env], [(int, Name, Value) | Env]) :- 
    integer(Value).
update(VarName, Value, [(float, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- float(Value).
update(VarName, Value, [(string, VarName,_)|Tail], [(int, VarName, Value)|Tail]) :- string(Value).
update(VarName, Value, [H|Tail], [H|UpdatedTail]) :- H \= (_ ,VarName, _), update(VarName, Value, Tail, UpdatedTail). 

update(VarName, Value, [(int , VarName, _) | _], _)  :- not(integer(Value)), write("cannot assign other datatype to int varaible"), fail.
update(VarName, Value, [(float, VarName, _) | _], _)  :- not(float(Value)),  write("cannot assign other datatype to float varaible"),fail.
update(VarName, Value, [(bool , VarName, _) | _], _)  :- not(member(Value, [true, false])), write("cannot assign other datatype to bool varaible"),fail.
update(VarName, Value, [(string, VarName, _) | _], _) :- not(string(Value)) , write("cannot assign other datatype to string varaible"),fail.

/* 2. update(Type,VarName, Value, Env, NewEnv) */
update(Type, VarName, Value, [], [(Type, VarName, Value)]) :- Type=int,integer(Value).
update(Type, VarName, Value, [], [(Type, VarName, Value)]):- Type=float,float(Value).
update(Type, VarName, Value, [], [(Type, VarName, Value)]):- Type=bool,member(Value, [true, false]).
update(Type, VarName, Value, [], [(Type, VarName, Value)]):- Type=string,string(Value).

update(Type,_VarName, Value, [], _)  :- Type=int, not(integer(Value)), write("cannot assign other datatype to int varaible"), fail.
update(Type,_VarName, Value, [], _)  :- Type=float,not(float(Value)),  write("cannot assign other datatype to float varaible"),fail.
update(Type,_VarName, Value, [], _)  :- Type=bool,not(member(Value, [true, false])), write("cannot assign other datatype to bool varaible"),fail.
update(Type,_VarName, Value, [], _) :- Type=string,not(string(Value)) , write("cannot assign other datatype to string varaible"),fail.

%should not allow to redine the same var twice, regardless of the type and Env remians the same
update(Type, VarName, Value, [(Type, VarName, _)| Tail], [(Type, VarName, Value)| Tail]) :- write("cannot redefine variable"),fail.
update(Type, VarName, Value, [H|Tail], [H|UpdatedTail]) :- H \= (_ ,VarName, _), update(Type, VarName, Value, Tail, UpdatedTail).
