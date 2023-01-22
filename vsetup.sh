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
        sudo touch $1 >/dev/null 2>&1 || { printError >&2 "Falha ao criar o arquivo $1."; exit 1; }
    fi
}

# Terminal style
TERMINAL_FILE=~/".zshrc"
createFileIfNeeded $TERMINAL_FILE

TERMINAL_STYLE="# VScripts - terminal style"
VALUE=`grep -c "$TERMINAL_STYLE" $TERMINAL_FILE`

if [ $VALUE = 0 ]; then
    echo -e "\n$TERMINAL_STYLE
function git_branch() {
        git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1] /p'
}

USER='%F{normal}%n%f'
CURRENT_PATH='%F{cyan}%~%f'
DEFAULT_PROMPT='%F{normal}%#%f'

setopt PROMPT_SUBST
export PROMPT='\${USER} \${CURRENT_PATH} %F{green}\$(git_branch)\${DEFAULT_PROMPT} '" >> $TERMINAL_FILE
    
    printSuccess "$TERMINAL_STYLE - configurado"
else
    printWarning "$TERMINAL_STYLE - já configurado"
fi

printSuccess "VSetup executado com sucesso!"