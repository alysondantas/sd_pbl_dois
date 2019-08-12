.data
at_wifi:                .ascii "AT+CWJAP_CUR=\"WLessLEDS\",\"HelloWorldMP31\"\n"
at_tcp:                 .ascii "AT+CIPSTART=\"TCP\",\"192.168.1.201\",1883\n"
at_send_cnt:            .ascii "AT+CIPSEND=22\n"
at_close: 				.ascii "AT+CIPCLOSE\n"
payload_connect:        .byte  0x10,0x14,0x00,0x04,0x4d,0x51,0x54,0x54,0x04,0x02,0x00,0x3c,0x00,0x08,0x45,0x53,0x50,0x2d,0x38,0x32,0x36,0x36,0x0a
at_send_pus:            .ascii "AT+CIPSEND=22\n"
payload_publish_A:        .byte  0x30,0x13,0x00,0x07,0x53,0x44,0x54,0x6f,0x70,0x69,0x63,0x00,0x01,0x4f,0x50,0x54,0x49,0x4f,0x4e,0x20,0x41,0xa
payload_publish_B:        .byte  0x30,0x13,0x00,0x07,0x53,0x44,0x54,0x6f,0x70,0x69,0x63,0x00,0x01,0x4f,0x50,0x54,0x49,0x4f,0x4e,0x20,0x42,0xa
payload_publish_C:        .byte  0x30,0x13,0x00,0x07,0x53,0x44,0x54,0x6f,0x70,0x69,0x63,0x00,0x01,0x4f,0x50,0x54,0x49,0x4f,0x4e,0x20,0x43,0xa
payload_publish_D:        .byte  0x30,0x13,0x00,0x07,0x53,0x44,0x54,0x6f,0x70,0x69,0x63,0x00,0x01,0x4f,0x50,0x54,0x49,0x4f,0x4e,0x20,0x44,0xa
payload_publish_E:        .byte  0x30,0x13,0x00,0x07,0x53,0x44,0x54,0x6f,0x70,0x69,0x63,0x00,0x01,0x4f,0x50,0x54,0x49,0x4f,0x4e,0x20,0x45,0xa

lcd_option:             .ascii "OPTION \n"
#lcd_select:             .ascii "SELECT \n"
lcd_select_a:             .ascii "SELECT A \n"
lcd_select_b:             .ascii "SELECT B \n"
lcd_select_c:             .ascii "SELECT C \n"
lcd_select_d:             .ascii "SELECT D \n"
lcd_select_e:             .ascii "SELECT E \n"

lcd_connect_wifi:        .ascii "CONNECTING... \n"

.equ	BASE_ADDRESS_UART,      0x5030
.equ	BASE_ADDRESS_BUTTONS,   0x5010

.equ    BUTTON_SELECT,  0x000E
.equ    BUTTON_BACK,    0x000D
.equ    BUTTON_RIGHT,   0x000B
.equ    BUTTON_LEFT,    0x0007

.global main

main:
	br _init
	br _MOVIMENT
	
_init:
	movia r10, 0x023f0 									# Definindo o endereÃ§o de memÃ³ria para armazenar os valores dos botÃµes
	addi r21, zero, BUTTON_SELECT						# Valores dos BotÃµes
	stwio r21, 0(r10)
	addi r21, zero, BUTTON_BACK							# Valores dos BotÃµes
	stwio r21, 4(r10)
	addi r21, zero, BUTTON_RIGHT						# Valores dos BotÃµes
	stwio r21, 8(r10)
	addi r21, zero, BUTTON_LEFT 						# Valores dos BotÃµes
	stwio r21, 12(r10)
	movia r12, BASE_ADDRESS_BUTTONS				        # Endereco base dos botÃ£o
	addi r15, zero, 0x0 								# Registrador de comparaÃ§Ã£o de botÃ£o
	addi r18, zero, 0x0001 								# Registrador de comparaÃ§Ã£o de estados
	addi r20, zero, 0x1									# Registrador que guarda o estado atual
	
	
	# -------------- INICIALIZAÃÃO DO LCD ------------------------------------
	
	call _delay_50ms
	addi r16, zero, 0x30 								# Registrador d - comando set
	addi r17, zero, 0x0 								# Registrador rs
	custom 0, r23, r17, r16  
	call _delay_50ms
	addi r16, zero, 0x0C 								# Registrador d - comando on/of
	custom 0, r23, r17, r16 
	call _delay_50ms
	addi r16, zero, 0x1 								# Registrador d - comando clear
	custom 0, r23, r17, r16 
	call _delay_50ms
	addi r16, zero, 0x4 								# Registrador d - comando mode set
	custom 0, r23, r17, r16 
	 
	
	# ---------------------------------- CONECTA AO WIFI -----------------------------------------
	# addi r23, zero, lcd_connect_wifi
    # call send_string_lcd
    # call _delay_200ms
    addi r23, zero, at_wifi								# Atribiu o endereÃ§o de memoria do codigo de conexao do wifi 		
    call send_caracter									# Envia a string salva no registrador r23
    call end_comand_at									# Confirma ao ESP o fim do comando enviando \r e \n

    call connect_tcp

	br _EXIBE

	# ------------------------------------- MAQUINA DE ESTADOS -----------------------------------
	
