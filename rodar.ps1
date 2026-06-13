# rodar.ps1
# Script PowerShell para compilar e rodar o projeto GHDL — Lab 8 Validação

Write-Host "Iniciando compilação com GHDL..."

# Componentes base (sem dependências)
ghdl -a REGS/reg16bits.vhd
ghdl -a REGS/reg1bit.vhd
ghdl -a PC/pc.vhd
ghdl -a ROM/rom.vhd
ghdl -a RAM/ram.vhd          # adicionado no Lab 7, mantido no Lab 8
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

# Elaboração
Write-Host "Elaborando..."
ghdl -e processador_tb

# Lab 8 — tempo aumentado para cobrir o crivo completo
# Bloco 1: 31 iterações x 8 instruções
# Blocos 2-5: ~60 iterações x 8 instruções
# Bloco 6 (Pessoa 2): ~50 instruções estimadas
# Total ~780 instruções x 3 estados x 10ns = ~23.4us de execução pura
# Com overhead do reset e latência da ROM: 150us é seguro
Write-Host "Executando simulação..."
ghdl -r processador_tb --wave=processador_tb.ghw --stop-time=150us

Write-Host "Simulação concluída! Arquivo de onda gerado: processador_tb.ghw"

# Abrir GTKWave com o arquivo de ondas atualizado
Write-Host "Abrindo a forma de onda..."
gtkwave processador_tb.ghw
