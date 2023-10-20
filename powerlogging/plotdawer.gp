set terminal qt
set datafile separator ","
set xdata time
set timefmt "%m.%d.%Y-%H:%M:%S%Z"
set format x "%m.%d.%Y-%H:%M:%S%Z"
set key autotitle columnhead # use the first line as title
set xtics rotate # rotate labels on the x axis
set key left center
set multiplot layout 4,1 rowsfirst

unset y2label
unset y2tics
set format x ''; unset xlabel
plot "powerlog_09.27.2023-14:31:23+05.csv" using 1:3 with lines, \
    '' using 1:4 with lines
plot "powerlog_09.27.2023-14:31:23+05.csv" using 1:5 with lines, \
    '' using 1:6 with lines
plot "powerlog_09.27.2023-14:31:23+05.csv" using 1:7 with lines, \
    '' using 1:8 with lines
set y2tics # enable second axis
plot "powerlog_09.27.2023-14:31:23+05.csv" using 1:9 with lines, \
    '' using 1:10 with lines axis x1y2

pause 999999999