_MOVIMENT:
	
	ldwio r15, 0(r12)									# Pega estado do botao
	ldwio r18, 8(r10)									# Pega o valor referÃªncia pro botÃ£o direita
	beq r15, r18, _botaoMenuDir
	ldwio r18, 12(r10)									# Pega o valor referÃªncia pro botÃ£o esquerda
	beq r15, r18, _botaoMenuEsq
	ldwio r18, 0(r10)									# Pega o valor referÃªncia pro botÃ£o select
	beq r15, r18, _botaoMenuSelect
	
	br _MOVIMENT

_BACK:
	ldwio r15, 0(r12)
	ldwio r18, 4(r10)									# Pega o valor referÃªncia pro botÃ£o voltar
	beq r15, r18, _botaoMenuBack
	br _BACK
	

_botaoMenuDir:
	#calcular para escrever nova msg usando o r20 que guarde o estado da opÃ§Ã£o
	subi r22, r20, 0x1
	beq r22, zero, _OPDOISD
	subi r22, r20, 0x2
	beq r22, zero, _OPTRESD
	subi r22, r20, 0x3
	beq r22, zero, _OPQUATROD
	subi r22, r20, 0x4
	beq r22, zero, _OPCINCOD
	subi r22, r20, 0x5
	beq r22, zero, _OPUMD


_botaoMenuEsq:
	#calcular para escrever nova msg usando o r20 que guarde o estado da opÃ§Ã£o
	subi r22, r20, 0x1
	beq r22, zero, _OPCINCOE
	subi r22, r20, 0x2
	beq r22, zero, _OPUME
	subi r22, r20, 0x3
	beq r22, zero, _OPDOISE
	subi r22, r20, 0x4
	beq r22, zero, _OPTRESE
	subi r22, r20, 0x5
	beq r22, zero, _OPQUATROE

_botaoMenuSelect:
	#calcular para escrever nova msg usando o r20 que guarde o estado da opÃ§Ã£o
	addi r20, r20, 0xA
	
	br _EXIBE_NOVO

_botaoMenuBack:
	#calcular para escrever nova msg usando o r20 que guarde o estado da opÃ§Ã£o
	subi r20, r20, 0xA
	br _EXIBE
	
# Altera o valor do r20 dependendo do sentido da movimentaÃ§Ã£o	
# ---------- OpÃ§Ãµes direita -----------------

_OPUMD:
	addi r20, zero, 0x1
	br _EXIBE
	br _MOVIMENT

_OPDOISD:
	addi r20, zero, 0x2
	br _EXIBE
	br _MOVIMENT

_OPTRESD:
	addi r20, zero, 0x3
	br _EXIBE
	br _MOVIMENT

_OPQUATROD:
	addi r20, zero, 0x4
	br _EXIBE
	br _MOVIMENT

_OPCINCOD:
	addi r20, zero, 0x5
	br _EXIBE
	br _MOVIMENT

# ---------- OpÃ§Ãµes esquerda -----------------
	
_OPUME:
	addi r20, zero, 0x1
	br _EXIBE
	br _MOVIMENT

_OPDOISE:
	addi r20, zero, 0x2
	br _EXIBE
	br _MOVIMENT

_OPTRESE:
	addi r20, zero, 0x3
	br _EXIBE
	br _MOVIMENT

_OPQUATROE:
	addi r20, zero, 0x4
	br _EXIBE
	br _MOVIMENT

_OPCINCOE:
	addi r20, zero, 0x5
	br _EXIBE
	br _MOVIMENT
	
	# ---------- ExbiÃ§Ã£o -----------------
	
