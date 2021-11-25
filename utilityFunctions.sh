#! /bin/bash

# INCLUDE
includeLocalFile(){
	DIR="${BASH_SOURCE%/*}"
	if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

	. "$DIR/$@" --source-only
}

ifNotRootExit() {
	[ $EUID != 0 ] && echo "ERROR: You have to be root to execute this script" && exit 1
}

ecolor(){
    color="$1"
	shift
	string="$@"
	
	blue='\e[34m'
	yellow='\e[1;33m'	
	green='\e[32m'
	red='\e[1;31m'
	clear='\e[0m'

	case $color in
		green) echo -ne $green$string$clear ; echo "" ;;
		blue) echo -ne $blue$string$clear ; echo "" ;;
		red) echo -ne $red$string$clear ; echo "" ;;
		yellow) echo -ne $yellow$string$clear ; echo "" ;;
		*) echo -ne $color $string; echo "" ;;
	esac
}

inputPromptOrDefault() { # usage: inputPromptOrDefault "prompt" "default"
	#~ prompt="$1"
	prompt="${1:-Inserisci un input}"	
	default="${2:-false}" # o 1? ...dovrebbe invalidare il prompt per default
	
	result=$(read -p "${prompt} [default: ${default}]: " response; echo $response)	
	result=${result:-$default}
	echo $result
	
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]|[sS])
            true
            ;;
        *)
            false
            ;;
    esac
}

section() {
	name="$@"
	echo
	echo "##### ${name}..."
	confirm
}
goOn() {
	if [ "$1" == '-s' ]; then
		read -p ""
	else
		echo ""
		read -p "${@:-### press ENTER to continue... }"
		echo ""
	fi
	
}

prova(){
	comando="$1"
	shift
	parametri="$@"
	section "Sto per eseguire il comando \"${comando}\" con parametri \"${parametri}\"" && "${comando}" "${parametri}" && echo "..." && read -p "### press ENTER to continue... "	
}

workInTmp(){
	initialDir=$(pwd)
	tmpWd=$(mktemp tmp.XXXXXXXXXX -dt)
	cd $tmpWd
	echo "Cartella di lavoro temporanea: $(ecolor blue $tmpWd) [reale: $(ecolor blue $(pwd))])"
	"${@}"
	cd $initialDir
	echo "Cartella attuale: $(ecolor blue $initialDir) [reale: $(ecolor blue $(pwd))])"
	# res=$(inputPromptOrDefault "# Eliminare la cartella di lavoro $tmpWd?")
	# if [ "$res" != "false" ]; then
	# 	rm -rf $tmpWd
	# fi

	# confirm "# Salvare la cartella di lavoro temporanea $tmpWd?" && read -p "Inseriere il percorso di salvataggio: " saveWd && cp -r $tmpWd $saveWd
	confirm "# Mantenere la cartella di lavoro $tmpWd?" || rm -rf $tmpWd
}

getCmdVersion () {
	# # "${@}" 2> /dev/null || echo "${@} NON TROVATO"
	# ver=$("${@}" --version 2> /dev/null) || res="not installed"
	# # ver=$("${@}" --version 2> /dev/null) && res=$(echo $ver | sed -e 's/.*version\(.*\)\,.*/\1/') # BENE O MALE ANDAVA
	# # ver=$("${@}" --version 2> /dev/null) && res=$(echo $ver | NUMERI E PUNTI FINO A SPAZIO ESCLUSO | sed 's/[^0-9.]//g')
	# # sed 's/[[:alpha:]|(|[:space:]]//g'
	# ver=$("${@}" --version 2> /dev/null) && res=$(echo $ver | sed 's/[[:alpha:]|(|[:space:]]//g' | cut -f1 -d"," | sed 's/[^0-9.]//g') # PORCHERIA
	
	which "${@}" > /dev/null
	if [ "$?" != "0" ]; then
		res="not installed"
	else
		res=$("${@}" --version | sed -e 's/ (GTK.*//g' | sed 's/[[:alpha:]|(|[:space:]]//g' | cut -f1 -d"," | cut -f1 | sed 's/[^0-9.]//g')
	fi
 
	echo $res
}

install_miaprova() {
	if [ "${1}" == "--test" ]; then
		echo "test ${@}"
	else
		read -p "scricvin qlcs: " res
		echo "$res"
	fi
}

cmdInstall () {
	# echo "test ${@}"
	# echo "------"
	array=("$@")
	for i in "${array[@]}"
	do
		# get version or install
		ver=$(getCmdVersion $i)
		if [ "${ver}" == "not installed" ]; then
			confirm "Installare il programma $i richiesto?" && $( install_"${i}" --test 2> /dev/null && install_"${i}" || apt install $i -y )
		fi

		# choose color
		if [ "$ver" == "not installed" ]; then
			ver=$(ecolor red "$ver")
		else
			ver=$(ecolor green "$ver")
		fi

		# print result
		echo "versione di $i installata: $ver"
		echo ""
	done
}


## MAIN LOOP FOR FILE OF FUNCTIONS TO INCLUDE
main() {
	moduleOK() {
		echo "# modulo ${BASH_SOURCE} caricato"
	}

	if [ "${1}" != "--source-only" ]; then
		moduleOK "${@}"
	fi
}
main "${@}"
