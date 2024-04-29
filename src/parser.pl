:- module(program, [program/3]).
:- table exp/3, term/3, factor/3,boolean_operator/3.
%:- use_rendering(svgtree).

% Entyy point of the program
program(program(P)) --> command_Statements(P).

% For gathering statemnets in one scope of action
block(block(CommandList)) -->
    ['{'],
    command_Statements(CommandList),
    ['}'].

% List of statements
command_Statements(command(Command, CommandList)) -->
    command(Command),
    command_Statements(CommandList).
command_Statements(command(Command)) -->
    command(Command).

% Commands to be process
command(C) --> print_Statements(C).
command(C) --> value_Assignner(C).
command(C) --> declaration_Assignment_Command(C).
command(C) --> if_Condition(C).
command(C) --> if_Else_Condition(C).
command(C) --> if_Else_IF_Condition(C).
command(C) --> forLoop_Command(C).
command(C) --> whileLoop_Command(C).
command(C) --> compact_Forloop_Command(C).

% condition to check [if] this then this or [else if] this then this or [else] definately this.
if_Else_IF_Condition(if_elseif_condition(Condition, Block1, ElseIfCond, Block2, Block3)) -->
    [if],
    ['('],condition(Condition),[')'], block(Block1),
    [elseif], 
    ['('], condition(ElseIfCond), [')'], block(Block2), 
    [else], block(Block3).

% condition to check [if] this then this or [else] definately this.
if_Else_Condition(if_else_condition(Condition, Block1, Block2)) -->
    [if],
    ['('],
    condition(Condition),
    [')'],
    block(Block1), [else], block(Block2).
   % else_part(ElseTree).

% condition to check [if] this then this.
if_Condition(if_condition(Condition,Block)) -->
     [if],
    ['('],
    condition(Condition),
    [')'],
    block(Block).

print_Statements(print(Value)) --> [print], ['>>'], value(Value), [;].
print_Statements(print(Value)) --> [print], ['>>'], check_Variable_Name(Value), [;].
print_Statements(print(Expression)) --> [print], ['>>'], expression(Expression), [;].


declaration_Assignment_Command(declration_assignment_command(Name,List))--> [list], check_Variable_Name(Name),[=], values(List) ,[;].
declaration_Assignment_Command(declration_assignment_command(Type, Name)) -->
    data_type(Type),
    check_Variable_Name(Name),
    [;].
declaration_Assignment_Command(declration_assignment_command(Type, Name, Expression)) -->
    data_type(Type),
    check_Variable_Name(Name),
    [=],
    expression(Expression),
    [;].

%check if its a list then pass it on to the tree.
values(list(List), [List | T],T):-is_list(List).

value_Assignner(Expression) -->
    assignment_expression(Expression),
    [;].

forLoop_Command(for_loop_command(Assignment, Condition, VariableChangePart, Block)) -->
    [for],
    ['('],
    assignment_expression(Assignment), [;],
    condition(Condition), [;],
    variable_change_part(VariableChangePart),
    [')'],
    block(Block).

variable_change_part(Expression) -->
    increment_exp(Expression) |
    decrement_exp(Expression).
variable_change_part(Expression) -->
    assignment_expression(Expression).

whileLoop_Command(while_command(Condition, Block)) -->
    [while],
    ['('],
    condition(Condition),
    [')'],
    block(Block).

compact_Forloop_Command(compact_ForLoop_command(Variable, Expression1, Expression2, Block)) -->
    [for],
    check_Variable_Name(Variable),
    [in],
    [range],
    ['('],
    expression(Expression1),
    [;],
    expression(Expression2),
    [')'],
    block(Block).

condition(condition(Expression1, Comparison_Operator, Expression2)) -->
    expression(Expression1),
    comparison_operator(Comparison_Operator),
    expression(Expression2).

% EXPRESSIONS (HIGHER THE LEVEL OF EXPRESSION, HIGHER THE PRECEDENCE OF OPERATOR)
expression(expression(Expression)) --> exp(Expression).

exp(+(X, Y)) --> term(X), [+], exp(Y).
exp(-(X, Y)) --> term(X), [-], exp(Y).
exp(X) --> term(X).

term(*(X, Y)) --> factor(X), [*], term(Y).
term(/(X, Y)) --> factor(X), [/], term(Y).

term(boolean(Operator, Y)) --> boolean_operator_not(Operator), expression(Y).
term(boolean(X, Operator, Y)) --> expression(X), boolean_operator(Operator), expression(Y).
term(X) --> factor(X).

factor(X) --> ['('], expression(X), [')'].
factor(X) -->
    ternary_Exp(X) |
    check_Variable_Name(X) |
    value(X).

boolean_operator_not(logical_operation(Operator), [Operator | Tail], Tail) :-
    member(Operator, ['!!']).
boolean_operator(logical_operation(Operator), [Operator | Tail], Tail) :-
    member(Operator,[&&,'||']).
                     
ternary_Exp(ternary_expression(Condition, TrueExpression, FalseExpression)) -->
    ['('],
    condition(Condition),
    ['?'],
    expression(TrueExpression),
    [':'],
    expression(FalseExpression),
    [')'].

assignment_expression(assignment_exp(Name, Expression)) -->
    check_Variable_Name(Name),
    [=],
    expression(Expression).

% NOT TESTED
value(Val) -->check_Int_value(Val).
value(Val) --> check_Float_value(Val).
value(Val) --> check_String_value(Val).
value(Val) --> check_Boolean_value(Val).

decrement_exp(post_decrement(Variable)) --> check_Variable_Name(Variable), [--].
decrement_exp(pre_decrement(Variable)) --> [--], check_Variable_Name(Variable).
increment_exp(post_increment(Variable)) --> check_Variable_Name(Variable), [++].
increment_exp(pre_increment(Variable)) --> [++], check_Variable_Name(Variable).


% checks if the given variable is valid or not ?
check_Variable_Name(variable_name(Variable), [Variable | Tail], Tail) :- valid_variable(Variable).

% Predicate to check if a variable is valid
valid_variable(Variable) :-
    \+ not_keyword(Variable),
    atom_string(Variable, AtomString),
    atom_chars(AtomString, Chars), 
    special_characters(SpecialChars), 
    \+ contains_special(Chars, SpecialChars), 
    \+ starts_with_underscore_or_digit(Chars),!. 
% if it is a keyword then false
not_keyword(Variable) :- (member(Variable, [int, float, bool, string, true, false, for,if, elseif, else, while])),!.
% List of special characters
special_characters(['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '+', '=', '[', ']', '{', '}', ';', ':', '|', ',', '.', '/', '?', '<', '>']).

% Predicate to check if a list of characters contains any special character from the given list
contains_special(Chars, SpecialChars) :-
    member(SpecialChar, SpecialChars),
    member(SpecialChar, Chars),
     !.% Cut to prevent backtracking after displaying "fail", nl. % Display "fail" and newline

starts_with_underscore_or_digit([First|_]) :-
    member(First, ['_','0', '1', '2', '3', '4', '5', '6', '7', '8', '9']),!.


data_type(dataType(Head), [Head | T], T) :-
    member(Head, [int, float, bool, string]).

comparison_operator(comparison_operator(Head), [Head | T], T) :-
    member(Head, [<, >, <=, >=, ==, '!!=']).

check_Int_value(integer(Var), [Var | Tail], Tail) :- integer(Var).
check_Float_value(float(Var), [Var | Tail], Tail) :- float(Var).
check_String_value(string(Var), [Var | Tail], Tail) :- string(Var).
check_Boolean_value(bool(Value), [Value | Tail], Tail) :- member(Value,[true,false]).
