del *.dll *.exe *.zip libzip.modules
del /f /Q release\*.exe
del /f /Q release\*.dll
del /f /Q release\*.zip

call perl lib.pl

call libzip -ob tinyperl.pl -allowopts ceiITvwWX

mkdir release

copy *.exe release\
copy *.dll release\
copy *.zip release\

del *.dll *.exe *.zip libzip.modules

