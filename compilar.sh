#!/bin/bash
echo "Iniciando compilação com GHDL..."

rm -f work-obj93.cf

# Componentes base (sem dependências entre si)
ghdl -a BANCO/reg16bits.vhd
ghdl -a UC/reg1bit.vhd
ghdl -a PC/pc.vhd
ghdl -a ROM/rom.vhd
ghdl -a RAM/ram.vhd          # novo no Lab 7 — precisa vir antes do processador.vhd
ghdl -a ULA/ula.vhd
ghdl -a BANCO/banco_regs.vhd
ghdl -a UC/maquina_estados.vhd

# Módulos compostos
ghdl -a PC/incr_pc.vhd
ghdl -a PC/pc_rom_top.vhd
ghdl -a UC/un_control.vhd

# Top level e testbench
ghdl -a processador.vhd
ghdl -a processador_tb.vhd

# Simulação — 25us para cobrir as 24 instruções do Lab 7
echo "Executando simulação..."
ghdl -r processador_tb --wave=processador_tb.ghw --stop-time=25us

echo "Simulação concluída!"
echo "Abrindo GTKWave..."
gtkwave processador_tb.ghw   