#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
RE='^[0-9]*$'

if [[ -z $1 ]]
then
	echo "Please provide an element as an argument."
else
	if [[ ! $1 =~ $RE ]]
	then
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1'")
	else
		ATOMIC_NUMBER=$1
	fi
	if [[ -n $ATOMIC_NUMBER ]]
	then
		NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
		SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER") | sed -r 's/[^a-z]*/''/ig')
		TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
		if [[ $TYPE_ID -eq 1 ]]
		then
			TYPE='metal'
		elif [[ $TYPE_ID -eq 2 ]]
		then
			TYPE='nonmetal'
		elif [[ $TYPE_ID -eq 3 ]]
		then	
			TYPE='metalloid'
		fi
		MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
		MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
		BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
		RESULT=$(echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius." | sed -r 's/^[ ]*|[ ]*$//gi')
		echo $RESULT
	else
		echo "I could not find that element in the database."
	fi
fi
