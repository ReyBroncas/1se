# 2 Seconds everyday
A two simple scripts to automate video journaling of 1 second everyday without using an [official app](https://1se.co/ourstory)

---

## Usage:
There are two folders:
1. `res` -- for raw videofiles
2. `archive` -- for formatted videofiles

Formatting raw files:
```bash
./prepare res archive
```

Merging formatted files:
```bash
./merge archive final_video_name.mp4
```