#!/bin/bash

LOG_FOLDER="/var/log/expense"
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%s)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.sh"
mkdir -p $LOG_FOLDER

USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

check_root(){
    if [ $USER_ID -ne 0 ]
    then
        echo -e "$R please run the user with root credentials $N" | tee -a $LOG_FILE
        exit 1
    fi
}

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is.......$R FAILED $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is........$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE

check_root

# dnf install mysql-server -y &>>$LOG_FILE
# validate $? "installing mysql"

systemctl enable mysqld &>>$LOG_FILE
validate $? "enable mysql server"

systemctl start mysqld &>>$LOG_FILE
validate $? "starting mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1
validate $? "setting up root password"

