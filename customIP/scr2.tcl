#vivado version: 2015.1
#this script: 
	#in the script directory, creates new project with name : new_project_1
	#creates block design and adds : 
		#ZynqProcessingSystem
		#custom IP, located in the script directory
		#connects interrupt of custom IP to PS(fabric IRQ_F2P)
		#regenerates layout & validates design
	#generates bitstream
	#exports hardware to sdk
	#launchs sdk

#basic variables
set PROJECTNAME new_project_1
	
#set the origin directory, to the location of the script
set origin_dir [file dirname [info script]]

# normalize, repalces "~/" with "/home/username", calculates "../"  and etc.
set orig_proj_dir "[file normalize "$origin_dir/$PROJECTNAME"]"

#create project
create_project project_1 $orig_proj_dir -part xc7z020clg484-1 -f
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_repo_paths  $origin_dir/ip_repo/MYMULTIPLIER_1.0 [current_project]
set_property target_language VHDL [current_project]

#Set the directory path for the new project
set proj_dir [get_property directory [current_project]]


#add IPs, processing system, multiplier
update_ip_catalog
create_bd_design "design_1"
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
startgroup
create_bd_cell -type ip -vlnv user.org:user:MYMULTIPLIER:1.0 MYMULTIPLIER_0
endgroup

#perform automations
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins MYMULTIPLIER_0/S00_AXI]

#enable interrupt
startgroup
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
endgroup

#connect irq from multiplier to interrupt
connect_bd_net [get_bd_pins MYMULTIPLIER_0/multiplier_rdy_irq_out] [get_bd_pins processing_system7_0/IRQ_F2P]

#regenerate layout, validate, save
regenerate_bd_layout
validate_bd_design
save_bd_design

#create hdl wrapper
make_wrapper -files [get_files $orig_proj_dir/project_1.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse $orig_proj_dir/project_1.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.vhd
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#generate bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

#export design to sdk, with bitstream
file mkdir $orig_proj_dir/project_1.sdk
file copy -force $orig_proj_dir/project_1.runs/impl_1/design_1_wrapper.sysdef $orig_proj_dir/project_1.sdk/design_1_wrapper.hdf

#launch sdk
launch_sdk -workspace $orig_proj_dir/project_1.sdk -hwspec $orig_proj_dir/project_1.sdk/design_1_wrapper.hdf
