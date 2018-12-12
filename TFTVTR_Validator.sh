#!/bin/bash
#Daniel Uzcátegui
#Telos-Venezuela
SAAV=0
TECLOS=teclos
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function validation {
while IFS=, read -r col1 col2 col3
do
echo "Validating that account = " $col1   "exists"
$TECLOS get account $col1 -j | jq -r  '.account_name , .permissions[0].required_auth.keys[].key , .total_resources.net_weight , .total_resources.cpu_weight' | perl -00 -lpe 's/\n/,/g' |  sed "s/ TLOS//g" >> val.csv
done < $CSV
sed '/^$/d' val.csv > val2.csv

while IFS=, read -r col1 col2 col3 col4
do
val=$( bc <<< "$col3 + $col4 + $ADJ")
echo "${col1},${col2},${val}" >> val3.csv
done < val2.csv

value=$(diff val3.csv $CSV)

if [[ -z "${value}" ]]; then 
echo -e  "${GREEN}TFRP Validation succesful${NC}";
let SAAV=$SAAV+1
else
echo -e "${RED}TFRP Validation unsuccesful printing diff output${NC}";
echo -e $RED
diff val3.csv $CSV
echo -e $NC

fi;
rm val2.csv val.csv val3.csv
}

function get {


wget https://raw.githubusercontent.com/Telos-Foundation/snapshots/master/tfrp_accounts.csv
wget https://raw.githubusercontent.com/Telos-Foundation/snapshots/master/tcrp_accounts.csv
wget https://raw.githubusercontent.com/Telos-Foundation/snapshots/master/tfvt_accounts.csv

transform;
}

function transform {
tail -n +2 tfrp_accounts.csv > tfrp_accounts.csv2
mv tfrp_accounts.csv2 tfrp_accounts.csv
tail -n +2 tcrp_accounts.csv > tcrp_accounts.csv2
mv tcrp_accounts.csv2 tcrp_accounts.csv

tail -n +2 tfvt_accounts.csv > tfvt_accounts.csv2
cut -c 3- tfvt_accounts.csv2 > tfvt_accounts.csv
awk -F',' -v OFS=',' '$3="10.0000"' tfvt_accounts.csv > tfvt_accounts.csv2
mv tfvt_accounts.csv2 tfvt_accounts.csv

}


function celebrate {

if [[  "${SAAV}" -eq "3"  ]]; then
echo "                                                              ,,,,,,.........                     
                                                              (#############(                      
                                                             ##############(                       
                          ,,,,,,,.....,,...                 #%%###########/                        
                        /(/,,,,,,*******************///////////////######*                         
                      /((#(,,,,,,,******************////////////////(#%#/                          
                    (((((##,,,,,,********************/*********///////%,                           
                  /(((((((#*,,,,,*,****************,,,,,***********////.                           
               ./((((((((##/,,,,,,,**********,,.,,,,,,,,,,,,********////*                          
               ./((((((((##(,,,,,,,******,..........,,,,,,,,,,,,,***//////                         
                .((((((((###,,,,,,*,,.    ...............,,,,,,,,,,,*//////,                       
                 .(((((((###,,,,.             ...............,,,,,,,,//******                      
                  /%%%%%%%%%/*,..                  ..............,,,,*********.                    
                   /%%%%%%%%(((((((((((((##((((//**,.................,*********,                   
                    (%%%%%%%(((((((((((((((((((//////////. ...........***********                  
                     #%%%%%%(((((((((((((((((/////////////*     ......,***********,                
                   *%%%%%%%%((((((((((((((//////////////////,       ...************,               
                 /####%%%#%%/(((((((((((////////////////////((.        **************.             
                 (#######%%%///////////////////////////////((((*       ,***********,,,,            
                 (##########///////////////////////////////((((((.     .*******,,,,,,,,,           
                 (##########///////////////////////////////(((((((/     ,*,,,,,,,,,,,,,,/.         
                 (##########///////////////////////////////(((((((((.   ,,,,,,,,,,,,*(##(          
                 (##########*/////////////////////////////((((((((((((. .,,,,,,,,/(((###*          
                 (#########(//////////////////////////////(((((((((((((* ,,,,*(((((((###           
                 (#########(*/////////////////////////////(((((((((((((((*/(((((((((###/           
                 (#########(////*//////////////////////////(((((((((((#%#%%(((((((((###.           
                 (#########/******//////////////////////////((((((((#%#%#%%%((((((((##(            
                 /#########/*********/////////////////////////(((#######%%%%%%((((((##*            
                  #########/**************/*/////////////////(##########%%%%%%#/,.                 
                  .########/**************////////////////(############*                           
                   *#######*******************//////////###############.                           
                    (#((((#*********************/**/*##################                            
                    .((((((***********************(#################(.                             
                     ,(((((********************(########((#######(.                                
                      /((((*****************(##########(((((#((.                                   
                       ((((**************(((###########(((((.                                      
                       .(((***********/(((((###########((.                                         
                        *(/********/((((((((#######(/*.                                            
                         //*****/((((((((((/*.                                                     
                         ./**/(((//*.                                                              
                           .                                                                       
                                                                                                   
                                                                                                   
                                                                                                   ";
fi

}




get;
CSV=tfrp_accounts.csv
ADJ=10.0000
validation "$@";
CSV=tcrp_accounts.csv
ADJ=-1
validation "$@";
CSV=tfvt_accounts.csv
ADJ=0
validation "$@";


rm tfrp_accounts.csv tcrp_accounts.csv tfvt_accounts.csv
celebrate;
