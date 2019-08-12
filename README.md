# Problema 2 – Conectando-se à Internet das Coisas

Repositório contendo os arquivos referentes ao desenvolvimento do Problema 2 da disciplina TEC499 MI Sistemas Digitais.

## Desenvolvido com:
1. [Altera Quartus II 13.0.1](http://fpgasoftware.intel.com/13.0sp1/).
2. Placa FPGA da Familia [Cyclone IV](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyclone-iv/cyiv-51001.pdf) com o Chip EP4CE6E22C8.

## Objetivos:

O sistema desenvolvido possui como objetivo reutilizar a IHM desenvolvida no projeto anterior, de forma que neste novo projeto seja interligada ao processador por meio de uma interface de E/S (UART) o módulo ESP-12 que utiliza o CI ESP8266 para prover comunicação sem fio. Um dos requisitos do projeto é a implementação da UART e a configuração (via processador) do módulo ESP-12 utilizando Comandos AT.

## Procedimentos:

1. Abrir o Altera Quartus II 13.0 SP1;
2. Em File -> Open Project;
3. Selecionar a pasta sd_pbl_dois;
4. Abrir o arquivo PBL2.qpf;
5. Executar a compilação do Projeto;
6. Descarregar na FPGA;
7. Abrir o Altera Monitor;
8. Em File -> Open Project;
9. Selecionar a pasta sd_pbl_dois;
10. Abrir a pasta monitor;
11. Abrir o arquivo PBL2.ncf;
12. Clicar em Actions -> Compile & Load.

## Informações Adicionais:

Veja a lista de [contribuidores](https://github.com/alysondantas/sd_pbl_dois/contributors) que participaram nesse projeto.
