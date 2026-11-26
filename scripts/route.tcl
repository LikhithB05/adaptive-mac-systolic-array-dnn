# Run from a fresh scratch directory with vivado -mode batch -source ... -tclargs <top>.
set root [file normalize [file join [file dirname [info script]] ..]]
set top [lindex $argv 0]
if {![regexp {^(mac|systolic)_array_(2x2|4x4)_accum_top$} $top]} {error "Select one of the four integrated tops"}
set_part xc7a200tfbg676-2
foreach source [concat [glob [file join $root rtl common *.v]] [glob [file join $root rtl *_array * *.v]]] {read_verilog $source}
read_xdc [file join $root constraints array_ooc.xdc]
synth_design -top $top -part xc7a200tfbg676-2 -mode out_of_context -max_dsp 0
opt_design
place_design
route_design
report_utilization -file utilization.rpt
report_timing_summary -report_unconstrained -file timing_summary.rpt
report_timing -max_paths 10 -file critical_paths.rpt
report_power -file power_vectorless.rpt
