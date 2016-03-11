#vivado version: 2015.1
#this script:
	#in the script directory, creates new project with name : $PROJECTNAME
	#creates block design and adds :
		#ZynqProcessingSystem
		#custom IP, located in the script directory
		#connects interrupt of custom IP to PS(fabric IRQ_F2P)
		#regenerates layout & validates design
	#generates bitstream

source generics.tcl -notrace

#create project
create_project $PROJECTNAME $orig_vivado -part xc7z020clg484-1 -f
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_repo_paths  $origin_dir/ip_repo/MYMULTIPLIER_1.0 [current_project]
set_property target_language VHDL [current_project]

#add IPs, processing system, multiplier
update_ip_catalog
create_bd_design "$BD"
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
make_wrapper -files [get_files $orig_vivado/$PROJECTNAME.srcs/sources_1/bd/$BD/$BD.bd] -top
add_files -norecurse $orig_vivado/$PROJECTNAME.srcs/sources_1/bd/$BD/hdl/${BD}_wrapper.vhd
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#generate bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
file copy -force $orig_vivado/$PROJECTNAME.runs/impl_1/${BD}_wrapper.bit $sd_temp