_EXIBE:
	# ---------- Primeiro estado -----------------
	call clear_lcd
	custom 0, r23, r17, r16 

    addi r17, zero, 0x1 # Registrador rs
    addi r23, zero, lcd_option
    call send_string_lcd

	call _delay_50ms
	
	subi r22,r20,0x1
	beq r22,zero, _EXIBEA
	subi r22,r20,0x2
	beq r22,zero, _EXIBEB
	subi r22,r20,0x3
	beq r22,zero, _EXIBEC
	subi r22,r20,0x4
	beq r22,zero, _EXIBED
	subi r22,r20,0x5
	beq r22,zero, _EXIBEE
	
	
_EXIBEA:
	addi r16, zero, 0x41 # Registrador d - caracter para escrita A
	custom 0, r23, r17, r16
	call _delay_50ms
	addi r16, zero, 0x20 # Registrador d - caracter para escrita EspaÃ§o
	custom 0, r23, r17, r16
	
	br _MOVIMENT

_EXIBEB:
	addi r16, zero, 0x42 # Registrador d - caracter para escrita B
	custom 0, r23, r17, r16
	call _delay_50ms
	addi r16, zero, 0x20 # Registrador d - caracter para escrita EspaÃ§o
	custom 0, r23, r17, r16

	br _MOVIMENT
	
_EXIBEC:
	addi r16, zero, 0x43 # Registrador d - caracter para escrita C
	custom 0, r23, r17, r16
	call _delay_50ms
	addi r16, zero, 0x20 # Registrador d - caracter para escrita EspaÃ§o
	custom 0, r23, r17, r16

	br _MOVIMENT

_EXIBED:
	addi r16, zero, 0x44 # Registrador d - caracter para escrita D
	custom 0, r23, r17, r16
	call _delay_50ms
	addi r16, zero, 0x20 # Registrador d - caracter para escrita EspaÃ§o
	custom 0, r23, r17, r16

	br _MOVIMENT
	
_EXIBEE:
	addi r16, zero, 0x45 # Registrador d - caracter para escrita E
	custom 0, r23, r17, r16
	call _delay_50ms
	addi r16, zero, 0x20 # Registrador d - caracter para escrita EspaÃ§o
	custom 0, r23, r17, r16

	br _MOVIMENT
	
# -----------------------------------------------------------------------------------------------------
_EXIBE_NOVO:
	# ---------- Primeiro estado -----------------
	call clear_lcd
	call _delay_50ms

    #addi r17, zero, 0x1 # Registrador rs
    #addi r23, zero, lcd_select
    #call send_string_lcd

	#addi r16, zero, 0x20 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16 
	
	#call _delay_50ms
	
	subi r22,r20,0xB
	beq r22,zero, _EXIBE_NOVO_A
	subi r22,r20,0xC
	beq r22,zero, _EXIBE_NOVO_B
	subi r22,r20,0xD
	beq r22,zero, _EXIBE_NOVO_C
	subi r22,r20,0xE
	beq r22,zero, _EXIBE_NOVO_D
	subi r22,r20,0xF
	beq r22,zero, _EXIBE_NOVO_E
	
	
_EXIBE_NOVO_A:
	#addi r16, zero, 0x41 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	#call _delay_50ms
	#addi r16, zero, 0x20 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	addi r17, zero, 0x1 # Registrador rs
    addi r23, zero, lcd_select_a
    call send_string_lcd

	addi r16, zero, 0x1
	custom 1, r23, r17, r16

    call connect_tcp
    call connect_mqtt
    call publish_mqtt_A
	call close_tcp

	br _BACK
	nop
	nop
	br _BACK

_EXIBE_NOVO_B:
	#addi r16, zero, 0x43 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	#call _delay_50ms
	#addi r16, zero, 0x20 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	
	addi r17, zero, 0x1 # Registrador rs
	nop
	nop
    addi r23, zero, lcd_select_b
    call send_string_lcd

	addi r16, zero, 0x1
	custom 1, r23, r17, r16

    call connect_tcp
    call connect_mqtt
    call publish_mqtt_B
	call close_tcp

	br _BACK
	nop
	nop
	br _BACK

_EXIBE_NOVO_C:
	#addi r16, zero, 0x43 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	#call _delay_50ms
	#addi r16, zero, 0x20 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16

	addi r17, zero, 0x1 # Registrador rs
    addi r23, zero, lcd_select_c
    call send_string_lcd

	addi r16, zero, 0x1
	custom 1, r23, r17, r16

    call connect_tcp
    call connect_mqtt
    call publish_mqtt_C
	call close_tcp

	br _BACK

