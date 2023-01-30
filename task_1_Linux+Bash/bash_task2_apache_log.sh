
# Using Apache log example create a script to answer the following questions:
# 1. From which ip were the most requests?
# 2. What is the most requested page?
# 3. How many requests were there from each ip?
# 4. What non-existent pages were clients referred to?
# 5. What time did site get the most requests?
# 6. What search bots have accessed the site? (UA + IP)



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