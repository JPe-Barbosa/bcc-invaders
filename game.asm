;No jogo temos a pilha onde é armazenado os valores dos registradores
;ao entrar em uma "função". No fim desta os valores são restaurados com um 
;pop.
;
;		push -> manda para a pilha
;		pop -> tira da pilha e armazena no registrador
main:
    .loop:
        ; return address for the call to the vtable method
        loadn r0, #main.loop
        push r0

        loadn r0, #vars.state.vtable
        load r1, vars.state
        add r0, r0, r1
        loadi r0, r0
        push r0

        rts

    halt

vars:
	;tabela de funções, usada na main
    .state: #d16 STATE_MAIN
        ..vtable: #d16 screen.main, screen.game, screen.game_over

    .enemies:
        ..offset: #d16 ENEMIES_START_OFFSET
        ..is_dead: #res ENEMIES_COUNT
        ..direction: #d16 1

    .ray:
        ..offset: #d16 0

    .player:
        ..offset: #d16 0
        ..can_shoot: #d16 0
        ..lost: #d16 0
        ..score: #d16 0

enemies:
    .render:
        ; save
        push r0
        push r1
        push r2
        push r3
        push r4
        push r5
        push r6
        push r7

        loadn r0, #ENEMIES_COUNT
        xor r1, r1, r1
        loadn r2, #vars.enemies.is_dead
        load r3, vars.enemies.offset
        loadn r4, #10
        loadn r5, #40

		;r0 -> qtd. inimigos
		;r1 -> contador (0)
		;r2 - > vetor de se um inimigo esta morto
		;r3 -> offset dos inimigos
		;r4 -> qnt. colunas de inimigos
		;r5 -> qnt colunas da tela.

        ..loop:
			;loop verificando se chegou na qnt. de inimigos
            cmp r1, r0
            jeq ..return

            loadi r6, r2
			;se for zero o inimigo está morto e o código vai para
			;..continue.
            dec r6
            jz ..continue

			; r6 -> linha 
			; r7 -> coluna 

			;descobrindo a linha do inimigo
            div r6, r1, r4
			;descobrindo a posição na tela do inimigo
            mul r6, r6, r5
			;descobrindo o coluna do inimigo
            mod r7, r1, r4
			;no jogo os inimigos estão separados de 2 em 2
            shiftl0 r7, #1

			;descobrindo o endereço linear na tela do inimigo.
            add r6, r6, r7
            add r6, r6, r3
			;carrega o caractere do inimigo 
            loadn r7, #"O"
			;imprime na tela
            outchar r7, r6

        ..continue:
            inc r1
            inc r2

            jmp ..loop

        ..return:
            ; restore
            pop r7
            pop r6
            pop r5
            pop r4
            pop r3
            pop r2
            pop r1
            pop r0

            rts

    .init:
        ; save
        push r0
        push r1
        push r2
        push r3
		
		;carrega a posição inicial
        loadn r0, #ENEMIES_START_OFFSET
		
        store vars.enemies.offset, r0

        loadn r0, #ENEMIES_COUNT
        xor r1, r1, r1
        loadn r2, #vars.enemies.is_dead
        xor r3, r3, r3

        ..loop:
            cmp r1, r0
            jeq ..return

            storei r2, r3
            inc r1
            inc r2
            
            jmp ..loop

        ..return:
            ; restore
            pop r3
            pop r2
            pop r1
            pop r0

            rts

    .update:
        ; save
        push r0
        push r1

        load r0, vars.enemies.offset
        load r1, vars.enemies.direction
        add r0, r0, r1
        store vars.enemies.offset, r0

        ; restore
        pop r1
        pop r0

        jmp .update_direction
    
    .update_direction:
        ; save
        push r0
        push r1
        push r2
        push r3
        push r4
        push r5
        push r6
        push r7

        loadn r0, #ENEMIES_COUNT
        xor r1, r1, r1 ; r1 = 0
        loadn r2, #vars.enemies.is_dead
        load r3, vars.enemies.offset
        loadn r4, #10
        loadn r5, #40

		;r0 -> qtd. inimigos
		;r1 -> contador (0)
		;r2 - > vetor de se um inimigo esta morto
		;r3 -> offset dos inimigos
		;r4 -> qnt. colunas de inimigos
		;r5 -> qnt colunas da tela.


        ..loop:
            cmp r1, r0
            jeq ..return
            loadi r6, r2
            dec r6
            jz ..continue



           	;descobrindo a linha do inimigo
            div r6, r1, r4
			;descobrindo a posição na tela do inimigo
            mul r6, r6, r5
			;descobrindo o coluna do inimigo
            mod r7, r1, r4
			;no jogo os inimigos estão separados de 2 em 2
            shiftl0 r7, #1

			;descobrindo o endereço linear na tela do inimigo.
            add r6, r6, r7
            add r6, r6, r3

			;parte responsavel por checar se os fantasmas chegaram ao fim
            loadn r7, #1160
            cmp r6, r7
            jeg ..game_over

            mod r6, r6, r5 ; r6 = n // 10 * 40 + n % 40 + offset
            mov r7, r5
            dec r7
            cmp r6, r7 
            jeq ..move_left  ; enemies reached the end of the row
            xor r7, r7, r7
            cmp r6, r7
            jeq ..move_right ; enemies reached the start of the row

        ..continue:
            inc r1
            inc r2

            jmp ..loop

        ..move_left:
            loadn r0, #-1
            jmp ..change_direction

        ..move_right:
            loadn r0, #1
            jmp ..change_direction

        ..game_over:
            loadn r0, #STATE_GAME_OVER
            store vars.state, r0
            jmp ..return

        ..change_direction:
            store vars.enemies.direction, r0
            add r0, r3, r5
            store vars.enemies.offset, r0

        ..return:
            ; restore
            pop r7
            pop r6
            pop r5
            pop r4
            pop r3
            pop r2
            pop r1
            pop r0

            rts

