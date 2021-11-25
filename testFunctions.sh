includeLocalFile(){
	DIR="${BASH_SOURCE%/*}"
	if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

	. "$DIR/$@" --source-only
}
includeLocalFile gitFunctions.sh

provaCiao(){
  echo "ciao io sono una funzione di prova"
}

dockerStopAllContainers() {
	docker kill $(docker ps -q)
}

genAndAddSshKey() {
		# Generating a new SSH key
		ssh-keygen -t ed25519 -C "${gitUsrEmail}"

		# Adding your SSH key to the ssh-agent
		eval "$(ssh-agent -s)"
		ssh-add ~/.ssh/id_ed25519
		cat ~/.ssh/id_ed25519.pub
		echo ""
		echo "Select and copy the contents of the id_ed25519.pub file"
		echo "Go to https://github.com/settings/keys and add it to GitHub"
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
