"""
References:
[1] https://www.geeksforgeeks.org/ply-python-lex-yacc-an-introduction/
[2] https://www.dabeaz.com/ply/ply.html#ply_nn0

"""


import ply.lex as lex
import os
import sys
import argparse


class Colors:             # Class to define colors for writing data to a file and defining the file extension.
    GREEN = '\033[92m'
    DEFAULT = '\033[0m'
    BLUE = '\033[34m'
    POODLE_TOKENS_EXTENSION = '.pootokens'


# All the Tokens used in Poodle

tokens = (
    'ASSIGN',
    'DECREMENT',
    'EQUAL',
    'FLOAT',
    'GREATER_EQUAL',
    'GREATER',
    'IDEN',
    'INCREMENT',
    'LESSER_EQUAL',
    'LESSER',
    'MODULO'
    'NUMBER',
    'PLUS',
    'MINUS',
    'MULTIPLY',
    'DIVIDE',
    'LPAREN',
    'RPAREN',
    'NOT_EQUAL',
    'POWER',
    'SINGLE_QUOTES',
    'STRING',
    'LCURL',
    'RCURL',
    'COMMA',
    'QMARK',
    'SEMICOLON',
    'COLON',
    'LSQUARE',
    'RSQUARE',
    'PERIOD',
    'EXCLAMATION',
)

# Regular expression rules for simple tokens

t_PLUS    = r'\+'
t_MINUS   = r'-'
t_MULTIPLY   = r'\*'
t_DIVIDE  = r'/'
t_LPAREN  = r'\('
t_RPAREN  = r'\)'
t_DECREMENT  = r'\++'
t_INCREMENT  = r'\--'
t_FLOAT  = r'\d+\.\d+'
t_GREATER_EQUAL  = r'>='
t_GREATER  = r'>'
t_LESSER_EQUAL  = r'<='
t_LESSER  = r'='
t_MODULO  = r'%'
t_NOT_EQUAL  = r'!='
t_NUMBER  = r'\d+'
t_POWER  = r'\^'
t_SINGLE_QUOTES  = r'\''
t_ASSIGN = r'='
t_STRING = r'\".*\"'

# Regex for Tokens with Action Code

def t_IDEN(x):
    r'[a-zA-Z_][a-zA-Z0-9_]*'
    return x

lits = {'.', '!', ',', '?', ';', ':', '[', ']', '(', ')', '{', '}'}

# Regex for Special Symbols

def t_LCURL(x):
    r'{'
    return x

def t_CURL(x):
    r'}'
    return x

def t_COMMA(x):
    r','
    return x

def t_QMARK(x):
    r'\?'
    return x

def t_SEMICOLON(x):
    r';'
    return x

def t_COLON(x):
    r':'
    return x

def t_LSQUARE(x):
    r'\['
    return x

def t_RSQUARE(x):
    r'\]'
    return x

def t_LPAREN(x):
    r'\('
    return x

def t_RPAREN(x):
    r'\)'
    return x

def t_PERIOD(x):
    r'\.'
    return x

def t_EXCLAMATION(x):
    r'!'
    return x