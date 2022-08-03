#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n" 
  fi

  #get available services
  SERVICES=$($PSQL"SELECT * FROM services ORDER BY service_id") 

  #display services
  echo -e "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED

  #display services
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "Please enter a valid service number"
  else
    #get list of service numbers
    SERVICE_EXISTS=$(echo $SERVICES | grep $SERVICE_ID_SELECTED)

    if [[ -z $SERVICE_EXISTS ]]
      then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #ask for a phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      #check if phone number is in database
      PHONE_EXISTS=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $PHONE_EXISTS ]]
        then 
        #ask for a name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUSTOMER_INSERTED=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      else
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi
        echo -e "\nHow much time would you like to reserve?"
        read SERVICE_TIME
        if [[ -z $SERVICE_TIME ]]
          then
          MAIN_MENU "Please enter a valid time"
          else
          SERVICE_INSERTED=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
          echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
    fi
  fi
}

MAIN_MENU
