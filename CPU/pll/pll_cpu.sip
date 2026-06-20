set_global_assignment -entity "pll_cpu" -library "lib_pll_cpu" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_cpu" -library "lib_pll_cpu" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "pll_cpu" -library "lib_pll_cpu" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_cpu" -name SPD_FILE [file join $::quartus(sip_path) "pll_cpu.spd"]

set_global_assignment -library "lib_pll_cpu" -name MISC_FILE [file join $::quartus(sip_path) "pll_cpu_sim/pll_cpu.vo"]
