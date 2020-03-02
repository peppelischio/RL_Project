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
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
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
    WZ_FOUND,
    WZ_NOT_FOUND);
  signal state : state_type; -- segnale per la gestione degli START_WAIT


  begin
    process (i_clk, i_rst)
    -- variabili utilizzate
    variable addressToEncode: std_logic_vector(7 downto 0);
    variable wzBase: std_logic_vector(7 downto 0); --indirizzo base della working zone letta
    variable wzCounter: integer range -1 to 7; --contatore che tiene traccia degli indirizzi base delle wz finora analizzati
    variable wzOffset: integer; --offset dell'indirizzo da codificare rispetto alla base della WZ che si sta analizzando
    variable out_val_true: std_logic_vector (7 downto 0); --valore di test
    variable out_val_false: std_logic_vector (7 downto 0); -- valore di test
    -- da completare --

    begin
      if (i_rst = '1') then 	--gestione reset asincrono con i_rst
        state <= RESET;		--vado nello stato di RESET
      end if;

      if (rising_edge(i_clk)) then
        case state is

          when RESET =>
            if (i_start = '1') then --inizializzazione segnali e variabili all'arrivo del segnale di START
              addressToEncode := "00000000";
              o_data := "00000000";
              wzBase := "00000000";
              wzCounter := -1;
              o_en <= '0';
              o_we <= '0';
              state <= RQST_ADDR;

              out_val_true := 01010101;
              out_val_false := 10101010;
              -- DA COMPLETARE --
            else
              state <= RESET;

            end if;

          when RQST_ADDR => --richiede l'indirizzo da leggere in memoria
            o_en <= '1';
            o_we <= '0';
            o_address <= "0000000000001000"; --lettura dell'indirizzo 8, dove è memorizzato l'indirizzo da codificare
            state <= WAIT_WZ;

          when WAIT_ADDR => --aspetta un ciclo di clock per leggere da memoria l'indirizzo da codificare
            state <= READ_ADDR;

          when READ_ADDR => --legge l'indirizzo da codificare dalla memoria e lo inserisce in una variabile
            addressToEncode := i_data;
            o_en <= '0';
            state <= RQST_WZ

          when RQST_WZ => --richiesta di lettura in memoria
            wzCounter := wzCounter + 1; --incremento il contatore per tenere traccia delle WZ che ho già analizzato
            if (wzCounter < 8)
              o_en <= '1';
              o_we <= '0';
              o_address <= "0000000000000000" + unsigned(wzCounter)); --definisco l'address di memoria che voglio leggere, incrementandolo ad ogni ciclo, qualora non venisse trovata una corrispondenza con una WZ
              state <= WAIT_WZ;
            else --quando wzCounter arriva ad 8 vuol dire che ho già fatto il check su tutti gli indirizzi base delle WZ, non trovando nessuna corrispondenza
              state <= WZ_NOT_FOUND;

            end if;

          when WAIT_WZ => --aspetta un ciclo di clock per leggere da memoria l'indirizzo base di una WZ
            state <= READ_WZ;

          when READ_WZ => --legge l'indirizzo base della WZ dalla memoria e lo inserisce in una variabile
            wzBase := i_data;
            o_en <= '0';
            state <= CMP_WZ_ADDR;

          when CMP_WZ_ADDR =>
            --faccio tipo un check sfruttando le sottrazioni
            --se -1 < addressToEncode - wzBase < 4
            wzOffset := to_integer(addressToEncode) - to_integer(wzBase);
            if ((wzOffset > -1) and (wzOffset < 4)) then  --caso in cui l'indirizzo appartiene ad una working zone
              state <= WZ_FOUND;
            else
              state <= RQST_WZ;

            end if;

          when WZ_FOUND =>
            --qui devo cominciare a operare sulla codifica dell'indirizzo
            --appartenente alla wz
            o_en <= '1';
            o_we <= '1';
            o_address <= '0000000000001001';
            o_data <= out_val_true;
            state <= RESET;

           

          end case;
        end if;
      end process;
    end Behavioral;
