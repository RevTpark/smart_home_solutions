import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import serial
from decouple import config
import requests

def send_email(receiver_email, user_name, temp, hum):
    sender_email = config('SENDER_MAIL')
    sender_password = config('SENDER_PASSWORD')
    subject = f'Welcome back {user_name}!'
    body = f'''
    Greetings <b>{user_name}</b>,<br>
        We wanted to let you know that our smart home system has detected motion in your home.<br>
        We take your safety and security seriously and want to assure you that our system is working to keep you and your property secure.
        <br><br>
        Today's temperature is {temp} and humidity is {hum}.
        <br><br>
        Thank you for choosing our service.
        <br><br>
        Best regards,<br>
        <b>STAU Smart Home</b>
    '''

    message = MIMEMultipart()
    message['From'] = sender_email
    message['To'] = receiver_email
    message['Subject'] = subject
    message.attach(MIMEText(body, 'html'))

    smtp_server = smtplib.SMTP('smtp.gmail.com', 587)
    smtp_server.starttls()
    smtp_server.login(sender_email, sender_password)

    # Send the email
    smtp_server.sendmail(sender_email, receiver_email, message.as_string())

    # Disconnect from the SMTP server
    smtp_server.quit()


def send_whatsapp_mssg(send_to):
    url = f"https://graph.facebook.com/v16.0/{config('PH_NUMBER_ID')}/messages"
    headers = {"Authorization": f"Bearer {config('TOKEN')}"}
    body = {
        "messaging_product": "whatsapp",
        "to": send_to,
        "type": "template",
        "template": {
            "name": "hello_world",
            "language": {
                "code": "en_US"
            },
        }
    }
    response = requests.post(url, headers=headers, json=body)
    if response.status_code != 200:
        print("Error in the Request")

    

ser = serial.Serial('COM3', 9600)
while True:
    data = ser.readline().decode().rstrip()
    temp, hum = list(map(int, data.split(",")))
    print(temp, hum)
    
    to_mail = "tparkar20comp@student.mes.ac.in"
    user_name = "Tanishq Parkar"
    send_email(to_mail, user_name, temp, hum)

    send_to = "XXXXXXXX000"
    send_whatsapp_mssg(send_to)
    break