_EXIBE_NOVO_D:
	#addi r16, zero, 0x44 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	#call _delay_50ms
	#addi r16, zero, 0x20 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16

	addi r17, zero, 0x1 # Registrador rs
    addi r23, zero, lcd_select_d
    call send_string_lcd

	addi r16, zero, 0x1
	custom 1, r23, r17, r16

    call connect_tcp
    call connect_mqtt
    call publish_mqtt_D
	call close_tcp

	br _BACK
	
_EXIBE_NOVO_E:
	#addi r16, zero, 0x45 # Registrador d - caracter para escrita
	#custom 0, r23, r17, r16
	#call _delay_50ms
	#addi r16, zero, 0x20 # Registrador d - caracter para escritan
	#custom 0, r23, r17, r16

	addi r17, zero, 0x1 # Registrador rs
    addi r23, zero, lcd_select_e
    call send_string_lcd

	addi r16, zero, 0x1
	custom 1, r23, r17, r16

    call connect_tcp
    call connect_mqtt
    call publish_mqtt_E
	call close_tcp

	br _BACK


connect_tcp:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_tcp
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

close_tcp:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_close
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

connect_mqtt:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_send_cnt
    call send_caracter
    call end_comand_at
    movia r23, payload_connect
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

publish_mqtt_A:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_send_pus
    call send_caracter
    call end_comand_at
    movia r23, payload_publish_A
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

	publish_mqtt_B:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_send_pus
    call send_caracter
    call end_comand_at
    movia r23, payload_publish_B
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

	publish_mqtt_C:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_send_pus
    call send_caracter
    call end_comand_at
    movia r23, payload_publish_C
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

	publish_mqtt_D:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_send_pus
    call send_caracter
    call end_comand_at
    movia r23, payload_publish_D
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret

	publish_mqtt_E:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r23, at_send_pus
    call send_caracter
    call end_comand_at
    movia r23, payload_publish_E
    call send_caracter
    call end_comand_at

    ldwio ra, 0(sp)
    addi sp, sp, 4
    ret


# *******************************************
# Limpa o LCD para adicionar um novo texto
# ******************************************
clear_lcd:
    subi sp, sp, 8
    stw r17, 0(sp)
    stw r16, 0(sp)

    addi r17, zero, 0x0 # Registrador rs
	addi r16, zero, 0x1 # Registrador Clear
	custom 0, r23, r17, r16 

    ldwio r17, 0(sp)
    ldwio r17, 4(sp)
    addi sp, sp, 8
    ret

# ************************************** SEND STRING LCD ************************************************
# Rotina para envio de um array de valores amazenado na memoria para o LCD
# O endereco, na memoria, do texto que serÃ¡ enviado tem que ser colocado no r23
# ***************************************************************************************************** 
send_string_lcd:
    subi sp, sp, 20                 				# salvando contexto
    nop
    stw r5, 0(sp)                   				# r5 caracter para ser enviado
    stw r6, 4(sp)                  					# r6 registrador de comparacao
    stw r7, 8(sp)                   				# r7 endereco de memoria da string
    stw ra, 12(sp)                  				# Salvando o endereco de retorno
    stw r17, 16(sp)                  				# Registrador de RS
    nop
    add r7, zero, r23              					# Pega a posiÃ§Ã£o de memoria da string e salva em r7
    addi r17, zero, 0x1     # Registrador RS
send_lcd_loop:    
    ldb r5, 0(r7)                  				    # LÃª o primeiro caracter
    addi r7, r7, 1                  				# r7 += 1
    subi r6, r5, 0xa                				# Se o valor lido Ã© igual a "\n" o resultado Ã© 0 
    nop
    beq zero, r6, lcd_end            		        # Caso igual a "\n" finaliza
    call _delay_50ms
    custom 0, r23, r17, r5
    bne zero, r6, send_lcd_loop            		    # Caso diferente de "\n" continua no loop enviando
lcd_end:
    ldwio r5, 0(sp)                  				# Se for igual a "\n" restaura o contexto, para de enviar e volta para o ponto anterior
    ldwio r6, 4(sp)
    ldwio r7, 8(sp)
    ldwio ra, 12(sp)
    ldwio r17, 16(sp)
    addi sp, sp, 20                 				# Decrementa o stack pointer que foi usada
    ret                             


