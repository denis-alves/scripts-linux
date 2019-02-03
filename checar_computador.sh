#!/bin/bash

#Este scrpit faz uso dos seguintes programas para checar o computador:
#Fail2ban, smarmontools, vnstati, free e df.
#O programa ssmtp é utilizado para envio de notificações por e-mail.

#Checagem do HD
echo -e "To: usuario-de-destino@gmail.com \nFrom: usuario-de-origem@outlook.com \nSubject:Logs do computador \n" > /var/log/logs_computador.txt

HDTAMANHO=$(df -h | awk {'print $2'} | sed -n '4p')
HDUTILIZADO=$(df -h | awk {'print $3'} | sed -n '4p')
HDRESTANTE=$(df -h | awk {'print $4'} | sed -n '4p')
echo -e "--------------------------" >> /var/log/logs_computador.txt
echo -e "| STATUS DO HD |" >> /var/log/logs_computador.txt
echo -e "--------------------------" >> /var/log/logs_computador.txt

echo -e "" >> /var/log/logs_computador.txt

echo -e "Tamanho do HD: $HDTAMANHO" >> /var/log/logs_computador.txt
echo -e "Espaco utilizado: $HDUTILIZADO" >> /var/log/logs_computador.txt
echo -e "Espaco restante: $HDRESTANTE" >> /var/log/logs_computador.txt

echo -e "" >> /var/log/logs_computador.txt

echo -e "-----------------------------------------------" >> /var/log/logs_computador.txt
echo -e "| CHECAGEM DE FALHAS DO HD |" >> /var/log/logs_computador.txt
echo -e "-----------------------------------------------" >> /var/log/logs_computador.txt

echo -e "" >> /var/log/logs_computador.txt

sudo smartctl -t long /dev/sda

sleep 120m

sudo smartctl -a /dev/sda | sed -n '79,104p' >> /var/log/logs_computador.txt 

echo -e "" >> /var/log/logs_computador.txt

echo -e "--------------------------------------------------" >> /var/log/logs_computador.txt
echo -e "| CHECAGEM DE FALHAS DO HD DE BACKUP|" >> /var/log/logs_computador.txt
echo -e "--------------------------------------------------" >> /var/log/logs_computador.txt

echo -e "" >> /var/log/logs_computador.txt

sudo smartctl -t long /dev/sdb

sleep 180m

sudo smartctl -a /dev/sdb | sed -n '185,300p' >> /var/log/logs_computador.txt 

echo -e "" >> /var/log/logs_computador.txt


echo -e "--------------------------------" >> /var/log/logs_computador.txt
echo -e "| STATUS DO FAIL2BAN |" >> /var/log/logs_computador.txt
echo -e "--------------------------------" >> /var/log/logs_computador.txt

echo -e "" >> /var/log/logs_computador.txt

sudo fail2ban-client status sshd >> /var/log/logs_computador.txt


echo -e "" >> /var/log/logs_computador.txt

echo -e "---------------------------------------------------------" >> /var/log/logs_computador.txt
echo -e "| ULTIMAS ATUALIZACOES DA SEMANA |" >> /var/log/logs_computador.txt
echo -e "---------------------------------------------------------" >> /var/log/logs_computador.txt

echo -e "" >> /var/log/logs_computador.txt

if [ -s /var/log/apt/history.log ];
then
	sudo tail /var/log/apt/history.log >> /var/log/logs_computador.txt

else
	echo -e "Arquivo nao possui logs" >> /var/log/logs_computador.txt
	echo -e "Descompactando o ultimo arquivo de logs" >> /var/log/logs_computador.txt
	sudo cp /var/log/apt/history.log.1.gz /home/denis/
	sudo gunzip /home/denis/history.log.1.gz
	echo -e "Exibindo logs" >> /var/log/logs_computador.txt
	echo -e "" >> /var/log/logs_computador.txt
	sudo tail /home/denis/history.log.1 >> /var/log/logs_computador.txt
	echo -e "" >> /var/log/logs_computador.txt
	echo -e "Excluindo arquivo de logs" >> /var/log/logs_computador.txt
	sudo rm -rf /home/denis/history.log.1
fi

sudo vnstati -s -o /root/log_rede1.png
sudo vnstati -d -o /root/log_rede2.png
sudo vnstati -m -o /root/log_rede3.png
sudo vnstati -t -o /root/log_rede4.png
sudo convert /root/log_rede1.png /root/log_rede2.png /root/log_rede3.png /root/log_rede4.png -append /root/log_rede.png

sudo ssmtp usuario-de-destino@gmail.com < /var/log/logs_computador.txt

echo -e "To: usuario-de-destino@gmail.com \nFrom: usuario-de-origem@outlook.com \nSubject:Logs do computador (rede)" | uuenview -a -bo /root/log_rede.png | sudo ssmtp usuario-de-destino@gmail.com

rm -rf /root/log_rede*

