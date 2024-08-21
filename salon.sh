#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~ Salon ~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo How may I help you?
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name from services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID NAME
  do
    SERVICE_INFO="$SERVICE_ID $NAME"
    echo $SERVICE_INFO | sed 's/ |/)/'
  done
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED != [1-5] ]]
  then
    MAIN_MENU "We don't offer that service here. Please check again."
  else
    echo -e "Whats your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')");
    echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    
  fi

}
MAIN_MENU