ray:
    .render:
        ; save
        push r0
        push r1

        loadn r0, #"|"
        load r1, vars.ray.offset
        outchar r0, r1

        ; restore
        pop r1
        pop r0

        rts

    .init:
        ; save
        push r0

        loadn r0, #-1
        store vars.ray.offset, r0

        ; restore
        pop r0

        rts

    .check_collision:
        push r0
        push r1
        push r2
        push r3
        push r4
        push r5
        push r6
        push r7

        loadn r0, #ENEMIES_COUNT
        xor r1, r1, r1 ; r1 = 0
        loadn r2, #vars.enemies.is_dead
        load r3, vars.enemies.offset
        loadn r4, #10
        loadn r5, #40

        ..loop:
            cmp r1, r0
            jeq ..return
            loadi r6, r2
            dec r6
            jz ..continue

            div r6, r1, r4
            mul r6, r6, r5
            mod r7, r1, r4
            shiftl0 r7, #1
            add r6, r6, r7
            add r6, r6, r3
            load r7, vars.ray.offset
            cmp r6, r7
            jne ..continue
            loadn r1, #1
            storei r2, r1
            store vars.player.can_shoot, r1
            loadn r1, #-1
            store vars.ray.offset, r1

            load r1, vars.player.score
            inc r1
            store vars.player.score, r1

            loadn r0, #ENEMIES_COUNT
            cmp r0, r1
            jeq ..game_over
            jmp ..return

        ..continue:
            inc r1
            inc r2

            jmp ..loop

        ..game_over:
            loadn r0, #STATE_GAME_OVER
    	    store vars.state, r0
    	    jmp ..return

        ..return:
            ; restore
            pop r7
            pop r6
            pop r5
            pop r4
            pop r3
            pop r2
            pop r1
            pop r0

            rts

    .update:
        ; save
        push r0
        push r1

        load r0, vars.player.can_shoot
        dec r0
        jz ..return

        load r0, vars.ray.offset
        loadn r1, #40
        sub r0, r0, r1
        cmp r0, r1
        jeg ..store
        loadn r0, #1
        store vars.player.can_shoot, r0
        loadn r0, #-1

        ..store:
            store vars.ray.offset, r0

        ..return:
            ; restore
            pop r1
            pop r0

            ; tail-call
            jmp .check_collision

