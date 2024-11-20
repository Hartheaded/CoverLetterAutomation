#!/usr/bin/env bash

# This script is aimed to take one of the files within the templates folder, change the company title and job title of the file in .tmp, then export it as a PDF in the output folder. Each of these PDFs should be named in a style similar to this [Company][Job Title][Date].pdf


# DANGEROUS WILL DELETE EVERYTHING INSIDE OF /.tmp/
cleanUp(){
	rm -Rf .tmp/*
}

# Generates a numbered list of templates to choose from, confirms data, and sets user's $templateChoice to the full directory of the template
templateSelection(){
	while true; do
		count=0
		for i in ./templates/* ; do
			count=$((count + 1))
			echo "$count. $i"
			echo "$count. $i" | cat >> .tmp/count.txt
		done
		
			read -p "Please select a template (1-$count)" templateChoice
				case $templateChoice in
					[0-$count]) 
				echo "$(cat .tmp/count.txt | grep "$templateChoice" )" &> .tmp/count.txt
				templateChoice=$(cat .tmp/count.txt)
				templateChoice=${templateChoice:2}
				return 0
						;;
					* ) echo "Please select using a number..." ;;
				esac	
	done
}

# Asks user to input the company name and job title for the $companyName and $jobTitle variables
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

# Appends the document with text from ./appendText.txt
appendText(){
	if [[ $(wc appendText.txt) != "0 0 0 appendText.txt" ]]; then
		cat "./appendText.txt" >> $template
		echo "Appended cover letter with ./appednedText.txt"
	else
		echo "appendText.txt file is empty"
		echo "Skipping. . ."
	fi
}

# Converts the temporary file found in ./.tmp/ to a pdf file in ./output/
pdfMaker(){
	libreoffice --convert-to "pdf" --outdir output $template
}

# Optional step when you can only give a resume. Merges the resume and cover letter together.
mergeToResume(){
	while true; do
		read -p "Do you wish to append this document to your resume? (Y/N)" response
		case $response in
			# swap the first two parameters in the pdfunite to merge the resume UNDER the generated cover letter
			[Yy]* ) pdfunite $($resume) $($pdfOut) $($pdfOut) && break;;
			[Nn]* ) break;;
			* ) echo "Your choices are (Y/N)"
		esac
	done
}

# Clean up .tmp
cleanUp
# Select a template from ./templates/
templateSelection
# User inputs company name and job title
positionInfo
# Sets the output filename ./output/CompanyTitle-JobTitle-01-02-03.pdf
pdfOut="./output/${companyName//[[:blank:]]/}-${jobTitle//[[:blank:]]/}-$(date +%d-%m-%y).pdf"
# Sets the working template file name as variable. Similar to above, but a .txt file
template="./.tmp/${companyName//[[:blank:]]/}-${jobTitle//[[:blank:]]/}-$(date +%d-%m-%y).txt"
# Used for mergeToResume. You will need to supply your OWN resume for this function to work
resume="./resume.pdf"
# Copies the selected template and puts it in .tmp for further processing
cp -f $templateChoice $template
# Scans through file and replaces all instances of #COMPANYNAME# to the peviously set $companyName
sed -i "s/#COMPANYNAME#/$companyName/g" "$template"
# Same thing as above, but with #JOBTITLE# and the job title.
sed -i "s/#JOBTITLE#/$jobTitle/g" "$template"
# Appends the text from ./appendText.txt to the bottom of the text file being worked on in .tmp
appendText
# Turns the entire document into a pdf file and places the results in the ./output/ folder
pdfMaker
# Optional step; Asks user if they want to merge their cover letter to their $resume
if [[ -e $resume ]]; then
	mergeToResume
fi
