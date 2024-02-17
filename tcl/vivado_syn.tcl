#TODO: Cleanup unused lines and change hardcoded paths with references to variables
#Define target part and create output directory
set partNum xc7z020clg400-1
set outputDir ./work
set rtlDir ../rtl
set utilsDir ../utils
set curDir [pwd]

puts "Current dir: $curDir"
puts "RTL DIR $rtlDir"

file mkdir $outputDir
set files [glob -nocomplain "$outputDir/*"]
if {[llength $files] != 0} {
    # clear folder contents
    puts "deleting contents of $outputDir"
    file delete -force {*}[glob -directory $outputDir *]; 
} else {
    puts "$outputDir is empty"
}

create_project -in_memory -part $partNum
set_property source_mgmt_mode All [current_project] 
read_verilog -verbose -sv [ glob $rtlDir/*.sv]
read_verilog -verbose -sv [ glob $utilsDir/*.sv]
read_vhdl -verbose [ glob $rtlDir/*.vhd]
read_xdc ../constraints/system.xdc

source zynq_hub75_new.tcl
generate_target all [ get_files ./gen_ip/zynq_hub75/zynq_hub75.bd ]
#generate_target all [ get_ips]
#read_bd ./gen_ip/zynq_hub75/zynq_hub75.bd
read_verilog ./gen_ip/zynq_hub75/hdl/zynq_hub75_wrapper.v


#make_wrapper -files [ get_files  ./gen_ip/zynq_hub75/zynq_hub75.bd ] -top -import
#read_verilog -verbose ./gen_ip/zynq_hub75/hdl/zynq_hub75_wrapper.v
#update_compile_order -fileset sources_1
report_compile_order 

synth_design -top zynq_hub75 -part $partNum
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.report_timing_summary
report_utilization -file $outputDir/post_synth_util.rpt

# Add ILA
#source add_ila.tcl

#run optimization
opt_design
place_design
report_clock_utilization -file $outputDir/clock_util.rpt



#get timing violations and run optimizations if needed
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
 puts "Found setup timing violations => running physical optimization"
 phys_opt_design
}
write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt

#Route design and generate bitstream
route_design -directive Explore
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/hub75_zynq.v -mode timesim -sdf_anno true
#write_bitstream -force $outputDir/bitstream.bit

# Export HW platform for Vitis
write_hw_platform -fixed -include_bit -force -file $outputDir/hub75_hw.xsa
