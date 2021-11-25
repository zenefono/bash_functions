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
	# da: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
	# Lists the files in your .ssh directory, if they exist
	if ls -al ~/.ssh 2> /dev/null; then
		echo "TODO! selezionare la chiave ssh"
	else
		echo "NON esiste!"

		# Generating a new SSH key
		ssh-keygen -t ed25519 -C "${gitUsrEmail}"

		# Adding your SSH key to the ssh-agent
		eval "$(ssh-agent -s)"
		ssh-add ~/.ssh/id_ed25519
		cat ~/.ssh/id_ed25519.pub
		echo ""
		echo "Select and copy the contents of the id_ed25519.pub file"
		echo "Go to https://github.com/settings/keys and add it to GitHub"

	fi
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
