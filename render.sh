#/bin/sh

# immediately stop running on interupt
function stop {
    printf "\nStopping !\n"
    exit 1
}

# add date labels to videos & trim them
#==[ARGS]: src_dir, output_dir, font_dir
function prepare_videos {
    mkdir -p $2

    for f in $(find "$1/" -name "*.mp4" -type f -printf "%f\n"); do
        c_name=$(printf "%s/cut-%s\n" $2 $f)
        f_name=$(printf "%s/fixed-%s\n" $2 $f)
        f_date=$(date -r "$1/$f" | awk '{printf "%s-%s-%s",$2,$3,$NF}')

        printf "[PREPARING]: %s/%s -> %s\n" $1 $f $f_name
        # cut last 2 seconds
        ffmpeg -sseof -2 -i "$1/$f" "$c_name" -y -hide_banner -loglevel error
        # add date label
        ffmpeg -i "$c_name" -vf "drawtext=fontfile=$3:text='$f_date':fontcolor=white:fontsize=100:box=1:boxcolor=black@0:boxborderw=5:x=(w-text_w)/5:y=(h-text_h)-50" -codec:a copy "$f_name" -hide_banner -loglevel error

        rm "$c_name"
    done
}

# concat prepared videos
#==[ARGS]: output_dir
function concat_videos {
    f_name="output_video.mp4"
    find "$1" -name "fixed-*.mp4" -type f | awk '{printf "file \047%s\047\n",$1}' | sort >"input.txt"

    printf "\n[MERGING] -> %s\n" $f_name
    ffmpeg -f concat -safe 0 -i "input.txt" -c copy $f_name -hide_banner -loglevel error

    rm input.txt
    rm -r $1
}

#==[main section]

trap stop INT

prepare_videos res temp font/Nunito-Regular.ttf

concat_videos temp
