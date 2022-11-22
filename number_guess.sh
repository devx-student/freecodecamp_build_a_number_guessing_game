#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

# Generate randon number 
SECRET_NUMBER=$(($RANDOM % 1000 +1))

# Prompt for user name
echo -e "Enter your username:"
read USERNAME

# Check if username is in DB
USER_GAME_DATA=$($PSQL "SELECT username, count(game_id) as games_played, min(tries) as best_game FROM users inner join games using(user_id) where username = '$USERNAME' group by username")

if [[ $USER_GAME_DATA ]]
then
  # If user exists
  echo $USER_GAME_DATA | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done
else
  # If user not exists
  SAVEUSER=$($PSQL "INSERT INTO users(username) values('$USERNAME')")
  echo Welcome, $USERNAME! It looks like this is your first time here.
fi

GET_GUESS() {
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]*$ ]]
  then
    echo That is not an integer, guess again:
    GET_GUESS
  fi
}

# Prompt for guess number
echo Guess the secret number between 1 and 1000:

GET_GUESS

GUESSED=1
NUMBER_OF_GUESSES=0

while [ $GUESSED == 1 ]
do
  let NUMBER_OF_GUESSES+=1
  # Check if is the number
  if (( $SECRET_NUMBER > $GUESS ))
  then
    echo "It's higher than that, guess again:"
    GET_GUESS
  elif (( $SECRET_NUMBER < $GUESS ))
  then
    echo "It's lower than that, guess again:"
    GET_GUESS
  else
    GUESSED=0
    USERID=$($PSQL "SELECT user_id FROM users where username = '$USERNAME'")
    SAVEGAME=$($PSQL "INSERT INTO games(user_id,tries) values($USERID,$NUMBER_OF_GUESSES)")
    echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GUESS. Nice job!
  fi
done
