#!/bin/bash



##### Constants
waittime=0
starttime=$(date +%s)
starttimepretty=$(date)
GREEN='\033[0;32m'
NOCOLOR='\033[0m'



##### Logic
if [ "$1" != "" ]; then
    echo "Grabbing urls from sitemap.xml ..."
    curl -s $1 | xmllint --format - | grep "<loc>" | sed -e 's/\<[\/]*loc\>//g;s/^ *//g' > sitemap.txt
    lines=`wc -l < ./sitemap.txt | awk '$1=$1'`
    echo -e "... sitemap.txt created with ${GREEN}$lines${NOCOLOR} entries."

    echo "Pre-cleaning spider_log file.";
    cp /dev/null ./spider_log

    echo "Spidering URLS for issues, please wait ..."
    ### wget --spider -i ./sitemap.txt -o ./spider_log --show-progress -w $waittime
    cat sitemap.txt | parallel --jobs 200% --gnu "wget --spider -nv -a ./spider_log"
    echo "... spider complete."

    echo "Cleaning up log, looking for errors ...";
    awk -v ORS='\n' '!/200 OK/' ./spider_log > ./error_log
    errorCount=`wc -l < ./error_log | awk '{print $1/2}'`
    echo -e "... ${GREEN}$errorCount${NOCOLOR} errors found. Check spider_log file."

    echo -e "Start Time: ${GREEN}$starttimepretty${NOCOLOR}"
    endtime=$(date +%s) && endtimepretty=$(date)
    echo -e "End Time: ${GREEN}$endtimepretty${NOCOLOR}"
    timediff=$((endtime-starttime))
    echo -e "Elapsed Time: ${GREEN}$(($timediff / 60)) minutes and $(($timediff % 60)) seconds.${NOCOLOR}"
else
    echo "Enter full URL to sitemap as script parameter."
fi
