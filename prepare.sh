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
        tmp_1_name=$(printf "%s/tmp_1-%s\n" $2 $f)
        tmp_2_name=$(printf "%s/tmp_2-%s\n" $2 $f)
        fixed_name=$(printf "%s/fixed-%s\n" $2 $f)
        f_date=$(date -r "$1/$f" | awk '{printf "%s-%s-%s",$2,$3,$NF}')

        printf "[PREPARING]: %s/%s -> %s\n" $1 $f $fixed_name

        # cut first 2 seconds
        ffmpeg -ss 0 -t 3 -i "$1/$f" "$tmp_1_name" -y -hide_banner -loglevel error

        # change resolution
        ffmpeg -i "$tmp_1_name" -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1" "$tmp_2_name" -y -hide_banner -loglevel error

        # re-encode
        ffmpeg -i "$tmp_2_name" -af apad -vf scale=1920:1080 -crf 15.0 -vcodec libx264 -acodec aac -ar 48000 -b:a 192k -coder 1 -rc_lookahead 60 -threads 0 -shortest -avoid_negative_ts make_zero -r 60 -fflags +genpts "$tmp_1_name" -y -hide_banner -loglevel error

        # add date label
        ffmpeg -i "$tmp_1_name" -vf "drawtext=fontfile=$3:text='$f_date':fontcolor=white:fontsize=50:box=1:boxcolor=black@0:boxborderw=5:x=(w-text_w)/5:y=(h-text_h)-30" -codec:a copy "$fixed_name" -hide_banner -loglevel error

        rm "$tmp_1_name"
        rm "$tmp_2_name"
    done
}

function modify_timestamps {
    for f in $(find "$1/" -name "*.mp4" -type f -printf "%f\n"); do
        timestamp=$(printf "%s0000.00" $(echo $f | cut -d '_' -f1))
        touch -a -m -t $timestamp "$1/$f"
    done
}

#==[main section]

trap stop INT

prepare_videos res archive font/Nunito-Regular.ttf
