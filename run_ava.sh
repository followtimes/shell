#!/bin/bash

AVA_PY_FILE=$(pwd)'/available.py'
AVA_RST_FILE=$(pwd)'/mail_ava_rst'
AVA_BACK_FILE=$(pwd)'/mail_static_rst'

echo '--- mail avaliable ---' >> ${AVA_RST_FILE}
echo $(date +%Y-%m-%d -d '-1days') >> ${AVA_RST_FILE}
python ${AVA_PY_FILE} >> ${AVA_RST_FILE}
echo '-----------------------' >> ${AVA_RST_FILE}

DATE_JUDE=$(date +%Y-%m-%d)
computing_cycle=$(cat $AVA_RST_FILE | grep '\.' | wc -l)

if [ $(echo $DATE_JUDE | awk -F '-' '{print $3}') -eq '01'  ] 
then
   sum=0.000
   for i in $(cat ${AVA_RST_FILE} | grep '\.') 
       do  sum=$(echo "$i + $sum " | bc)
   done  
   echo "**** $(date +%Y-%m -d '-1days') mail average ***" >> ${AVA_BACK_FILE}
   echo "$(date +%Y-%m-%d) compute ${computing_cycle} days data :" >> ${AVA_BACK_FILE}
   echo "scale=4 ; $sum / ${computing_cycle}" | bc >> ${AVA_BACK_FILE}
   echo "************************" >> ${AVA_BACK_FILE}
   echo "" > ${AVA_RST_FILE}
fi

