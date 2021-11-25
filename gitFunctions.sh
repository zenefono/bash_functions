#! /bin/bash

# INCLUDE
includeLocalFile(){
	DIR="${BASH_SOURCE%/*}"
	if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

	. "$DIR/$@" --source-only
}
includeLocalFile utilityFunctions.sh

gitUsrName="Name Surname"
gitUsrEmail="name.surname@gmail.com"


# SPECIFIC
get_latest_github_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

gitUserSetup() {
  	gitUsrName=$(inputPromptOrDefault "Inserire il nome dell'utente git globale" "$gitUsrName")
	git config --global user.name "$gitUsrName"
	gitUsrEmail=$(inputPromptOrDefault "Inserire l'email dell' utente git globale" "$gitUsrEmail")
	git config --global user.email "$gitUsrEmail"
}
gitLocalUserSetup() {
  	gitUsrName=$(inputPromptOrDefault "Inserire il nome dell'utente git locale" "$gitUsrName")
	git config --local user.name "$gitUsrName"
	gitUsrEmail=$(inputPromptOrDefault "Inserire l'email dell' utente git locale" "$gitUsrEmail")
	git config --local user.email "$gitUsrEmail"
}

gitCreateRepo() {
	initialDir=$(pwd)
	# Ask the user for a directory name to be created.
	# echo "Enter the directory name to be created:"
	# read dirname
	dirname=$(inputPromptOrDefault "Enter the project name to be created" "testRepo")
	description=$(inputPromptOrDefault "Enter the project description" "questo è il testRepo")

	# Create a new directory with that name and CD into it.
	mkdir $dirname
	cd ./$dirname

	# Report the working directory.
	echo "$dirname has been created"
	echo "Moved into $( pwd )"

	# Create a few files.
	# if true ; then
	# 	cat <<- EOF > README.md
	# 	# $dirname
	# 	> Outline a brief description of your project.
	# 	> Live demo [_here_](https://www.example.com). <!-- If you have the project hosted somewhere, include the link here. -->

	# 	## Table of Contents
	# 	* [General Info](#general-information)
	# 	* [Technologies Used](#technologies-used)
	# 	* [Features](#features)
	# 	* [Screenshots](#screenshots)
	# 	* [Setup](#setup)
	# 	* [Usage](#usage)
	# 	* [Project Status](#project-status)
	# 	* [Room for Improvement](#room-for-improvement)
	# 	* [Acknowledgements](#acknowledgements)
	# 	* [Contact](#contact)
	# 	<!-- * [License](#license) -->


	# 	## General Information
	# 	- Provide general information about your project here.
	# 	- What problem does it (intend to) solve?
	# 	- What is the purpose of your project?
	# 	- Why did you undertake it?
	# 	<!-- You don't have to answer all the questions - just the ones relevant to your project. -->


	# 	## Technologies Used
	# 	- Tech 1 - version 1.0
	# 	- Tech 2 - version 2.0
	# 	- Tech 3 - version 3.0


	# 	## Features
	# 	List the ready features here:
	# 	- Awesome feature 1
	# 	- Awesome feature 2
	# 	- Awesome feature 3


	# 	## Screenshots
	# 	![Example screenshot](./img/screenshot.png)
	# 	<!-- If you have screenshots you'd like to share, include them here. -->


	# 	## Setup
	# 	What are the project requirements/dependencies? Where are they listed? A requirements.txt or a Pipfile.lock file perhaps? Where is it located?

	# 	Proceed to describe how to install / setup one's local environment / get started with the project.


	# 	## Usage
	# 	How does one go about using it?
	# 	Provide various use cases and code examples here.

	# 	`write-your-code-here`


	# 	## Project Status
	# 	Project is: _in progress_ / _complete_ / _no longer being worked on_. If you are no longer working on it, provide reasons why.


	# 	## Room for Improvement
	# 	Include areas you believe need improvement / could be improved. Also add TODOs for future development.

	# 	Room for improvement:
	# 	- Improvement to be done 1
	# 	- Improvement to be done 2

	# 	To do:
	# 	- Feature to be added 1
	# 	- Feature to be added 2


	# 	## Acknowledgements
	# 	Give credit here.
	# 	- This project was inspired by...
	# 	- This project was based on [this tutorial](https://www.example.com).
	# 	- Many thanks to...


	# 	## Contact
	# 	Created by [@namesurname](mailto: name.surname@gmail.com/) - feel free to contact me!


	# 	<!-- Optional -->
	# 	<!-- ## License -->
	# 	<!-- This project is open source and available under the [... License](). -->

	# 	<!-- You don't have to include all sections - just the one's relevant to your project -->

		


	# 	EOF
	# fi
	echo "*.conf" > .gitignore
	echo "# Project: $dirname" > readme.md
	echo "" >> readme.md; echo "## $description" >> readme.md; echo "" >> readme.md

	# Initialize git.
	git init
	git add -A
	git commit -m "Initial commit"

	# Report the filenames that have been created.
	echo ""; echo "File that have been created:"
	ls -hartl

	# Tell the user that this script is done.
	echo "Done!"

	cd $initialDir
	
	myRepo="$dirname"
	export $myRepo
}

