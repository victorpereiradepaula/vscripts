#! /bin/bash

USER_OPTION=false

if [ ! $SHELL = '/bin/zsh' ]; then
    command chsh -s /bin/zsh
fi

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
    if $USER_OPTION; then
        echo "Instalando Homebrew..."
        command /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

function checkHomebrew {
    echo "Verificando Homebrew..."
    command -v brew >/dev/null 2>&1 || { installHomebrew; }
}

checkHomebrew

# Git
function installGit {
    askToUser "Deseja instalar o Git?"
    if $USER_OPTION; then
        echo "Instalando git..."
        command brew install git
    fi
}

function checkGit {
    echo "Verificando git..."
    command -v git 2>&1 >/dev/null || { checkHomebrew; installGit; }
}

checkGit

# Git global configuration
function configGit {
    askToUser "Deseja configurar o git?"
    if $USER_OPTION; then
        echo "iniciando configurações globais do git..."

        read -a fullName -p "Digite seu nome: "
        git config --global user.name "${fullName[*]}"

        read -p "Digite seu email: " email
        git config --global user.email $email

        git config --global pull.rebase false
        git config --global push.autoSetupRemote true
        git config --global fetch.prune true

        git config --global alias.cleanbranches "!f() { git branch --merged | grep -v \"main\\|master\\|develop\\|*\" | xargs git branch -D; }; f"

        printSuccess "Git global - configurado"
    fi
}

configGit

# Terminal style
function configTerminalStyle {
    askToUser "Deseja configurar o estilo do terminal?"
    if $USER_OPTION; then
        echo "Configurando terminal style..."

        TERMINAL_FILE=~/".zshrc"
        createFileIfNeeded $TERMINAL_FILE

        TERMINAL_STYLE="# VScripts - terminal style"
        VALUE=`grep -c "$TERMINAL_STYLE" $TERMINAL_FILE`

        if [ $VALUE = 0 ]; then
            if [ -w $TERMINAL_FILE ]; then
                echo "" >> $TERMINAL_FILE
                echo "" >> $TERMINAL_FILE
                echo "$TERMINAL_STYLE
function git_branch() {
        git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1] /p'
}

CURRENT_USER_PATH='%F{normal}%n%f'
CURRENT_PATH='%F{cyan}%~%f'
DEFAULT_PROMPT='%F{normal}%#%f'

setopt PROMPT_SUBST
export PROMPT='\${CURRENT_USER_PATH} \${CURRENT_PATH} %F{green}\$(git_branch)\${DEFAULT_PROMPT} '" >> $TERMINAL_FILE
                echo "" >> $TERMINAL_FILE
                echo "" >> $TERMINAL_FILE
            else
                printError "Sem acesso de escrita para adicionar configuração de estilo."
                exit 0
            fi
            printSuccess "$TERMINAL_STYLE - configurado"
        else
            printWarning "$TERMINAL_STYLE - já configurado"
        fi
    fi
}

configTerminalStyle

printSuccess "VSetup executado com sucesso!"

# Apply style configuration
exec zsh