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
    if [ ! -f  "$1" ]; then
        printWarning "$1 não encontrado"
        echo "Criando $1 ..."
        touch $1 >/dev/null 2>&1 || { printError >&2 "Falha ao criar o arquivo $1."; exit 1; }
    fi
}

# USER_OPTION=false
function askToUser {
    echo "$1 [s/n]"
    USER_OPTION=false
    read readedUserOption
    for positiveOption in "Y" "Yes" "y" "yes" "S" "Sim" "s" "sim"; do
        if [ $positiveOption = $readedUserOption ]; then
            USER_OPTION=true
            break
        fi
    done
}

# Homebrew
function installHomebrew {
    printWarning "Homebrew não instalado."
    askToUser "Deseja instalar o Homebrew?"
    if [ $USER_OPTION ]; then
        echo "Instalando Homebrew..."
        command /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

function checkHomebrew {
    command -v brew >/dev/null 2>&1 || { installHomebrew; }
}

echo "Verificando Homebrew..."
checkHomebrew

# Git
function installGit {
    askToUser "Deseja instalar o Git?"
    if [ $USER_OPTION ]; then
        echo "Instalando git..."
        command brew install git
    fi
}

function checkGit {
    command -v git 2>&1 >/dev/null || { checkHomebrew; installGit; }
}

echo "Verificando git..."
checkGit

# Git config
echo "Configurando git config..."

command git config --global push.autoSetupRemote true

printSuccess "Git config configurado"

# Terminal style
echo "Configurando terminal style..."

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
export PROMPT='\${USER} \${CURRENT_PATH} %F{green}\$(git_branch)\${DEFAULT_PROMPT} '\n" >> $TERMINAL_FILE
    
    printSuccess "$TERMINAL_STYLE - configurado"
else
    printWarning "$TERMINAL_STYLE - já configurado"
fi

printSuccess "VSetup executado com sucesso!"

# Apply style configuration
exec zsh