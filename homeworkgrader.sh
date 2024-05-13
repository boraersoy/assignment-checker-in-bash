#!/bin/bash
echo "creating grading file"
mkdir grading

echo "checking the arguments"
if [ $# -eq 0 ]; then
    echo "Please provide total grade, correct output file and submission folder"
    exit 1
fi
if [ $1 -le 0 ]
then
	echo "maximum grade should be a positive integer"
	exit 1
fi

if [ $2 != "golden.txt" ]
then	echo "correct output file doesn't exits!"
	exit 1
fi
if [ $3 != "submissions" ]
then echo " submissions folder doesn not exist!"
	exit 1
fi

cd $3

filecount=$(ls *.sh | wc -l)

if [ "$filecount" -eq 0 ]
	then echo " submissions folder is empty!"
	exit 1
else

echo "$filecount number of students submitted their homework."
fi

touch log.txt

FILES=$(ls *.sh)

for FILE in $FILES

do 
	echo "Grading process for $FILE is started.."  
  if [[ ! $FILE =~ ^322_h1_[0-9]{9}\.sh$ ]]
	then 
	    echo  "Incorrect file name format: $FILE" >> log.txt
		echo "Incorrect file name"	
	continue
	else
    echo  "checking the file permission..."
  if [[ ! $(ls -l  $FILE) =~ x   ]] 
	then  chmod a+rx $FILE 
	echo "Changed permission of $FILE to executable"
	fi 
  	touch ../grading/result.txt
 
	file_being_executed="./$FILE"
		
	 [[ $FILE =~ ([0-9]+)\.sh$ ]]
		numbers=${BASH_REMATCH[1]}
		echo "id is $numbers"
	
	timeout 15s "$file_being_executed" > out.txt
	
	if [ $? -eq 124 ]  #originally 124
	then  
	echo "timeout has occured"
	
		echo "Student $numbers: Too long execution" >> log.txt
		echo "Student $numbers : 0" >> ../grading/result.txt
		mv out.txt ../grading/$(basename "$FILE")_out.txt
		continue
	else
	diflines=0
	while IFS= read -r line1 && IFS= read -r line2 <&3; do
    	if [ "$line1" != "$line2" ]; then
        ((diflines++))
    fi
	done < "$2" 3< "out.txt"	
	score=$(($1 - diflines))
	echo "Student $numbers : $score" >> ../grading/result.txt
	mv out.txt ../grading/$(basename "$FILE")_out.txt
  	fi
	
	fi
done
echo "*****grading competed******"
