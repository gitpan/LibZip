call perl lib.pl

call libzip -ob tinyperl.pl -allowopts ceiITvVwWX

mkdir release

copy *.exe release\
copy *.dll release\
copy *.zip release\
