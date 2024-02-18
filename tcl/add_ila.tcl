set ila_clock processing_system7_0_FCLK_CLK0

create_debug_core ila1 ila
set_property C_DATA_DEPTH   1024 [get_debug_cores ila1]
set_property C_EN_STRG_QUAL true  [get_debug_cores ila1]
set_property C_ADV_TRIGGER  true  [get_debug_cores ila1]
set_property ALL_PROBE_SAME_MU_CNT 4  [get_debug_cores ila1]

set ila_nets [get_nets -hier -filter {MARK_DEBUG==1}]
set num_ila_nets [llength [get_nets [list $ila_nets]]]

set_property port_width 1 [get_debug_ports ila1/clk]
set_property port_width $num_ila_nets [get_debug_ports ila1/probe0]
connect_debug_port ila1/probe0 [lsort -dictionary [get_nets [list $ila_nets ]]]
get_nets [list $ila_nets]
connect_debug_port ila1/clk [get_nets [list $ila_clock ]]

implement_debug_core [get_debug_cores ila1]
write_debug_probes -force ./results/ila1.ltx