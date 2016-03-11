#generates FSBL.elf in SDK
	#run: vivado > hsi > source fsbl.tcl

source generics.tcl -notrace

# TODO: here i want to enter this command in the shell that is running the script: hsi

#export design to sdk, with bitstream
file copy -force $orig_vivado/$PROJECTNAME.runs/impl_1/${BD}_wrapper.sysdef $orig_vivado/$PROJECTNAME.sdk/${BD}_wrapper.hdf

#open design
open_hw_design $orig_vivado/$PROJECTNAME.sdk/${BD}_wrapper.hdf

#generate FSBL
generate_app -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl -dir $orig_vivado/$PROJECTNAME.sdk/FSBL
file copy -force $orig_vivado/$PROJECTNAME.sdk/FSBL/executable.elf $sd_temp/FSBL.elf
