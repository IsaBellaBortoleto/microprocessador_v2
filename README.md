# Formato das Instruções (16 bits)

As instruções possuem 16 bits e seguem um formato padronizado para facilitar a decodificação pela Unidade de Controle.

## Organização dos Bits

| Bits      | Campo        | Descrição                                    |
|-----------|--------------|----------------------------------------------|
| `[15:12]` | `oooo`       | Opcode da instrução (4 bits)                 |
| `[11:8]`  | `dddd`       | Registrador de destino (`Rd`) ou `0000`      |
| `[7:4]`   | `ssss`       | Registrador fonte (`Rs`) ou `0000`           |
| `[7:0]`   | `cccccccc`   | Constante (`cte`), endereço (`addr`) ou delta|

> Nas instruções do tipo **I** e **J**, o campo `[7:0]` substitui os campos `Rs` e os 4 bits menos significativos.

---

# Tabela de Opcodes

| Instrução | Opcode | Formato Binário              | Operação Interna              | Observações                                          |
|-----------|--------|------------------------------|-------------------------------|------------------------------------------------------|
| `NOP`     | `0000` | `0000 0000 0000 0000`        | Nenhuma operação              | Deve obrigatoriamente ser `0x0000`                   |
| `LD`      | `0001` | `0001 dddd cccccccc`         | `Rd = cte`                    | Carregamento imediato de constante                   |
| `MOV_A`   | `0010` | `0010 0000 ssss 0000`        | `A = Rs`                      | Move registrador para o acumulador                   |
| `MOV_R`   | `0011` | `0011 dddd 0000 0000`        | `Rd = A`                      | Move acumulador para registrador                     |
| `ADD`     | `0100` | `0100 0000 ssss 0000`        | `A = A + Rs`                  | Soma entre acumulador e registrador                  |
| `ADDI`    | `0101` | `0101 0000 cccccccc`         | `A = A + cte`                 | Soma imediata; atualiza flags                        |
| `SUB`     | `0110` | `0110 0000 ssss 0000`        | `A = A - Rs`                  | Subtração entre acumulador e registrador             |
| `CMPR`    | `0111` | `0111 0000 ssss 0000`        | `Flags = A - Rs`              | Compara sem salvar resultado; atualiza flags         |
| `JMP`     | `1000` | `1000 0000 aaaaaaaa`         | `PC = PC + delta`             | Salto incondicional **RELATIVO** (delta em compl. 2) |
| `BHI`     | `1001` | `1001 0000 aaaaaaaa`         | `se C=1 e Z=0: PC = addr`     | Salto condicional **ABSOLUTO** (unsigned higher)     |
| `BVS`     | `1010` | `1010 0000 aaaaaaaa`         | `se V=1: PC = addr`           | Salto condicional **ABSOLUTO** (overflow set)        |
| `LW`      | `1011` | `1011 dddd ssss 0000`        | `Rd = RAM[Rs]`                | Leitura da RAM; Rs é o registrador ponteiro          |
| `SW`      | `1100` | `1100 0000 ssss 0000`        | `RAM[Rs] = A`                 | Escrita na RAM; Rs é o ponteiro, dado vem do acumulador |

---

# Convenções Utilizadas

- `A` → Acumulador
- `Rd` → Registrador de destino
- `Rs` → Registrador fonte ou ponteiro de endereço
- `cte` → Constante imediata de 8 bits (zero-extended para 16 bits)
- `addr` → Endereço absoluto de destino de 8 bits (para BHI/BVS)
- `delta` → Deslocamento relativo em complemento de 2 de 8 bits (para JMP)
- `PC` → Program Counter (7 bits)

---

# Observações Gerais

Todas as instruções possuem tamanho fixo de **16 bits**. O acumulador (`A`) é utilizado como operando principal nas operações aritméticas. O opcode ocupa sempre os 4 bits mais significativos da instrução.

**Sobre os saltos:** o JMP é incondicional e **relativo** — o campo `[7:0]` é somado ao PC atual, permitindo saltos para frente e para trás usando complemento de 2. Os branches BHI e BVS são condicionais e **absolutos** — o campo `[7:0]` é carregado diretamente no PC. Para travar o programa em loop infinito no endereço N, usa-se `JMP -1`, cujo delta em 8 bits é `0xFF`.

**Sobre as flags:** C, Z e V são armazenadas em flip-flops fora da ULA e só são atualizadas durante a execução de ADD, ADDI, SUB e CMPR. Instruções como LD, MOV, JMP, BHI, BVS, LW, SW e NOP **não** alteram as flags.

**Sobre a memória RAM (Lab 7):** a escrita é síncrona (ocorre na borda de subida do clock quando `wr_en=1`) e a leitura é assíncrona (o dado aparece imediatamente na saída quando o endereço muda). O endereço de acesso é sempre fornecido por um registrador ponteiro (`Rs`), permitindo o uso de loops sobre vetores. Em SW, o dado a escrever vem sempre do acumulador.

---

# Exemplo de Utilização

A arquitetura utiliza um acumulador (`A`) como operando principal da ULA. Assim, operações aritméticas normalmente seguem três etapas: carregar um valor no acumulador, executar a operação e salvar o resultado em um registrador.

## Exemplo 1: Soma entre Registradores

Objetivo: `R3 = R1 + R2`

```asm
MOV_A R1   ; A = R1
ADD   R2   ; A = A + R2
MOV_R R3   ; R3 = A
```

Com R1=5 e R2=3, o resultado final é R3=8.

---

## Exemplo 2: Escrita e Leitura na RAM (Lab 7)

Objetivo: gravar o valor 0xAB no endereço 5 da RAM e depois lê-lo de volta para R9.

```asm
LD    R1, 0xAB  ; R1 = 171 (dado a escrever)
LD    R5, 5     ; R5 = 5   (endereço na RAM)
MOV_A R1        ; A  = R1 = 0xAB
SW    (R5)      ; RAM[5] = A = 0xAB
NOP             ; aguarda estabilização
LW    R9, (R5)  ; R9 = RAM[5] = 0xAB
```

O NOP entre o SW e o LW é uma boa prática para garantir que o valor gravado (escrita síncrona) já esteja disponível antes da leitura, evitando problemas de timing em simulação.