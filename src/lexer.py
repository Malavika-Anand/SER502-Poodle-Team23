import ply.lex as lex
import os
import sys
import argparse

class Colors:
    GREEN = '\033[92m'
    DEFAULT = '\033[0m'
    BLUE = '\033[34m'
    POODLE_TOKENS_EXTENSION = '.pootokens'

# All the Tokens used in Poodle
tokens = (
    'ASSIGN', 'DECREMENT', 'EQUAL', 'FLOAT', 'GREATER_EQUAL', 'GREATER', 'IDEN', 'INCREMENT',
    'LESSER_EQUAL', 'LESSER', 'MODULO', 'NUMBER', 'PLUS', 'MINUS', 'MULTIPLY', 'DIVIDE', 'LPAREN',
    'RPAREN', 'NOT_EQUAL', 'POWER', 'SINGLE_QUOTES', 'STRING', 'LCURL', 'RCURL', 'COMMA', 'QMARK',
    'SEMICOLON', 'COLON', 'LSQUARE', 'RSQUARE', 'PERIOD', 'EXCLAMATION',
)

# Regular expression rules for simple tokens
t_PLUS = r'\+'
t_MINUS = r'-'
t_MULTIPLY = r'\*'
t_DIVIDE = r'/'
t_LPAREN = r'\('
t_RPAREN = r'\)'
t_DECREMENT = r'\--'
t_INCREMENT = r'\++'
t_FLOAT = r'\d+\.\d+'
t_GREATER_EQUAL = r'>='
t_GREATER = r'>'
t_LESSER_EQUAL = r'<='
t_LESSER = r'<'
t_MODULO = r'%'
t_NOT_EQUAL = r'!!='
t_NUMBER = r'\d+'
t_POWER = r'\^'
t_SINGLE_QUOTES = r'\''
t_ASSIGN = r'='
t_STRING = r'\".*?\"'

# Regex for Tokens with Action Code
def t_IDEN(t):
    r'[a-zA-Z][a-zA-Z0-9_]*'
    return t

# Regex for Special Symbols
t_LCURL = r'\{'
t_RCURL = r'\}'
t_COMMA = r','
t_QMARK = r'\?'
t_SEMICOLON = r';'
t_COLON = r':'
t_LSQUARE = r'\['
t_RSQUARE = r'\]'
t_PERIOD = r'\.'
t_EXCLAMATION = r'!'

# Error handling rule
def t_error(t):
    print(f"Illegal character '{t.value[0]}'")
    t.lexer.skip(1)

# Build the lexer
lexer = lex.lex()

def parse_args():
    parser = argparse.ArgumentParser(
        description='Poodle Lexer Converts the Source Code into Tokens.')
    parser.add_argument('input', metavar='InputFileName', type=str,
                        nargs=1, help='POODLE Source Code Path')
    parser.add_argument('--evaluate', action='store_true', help='Analyze the Source Code')
    return parser.parse_args()

def read_input_file(filename):
    data = None
    try:
        with open(filename, "r") as input_file:
            data = input_file.read()
    except FileNotFoundError:
        print("File Does Not Exist: ", sys.argv[1])
    print("Source Code: " + Colors.GREEN + 'Read Successfully' + Colors.DEFAULT)
    return data

def write_tokens_to_file(tokens, filename):
    with open(filename, "w") as file:
        for tok in tokens:
            file.write('{}\t'.format(tok.value))
        print("Tokens Written in " + filename + ": " + Colors.GREEN +
              'Writing Successful' + Colors.DEFAULT)

if __name__ == '__main__':
    print(Colors.BLUE + "Starting POODLE Lexer" + Colors.DEFAULT)
    parsed_args = parse_args()
    input_filename = parsed_args.input[0]
    output_filename = parsed_args.input[0][:-4] + Colors.POODLE_TOKENS_EXTENSION
    file_data = read_input_file(input_filename)

    lexer.input(file_data)
    tokens = list(lexer)
    write_tokens_to_file(tokens, output_filename)

    should_evaluate = parsed_args.evaluate
    if should_evaluate:
        os.system("swipl -g \"main('" + output_filename + "')\" main.pl")
