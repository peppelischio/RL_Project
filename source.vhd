------ Libraries and entity ------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; --Needed to perform arithmetical operations on some values.

entity project_reti_logiche is
port (
		i_clk          : in  std_logic;  -- CLOCK signal
		i_start        : in  std_logic;  -- START signal
		i_rst          : in  std_logic;  -- RESET signal
		o_done         : out std_logic;  -- DONE  signal

		i_data         : in  std_logic_vector(7 downto 0);   --[RAM]: input  
		o_address      : out std_logic_vector(15 downto 0);  --[RAM]: output
		o_en           : out std_logic;                      --[RAM]: output
		o_we           : out std_logic;                      --[RAM]: output
		o_data         : out std_logic_vector (7 downto 0)   --[RAM]: output
	);

end project_reti_logiche;
