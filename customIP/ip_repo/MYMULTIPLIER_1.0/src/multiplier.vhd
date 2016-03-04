library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_mult is
	generic(
		size : integer
	);
	port(
		answer_out    : out std_logic_vector(size * 2 - 1 downto 0);
		ans_ready_out : out std_logic;
		a_in          : in  std_logic_vector(size - 1 downto 0);
		b_in          : in  std_logic_vector(size - 1 downto 0);
		start_calc_in : in  std_logic;
		clk           : in  std_logic;
		rst           : in  std_logic
	);
end entity top_level_mult;

architecture RTL of top_level_mult is
	constant zero    : std_logic_vector(size - 1 downto 0)     := (others => '0');
	signal ans_store : std_logic_vector(size * 2 - 1 downto 0) := (others => '0');
	signal a_store   : std_logic_vector(size * 2 - 1 downto 0) := (others => '0');
	signal b_store   : std_logic_vector(size - 1 downto 0)     := (others => '0');
	signal ans_rdy   : std_logic                               := '1';
begin
	ans_ready_out <= ans_rdy;
	answer_out    <= ans_store when ans_rdy = '1' else (others => '0');
	process(clk, rst, a_in, b_in, start_calc_in)
	begin
		if rst = '1' then
			ans_store <= (others => '0');
			a_store   <= (others => '0');
			b_store   <= (others => '0');
			ans_rdy   <= '1';
		elsif start_calc_in = '1' then
			ans_store(size - 1 downto 0) <= (others => '0');
			a_store(size - 1 downto 0)   <= a_in;
			b_store                      <= b_in;
			ans_rdy                      <= '0';
		elsif rising_edge(clk) then
			if b_store(0) = '1' then
				ans_store <= std_logic_vector(unsigned(ans_store) + unsigned(a_store));
			end if;
			if b_store = zero then
				ans_rdy <= '1';
			end if;
			a_store <= a_store(a_store'left - 1 downto 0) & '0';
			b_store <= '0' & b_store(b_store'left downto 1);
		end if;
	end process;

end architecture RTL;
