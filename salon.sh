#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {
    if [[ $1 ]]
    then
	echo -e "\n$1"
    fi  

    #echo -e "\nWhat service would you like to schedule?"
    SERVICE_MENU
}

SERVICE_MENU() {
    # get available services
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    # display available services
    # echo -e "\nOur list of services:"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
	echo "$SERVICE_ID) $NAME"
    done

    # ask for service to schedule
    # echo -e "\nWhich one would you like to schedule?"
    read SERVICE_ID_SELECTED
    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
	# send to main menu  
	MAIN_MENU "That is not a valid service number."
    else 
	# get customer info
	echo -e "\nWhat's your phone number?"
	read CUSTOMER_PHONE
	CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
	# if customer doesn't exist
	if [[ -z $CUSTOMER_NAME ]]
	then
	    # get new customer name
	    echo -e "\nWhat's your name?"
	    read CUSTOMER_NAME
	    # insert new customer
	    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
	fi
	# get appointment time
	echo -e "\nAt what time would you like to schedule it?"
	read SERVICE_TIME
	# get customer_id
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
	# insert service appointment
	INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") 

	# get service info
	SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
	SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ |/"/')

	# send to main menu
	echo -e "\nI have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi
}


MAIN_MENU
