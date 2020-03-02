------------------------------------------------------------------------------
--
--              PROVA FINALE - PROGETTO DI RETI LOGICHE 2019/2020
--                      --  INGEGNERIA INFORMATICA  --
--
-- 					              Sezione prof. Fabio Salice
--
	                                  --
--
-- 		                           Studenti:
--
--              Lorenzo Gadolini (mat. 846882; cod.pers. 10522690)
--		          Giuseppe Lischio (mat. 847367; cod.pers. 10523449)
--
------------------------------------------------------------------------------

------ LIBRERIE ------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--- ENTITY DEL PROGETTO ---
entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0); --indirizzo di memoria per cui si richiede lettura/scrittura
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;	--segnale di ENABLE per poter comunicare con la memoria
           o_we : out STD_LOGIC;	--segnale di abilitazione alla scrittura in memoria
           o_data : out STD_LOGIC_VECTOR (7 downto 0)); --dato da scrivere in memoria
end project_reti_logiche;

-- BEHAVIORAL ARCHITECTURE --
architecture Behavioral of project_reti_logiche is
  type state_type is (
    RESET,
    RQST_ADDR,
    WAIT_ADDR,
    READ_ADDR,
    RQST_WZ,
    WAIT_WZ,
    READ_WZ,
    CMP_WZ_ADDR,
    ONEHOT_ENCODE,
    WZ_FOUND,
    WZ_NOT_FOUND,
    MEM_WRITE_WAIT,
    MEM_WRITE_DONE,
    DONE,
    FSM_CLOSE);
  signal state : state_type;  -- Segnale che gestisce lo stato corrente e a cui assegnare lo stato futuro

  begin
    process (i_clk, i_rst)
    -- Variabili
    variable addressToEncode: std_logic_vector(7 downto 0);   -- std_logic_vector in cui salvare l'indirizzo su cui effettuare l'encoding
    variable wzBase: std_logic_vector(7 downto 0);            --indirizzo base della working zone letta
    variable wzCounter: integer range -1 to 7;                --contatore che tiene traccia degli indirizzi base delle wz finora analizzati
    variable wzOffset: integer;                               --offset dell'indirizzo da codificare rispetto alla base della WZ che si sta analizzando
    variable out_val_true: std_logic_vector (7 downto 0);     --valore di test
    variable out_val_false: std_logic_vector (7 downto 0);    -- valore di test
    variable encodedOutput: std_logic_vector (7 downto 0);    -- contiene l'indirizzo codificato rispetto ad una WZ.
    variable onehotOffset: std_logic_vector (3 downto 0);     -- Contiene la codifica onehot dell'offset

    --Gestione asincrona del segnale di reset.
    begin
      if (i_rst = '1') then
        state <= RESET;
      end if;

      if (rising_edge(i_clk)) then
        case state is
          when RESET =>                       --Stato di inizializzazione
            if (i_start = '1') then
              addressToEncode := "00000000";
              o_data := "00000000";
              wzBase := "00000000";
              wzCounter := -1;
              o_en <= '0';
              o_we <= '0';
              state <= RQST_ADDR;

              out_val_true := 01010101;  --Test
              out_val_false := 10101010; --Test
              -- DA COMPLETARE --
            else
              state <= RESET;
            end if;

          when RQST_ADDR =>                         --richiede l'indirizzo da leggere in memoria
            o_en <= '1';
            o_we <= '0';
            o_address <= "0000000000001000";        --lettura dell'indirizzo 8, dove è memorizzato l'indirizzo da codificare
            state <= WAIT_WZ;


          when WAIT_ADDR =>                         --aspetta un ciclo di clock per leggere da memoria l'indirizzo da codificare
            state <= READ_ADDR;


          when READ_ADDR =>                         --legge l'indirizzo da codificare dalla memoria e lo inserisce in una variabile
            addressToEncode := i_data;
            o_en <= '0';
            state <= RQST_WZ


          when RQST_WZ =>                               --richiesta di lettura in memoria
            wzCounter := wzCounter + 1;                 --incremento il contatore per tenere traccia delle WZ che ho già analizzato
            if (wzCounter < 8) then
              o_en <= '1';
              o_we <= '0';
              o_address <= "0000000000000000" + unsigned(wzCounter)); --definisco l'address di memoria che voglio leggere, incrementandolo ad ogni ciclo, qualora non venisse trovata una corrispondenza con una WZ
              state <= WAIT_WZ;
            else                                        --quando wzCounter arriva ad 8 vuol dire che ho già fatto il check su tutti gli indirizzi base delle WZ, non trovando nessuna corrispondenza
              state <= WZ_NOT_FOUND;
            end if;


          when WAIT_WZ =>                               --aspetta un ciclo di clock per leggere da memoria l'indirizzo base di una WZ
            state <= READ_WZ;


          when READ_WZ =>                               --legge l'indirizzo base della WZ dalla memoria e lo inserisce in una variabile
            wzBase := i_data;
            o_en <= '0';
            state <= CMP_WZ_ADDR;

          --Esegue il check di appartenenza ad una WZ. Sottrae l'indirizzo da verificare alla base della WZ, se il risultato è compreso fra 0 e 3 allora cade nella WZ
          when CMP_WZ_ADDR =>
            wzOffset := to_integer(addressToEncode) - to_integer(wzBase);
            if ((wzOffset > -1) and (wzOffset < 4)) then
              state <= ONEHOT_ENCODE;
            else
              state <= RQST_WZ;
            end if;


              --TODO prima di andare a WZ found faccio l' encoding in one hot


          when ONEHOT_ENCODE =>  -- Lookup Table per la codifica dell'offset in onehot
            begin
                case wzOffset is
                  when 0 => onehotOffset <= "0001";
                  when 1 => onehotOffset <= "0010";
                  when 2 => onehotOffset <= "0100";
                  when 3 => onehotOffset <= "1000";
                end case;

          state <= WZ_FOUND;



          when WZ_FOUND =>

            o_en <= '1';
            o_we <= '1';
            o_address <= '0000000000001001';
            o_data <= '1' & std_logic_vector(to_unsigned(wzCounter, 3)) & onehotOffset;
           state <= MEM_WRITE_WAIT;


           when WZ_NOT_FOUND =>     -- Non ho trovato una WZ di appartenenza, il segnale viene stampato come unsigned in memoria.
             o_en <= '1';
             o_we <= '1';
             o_address <= '0000000000001001';
             o_data <= addressToEncode;
             state <= MEM_WRITE_WAIT;


          when MEM_WRITE_WAIT  =>  --Attendo un clk per far attivare la memoria in uscita
          state <= MEM_WRITE_DONE;


          when MEM_WRITE_DONE =>  --Il dato è arrivato alla memoria e posso abbassare i segnali
          o_en <= '0';
          o_we <= '0';
          state <= DONE;


          when DONE =>                -- Ho stampato un risultato, entro nella fase di chiusura segnalando al test bench che ho finito
          o_done <= '1';
          state <= FSM_CLOSE;


          when FSM_CLOSE =>           -- il test bench riceve il segnale di done, in questo stato attendo che start torni a 0 prima di andare a reset.
          if (i_start = '1') then
            state <= FSM_CLOSE
          elsif (i_start ='0') then
            o_done <= '0';
            state <= RESET;
          end if;

        end case;
      end if;
    end process;
  end Behavioral;
