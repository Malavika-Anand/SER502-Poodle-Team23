# Importing necessary modules
import ply.lex as lex
import os
import sys
import argparse

# Class for defining colors for console output
class Colors:
    GREEN = '\033[92m'  # Green color code
    DEFAULT = '\033[0m'  # Default color code
    BLUE = '\033[34m'    # Blue color code
    POODLE_TOKENS_EXTENSION = '.pootokens'  # File extension for tokens

# All the Tokens used in Poodle
tokens = (
    'ASSIGN', 'DECREMENT', 'EQUAL', 'FLOAT', 'GREATER_EQUAL', 'GREATER', 'IDEN', 'INCREMENT',
    'LESSER_EQUAL', 'LESSER', 'MODULO', 'NUMBER', 'PLUS', 'MINUS', 'MULTIPLY', 'DIVIDE', 'LPAREN',
    'RPAREN', 'NOT_EQUAL', 'POWER', 'SINGLE_QUOTES', 'STRING', 'LCURL', 'RCURL', 'COMMA', 'QMARK',
    'SEMICOLON', 'COLON', 'LSQUARE', 'RSQUARE', 'PERIOD', 'EXCLAMATION',
)

# Regular expression rules for simple tokens
t_PLUS = r'\+'           # Plus operator
t_MINUS = r'-'           # Minus operator
t_MULTIPLY = r'\*'       # Multiply operator
t_DIVIDE = r'/'          # Divide operator
t_LPAREN = r'\('         # Left parenthesis
t_RPAREN = r'\)'         # Right parenthesis
t_DECREMENT = r'\--'     # Decrement operator
t_INCREMENT = r'\++'     # Increment operator
t_FLOAT = r'\d+\.\d+'   # Floating point number
t_GREATER_EQUAL = r'>=' # Greater than or equal to
t_GREATER = r'>'        # Greater than
t_LESSER_EQUAL = r'<='  # Lesser than or equal to
t_LESSER = r'<'         # Lesser than
t_MODULO = r'%'         # Modulo operator
t_NOT_EQUAL = r'!!='    # Not equal to
t_NUMBER = r'\d+'       # Integer number
t_POWER = r'\^'         # Power operator
t_SINGLE_QUOTES = r'\'' # Single quotes
t_ASSIGN = r'='         # Assignment operator
t_STRING = r'\".*?\"'   # String enclosed in double quotes

# Regex for Tokens with Action Code
def t_IDEN(t):
    r'[a-zA-Z][a-zA-Z0-9_]*'  # Identifier
    return t

# Regex for Special Symbols
t_LCURL = r'\{'          # Left curly brace
t_RCURL = r'\}'          # Right curly brace
t_COMMA = r','           # Comma
t_QMARK = r'\?'          # Question mark
t_SEMICOLON = r';'       # Semicolon
t_COLON = r':'           # Colon
t_LSQUARE = r'\['        # Left square bracket
t_RSQUARE = r'\]'        # Right square bracket
t_PERIOD = r'\.'         # Period
t_EXCLAMATION = r'!'     # Exclamation mark

# Error handling rule
def t_error(t):
    print(f"Illegal character '{t.value[0]}'")  # Print error message
    t.lexer.skip(1)  # Skip the illegal character

# Build the lexer
lexer = lex.lex()

# Function to parse command line arguments
def parse_args():
    parser = argparse.ArgumentParser(
        description='Poodle Lexer Converts the Source Code into Tokens.')  # Description for argparse
    parser.add_argument('input', metavar='InputFileName', type=str,
                        nargs=1, help='POODLE Source Code Path')  # Input filename argument
    parser.add_argument('--evaluate', action='store_true', help='Analyze the Source Code')  # Optional evaluate flag
    return parser.parse_args()  # Parse arguments and return them

# Function to read input file
def read_input_file(filename):
    data = None
    try:
        with open(filename, "r") as input_file:
            data = input_file.read()  # Read file content
    except FileNotFoundError:
        print("File Does Not Exist: ", sys.argv[1])  # Print error if file not found
    print("Source Code: " + Colors.GREEN + 'Read Successfully' + Colors.DEFAULT)  # Print success message
    return data  # Return file content

# Function to write tokens to file
def write_tokens_to_file(tokens, filename):
    with open(filename, "w") as file:
        for tok in tokens:
            file.write('{}\t'.format(tok.value))  # Write token value to file
        print("Tokens Written in " + filename + ": " + Colors.GREEN +
              'Writing Successful' + Colors.DEFAULT)  # Print success message

# Main function
if __name__ == '__main__':
    print(Colors.BLUE + "Starting POODLE Lexer" + Colors.DEFAULT)  # Print starting message in blue
    parsed_args = parse_args()  # Parse command line arguments
    input_filename = parsed_args.input[0]  # Get input filename from arguments
    output_filename = parsed_args.input[0][:-4] + Colors.POODLE_TOKENS_EXTENSION  # Generate output filename
    file_data = read_input_file(input_filename)  # Read input file

    lexer.input(file_data)  # Input data to lexer
    tokens = list(lexer)  # Get list of tokens
    write_tokens_to_file(tokens, output_filename)  # Write tokens to file

    should_evaluate = parsed_args.evaluate  # Check if evaluate flag is set
    if should_evaluate:
        os.system("swipl -g \"main('" + output_filename + "')\" main.pl")  # Execute evaluation command
