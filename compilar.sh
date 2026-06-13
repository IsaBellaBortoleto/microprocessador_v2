#!/bin/bash
echo "Iniciando compilação com GHDL..."

rm -f work-obj93.cf

# Componentes base (sem dependências entre si)
ghdl -a BANCO/reg16bits.vhd
ghdl -a UC/reg1bit.vhd
ghdl -a PC/pc.vhd
ghdl -a ROM/rom.vhd
ghdl -a RAM/ram.vhd
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

# Lab 8 — tempo aumentado para cobrir o crivo completo:
# Bloco 1: 31 iterações x 8 instruções = ~248 instruções
# Blocos 2-5: ~60 iterações x 8 instruções = ~480 instruções
# Bloco 6 (Pessoa 2): ~50 instruções estimadas
# Total ~780 instruções x 3 estados x 10ns = ~23.4us só de execução
# Com overhead do reset e latência da ROM: 150us é seguro
echo "Executando simulação..."
ghdl -r processador_tb --wave=processador_tb.ghw --stop-time=150us

echo "Simulação concluída!"
echo "Abrindo GTKWave..."
gtkwave processador_tb.ghw