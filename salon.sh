#! /bin/bash

echo "****************************** Welcome To My Salon *******************************"

#displaying the list of services
display_services(){
  echo "Choose a Service: "
  psql -U freecodecamp -d salon -t -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
  
}

get_valid_service(){
  SERVICE_ID_SELECTED=''
  while [[ -z $SERVICE_ID_SELECTED ]];
  do
    display_services  # Display the services before prompting for input
    read SERVICE_ID_SELECTED
    VALID_SERVICE_ID=$(psql -U freecodecamp -d salon -t -c "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $VALID_SERVICE_ID ]];
    then
       echo "Entered Service ID is Invalid"
       echo "Please Enter the Correct One"
       SERVICE_ID_SELECTED='' #make it Empty so that loop continues
    else
       SERVICE_ID_SELECTED=$VALID_SERVICE_ID
    fi
  done
}


get_valid_service

echo -e "\nWhat's Your Phone Number?"
read CUSTOMER_PHONE

#checks if customer id exist
CUSTOMER_ID=$(psql -U freecodecamp -d salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_ID ]];
then 
   echo -e "\nI don't have a record for that phone number. What's Your Name?"
   read CUSTOMER_NAME
   psql -U freecodecamp -d salon -t -c "INSERT INTO customers (name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE');"
   CUSTOMER_ID=$(psql -U freecodecamp -d salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
fi

#Save Customer Name and Customer Service Name
SERVICE_NAME=$(psql -U freecodecamp -d salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
CUSTOMER_NAME=$(psql -U freecodecamp -d salon -t -c "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")


#take appointment time as input
echo -e "\nWhat time would you like your $SERVICE_NAME,$CUSTOMER_NAME? "
read SERVICE_TIME

#Insert the appointment ,use -q(quiet) to remove insert 0 1
psql -U freecodecamp -d salon -t -c "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');" 


#Show Output

echo e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."