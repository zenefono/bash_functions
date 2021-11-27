includeLocalFile(){
	DIR="${BASH_SOURCE%/*}"
	if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

	. "$DIR/$@" --source-only
}
includeLocalFile gitFunctions.sh

provaCiao(){
  echo "ciao io sono una funzione di prova"
  goOn
}

dockerStopAllContainers() {
	docker kill $(docker ps -q)
}

old_dotenvFromExample() {
	# --> get file contents and convert them to an array
	readarray thearray < $1

	# --> Iterate the array and do interactive editing
	declare i=1;
	#printf "%s\n" "${thearray[@]}"

	while [ $i -le  ${#thearray[@]} ]; do
	    echo $i
	    echo -e "First line: ${thearray[$i]}. Change this line? (y/n)"
	    read Useranswer
	    if [ $Useranswer == "y" ]; then

		echo "Please type any string:"
		read Firststring
		thearray[$i]="${Firststring}"
		let i=$i+1
	    elif [ $Useranswer == "n" ]; then
		let i=$i+1
		echo $i
	    fi
	done
	echo "printing results\n"
	printf "%s\n" "${thearray[@]}"

	echo "Everything done!"
}

dotenvFromExample() {
        Counter=0
        function process_line() {
                echo "Processing line $Counter: $1"
                key=$(echo $1 | cut -d '=' -f 1)
                val=$(echo $1 | cut -d '=' -f 2)
                echo "chiave: $key | valore: $val"
                read -p "premi INVIO per continuare... "
        }

        while IFS='' read -r LinefromFile || [[ -n "${LinefromFile}" ]]; do

                ((Counter++))

                if [[ "$LinefromFile" == *'='* ]]; then
                  process_line "$LinefromFile"
                fi

        done < "$1"
}


genAndAddSshKey() {
	# da: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
	# Lists the files in your .ssh directory, if they exist
	if ls -al ~/.ssh 2> /dev/null; then
		echo "TODO! selezionare la chiave ssh"
	else
		echo "NON esiste!"

		# Generating a new SSH key
		ssh-keygen -t ed25519 -C $(git config user.email)

		# Adding your SSH key to the ssh-agent
		eval "$(ssh-agent -s)"
		ssh-add ~/.ssh/id_ed25519
		cat ~/.ssh/id_ed25519.pub
		echo ""
		echo "Select and copy the contents of the id_ed25519.pub file"
		echo "Go to https://github.com/settings/keys and add it to GitHub"

	fi
}


importPublicRepo(){ # usage: importPublicRepo "hostDomain" "serviceName" "publicRepoUri" "privateDotEnv"
	hostDomain="${1}"
	serviceName="${2}"
	publicRepoUri="${3}"
	privateDotEnv="${4}"
	
	echo "clone ${serviceName} service public repo for ${hostDomain}"
	
	git clone "${publicRepoUri}" "./${serviceName}.${hostDomain}"

	echo ""	
	echo "set file .env"	
	#dotenvFromExample ./"traefik.${1}"/env.example ./"traefik.${hostDomain}"/.env
	
	# from: https://gist.github.com/madrobby/9476733#gistcomment-2817366
	USER="$(git config user.name)"
	PASSWD=""
	OUTPUT_FILEPATH="${privateDotEnv}"
	OWNER="mycompany"
	REPOSITORY="boo"
	RESOURCE_PATH="project-x/a/b/c.py"
	TAG="my_unit_test"
	
	curl \
	    -u "$USER:$PASSWD" \
	    -H 'Accept: application/vnd.github.v4.raw' \
	    -o "$OUTPUT_FILEPATH" \
	    -L "https://api.github.com/repos/$OWNER/$REPOSITORY/contents/$RESOURCE_PATH?ref=$TAG"
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
