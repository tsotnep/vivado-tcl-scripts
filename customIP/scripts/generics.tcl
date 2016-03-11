#vivado project directory
set vivado vivado

#vivado project name
set PROJECTNAME lab3

#vivado project's block design name
set BD BlockDesign



#temporary files
set sd_temp sd-temp

#image files ready to be copied on sd card
set sd_image sd-image



#set the origin directory, to the location of the script
#set origin_dir [file dirname [info script]]
set origin_dir .

# normalize, repalces "~/" with "/home/username", calculates "../"  and etc. and set root directory
set orig_vivado "[file normalize "$origin_dir/$vivado"]"



file mkdir sd-temp sd-image temp
file mkdir $orig_vivado/$PROJECTNAME.sdk
