#!/bin/bash
ghdl -a reg16bits.vhd reg1bit.vhd pc.vhd rom.vhd ula.vhd banco_regs.vhd un_control.vhd processador.vhd processador_tb.vhd &&
ghdl -e processador_tb &&
ghdl -r processador_tb --wave=processador_tb.ghw &&
gtkwave processador_tb.ghw sinais.gtkw
chmod +x simular.sh
./simular.sh