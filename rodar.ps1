Write-Host "Iniciando compilacao com GHDL..."

ghdl -a BANCO/reg16bits.vhd
ghdl -a UC/reg1bit.vhd
ghdl -a PC/pc.vhd
ghdl -a ROM/rom.vhd
ghdl -a ULA/ula.vhd
ghdl -a BANCO/banco_regs.vhd
ghdl -a UC/maquina_estados.vhd
ghdl -a PC/incr_pc.vhd
ghdl -a PC/pc_rom_top.vhd
ghdl -a UC/un_control.vhd
ghdl -a processador.vhd
ghdl -a processador_tb.vhd

Write-Host "Executando simulacao..."
ghdl -r processador_tb --wave=processador_tb.ghw --stop-time=15us

Write-Host "Simulacao concluida!"
Write-Host "Abrindo GTKWave..."
gtkwave processador_tb.ghw
