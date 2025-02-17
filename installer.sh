#!/bin/bash
#
# __author__     : @mrblackx
# __version__    : v1.4
# __description__: burpsuite pro setup
# __support__    : https://t.me/burp_chat
# __burpsuite__  : v2020.11.3
# __changelog__  : Changed Functions & Added xterm Package Check

r="\e[31m"
g="\e[32m"
y="\e[33m"
b="\e[34m"
m="\e[35m"
c="\e[36m"
w="\e[37m"
bl="\e[1m"
rs="\e[0m"
path=$(pwd)
ueuid=$(cat /etc/passwd | grep "$USER" | cut -d":" -f3)



banner(){
	figlet -f slant "BurpSuite";figlet -f slant "Installer"
	echo -e "\t\t\t\t    ${r}@mrblackx\n\n\n\n"
}


run(){
	for i in {1..3}
	do
		echo -ne "${l:0:$i}";sleep 0.1
	done
}

main(){
	echo -e "${bl}${b}[${g}*${b}] ${w}I will start Burpsuite, all you have to do is activate it manually.\nAfter activation, you can go back here and i will make the rest."
	xterm -e java -javaagent:BurpSuiteLoader_v2020.11.3.jar -noverify -jar burpsuite_pro_v2020.11.3.jar &
	xterm -e java -jar burploader-old.jar &
	echo -ne "${bl}${b}[${g}*${b}] ${w}Hit enter if you have activated the burpsuite correctly> "
	read enter
	ps aux | grep xterm | sed 's/   / /g' | cut -d\  -f2 | head -n2 | xargs kill -9 &>/dev/null
	ls *.burp &>/dev/null
	if [ $? -eq 0 ]; then
		echo -ne "${bl}${b}[${g}*${b}] ${w}Finishing setup"; run
		laste=$(cat ~/.bashrc | tail -1)
		path=$(pwd)
		if [[ "${laste}" == "alias burpy='cd ${path}; java -javaagent:BurpSuiteLoader_v2020.11.3.jar -noverify -jar burpsuite_pro_v2020.11.3.jar&'" ]]; then
			echo -e "\n${bl}${b}[${g}*${b}] ${w}Already setuped as ${g}burpy ${w}command."
			fix_errors
		else
			echo -e "\n${bl}${b}[${g}*${b}] ${w}Adding ${g}burpy ${w}command."
			echo -e "alias burpy='cd ${path}; java -javaagent:BurpSuiteLoader_v2020.11.3.jar -noverify -jar burpsuite_pro_v2020.11.3.jar&'" >> ~/.bashrc
			fix_errors
		fi
	elif [ $? -eq 2 ]; then
		echo -e "${bl}${b}[${r}!${b}] ${w}You didn't followed the instructions, can't find burp project file!"
		exit 1
	fi
}

file_check(){
	i=0
	if [ -f BurpSuiteLoader_v2020.11.3.jar ]; then
		echo -e "${bl}${b}[${g}✓${b}] ${w}Found ${c}BurpSuiteLoader_v2020.11.3.jar"
		i=$(( $i + 1 ))
	elif [ ! -f BurpSuiteLoader_v2020.11.3.jar ]; then
		echo -e "${bl}${b}[${r}✗${b}] ${w}Not found ${c}BurpSuiteLoader_v2020.11.3.jar"
		exit 1
	fi
	if [ -f burploader-old.jar ]; then
		echo -e "${bl}${b}[${g}✓${b}] ${w}Found ${c}burploader-old.jar"
		i=$(( $i + 1 ))
	elif [ ! -f burploader-old.jar ]; then
		echo -e "${bl}${b}[${r}✗${b}] ${w}Not found ${c}burploader-old.jar"
		exit 1
	fi
	if [ -f burpsuite_pro_v2020.11.3.jar ]; then
		echo -e "${bl}${b}[${g}✓${b}] ${w}Found ${c}burpsuite_pro_v2020.11.3.jar"
		i=$(( $i + 1 ))
	elif [ ! -f burpsuite_pro_v2020.11.3.jar ]; then
		echo -e "${bl}${b}[${r}✗${b}] ${w}Not found ${c}burpsuite_pro_v2020.11.3.jar"
		exit 1
	fi

	if [ "${i}" -eq 3 ]; then
		main
	else
		echo -e "${bl}${b}[${r}✗${b}] ${w}Sorry, some files are missing and i can't continue!"
		exit 1
	fi
}

getinfo(){
	l="."
	
	cmd=$(apt list --installed ${item} | grep -o "installed\|installed" &>/dev/null)
	packets=(openjdk-14-dbg openjdk-14-demo openjdk-14-doc openjdk-14-jdk openjdk-14-jdk-headless openjdk-14-jre openjdk-14-jre-zero openjdk-14-source)
	for item in ${packets[@]}
	do
		if ! ${cmd}; then
			echo -ne "${bl}${b}[${r}!${b}] ${w}Package ${r}${item} ${w}not found.\nInstalling it for you"; run
			sudo apt install ${item} -y
		fi
	done
	os=$(uname -s) # temp | no use
	dis=$(uname -s) # temp | no use
	file_check
}


fix_errors(){
	echo -e "\n${bl}${b}[${g}*${b}] ${w}Fixing common errors, please give root password if required."
	sudo sysctl -w kernel.unprivileged_userns_clone=1
	x=$(java --version | head -1 | cut -d\  -f2 | cut -d"." -f1)
	if [[ "${x}" == "14" ]]; then
		echo -e "${bl}${b}[${g}*${b}] ${w}Up-To-Date."
	else
		echo -e "${bl}${b}[${g}*${b}] ${w}Re-Fixing";run
		getinfo
	fi
}

check(){
	clear;banner
	if [[ "${EUID}" == 0 ]]; then
		echo -e "${bl}${b}[${r}!${b}] ${w}Warning!\n\nYou are running this script as ${r}root ${w}user.\nNormally this has ${r}no influence${w}, but please be careful and enter the super-user password manually."; sleep 0.5
		echo -ne "${bl}${b}[${y}?${b}] ${w}Do you want to start anyway?[${g}Y${w}/${r}N${w}]:${b} "
		read t
		if [[ "${t}" == "y" || "${t}" == "Y" ]]; then
			xterm=$(which xterm)
			if [[ "${xterm}" == "" ]]; then
				echo -e "${bl}${b}[${r}!${b}] ${g}xterm ${w}is not installed yet, let me install.${y}"
				sudo apt install xterm -y
				getinfo
			elif [[ "${xterm}" == "/usr/bin/xterm" ]]; then
				echo -e "${bl}${b}[${g}*${b}] ${g}xterm ${w}found, continue";run
				getinfo
			fi
		elif [[ "${t}" == "n" || "${t}" == "N" ]]; then
			exit 1
		fi
	elif [[ "${ueuid}" == 1000 ]]; then
		echo -e "${bl}${b}[${g}*${b}] ${w}Well you are running the script as common user, please wait."; sleep 0.5
		xterm=$(which xterm)
			if [[ "${xterm}" == "" ]]; then
				echo -e "${bl}${b}[${r}!${b}] ${g}xterm ${w}is not installed yet, let me install.${y}"
				sudo apt install xterm -y
				getinfo
			elif [[ "${xterm}" == "/usr/bin/xterm" ]]; then
				echo -e "${bl}${b}[${g}*${b}] ${g}xterm ${w}found, continue";run
				getinfo
			fi
	fi

}



check