function gitMergeRepo() {  
    SOURCE=$1
    DEST=$2

    echo
    echo "---> Merging $SOURCE with $DEST" 

    echo
    echo "---> ---> Checkout $DEST ..."     
    git checkout $DEST

    echo
    echo "---> ---> Pull $DEST ..."
    if ! git pull --ff-only origin $DEST
    then
     exit 1
    fi

    echo
    echo "---> ---> Merging $SOURCE with $DEST ..." 
    # --ff-only trigger errors if merge/pull is not possible
    if ! git merge --ff-only $SOURCE --no-edit
    then
      exit 1
    fi

    echo
    echo "---> ---> Push $DEST ..."
    git push origin $DEST
}

function gitDeployRepo() {
    MODE=$1
    SOURCE_BRANCH=$2

    echo     
    echo "---> Pull changes from Master ..."

    if ! git checkout $SOURCE_BRANCH
    then    
        exit 1
    fi

    git pull --progress --no-edit --no-stat -v --progress origin master

    if ! gitMergeRepo $SOURCE_BRANCH 'staging'
    then      
      exit 1
    fi

    if [ $MODE = "live" ]
    then
        if ! gitMergeRepo $SOURCE_BRANCH 'master'
        then          
          exit 1
        fi

        if ! gitMergeRepo 'master' 'production'
        then          
          exit 1
        fi
    fi
}

gitDeploy() {
	MODE=$1
	SOURCE_BRANCH=$2

	if [ -z "$MODE"  -o -z "$SOURCE_BRANCH" ]
	then
		echo "Usage:"
		echo ""
		echo  "MODE BRANCH_NAME (MODE: live|staging)"
	else
		if git show-ref --verify --quiet "refs/heads/$SOURCE_BRANCH"
		then
			echo
			echo "### START ###"
			echo
			gitDeployRepo $MODE $SOURCE_BRANCH
			echo
			echo "### END ###"
			echo
		else
			echo
			echo "Error: Branch $SOURCE_BRANCH not found"
		fi
	fi
}

gitCheck(){ # Check a directory and report whether Git projects have been committed, or are being tracked.
	curdir=$PWD
	cnt=0
	good=0
	untr=0
	uncom=0

	ls -hartl
	echo ""

	for D in */; do
	cnt=$((cnt+1))
	cd $D

	ls -hartl
	echo ""
	
	find -maxdepth 1 -name '\.git' -type d -print -quit | grep '\.git' &> /dev/null
		if [ $? == 0 ]; then
		if [ -z "$(git status --porcelain)" ]; then
			good=$((good+1))
			printf "$(ecolor green %-30s) is tracked and up to date.\n" $D
		else
			printf "$(ecolor red %-30s) contains untracked (or uncommitted) files.\n" $D
			uncom=$((uncom+1))
		fi
		else
		printf "$(ecolor yellow %-30s) is not currently tracked with git.\n" $D
		untr=$((untr+1))
		fi
		cd $curdir
	done

	printf "You currently have:\n * %s clean project folders\n * %s tracked folders awaiting commits\n * %s untracked folders\n" $good $uncom $untr
	echo ""
	if [ $untr -gt 0 ]  || [ $uncom -gt 0 ]; then
		 return 1
	else 
		return 0
	fi
	
}

