#!/bin/bash

measure() {

    cpuFreqAverage="$( \
        kstatsviewer cpu/cpu0/frequency \
        cpu/cpu1/frequency \
        cpu/cpu2/frequency \
        cpu/cpu3/frequency \
        cpu/cpu4/frequency \
        cpu/cpu5/frequency \
        cpu/cpu6/frequency \
        cpu/cpu7/frequency \
        cpu/cpu8/frequency \
        cpu/cpu9/frequency \
        cpu/cpu10/frequency \
        cpu/cpu11/frequency \
        cpu/cpu12/frequency \
        cpu/cpu13/frequency \
        cpu/cpu14/frequency \
        cpu/cpu15/frequency \
        | cut -d' ' -f2 \
        | paste -s -d+ - \
        | bc \
        | tr -d '\n' \
        | cat - <(echo "/ 16") \
        | bc \
        )"

    cpuFreqMax="$( \
        kstatsviewer cpu/cpu0/frequency \
        cpu/cpu1/frequency \
        cpu/cpu2/frequency \
        cpu/cpu3/frequency \
        cpu/cpu4/frequency \
        cpu/cpu5/frequency \
        cpu/cpu6/frequency \
        cpu/cpu7/frequency \
        cpu/cpu8/frequency \
        cpu/cpu9/frequency \
        cpu/cpu10/frequency \
        cpu/cpu11/frequency \
        cpu/cpu12/frequency \
        cpu/cpu13/frequency \
        cpu/cpu14/frequency \
        cpu/cpu15/frequency \
        | cut -d' ' -f2 \
        | sort -rn \
        | head -1 \
        )"

    cpuFreqMin="$( \
        kstatsviewer cpu/cpu0/frequency \
        cpu/cpu1/frequency \
        cpu/cpu2/frequency \
        cpu/cpu3/frequency \
        cpu/cpu4/frequency \
        cpu/cpu5/frequency \
        cpu/cpu6/frequency \
        cpu/cpu7/frequency \
        cpu/cpu8/frequency \
        cpu/cpu9/frequency \
        cpu/cpu10/frequency \
        cpu/cpu11/frequency \
        cpu/cpu12/frequency \
        cpu/cpu13/frequency \
        cpu/cpu14/frequency \
        cpu/cpu15/frequency \
        | cut -d' ' -f2 \
        | sort -n \
        | head -1 \
        )"

    maxTemp="$( \
        sensors \
        | grep °C \
        | awk -F' +' '{print $2}' \
        | sed 's|+||g' \
        | sed 's|°C||g' \
        | grep \\. \
        | sort -rn \
        | head -1 \
    )"

    ramFreePercent="$(kstatsviewer memory/physical/freePercent |  cut -d' ' -f2)"
    swapFreePercent="$(kstatsviewer memory/swap/freePercent |  cut -d' ' -f2)"
    consumption="$(kstatsviewer power/MB1000007967125H1B38/chargeRate | cut -d' ' -f2 | sed 's|-||g')"
    chargePercent="$(kstatsviewer power/MB1000007967125H1B38/chargePercentage | cut -d' ' -f2)"
    compositeTemp="$(sensors | grep Composite | awk -F' +' '{print $2}' | sed 's|+||g' | sed 's|°C||g')"
}

get_date(){

    echo "$(date +%m.%d.%Y-%H:%M:%S%Z)"
}

echo "logging started"

filename="powerlog_$(get_date).csv"

echo "date,cpuFreqMin,cpuFreqMax,cpuFreqAverage,ramFreePercent,swapFreePercent,compositeTemp,maxTemp,chargePercent,consumption" | tee -a $filename


while true; do
    measure #takes 1-2 seconds
    echo "$(get_date),$cpuFreqMin,$cpuFreqMax,$cpuFreqAverage,$ramFreePercent,$swapFreePercent,$compositeTemp,$maxTemp,$chargePercent,$consumption" | tee -a $filename
done





