#!/bin/bash

#Descrição: Instala e configura o serviço DHCP de forma interativa.
#Versão do script: 1.0
#Nota: Testado nos sistemas Ubuntu 18.04 e Debian 9.x


clear

echo "Escolha uma das opcoes abaixo: "
echo ""
echo -e "1)Instalar servico DHCP"
echo -e "2)Reservar IP para um host na rede"
echo -e "3)Sair"
echo ""
echo -n "Opcao: "
read OPCAO

#Abaixo mostra a execução de cada opção de acordo com o que o usuário escolheu.

case "$OPCAO" in
1)	
echo "-----------------------"
echo "ATUALIZANDO REPOSITORIO"
echo "-----------------------"
sudo apt update

echo ""

echo "------------------------"
echo "INSTALANDO SERVIDOR DHCP"
echo "------------------------"
sudo apt-get install isc-dhcp-server -y > /dev/null 2>&1

#Verifica se o serviço foi instalado sem erros. Em caso negativo, informa que não foi possível instalar.
if [ $? -eq 0 ]; then
echo ""

echo "SERVICO INSTALADO."

echo -e "" >> /etc/dhcp/dhcpd.conf
else 
echo "Nao foi possivel instalar o servico DHCP"
fi

#Aqui o usuário é solicitado a fornecer algumas informações para configurar o serviço DHCP. As opções podem ser alteradas depois em /etc/dhcp/dhcpd.conf
echo "--------------------------"
echo "CONFIGURANDO SERVIDOR DHCP"
echo "--------------------------"

echo ""

echo -e "Insira a subrede da sua rede local (Exemplo: 192.168.1.0): "
read DHCPSUBREDE
echo -e "Insira a mascara de subrede da sua rede local (Exemplo: 255.255.255.0): "
read DHCPMASCARA
echo -e "Insira o inicio da faixa de IPs que o servidor DHCP vai entregar aos clientes: "
read DHCPINICIO
echo -e "Insira o final da faixa de IPs: "
read DHCPFINAL
echo -e "Insira o IP de um servidor DNS para a sua rede local: "
read DHCPDNS1
echo -e "Insira o IP do gateway da sua rede local: "
read DHCPGATEWAY

echo -e "#DHCP da subrede $DHCPSUBREDE\n

subnet $DHCPSUBREDE netmask $DHCPMASCARA {\n
range $DHCPINICIO $DHCPFINAL;\n
option subnet-mask $DHCPMASCARA;\n
option domain-name-servers $DHCPDNS1;\n
option routers $DHCPGATEWAY;\n
option netbios-name-servers $DHCPDNS1;\n
get-lease-hostnames true;\n
use-host-decl-names true;\n
default-lease-time 600;\n
max-lease-time 7200;\n
}" >> /etc/dhcp/dhcpd.conf 


#O script vai mostrar as interfaces de rede que ele localizou no sistema para que o usuário escolha a que será a interface de rede para o DHCP.
echo ""
echo "Interfaces de rede detectadas neste host:"
ls -1 /sys/class/net
echo ""
echo "Insira uma das interfaces de rede acima para ser a interface de rede do servidor DHCP: "
read DHCPPLACA
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$DHCPPLACA\"/" /etc/default/isc-dhcp-server

echo ""

echo "--------------------------"
echo "REINICIANDO O SERVICO DHCP"
echo "--------------------------"

sudo systemctl restart isc-dhcp-server

echo ""

#Em algumas vezes em que o serviço foi instalado e configurado no Debian 9, foi preciso reiniciar o computador para que o serviço DHCP pudesse subir normalmente.
echo "Considere reiniciar este host caso o servico DHCP nao tenha iniciado. Em alguns casos, o servico volta a funcionar normalmente depois que o host eh reiniciado."
;;

#Aqui é possível reservar um IP para uma máquina na rede. É recomendado que seja um IP fora da faixa de IPs que o servidor DHCP fornece. O script primeiro verifica se o arquivo dhcpd.conf existe para então continuar com a configuração.
2)
if [ -f "/etc/dhcp/dhcpd.conf" ]; 
then
echo "" >> /etc/dhcp/dhcpd.conf
echo -e "Insira o nome do host: "
read DHCPNOME
echo -e "Insira o MAC Address do host (Exemplo 00:0c:19:bc:2e:e1): "
read DHCPMAC
echo -e "Insira o IP que deseja reservar para o host: "
read DHCPENDERECO

echo -e "host $DHCPNOME {\n
hardware ethernet $DHCPMAC;\n
fixed-address $DHCPENDERECO;\n
}" >> /etc/dhcp/dhcpd.conf

sudo systemctl restart isc-dhcp-server

else
echo "O arquivo /etc/dhcp/dhcpd.conf nao foi encontrado. Talvez o servico DHCP nao foi instalado."
fi
;;

3)
echo "Saindo..."
sleep 2
;;

*)
echo "Opcao invalida"
sleep 2
;;

esac
