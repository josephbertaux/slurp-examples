#!/usr/bin/bash

nevents=${1}
outbase=${2}
logbase=${3}
runnumber=${4}
segment=${5}
outdir=${6}
build=${7/./}
dbtag=${8}
inputs=(`echo ${9} | tr "," " "`)  # array of input files 
ranges=(`echo ${10} | tr "," " "`)  # array of input files with ranges appended
logdir=${11:-.}
histdir=${12:-.}
{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}
hostname

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${7}

export ODBCINI=./odbc.ini

#______________________________________________________________________________________ started __
#
./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started
#_________________________________________________________________________________________________

echo ..............................................................................................
echo $@
echo .............................................................................................. 
echo nevents: $nevents
echo outbase: $outbase
echo logbase: $logbase
echo runnumb: $runnumber
echo segment: $segment
echo outdir:  $outdir
echo build:   $build
echo dbtag:   $dbtag
echo inputs:  ${inputs[@]}

echo .............................................................................................. 

for i in ${inputs[@]}; do
   cp -v ${i} .
   echo $( basename $i ) >> inlist   
done

# Temp hack for testing...
#rsync --verbose /direct/sphenix+u/sphnxpro/ProductionSystemIntegration/ProductionSystem/cups.py .
#rsync --verbose /direct/sphenix+u/sphnxpro/ProductionSystemIntegration/ProductionSystem/bachi.py .
#rsync --verbose /direct/sphenix+u/sphnxpro/ProductionSystemIntegration/ProductionSystem/odbc.ini .
#rsync --verbose /direct/sphenix+u/sphnxpro/ProductionSystemIntegration/ProductionSystem/slurp-examples/sPHENIX/TrackingProduction/ .




#$$$ ./cups.py -r ${runnumber} -s ${segment} -d ${outbase} inputs --files "$( cat inlist )"
./cups.py -r ${runnumber} -s ${segment} -d ${outbase} running

dstname=${logbase%%-*}
echo ./bachi.py --blame cups created ${dstname} ${runnumber} --parent ${inputs[0]}
     ./bachi.py --blame cups created ${dstname} ${runnumber} --parent ${inputs[0]}

echo root.exe -q -b Fun4All_TrkrHitSet_Unpacker.C\(${nevents},${runnumber},\"${logbase}.root\",\"${dbtag}\",\"inlist\"\)
     root.exe -q -b Fun4All_TrkrHitSet_Unpacker.C\(${nevents},${runnumber},\"${logbase}.root\",\"${dbtag}\",\"inlist\"\);  status_f4a=$?

ls -la

./stageout.sh ${logbase}.root ${outdir}

for hfile in `ls HIST_*.root`; do
    echo Stageout ${hfile} to ${histdir}
    ./stageout.sh ${hfile} ${histdir}
done}


ls -la

if [ "${status_f4a}" -eq 0 ]; then
  echo ./bachi.py --blame cups finalized ${dstname} ${runnumber}  
       ./bachi.py --blame cups finalized ${dstname} ${runnumber} 
fi

# Flag run as finished. 
echo ./cups.py -v -r ${runnumber} -s ${segment} -d ${outbase} finished -e ${status_f4a} --nevents ${nevents}  
     ./cups.py -v -r ${runnumber} -s ${segment} -d ${outbase} finished -e ${status_f4a} --nevents ${nevents}

echo "bdee bdee bdee, That's All Folks!"


}  > ${logbase}.out 2>${logbase}.err

mv ${logbase}.out ${logdir#file:/}
mv ${logbase}.err ${logdir#file:/}

exit $status_f4a