gitAddSubmodule() { # This script makes it much easier to add new submodules
	GIT_DIR=$(git rev-parse --git-dir)

	PROJ_DIR=$(dirname "$GIT_DIR")
	PROJ_DIR=$(abspath "$PROJ_DIR")
	PROJ_RE=$(echo "$PROJ_DIR/" | sed 's/\//\\\//g')

	for dir in "$@"; do
		SUBDIR=$(abspath "$dir")
		SUBDIR=$(echo $SUBDIR | sed s/$PROJ_RE//)

		repo=$(echo $(grep "url = " "$dir/.git/config") | \
			sed 's/.*url = //' | \
			sed 's/git@github.com:\([^\/]*\)\//git:\/\/github.com\/\1\//' )

		(cd "$PROJ_DIR" && \
		git submodule add "$repo" "$SUBDIR" && \
		git commit -m "Added submodule $SUBDIR")
	done
}


gitCommit() {
	repos=( 
	"/c/Users/Win10/Documents/projects/store" #location to git repo
	#you can add more repos here
	)

	#Reading user defined inputs start
	echo "Enter Commit First Line: "
	read first_line
	echo "Enter Commit Message: "
	read commit_message
	#Reading user defined inputs end

	finalcommitMsq=$first_line
	finalcommitMsq+=$'\n'
	finalcommitMsq+='-'
	finalcommitMsq+=$commit_message
	finalcommitMsq+=$'\n'

	echo $'\n';
	echo $'\n';

	for repo in "${repos[@]}"
	do
	commitMessage=''
	echo ""
	echo -e "\033[1;32mScript Operation in " ${repo} " \033[0m"
	cd "${repo}"
	git config --global core.safecrlf false
	addedFiles=$(git ls-files --others --exclude-standard)
	output=`git status --porcelain`
	$addedFiles && $output && 
	if [ -z "$output" ] && [ -z "$addedFiles" ]; then
		echo -e "\e[0;31m Nothing to commit Did you run ADD manually If yes then commit Manually \033[0;37m"
	else
		echo -e "\033[1;33m FILES THAT HAVE CHANGES \033[0;37m"
		echo "$output"
		echo "$addedFiles"
		echo "Do you want to commit these changes, y for yes and n for No in :  "
		read DECISION
		if [ "$DECISION" == "y" ]; then #Reading user defined inputs start
			files=`git diff --name-only` #getting modified/new file names
			git add --all #adding all new/modified files
			git status #added status
			f=''
			for file in $files; do #loop for new/modified file to make commit message start
				f+='-      modified:    '
				f+=$file
				f+=$'\n'
			done #loop for new/modified file to make commit message end
			for addF in $addedFiles; do
				f+='-      added:    '
				f+=$addF
				f+=$'\n'
			done
			commitMessage+=$finalcommitMsq
			commitMessage+=$f
			echo -e "\033[0;35m$commitMessage \033[0;37m"
			#git commit -m"$(echo -e "$commitMessage")" #commiting changes
			#git push origin dev
		else
			if ! [ "$DECISION" == "y"  -o "$DECISION" == "n" ]; then
				echo "Please choose y for yes and n for no"
			fi
		fi
	fi
	echo -e "\033[44m**END**END**${repo}**END**END** \033[0m"
	done
	echo "######################DONE Commiting#############"
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
