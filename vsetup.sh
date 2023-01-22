#! /bin/bash

# Utils
function printError {
	printf "\033[0;31m$1\033[0m\n"
}

function printSuccess {
	printf "\033[0;32m$1\033[0m\n"
}

function printWarning {
	printf "\033[0;33m$1\033[0m\n"
}

function createFileIfNeeded {
    if [ ! -f  "$1" ];then
        printWarning "$1 não encontrado"
        printf "Criando $1 ...\n"
        sudo touch $1
    fi
}

# Terminal style
TERMINAL_FILE=~/".zshrc"
createFileIfNeeded $TERMINAL_FILE

TERMINAL_STYLE="# VScripts - terminal style"
VALUE=`grep -c "$TERMINAL_STYLE" $TERMINAL_FILE`

if [ $VALUE = 0 ]; then
    echo "" >> $TERMINAL_FILE
    echo $TERMINAL_STYLE >> $TERMINAL_FILE
    echo "function git_branch() {" >> $TERMINAL_FILE
    echo "  git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1] /p'" >> $TERMINAL_FILE
    echo "}" >> $TERMINAL_FILE
    echo "" >> $TERMINAL_FILE
    echo "USER='%F{normal}%n%f'" >> $TERMINAL_FILE
    echo "CURRENT_PATH='%F{cyan}%~%f'" >> $TERMINAL_FILE
    echo "DEFAULT_PROMPT='%F{normal}%#%f'" >> $TERMINAL_FILE
    echo "" >> $TERMINAL_FILE
    echo "setopt PROMPT_SUBST" >> $TERMINAL_FILE
    echo "export PROMPT='\${USER} \${CURRENT_PATH} %F{green}\$(git_branch)\${DEFAULT_PROMPT} '" >> $TERMINAL_FILE
    
    printSuccess "$TERMINAL_STYLE - configurado"
else
    printWarning "$TERMINAL_STYLE - já configurado"
fi

printSuccess "VSetup executado com sucesso!"