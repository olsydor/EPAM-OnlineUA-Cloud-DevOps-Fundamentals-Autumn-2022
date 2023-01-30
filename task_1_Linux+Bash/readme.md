# Linux administration with bash. Home task

### Task 1_1 
### Create a script that uses the following keys:
1. When starting without parameters, it will display a list of possible keys and their description.
2. The --all key displays the IP addresses and symbolic names of all hosts in the current subnet
3. The --target key displays a list of open system TCP ports. The code that performs the functionality of each of the subtasks must be placed in a separate function


```
f_showhelp(){
  echo "";
  echo "###############";
  echo "======================";
  echo "script made by Oleksandr Sydor";
  echo "======================";
  echo "List of possible keys and their description";
  echo "--all , --target";
  echo "-all key displays the IP addresses and symbolic names of all hosts in the current subnet. For fast scan type --all fast";
  echo "--target key displays a list of open system TCP ports. Use --target IP";
  echo "###############";
}
f_showallhost(){
  rm ip.txt 2>/dev/null
  net_mask=$(ip a | grep "global" | cut -d ' ' -f 6 | cut -d '/' -f 2)
  host_ip=$(ip a | grep "global" | cut -d ' ' -f 6 | cut -d '/' -f 1 | cut -d '.' -f 4)
  host_network=$(ip a | grep "global" | cut -d ' ' -f 6 | cut -d '/' -f 1 | cut -d '.' -f 1,2,3)
  if [[ $net_mask -ge 24 && $net_mask -le 26 ]]; then
    if [[ $net_mask -eq 24 ]]; then
      start_ip="1"
      end_ip="254";
    elif [[ $net_mask -eq 25 ]]; then
      if [[ $host_ip -le 127 ]]; then
        start_ip="1";
        end_ip="126";
      else
        start_ip="128";
        end_ip="254";
      fi
    else
      if [[$host_ip -le 63]]; then
        start_ip="1";
        end_ip="62";
      elif [[ $host_ip -le 127 ]]; then
        start_ip="65";
        end_ip="126";
      elif [[ $host_ip -le 191 ]]; then
        start_ip="129";
        end_ip="190";
      else
        start_ip="193";
        end_ip="254";
      fi
    fi
  else
    echo "Network is too big or too small. Script allow to scan network with mask 24-26"
    exit 0
  fi
  case $1 in
    "fast" )
      for (( i=$start_ip; i<=$end_ip; i++))
      do
        #if [[ $(ping "$host_network.$i"  -c 1 | grep ttl | cut -d " " -f 4 | cut -d ":" -f 1 & ) ]];then
        #  echo "$host_network.$i"
        #  echo "$host_network.$i" >> ip.txt
        #fi
        ping "$host_network.$i"  -c 1 | grep ttl | cut -d " " -f 4 | cut -d ":" -f 1 >> ip.txt &
      done;;

    * )
      for (( i=$start_ip; i<=$end_ip; i++))
      do
        if [[ $(ping "$host_network.$i" -c 1 | grep ttl ) ]];then
          echo "$host_network.$i"
          echo "$host_network.$i" >> ip.txt
        fi
      done;;
  esac
}

f_showopenports(){
# check if file with ip address exists and it isn't  empty
  if [[ -f "ip.txt" && $(wc ip.txt -l | cut -d " " -f 1) -gt 1 ]];then
    if [[ $(dpkg --get-selections | grep netcat) ]];then
      while read  ip; do
        echo $ip
        while read  port; do
          nc -zvw1 $ip $port 2> /dev/null
          if [[ $? = 0 ]]; then
            echo "Port $port is open"
#          else
#            echo "Port $port is closed"
          fi
        done < ports.txt
      done < ip.txt
    else
      echo "To scan open port you need to install netcat utility."
    fi
  else
    echo "First you need to run script with (--all) or (--all fast) parament to scan network for available ip address"
  fi
}

case $1 in
  "--all" )
    if [[ $2 ]]; then
      f_showallhost $2
    else
      f_showallhost
    fi;;

  "--target" )
    f_showopenports;;

  * )
    f_showhelp;;
esac
```


### Task 1 2 
### Using Apache log example create a script to answer the following questions:

1. From which ip were the most requests?
2. What is the most requested page?
3. How many requests were there from each ip?
4. What non-existent pages were clients referred to?
5. What time did site get the most requests?
6. What search bots have accessed the site? (UA + IP)
```
f_show_from_wich_ip_most_request(){
  requests_ip_uniq=$(cat apache_logs | cut -d " " -f 1 | sort | uniq )
  ip_max=0
  count_max=0
  for ip in $requests_ip_uniq
  do
    count=$( cat apache_logs | cut -d " " -f 1 | sort | grep $ip | wc -l)
    if [[ $count -gt $count_max ]]; then
      count_max=$count
      ip_max=$ip
    fi
  done
  echo "Max requests from IP : $ip_max - $count_max"
}

f_show_most_request_page(){
  echo "Max requests page : "
  awk {'print $7 "\t" $11'} apache_logs | sort | uniq -c | sort -n | tail -n 1
}

f_count_all_uniq_ip_request(){
  echo "How many requests were there from each ip?"
  awk {'print $1'} apache_logs | sort | uniq -c | sort -n
}

f_non-existent_pages(){
  echo "What non-existent pages were clients referred to";
  cat example_log | grep 404 | awk {'print $7 "\t" $11'} | sort | uniq
}

#1
f_show_from_wich_ip_most_requesty
#2
f_show_most_request_page
#3
f_count_all_uniq_ip_request
#4
f_non-existent_pages
```

### Task 1_3
### Create a data backup script that takes the following data as parameters:
1. Path to the syncing directory.
2. The path to the directory where the copies of the files will be stored. In case of adding new or deleting old files, the script must add a corresponding entry to the log file indicating the time, type of operation and file name. [The command to run the script must be added to crontab with a run frequency of one minute]

```
f_create_backup(){
  sourse_files=$( ls $1 )
  dest_files=$( ls $2 )
  log="$2/log"
  for src_file_name in  $sourse_files;
  do
    dest_temp="$2/$src_file_name"
    if [[ -f $dest_temp ]]; then
      cur_date=$( date )
      echo "File $src_file_name repalced $cur_date" >> $log
      cp "$1/$src_file_name" "$2/$src_file_name" 1> /dev/null
    else
      cur_date=$( date )
      echo "File $src_file_name add $cur_date" >> $log
      cp "$1/$src_file_name" "$2/$src_file_name" 1> /dev/null
    fi
  done
  for dest_file_name in $dest_files;
  do
    if [[ $dest_file_name != "log" ]]; then
      if [[ -z $( echo $sourse_files | grep $dest_file_name) ]];then
        rm -f "$2/$dest_file_name"
        echo "File $dest_file_name delete $cur_date" >> $log
      fi
    fi
  done
}

#Check count of parametrs,  if catalog exists and run backup
if [[ ${#} -ge 2 ]]; then
  ls $1 > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    ls $2 > /dev/null  2>&1
    if [[ $? -eq 0 ]]; then
      f_create_backup $1 $2
    else
      echo "Wrong destination catalog. Check if catalog exists!"
    fi
  else
    echo "Wrong sourse catalog. Check if catalog exists!"
  fi
else
  echo "You must enter two catalog path - source and destination without / in the end"
fi
```