player:
    .render:
        ; save
        push r0
        push r1

        loadn r0, #"@"
        load r1, vars.player.offset
        outchar r0, r1

        ; restore
        pop r1
        pop r0

        rts

    .init:
        ; save
        push r0

        loadn r0, #PLAYER_START_OFFSET
        store vars.player.offset, r0

        xor r0, r0, r0
        store vars.player.score, r0
        store vars.player.lost, r0

        inc r0
        store vars.player.can_shoot, r0

        ; restore
        pop r0

        rts

    .update:
        ; save
        push r0
        push r1
        
        inchar r0
        loadn r1, #"D"
        cmp r0, r1
        jeq ..move_right

        loadn r1, #"A"
        cmp r0, r1
        jeq ..move_left

        loadn r1, #" "
        cmp r0, r1
        jeq ..shoot

        ..return:
            ; restore
            pop r1
            pop r0

            rts

        ..move_right:
            load r0, vars.player.offset
            loadn r1, #29 * 40 + 39
            cmp r0, r1
            jeq ..return
            inc r0

            store vars.player.offset, r0

            jmp ..return

        ..move_left:
            load r0, vars.player.offset
            loadn r1, #29 * 40
            cmp r0, r1
            jeq ..return
            dec r0

            store vars.player.offset, r0

            jmp ..return

        ..shoot:
            load r0, vars.player.can_shoot ; if player.can_shoot else return
            dec r0
            jnz ..return

            xor r0, r0, r0
            store vars.player.can_shoot, r0
            load r0, vars.player.offset
            store vars.ray.offset, r0

            jmp ..return

    .show_score:
        ; save
        push r0
        push r1
        push r2
        push r3
        push r4
        push r5

    	mov r4, r0
        load r0, vars.player.score
        loadn r1, #10
        loadn r3, #"0"
        xor r5, r5, r5

        ..loop:
            mod r2, r0, r1
            div r0, r0, r1
            add r2, r2, r3
            outchar r2, r4
            dec r4

            cmp r0, r5
            jne ..loop

        ..return:
            ; restore
            pop r5
            pop r4
            pop r3
            pop r2
            pop r1
            pop r0

            rts

screen:
    .render:
        ; save
        push r0
        push r1
        push r2
        push r3

        xor r1, r1, r1
        loadn r2, #1200

        ..loop:
            cmp r1, r2
            jeq ..return
            loadi r3, r0
            outchar r3, r1
            inc r0
            inc r1

            jmp ..loop

        ..return:
            ; restore
            pop r3
            pop r2
            pop r1
            pop r0

            rts

    .main:
        ; save
        push r0
        push r1

        loadn r0, #screens.main
        call .render
        loadn r1, #0x0D

        ..loop:
            inchar r0
            cmp r0, r1
            jne ..loop

        loadn r0, #STATE_GAME
        store vars.state, r0

        ; restore
        pop r1
        pop r0

        rts
    ; entra nesta função ao mudar de tela e inicializa tudo 
    .game:
        call ray.init
        call enemies.init
        call player.init

        loadn r7, #0

        ..loop:
            loadn r6, #0x100
            mod r6, r7, r6
            cz ray.update

            loadn r6, #0x500
            mod r6, r7, r6
            cz enemies.update

            loadn r6, #0x100
            mod r6, r7, r6
            cz player.update

            loadn r6, #0x100
            mod r6, r7, r6
            jnz ...continue

            loadn r0, #screens.clear
            call .render
            loadn r0, #11
            call player.show_score

            call ray.render
            call enemies.render
            call player.render

            ...continue:
                inc r7

                loadn r0, #STATE_GAME
                load r1, vars.state
                cmp r0, r1

                jeq ..loop
        rts
    
    .game_over:
        ; save
        push r0
        push r1

        loadn r0, #screens.game_over
        call .render
        loadn r0, #540
        call player.show_score

        loadn r1, #0x0D

        ..loop:
            inchar r0
            cmp r0, r1
            jne ..loop

        loadn r0, #STATE_GAME
        store vars.state, r0

        ; restore
        pop r1
        pop r0

        rts

screens:
    .main:
        string "                                        "
        string "                                        "
        string "                                        "
        string "              .__  __  __               "
        string "              [__)/  `/  `              "
        string "              [__)\\__.\\__.              "
        string "                                        "
        string "        ._.            .                "
        string "         | ._ .  , _. _| _ ._. __       "
        string "        _|_[ ) \\/ (_](_](/,[  _)        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "          Press enter to start          "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "

    .clear:
        string "SCORE:                                  "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "

    .game_over:
        string "                                        "
        string "                                        "
        string "                                        "
        string "          ___   __   _  _  ____         "
        string "         / __) / _\\ ( \\/ )(  __)        "
        string "        ( (_ \\/    \\/ \\/ \\ ) _)         "
        string "         \\___/\\_/\\_/\\_)(_/(____)        "
        string "          __   _  _  ____  ____         "
        string "         /  \\ / )( \\(  __)(  _ \\        "
        string "        (  O )\\ \\/ / ) _)  )   /        "
        string "         \\__/  \\__/ (____)(__\\_)        "
        string "                                        "
        string "                                        "
        string "         Score:                         "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "                                        "
        string "       Press enter to play again.       "
        string "                                        "
        string "                                        "
        string "                                        "


end:

STATE_MAIN=0
STATE_GAME=1
STATE_GAME_OVER=2

ENEMIES_START_OFFSET=42
ENEMIES_COUNT=50

PLAYER_START_OFFSET=29 * 40 + 20
