#Create a data backup script that takes the following data as parameters:
#1. Path to the syncing directory.
#2. The path to the directory where the copies of the files will be stored.
#In case of adding new or deleting old files, the script must add a corresponding entry to the log file
#indicating the time, type of operation and file name. [The command to run the script must be added to
#crontab with a run frequency of one minute]
#


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

# Check count of parametrs,  if catalog exists and run backup
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