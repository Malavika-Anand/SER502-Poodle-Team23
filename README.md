# SER502-Poodle-Team23

#POODLE PROGRAMMING LANGUAGE

#INSTALLATION
Requires SWI-Prolog to be installed on the computer

#Installing PLY
python3 -m pip install ply

Steps to Run:
1. Run this command on command line inside your src folder where the testprog.poo file is located-> python3 Lexer.py testprog.poo
2. The above command will succssfully generate a testprog.pootokens file in the same src directory.
3. Open Swipl command line and change the directory to src
4. Load/consult the mainFile.pl
5. Run main_prog('testprog.pootokens')


#MAKING OF .poo files using VIM

1. Open command line and open file via this command vim ~/.vimrc
2. add this code to the above file -
augroup imp_ft
au!
autocmd BufNewFile,BufRead *.imp  set filetype=imp
augroup END
3. Add the below code to this file ~/.vim/ftplugin/imp.vim:
 nnoremap <F10> :w<CR>:!python Lexer.py --evaluate %<CR>
4. Go to src directory and create a new file by: touch newfile.poo
5. Edit file by this command: vim newfile.poo
6. save the code and follow the steps mentioned in the start of the document.


#CONTRIBUTORS
1. Shloka Manish Pandya
2. Malavika Anand
3. Vipsa Kamani

#Acknowledgments
Dr. Ajay Bansal
James Smith

#Youtube Video Link

 

