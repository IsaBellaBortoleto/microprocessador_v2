#!/bin/bash
# compilar.sh
# Script para compilar e rodar o projeto GHDL

echo "Iniciando compilação com GHDL..."

# Componentes base
ghdl -a REGS/reg16bits.vhd
ghdl -a REGS/reg1bit.vhd
ghdl -a PC/pc.vhd
ghdl -a ROM/rom.vhd
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

# Simulação
echo "Executando simulação..."
ghdl -r processador_tb --wave=processador_tb.ghw --stop-time=15us

echo "Simulação concluída! Arquivo: processador_tb.ghw"

# Abrir GTKWave
echo "Abrindo GTKWave..."
gtkwave lab06_gtk_final.gtkw