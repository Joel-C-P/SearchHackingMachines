#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c()
{
  echo -e "\n\n${redColour}[!] Getting out ....${endColour}\n"
  tput cnorm && exit 1
  
}


trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"





function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"

  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios${endColour}"  
  
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de maquina${endColour}"  

  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por dificultad de la maquina${endColour}"

  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por Sistema Operativo${endColour}"

  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por Skill${endColour}"

  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por direccion IP${endColour}"  
  
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de youtube${endColour}" 

  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}\n"  
}



function update_Files(){
  

  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else
    tput civis

    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}\n"

    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han detectado actualizaciones, lo tienes todo al dia${endColour}"

      rm -rf bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones pendientes${endColour}"
      sleep 1

      rm -rf bundle.js && mv bundle_temp.js bundle.js

      echo  -e "\n${yellowColour}[+]${endColour} ${grayColour}Los archivos han sido actualizados${endColour}"
    fi

    tput cnorm

  fi

}

function searchMachine(){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then

    echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina${endColour} $machineName ${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d "," | sed 's/^ *//'

  else
    echo -e "\n ${redColour}[!] La maquina no existe o esta mal escrito${endColour}\n"
  fi    
}



function searchIP(){

  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ",")"

  if [ "$machineName" ]; then  
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La maquina del IP:${endColour} ${blueColour}$ipAddress${endColour} es ${redColour}$machineName${endColour}"
  else
    
    echo -e "\n ${redColour}[!] La IP es incorrecta o no existe${endColour}\n"
    
  fi

  
}

function getYoutubeLink(){
  #cat bundle.js | awk "/name: \"Tentacle\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | sed 's/^ *//' | grep "youtube" | awk 'NF{print $NF}'
  
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | sed 's/^ *//' | grep "youtube" | awk 'NF{print $NF}')"
  
    if [ $youtubeLink ]; then


      echo -e "\n ${yellowColour}[+] ${endColour}EL turorial para esta maquina esta en este enlace:${purpleColour} $youtubeLink ${endColour}\n"

    else
      
      echo -e "\n ${redColour}[!] La Maquina no existe o esta mal escrito${endColour}\n"
    fi
}

function getMachinesDifficulty(){

  machineName="$1"

  results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)" 

  if [ "$results_check" ]; then

    echo -e "\n ${yellowColour}[+] ${endColour}Representando las maquinas que poseen una dificultad: $difficulty :\n"
  

    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column

  else
  
    
    echo -e "\n ${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi


}

function getOSMachines(){

  os=$1

  os_results="$(cat bundle.js | grep "so: \"Linux\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)" 


  if [ "$os_results" ]; then
  
    echo -e "\n ${yellowColour}[+]${endColour} Mostrando las maquinas cuyo sistema operativo es $os\n\n"
  
    
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column    
  
  else

    echo -e "\n Ese SO no existe o no esta contemplado"
    
  fi
}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"

  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$check_results" ]; then
    echo -e "\n [+] Listando maquinas de dificultad $difficulty que tengan sistema operativo $os\n"

    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n ${redColour}[!] Se ha indicado uan dificultad o sistema operativo inccorecto${endColour}\n "
  fi

}

function getSkill(){

  skill="$1"

  check_skill="$(cat bundle.js | grep "skill" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"

  if [ "$check_skill" ]; then

    echo -e " [+] Las siguientes maquinas usan la skill: $skill"
     
    cat bundle.js | grep "skill" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column

  else
    echo -e "\n ${redColour}[!] La siguiente skill no existe o esta mal escrita ${endColour}\n"

  fi
}
# Indicadores
declare -i parameter_counter=0 
#Chivatos
declare -i chivato_difficulty=0 
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do 

  case $arg in 
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done 

if [ $parameter_counter -eq 1 ]; then
 searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  update_Files
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress


elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName

elif [ $parameter_counter -eq 5 ]; then 

  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then

  getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then

    getSkill "$skill"

elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then 
  getOSDifficultyMachines $difficulty $os

else 
  helpPanel
  
fi


