#!/bin/bash

printLogo(){
  echo -e """
  =^^=  ### \e[91mALLEYCAT \e[39m###                                                          
  /  |  \e[39mHashcat Automator
?/_\||  
  """
}

checkDir(){
  if [[ ! -d /tmp/hccapx ]];
  then
    mkdir "/tmp/hccapx"
  fi
}

popDir(){
  STRLEN=$(echo -n $DIREC | wc -m)
  LCHAR=${1:$STRLEN-1:1}
  if [[ $LCHAR != / ]]
  then
    DIREC="$DIREC/"
  fi
  HC="cathouse"
  PROC="processed"
  D2="$DIREC$HC"
  D3="$DIREC$PROC"  
  if [[ ! -d "$D2" ]];
  then
    mkdir "$D2"
  fi
  if [[ ! -d "$D3" ]];
  then
    mkdir "$D3"
  fi
  cd /usr/share/hashcat-utils
  for f in $DIREC*
  do
    IFS='/'
    read -ra STRARR <<< "$f"
    FILE="${STRARR[-1]}"
    IFS='.'
    read -ra STRARR <<< "$FILE"
    IFS=' '
    FILE="${STRARR[0]}"
    if [[ $FILE != "cathouse" && $FILE != "processed" ]]
    then
      echo -e "\e[91m[*] \e[39mProcessing \e[30m$FILE\e[39m..."
      ./cap2hccapx.bin "$f" /tmp/hccapx/$FILE.hccapx > /dev/null
      mv "$f" "$D3/$FILE"
    fi
  done
}
hashCrack(){
  for f in /tmp/hccapx/*
  do
    IFS='/'
    read -ra STRARR <<< "$f"
    FILE="${STRARR[-1]}"
    IFS='.'
    read -ra STRARR <<< "$FILE"
    IFS=' '
    FILE="${STRARR[0]}"
    if [[ "$FILE" != "log" ]]
    then
      echo -e "\e[32m[*] \e[39mCracking \e[31m$FILE\e[39m... [\e[30m"$LOUD"\e[39m]"
      if [[ "$LOUD" == "LOUD" ]]
      then
        hashcat -m 2500 -a 0 "$f" -o "$D2/$FILE.txt" "$WORDLIST" 
      else
        hashcat -m 2500 -a 0 "$f" -o "$D2/$FILE.txt" "$WORDLIST" &>> /tmp/hccapx/log
      fi
    fi
    echo -e "\e[32m[*] \e[31m$FILE \e[39mfinished!"
    rm $f
  done
}
if [[ $EUID -ne 0 ]];
then
  echo "This script must be run as root!"
  exit 1
else
  if [[ $(pgrep hashcat) != "" ]]
  then
      echo "Hashcat already running! Please kill the process and try again."
      exit 1
  fi
  if [[ -z $1 ]]
  then
    DIREC="$HOME"
  else
    if [[ $1 != "loud" ]]
    then
      DIREC=$1
    else
      LOUD="LOUD"
      DIREC="/home/$USER/hs"
    fi
  fi

  if [[ -z $2 ]]
  then
    WORDLIST="/usr/share/wordlists/rockyou.txt"
  else
    if [[ $2 != "loud" ]]
    then
      WORDLIST=$2
    else
      LOUD="LOUD"
      WORDLIST="/usr/share/wordlists/rockyou.txt"
    fi
  fi
  
  if [[ "$3" == "loud" ]]
  then
    LOUD="LOUD"
  fi
  ORIGDIR=$(pwd)
  if [[ -z $LOUD ]]
  then
    LOUD="QUIET"
  fi
  printLogo
  checkDir
  popDir
  cd "$ORIGDIR"
  hashCrack 
fi
