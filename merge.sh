#/bin/sh

# concat prepared videos
#==[ARGS]: output_dir
function concat_videos {
    f_name="output_video.mp4"
    find "$1" -name "fixed-*.mp4" -type f | awk '{printf "file \047%s\047\n",$1}' | sort >"input.txt"

    printf "\n[MERGING] -> %s\n" $f_name
    ffmpeg -f concat -safe 0 -i "input.txt" -c copy $f_name -hide_banner -loglevel error

    rm input.txt
}

#==[main section]

trap stop INT

concat_videos archive
