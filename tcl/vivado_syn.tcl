#Define target part and create output directory
set partNum xc7z020clg400-1
set outputDir ./work
set rtlDir ../rtl


file mkdir $outputDir
set files [glob -nocomplain "$outputDir/*"]
if {[llength $files] != 0} {
    # clear folder contents
    puts "deleting contents of $outputDir"
    file delete -force {*}[glob -directory $outputDir *]; 
} else {
    puts "$outputDir is empty"
}

read_vhdl -library hub75_lib [ glob $rtlDir/*.vhd]
read_verilog -sv [ glob $rtlDir/*.sv]

synth_design -top hub75_driver_wrapper -part $partNum
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.report_timing_summary
report_utilization -file $outputDir/post_synth_util.rpt