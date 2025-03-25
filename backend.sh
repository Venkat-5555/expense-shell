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

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "Disable default nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
validate $? "Enable nodejs:20"

dnf install nodejs -y  &>>$LOG_FILE
validate $? "nodejs install"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "user  expense dont exists.... $G adding $N" &>>$LOG_FILE
    useradd expense  &>>$LOG_FILE
    validate $? "adding expense user"
else
    echo -e "$Y user expense already exists $N" &>>$LOG_FILE
fi
mkdir -p /app
validate $? "creating /app  folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
validate $? "download backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
validate $? "extracting backend file"

npm install &>>$LOG_FILE
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#load data before running backend

dnf install mysql -y &>>$LOG_FILE
validate $? "installing mysql"

#load schema

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "schema loading"

#loading demon

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reload"

systemctl restart backend &>>$LOG_FILE
validate $? "backend service restarting"

systemctl enable backend &>>$LOG_FILE
validate $? "backend service enabling "






