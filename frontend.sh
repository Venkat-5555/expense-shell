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

dnf install nginx -y &>>$LOG_FILE
validate $? "install nginix"

systemctl enable nginx  &>>$LOG_FILE
validate $? "enable nginix"

systemctl start nginx  &>>$LOG_FILE
validate $? "stating nignix"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
validate $? "removing default html folder"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
validate $? "download application Package" 

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
validate $? "extarcting frontend application code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
validate $? "copy config file to nginix"

systemctl restart nginx
validate $? "restarting nginix" 


