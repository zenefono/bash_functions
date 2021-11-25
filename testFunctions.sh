includeLocalFile(){
	DIR="${BASH_SOURCE%/*}"
	if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

	. "$DIR/$@" --source-only
}
includeLocalFile gitFunctions.sh

provaCiao(){
  echo "ciao io sono una funzione di prova"
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
