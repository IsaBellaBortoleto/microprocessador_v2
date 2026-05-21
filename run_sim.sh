#!/bin/bash

set -e

echo "==> Limpando arquivos antigos..."
rm -f work-obj93.cf
rm -f *.ghw
rm -f *.vcd

echo "==> Compilando os arquivos VHDL..."
ghdl -a *.vhd

echo "==> Elaborando o Testbench Principal..."
ghdl -e processador_tb

echo "==> Executando a Simulação..."
ghdl -r processador_tb --wave=ondas_processador.ghw

echo "==> Abrindo GTKWave..."

if [ -f "config_pinos.gtkw" ]; then
    gtkwave ondas_processador.ghw config_pinos.gtkw &
else
    gtkwave ondas_processador.ghw &
fi