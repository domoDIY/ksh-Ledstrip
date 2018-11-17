#!/bin/bash
#####################################################################################
#                                                                                   #
# Script created by dresder for domotique DIY                                       # 
# The script purpose is to vary PWM levels on 3 GPIO to create color change effects #
# https://domotique-diy.home.blog/2018/11/15/ledstrip-rgb-raspberry-pi/             #
# Contact : dresder@gmail.com                                                       #
#                                                                                   #
#    This program is free software: you can redistribute it and/or modify           #
#    it under the terms of the GNU General Public License as published by           #
#    the Free Software Foundation, either version 3 of the License, or              #
#    (at your option) any later version.                                            #
#                                                                                   #
#    This program is distributed in the hope that it will be useful,                #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
#    GNU General Public License for more details.                                   #
#                                                                                   #
#    You should have received a copy of the GNU General Public License              #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>          #
#                                                                                   #
#####################################################################################

ARGUMENTS=$* 

## KILL EXISTING INSTANCE OF THE SCRIPT RUNNING 
PID_TO_KILL=`ps -edf | grep Generic_Led | grep -v grep | grep -v $$ | awk '{print $2}'`
if [ "${PID_TO_KILL}" != "" ]
        then
        kill -9 ${PID_TO_KILL}
fi      

TIME=0.1 ## TIME INTERVAL BETWEEN EACH LOOP 
LOOPS=500000 ## NUMBER OF LOOPS 
RED_PIN=27 ## GPIO PIN FOR RED CHANEL 
GREEN_PIN=17 ## GPIO PIN FOR GREEN CHANEL 
BLUE_PIN=22 ## GPIO PIN FOR BLUE CHANEL 

RED_STEP=2 ## STEPS TO INCR RED - COLOR STEPS SHOULD BE DIFFERENT TO GET ALL COLORS 
GREEN_STEP=3 ## STEPS TO INCR GREEN - COLOR STEPS SHOULD BE DIFFERENT TO GET ALL COLORS 
BLUE_STEP=5 ## STEPS TO INCR BLUE - COLOR STEPS SHOULD BE DIFFERENT TO GET ALL COLORS 

## THE BELOW WORKING VARIABLES ARE INITIALISED BUT SHOULD NOT BE CHANGED 
RED_LEVEL=0 
GREEN_LEVEL=0 
BLUE_LEVEL=0 
RED_WAY="UP" 
GREEN_WAY="UP" 
BLUE_WAY="UP" 

LoadInputParameters () 
{ 
while [ $# -gt 0 ] 
do 
	KEY_PARAM=$1 
	VALUE_PARAM=$2 
	case ${KEY_PARAM} in 
		-T | -TIME ) 
		TIME=${VALUE_PARAM} 
		;; 
		-L | -LOOPS ) 
		LOOPS=${VALUE_PARAM} 
		;; 
		-RS | -RED_STEP ) 
		RED_STEP=${VALUE_PARAM} 
		;; 
		-BS | -BLUE_STEP ) 
		BLUE_STEP=${VALUE_PARAM} 
		;; 
		-GS | -GREEN_STEP ) 
		GREEN_STEP=${VALUE_PARAM} 
		;; 
	esac 
	shift 
done 
} 

LoadInputParameters ${ARGUMENTS} 

while [ $LOOPS -gt 0 ] 
do 
	## SET PWM VALUE FOR EACH COLOR
	pigs p ${RED_PIN} ${RED_LEVEL} 
	pigs p ${GREEN_PIN} ${GREEN_LEVEL} 
	pigs p ${BLUE_PIN} ${BLUE_LEVEL} 
	sleep $TIME 
	
	## CHANGE RED PWM VALUE
	if [ $RED_WAY = "UP" ] 
		then RED_LEVEL=$(($RED_LEVEL + ${RED_STEP})) 
		if [ $RED_LEVEL -gt 255 ] 
			then RED_WAY="DOWN" 
		fi 
	fi 
	
	if [ $RED_WAY = "DOWN" ] 
		then RED_LEVEL=$(($RED_LEVEL - ${RED_STEP})) 
		if [ $RED_LEVEL -lt 0 ] 
			then RED_WAY="UP" 
		RED_LEVEL=$(($RED_LEVEL + ${RED_STEP})) 
		fi 
	fi 
	
	## CHANGE BLUE PWM VALUE
	if [ $BLUE_WAY = "UP" ] 
		then BLUE_LEVEL=$(($BLUE_LEVEL + ${BLUE_STEP})) 
		if [ $BLUE_LEVEL -gt 255 ] 
			then BLUE_WAY="DOWN" 
		fi 
	fi 
	
	if [ $BLUE_WAY = "DOWN" ] 
		then BLUE_LEVEL=$(($BLUE_LEVEL - ${BLUE_STEP})) 
		if [ $BLUE_LEVEL -lt 0 ] 
			then BLUE_WAY="UP" BLUE_LEVEL=$(($BLUE_LEVEL + ${BLUE_STEP})) 
		fi 
	fi 
	
	## CHANGE GREEN PWM VALUE
	if [ $GREEN_WAY = "UP" ] 
		then GREEN_LEVEL=$(($GREEN_LEVEL + ${GREEN_STEP})) 
		if [ $GREEN_LEVEL -gt 255 ] 
			then GREEN_WAY="DOWN" 
		fi 
	fi 
	
	if [ $GREEN_WAY = "DOWN" ] 
		then GREEN_LEVEL=$(($GREEN_LEVEL - ${GREEN_STEP}))
		if [ $GREEN_LEVEL -lt 0 ] 
			then GREEN_WAY="UP" GREEN_LEVEL=$(($GREEN_LEVEL + ${GREEN_STEP})) 
		fi 
	fi 
	
	LOOPS=$(($LOOPS - 1)) 
done 

## RESET THE RGB PINS TO 0 IN ORDER TO SWITCH OFF THE LIGHT 
pigs p ${RED_PIN} 0 
pigs p ${GREEN_PIN} 0 
pigs p ${BLUE_PIN} 0

