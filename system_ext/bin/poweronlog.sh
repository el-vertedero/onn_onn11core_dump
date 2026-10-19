#!bin/sh

function logcmd()
{
	echo -e "\n"
}

function exe_cmd()
{
	logcmd "$@";
	eval $@;
}

dstdir="/mnt/poweron_info/poweron_log/"

min=9999
max=-1
count=0

for dir in $(ls $dstdir); do
    if [ -d "$dstdir$dir" ]; then 
        if [ "$dir" -lt 9999 ] && [ "$dir" -ge 0 ]; then
            count=$((count + 1))
            if [ "$dir" -lt "$min" ]; then 
                min=$dir
            fi
            if [ "$dir" -gt "$max" ]; then 
                max=$dir
            fi
        else
            echo "Directory number out of range: $dir"
        fi
    fi
done

if [ $count -ge 4 ]; then
    max=$((max + 1))
    exe_cmd "mkdir $dstdir$max"
    exe_cmd "rm -rf $dstdir$min"
else
    max=$((max + 1))
    exe_cmd "mkdir $dstdir$max"
fi

exe_cmd "dmesg -Tw > $dstdir$max/kernel.log" & 
exe_cmd "logcat -f $dstdir$max/android.log" &
sleep 3m
exe_cmd "cat /proc/bootprof > $dstdir$max/bootprof" & 
exe_cmd "cat /proc/pl_lk > $dstdir$max/pl_lk" & 
exe_cmd "sync"

if [ "$(ls -A $dstdir$max)" ]; then
    files=""
    if [ -f "$dstdir$max/kernel.log" ]; then
        files="$files kernel.log"
    else
        echo "File $dstdir$max/kernel.log does not exist."
    fi
    if [ -f "$dstdir$max/android.log" ]; then
        files="$files android.log"
    else
        echo "File $dstdir$max/android.log does not exist."
    fi
    if [ -f "$dstdir$max/bootprof" ]; then
        files="$files bootprof"
    else
        echo "File $dstdir$max/bootprof does not exist."
    fi
    if [ -f "$dstdir$max/pl_lk" ]; then
        files="$files pl_lk"
    else
        echo "File $dstdir$max/pl_lk does not exist."
    fi

    # files=$(echo $files | sed 's/^ //')

    if [ -n "$files" ]; then
        cd $dstdir$max
        exe_cmd "tar -zcvf log_$max.tar.gz $files"
        exe_cmd "rm -rf $dstdir$max/android.log"
        exe_cmd "rm -rf $dstdir$max/kernel.log" 
        exe_cmd "rm -rf $dstdir$max/bootprof"  
        exe_cmd "rm -rf $dstdir$max/pl_lk"  
        exe_cmd "sync"
    else
        echo "No files to archive in directory $dstdir$max."
    fi
else
    echo "Directory $dstdir$max is empty, no need to create archive."
fi

echo "poweron_info end"
