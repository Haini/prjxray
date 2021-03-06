proc print_tile_pips {tile_type filename} {
    set tile [lindex [get_tiles -filter "TYPE == $tile_type"] 0]
    puts "Dumping PIPs for tile $tile ($tile_type) to $filename."
    set fp [open $filename w]
    foreach pip [lsort [get_pips -of_objects [get_tiles $tile]]] {
        set src [get_wires -uphill -of_objects $pip]
        set dst [get_wires -downhill -of_objects $pip]
        if {[llength [get_nodes -uphill -of_objects [get_nodes -of_objects $dst]]] == 1} {
            set src_node [get_nodes -of $src]
            set dst_node [get_nodes -of $dst]

            if { [string first INT_INTERFACE [get_wires -of $src_node]] != -1 } {
                continue
            }
            if { [string first INT_INTERFACE [get_wires -of $dst_node]] != -1 } {
                continue
            }
        }
        puts $fp "$tile_type.[regsub {.*/} $dst ""].[regsub {.*/} $src ""]"
    }
    close $fp
}

create_project -force -part $::env(XRAY_PART) design design
set_property design_mode PinPlanning [current_fileset]
open_io_design -name io_1

print_tile_pips CMT_TOP_L_UPPER_T cmt_top_l_upper_t.txt
print_tile_pips CMT_TOP_R_UPPER_T cmt_top_r_upper_t.txt
