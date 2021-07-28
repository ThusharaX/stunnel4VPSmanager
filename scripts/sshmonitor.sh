#!/bin/bash
clear
database="/root/usuarios.db"
fun_drop () {
port_dropbear=`ps aux | grep dropbear | awk NR==1 | awk '{print $17;}'`
log=/var/log/auth.log
loginsukses='Password auth succeeded'
clear
pids=`ps ax |grep dropbear |grep  " $port_dropbear" |awk -F" " '{print $1}'`
for pid in $pids
do
    pidlogs=`grep $pid $log |grep "$loginsukses" |awk -F" " '{print $3}'`
    i=0
    for pidend in $pidlogs
    do
      let i=i+1
    done
    if [ $pidend ];then
       login=`grep $pid $log |grep "$pidend" |grep "$loginsukses"`
       PID=$pid
       user=`echo $login |awk -F" " '{print $10}' | sed -r "s/'/ /g"`
       waktu=`echo $login |awk -F" " '{print $2"-"$1,$3}'`
       while [ ${#waktu} -lt 13 ]; do
           waktu=$waktu" "
       done
       while [ ${#user} -lt 16 ]; do
           user=$user" "
       done
       while [ ${#PID} -lt 8 ]; do
           PID=$PID" "
       done
       echo "$user $PID $waktu"
    fi
done
}
echo -e "\E[44;1;37m Usuario         Status       Conexão     Tempo   \E[0m"
echo ""
echo ""
 while read usline
    do
        user="$(echo $usline | cut -d' ' -f1)"
        s2ssh="$(echo $usline | cut -d' ' -f2)"
        sqd="$(ps -u $user | grep sshd | wc -l)"
        if [[ -e /etc/openvpn/openvpn-status.log ]]; then
        ovp="$(cat /etc/openvpn/openvpn-status.log | grep -E ,"$user", | wc -l)"
        else
        ovp=0
        fi
        if netstat -nltp|grep 'dropbear'> /dev/null;then
        drop="$(fun_drop | grep "$user" | wc -l)"
        else
        drop=0
        fi
        cnx=$(($sqd + $drop))
        conex=$(($cnx + $ovp))
        if [[ $cnx -gt 0 ]]; then
        timerr="$(ps -o etime $(ps -u $user |grep sshd |awk 'NR==1 {print $1}')|awk 'NR==2 {print $1}')"
        elif [[ $ovp -gt 0 ]]; then
        timerr="--:--"
        else
        timerr="00:00"
        fi
        if [[ $conex -eq 0 ]]; then
           status=$(echo -e "\033[1;31mOffline \033[1;33m       ")
           echo -ne "\033[1;33m"
           printf '%-17s%-14s%-10s%s\n' " $user"      "$status" "$conex/$s2ssh" "$timerr" 
        else
           status=$(echo -e "\033[1;32mOnline\033[1;33m         ")
           echo -ne "\033[1;33m"
           printf '%-17s%-14s%-10s%s\n' " $user"      "$status" "$conex/$s2ssh" "$timerr"
        fi
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    done < "$database"
