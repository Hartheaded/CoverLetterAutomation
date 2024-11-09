#!/usr/bin/env bash

# This script is aimed to take one of the files within the templates folder, change the company title and job title of the file in .tmp, then export it as a PDF in the output folder. Each of these PDFs should be named in a style similar to this [Company][Job Title][Date].pdf


#templateChoice="./templates/$1.txt"
#companyName=$2
#jobTitle=$3

# Takes the contents of ./appendText.txt and appends it to the bottom of the output of inputVerifier
appendText(){
	if [[ $(wc appendText.txt) != "0 0 0 appendText.txt" ]]; then
		cat "./appendText.txt" >> $template
		echo "Appended $templateOutput with ./appednedText.txt"
	else
		echo "appendText.txt file is empty"
		echo "Skipping. . ."
	fi
}

# Converts the temporary file found in ./.tmp/ to a pdf file in ./output/
pdfMaker(){
	libreoffice --convert-to "pdf" --outdir output $template
}
i
# DANGEROUS WILL DELETE EVERYTHING INSIDE OF /.tmp/
cleanUp(){
	rm -Rf .tmp/*
}


# Select a template; Verify Selection
templateSelection(){
	while true; do
		echo "Please select a template"
		cleanUp
		count=0
		for i in ./templates/* ; do
			count=$((count + 1))
			echo "$count. $i"
			echo "$count. $i" | cat >> .tmp/count.txt
		done	
		read templateChoice
	
		echo "$(cat .tmp/count.txt | grep "$templateChoice" )" &> .tmp/count.txt
		templateChoice=$(cat .tmp/count.txt)
		templateChoice=${templateChoice:2}
		break
	done
}

positionInfo(){
	while true; do
		echo "What is the name of the company?"
		read companyName
		echo "What is the job title?"
		read jobTitle
		while true; do
			echo "Company: $companyName Job Title: $jobTitle"
			read -p "Is the following correct? (Y/N)" response
			case $response in
				[Yy]* ) return 0;;
				[Nn]* ) break;;
				* ) echo "Your choices are (Y/N)"
			esac
		done
	done
}

cleanUp
templateSelection
positionInfo
template=".tmp/${companyName//[[:blank:]]/}-${jobTitle//[[:blank:]]/}-$(date +%d-%m-%y).txt"
cp -f $templateChoice $template
sed -i "s/#COMPANYNAME#/$companyName/g" "$template"
sed -i "s/#JOBTITLE#/$jobTitle/g" "$template"
appendText
templateOutput="output/$companyName-$jobTitle-$(date +%d-%m-%y).txt"
pdfMaker