# ************************************** SEND CARACTER UART ************************************************
# Rotina para envio de um array de valores amazenado na memoria
# O endereco, na memoria, do texto que serÃ¡ enviado tem que ser colocado no r23
# ***************************************************************************************************** 
send_caracter:
    subi sp, sp, 16                 				# salvando contexto
    nop
    stw r5, 0(sp)                   				# r5 caracter para ser enviado
    stw r6, 4(sp)                  					# r6 registrador de comparacao
    stw r7, 8(sp)                   				# r7 endereco de memoria da string
    stw ra, 12(sp)                  				# Salvando o endereco de retorno
    nop
    add r7, zero, r23              					# Pega a posiÃ§Ã£o de memoria da string e salva em r7
send_loop:    
    ldb r5, 0(r7)                  				 	# LÃª o primeiro caracter
    addi r7, r7, 1                  				# r7 += 1
    subi r6, r5, 0xa                				# Se o valor lido Ã© igual a "\n" o resultado Ã© 0 
    nop
    addi ra, zero, ra_w
    bne zero, r6, PUT_CHAR          				# Caso diferente de "\n" chama o metodo de envio
ra_w:
    bne zero, r6, send_loop            				# Caso diferente de "\n" continua no loop enviando

    ldwio r5, 0(sp)                  				# Se for igual a "\n" restaura o contexto, para de enviar e volta para o ponto anterior
    ldwio r6, 4(sp)
    ldwio r7, 8(sp)
    ldwio ra, 12(sp)
    addi sp, sp, 16                 				# Decrementa o stack pointer que foi usada
    ret                             


# *************************************************************************** 
# Rotina para envia a finalizaÃ§Ã£o de comando, sendo elas \r seguido do \n
# ***************************************************************************
end_comand_at:
    subi sp, sp, 4									# Reseva espaÃ§o na pilha
    stw ra, 0(sp) 									# Salva o endereÃ§o de ra
    addi r5, zero, 0xd								# Adiciona \r em r5
    call PUT_CHAR									# Envia a letra
    addi r5, zero, 0xa								# Adiciona \n em r5
    call PUT_CHAR									# Envia a letra
    ldwio ra, 0(sp)									# Recupera o valor de ra anterior
    addi sp, sp, 4
    ret


# *******************************************************************************
# Rotina para envio de caracteres RS232 UART.
# r4 = Endereco base RS232 UART
# r5 = caractere para ser enviado 
# *******************************************************************************
PUT_CHAR:
    subi sp, sp, 12 							# Reserva espaco na pilha 
    stw r6, 0(sp) 								# Salva os registradores que serÃ£o utilizados 
    stw ra, 4(sp)
	stw r4, 8(sp)
	movia r4, BASE_ADDRESS_UART			# Colocando em r4 o endereco base da uart

    call _delay_50ms
    ldwio r6, 4(r4) 							# Ler registrador de controle da uart 
    andhi r6, r6, 0x00ff 						# Verifica se ha espaco para escrever 
    beq r6, r0, END_PUT 						# Caso nÃ£o tenha, o caracter nÃ£o Ã© enviado 
    stwio r5, 0(r4) 							# Enviando letra 
END_PUT: 
    ldwio r6, 0(sp)								# Recupera registradores
    ldwio ra, 4(sp)
	ldwio r4, 8(sp)
    addi sp, sp, 12
    ret


# # ------------------------------------------- DELAYS -----------------------------------------------
_delay_200ms:
    subi sp, sp, 8                          	# Salvando o contexto
    stw r6, 0(sp)
    stw r9, 4(sp)
	movia r9, 0xCB735                       	# Setando o DELAY 50ms
    add r6, zero, zero							# Zera o registrador r6, adiciona +20ns
d200:
    addi r6, r6, 1       	   					# adiciona um ao contador
    bne r6, r9, d200	                    	# continua chamando a label
	
    ldwio r6, 0(sp)
    ldwio r9, 4(sp)
    addi sp, sp, 8
    ret  										# pc <- ra. Tempo da rotina 199,99996  milisegundos

_delay_50ms:
    subi sp, sp, 8                           	# Salvando o contexto
    stw r6, 0(sp)
    stw r9, 4(sp)
	movia r9, 0x32DCD                       	# Setando o DELAY 50ms
    add r6, zero, zero							# Zera o registrador r6, adiciona +20ns
d50:
    addi r6, r6, 1       	   					# adiciona um ao contador
    bne r6, r9, d50	    	                	# continua chamando a label
	
    ldwio r6, 0(sp)
    ldwio r9, 4(sp)
    addi sp, sp, 8
    ret  										# pc <- ra. Tempo da rotina 49,99996 milisegundos
end:
	br end
.end
