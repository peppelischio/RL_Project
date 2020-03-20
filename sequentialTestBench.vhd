library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD		: time := 100 ns;
signal   tb_done		: std_logic;
signal   mem_address		: std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst	                : std_logic := '0';
signal   tb_start		: std_logic := '0';
signal   tb_clk		        : std_logic := '0';
signal   mem_o_data,mem_i_data	: std_logic_vector (7 downto 0);
signal   enable_wire  		: std_logic;
signal   mem_we		        : std_logic;

--variabili e segnali per gestione file di testo
file testValuesFile : text open read_mode is "test13032020.txt";
shared variable row : line; --linea del file di testo che viene letto
shared variable dataIn : integer;
shared variable expectedResult : integer; --risultato atteso dopo la codifica dell'indirizzo
shared variable testCount : integer; --contatore dei casi di test che sono stati svolti
signal load_ram : std_logic; --segnale per avviare il caricamento di nuovi dati di test da file
type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

--inizializzazione a zero delle celle della memoria
signal RAM: ram_type := (others => (others =>'0'));

component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_start       => tb_start,
          i_rst      	=> tb_rst,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    	=> mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk, load_ram)
begin
    --quando il segnale load_ram sale, viene letta una nuova riga nel file
    --contenente i casi di test da effettuare in sequenza
    if load_ram'event and load_ram = '1' then
      readline(testValuesFile, row);
      for i in 0 to 8 loop --loop per inserire in ram gli indirizzi delle wz
        read(row, dataIn);
        RAM(i) <= std_logic_vector(to_unsigned(dataIn, 8));
      end loop;
      read(row, expectedResult); --lettura del valore atteso dopo la codifica
      RAM(9) <= "00000000"; --inizializzazione dell'indirizzo in cui memorizzare il valore codificato
    end if;

    if tb_clk'event and tb_clk = '1' then
        if enable_wire = '1' then
            if mem_we = '1' then
                RAM(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM(conv_integer(mem_address)) after 1 ns;
            end if;
        end if;
    end if;
end process;


test : process is
begin
    testCount := 0;
    load_ram <= '0';
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    tb_rst <= '0';

    --loop fino a che non si arriva alla fine del file di testo
    --contenente i casi di test sequenziali
    while (not endfile(testValuesFile)) loop
      testCount := testCount + 1;
      load_ram <= '1'; --alzando il segnale vengono caricati i nuovi valori da testare
      wait for c_CLOCK_PERIOD;
      load_ram <= '0';
      wait for c_CLOCK_PERIOD;
      tb_start <= '1';
      wait for c_CLOCK_PERIOD;
      wait until tb_done = '1';
      wait for c_CLOCK_PERIOD;
      tb_start <= '0';
      wait until tb_done = '0';

      -- Assertions
      assert RAM(9) = std_logic_vector(to_unsigned(expectedResult, 8)) report "TEST #" & integer'image(testCount) & " FALLITO. Expected " & integer'image(expectedResult) & " but found: " & integer'image(to_integer(unsigned(RAM(9))))  severity failure;
      report integer'image(testCount) & "test fatto" & integer'image(expectedResult);
    end loop;

    assert false report "Simulation Ended!, SUPERATI TUTTI I " & integer'image(testCount) & " TEST" severity failure;
end process test;

end projecttb;
