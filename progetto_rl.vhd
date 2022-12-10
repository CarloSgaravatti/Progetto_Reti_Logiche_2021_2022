----------------------------------------------------------------------------------
--
-- Prova Finale - Progetto di Reti Logiche - 2021/2022
-- Prof. Gianluca Palermo
--
-- Carlo Sgaravatti (10660072/937539)
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Convolutore
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity convolutore is
    port(
        u_k : in std_logic;
        clk : in std_logic;
        rst : in std_logic;
        done : in std_logic;
        p1_k : out std_logic;
        p2_k : out std_logic
    );
end convolutore; 

architecture behavioral of convolutore is
    signal curr_state, next_state : std_logic_vector(1 downto 0);
    signal p1_k_next, p2_k_next : std_logic := '0';
begin
    state_output : process (clk, rst)
    begin
        if rst = '1' then
            curr_state <= "00";
        elsif rising_edge(clk) then
            if done = '0' then
                curr_state <= next_state;
                p1_k <= p1_k_next;
                p2_k <= p2_k_next;
            end if;
        end if;
    end process;
    
    delta_lambda : process (u_k, curr_state)
    begin
        p1_k_next <= '0';
        p2_k_next <= '0';
        
        case curr_state is
            when "00" =>
                if u_k = '1' then
                    next_state <= "10";
                    p1_k_next <= '1';
                    p2_k_next <= '1';
                else 
                    next_state <= "00";
                    p1_k_next <= '0';
                    p2_k_next <= '0';
                end if;
            when "01" =>
                if u_k = '1' then
                    next_state <= "10";
                    p1_k_next <= '0';
                    p2_k_next <= '0';
                else 
                    next_state <= "00";
                    p1_k_next <= '1';
                    p2_k_next <= '1';
                end if;
            when "10" =>
                if u_k = '1' then
                    next_state <= "11";
                    p1_k_next <= '1';
                    p2_k_next <= '0';
                else 
                    next_state <= "01";
                    p1_k_next <= '0';
                    p2_k_next <= '1';
                end if;
            when "11" =>
                if u_k = '1' then
                    next_state <= "11";
                    p1_k_next <= '0';
                    p2_k_next <= '1';
                else 
                    next_state <= "01";
                    p1_k_next <= '1';
                    p2_k_next <= '0';
                end if;
            when others =>
                next_state <= "--";
        end case;
    end process;
end behavioral;

----------------------------------------------------------------------------------
-- Serializzatore e deserializzatore
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity serializzatore_deserializzatore is
    port(
        i_data_ser : in std_logic_vector(7 downto 0);
        i_rst_ser : in std_logic;
        i_clk : in std_logic;
        i_rst_conv : in std_logic;
        o_data_deser : out std_logic_vector(15 downto 0);
        o_ready : out std_logic
    );
end serializzatore_deserializzatore;

architecture structural of serializzatore_deserializzatore is
    signal next_state, current_state : std_logic_vector(3 downto 0);
    signal done, done_next, i_conv, i_conv_next : std_logic := '0';
    signal o1_conv, o2_conv : std_logic := '0';
    signal o_ready_next : std_logic := '0';
    signal o_data_deser_next, o_data_deser_buf : std_logic_vector(15 downto 0) := "0000000000000000";
    
    component convolutore is
        port(
            u_k : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            done : in std_logic;
            p1_k : out std_logic;
            p2_k : out std_logic
        );
    end component;

begin
    conv: convolutore
        port map(u_k => i_conv, clk => i_clk, rst => i_rst_conv,done => done, p1_k => o1_conv, p2_k => o2_conv); 

    state_output : process (i_clk, i_rst_ser)
    begin
        if i_rst_ser = '1' then
            current_state <= "0000";
            o_ready <= '0';
        elsif rising_edge(i_clk) then
            current_state <= next_state;
            done <= done_next;
            o_ready <= o_ready_next;
            o_data_deser <= o_data_deser_next;
            o_data_deser_buf <= o_data_deser_next;
            i_conv <= i_conv_next;
        end if;
    end process;
    
    delta_lambda : process (current_state, i_conv, i_data_ser, done, o_data_deser_buf, o1_conv, o2_conv)
    begin
        done_next <= done;
        next_state <= current_state;
        o_ready_next <= '0';
        i_conv_next <= i_conv;
        o_data_deser_next <= o_data_deser_buf;
        
        case current_state is
            when "0000" =>
                next_state <= "0001";
                done_next <= '0';
                i_conv_next <= i_data_ser(7);
            when "0001" =>
                next_state <= "0010";
                i_conv_next <= i_data_ser(6);
            when "0010" =>
                next_state <= "0011";
                i_conv_next <= i_data_ser(5);
                o_data_deser_next(15) <= o1_conv;
                o_data_deser_next(14) <= o2_conv;
            when "0011" =>
                next_state <= "0100";
                i_conv_next <= i_data_ser(4);
                o_data_deser_next(13) <= o1_conv;
                o_data_deser_next(12) <= o2_conv;
            when "0100" =>
                next_state <= "0101";
                i_conv_next <= i_data_ser(3);
                o_data_deser_next(11) <= o1_conv;
                o_data_deser_next(10) <= o2_conv;
            when "0101" =>
                next_state <= "0110";
                i_conv_next <= i_data_ser(2);
                o_data_deser_next(9) <= o1_conv;
                o_data_deser_next(8) <= o2_conv;
            when "0110" =>
                next_state <= "0111";
                i_conv_next <= i_data_ser(1);
                o_data_deser_next(7) <= o1_conv;
                o_data_deser_next(6) <= o2_conv;
            when "0111" =>
                next_state <= "1000";
                i_conv_next <= i_data_ser(0);
                o_data_deser_next(5) <= o1_conv;
                o_data_deser_next(4) <= o2_conv;
            when "1000" =>
                next_state <= "1001";
                o_data_deser_next(3) <= o1_conv;
                o_data_deser_next(2) <= o2_conv;
                done_next <= '1';
            when "1001" =>
                o_data_deser_next(1) <= o1_conv;
                o_data_deser_next(0) <= o2_conv;
                o_ready_next <= '1';   
            when others =>
                next_state <= "----";
        end case;
    end process;
end structural;
----------------------------------------------------------------------------------
-- Top module
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is(
        RST,
        START,
        READ_NUM_BYTE,
        SAVE_NUM_BYTE,
        SET_ADDR,
        READ_WORD,
        SAVE_WORD,
        CALC_OUT,
        MEM_WRITE_FIRST,
        MEM_WRITE_SECOND,
        DONE
    );
    signal current_state, next_state : state_type;
    signal rst_ser, rst_ser_next : std_logic := '0';
    signal end_calc : std_logic;
    signal o_data_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
    signal rst_conv, rst_conv_next : std_logic := '0';
    signal data_ser, data_ser_next : std_logic_vector(7 downto 0) := "00000000";
    signal num_word_in, num_word_in_next : std_logic_vector(7 downto 0) := "00000000";
    signal o_address_read, o_address_read_next : std_logic_vector(15 downto 0) := "0000000000000000";
    signal o_address_next : std_logic_vector(15 downto 0) := "0000000000000000";
    signal o_en_next, o_we_next, o_done_next : std_logic := '0';
    signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
     
    component serializzatore_deserializzatore is
        port(
            i_data_ser : in std_logic_vector(7 downto 0);
            i_rst_ser : in std_logic;
            i_clk : in std_logic;
            i_rst_conv : in std_logic;
            o_data_deser : out std_logic_vector(15 downto 0);
            o_ready : out std_logic
        );
    end component;
begin
    sd: serializzatore_deserializzatore
        port map(i_data_ser => data_ser, i_rst_ser => rst_ser, i_clk => i_clk, 
                    i_rst_conv => rst_conv, o_data_deser => o_data_tmp, o_ready => end_calc);
                    
    state_output : process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            current_state <= RST;
            o_en <= '0';
            o_we <= '0';
            o_address <= "0000000000000000";
        elsif rising_edge(i_clk) then
            current_state <= next_state;
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_address <= o_address_next;
            o_data <= o_data_next;
            o_done <= o_done_next;
            rst_conv <= rst_conv_next;
            rst_ser <= rst_ser_next;
            data_ser <= data_ser_next;
            num_word_in <= num_word_in_next;
            o_address_read <= o_address_read_next;
        end if;
    end process;
    
    delta_lambda : process (current_state, i_start, i_data, end_calc, num_word_in, o_data_tmp,
                            o_address_read, data_ser, rst_ser, rst_conv)
        variable o_address_tmp : std_logic_vector(15 downto 0);
    begin
        o_en_next <= '0';
        o_we_next <= '0';
        o_done_next <= '0';
        o_address_next <= "0000000000000000";
        o_data_next <= "00000000";
        rst_conv_next <= '0';
        rst_ser_next <= '0';
        data_ser_next <= data_ser;
        next_state <= current_state;
        num_word_in_next <= num_word_in;
        o_address_read_next <= o_address_read;
        
        case current_state is
            when RST =>
                if i_start = '1' then
                    next_state <= START;
                end if;
            when START =>
                o_address_next <= "0000000000000000";
                o_address_read_next <= "0000000000000000";
                o_en_next <= '1';
                rst_conv_next <= '1';
                data_ser_next <= "00000000";
                next_state <= READ_NUM_BYTE;
            when READ_NUM_BYTE =>
                next_state <= SAVE_NUM_BYTE;
            when SAVE_NUM_BYTE =>
                num_word_in_next <= i_data;
                next_state <= SET_ADDR;
            when SET_ADDR =>
                if num_word_in = o_address_read(7 downto 0) then
                    next_state <= DONE;
                    o_done_next <= '1';
                else 
                    o_address_tmp := std_logic_vector(unsigned(o_address_read) + 1);
                    o_address_read_next <= o_address_tmp;
                    o_address_next <= o_address_tmp;
                    o_en_next <= '1';
                    next_state <= READ_WORD;
                end if;
            when READ_WORD =>
                next_state <= SAVE_WORD;
            when SAVE_WORD =>
                data_ser_next <= i_data;
                rst_ser_next <= '1';  
                next_state <= CALC_OUT;
            when CALC_OUT =>  
                if end_calc = '1' then
                    next_state <= MEM_WRITE_FIRST;
                end if;
            when MEM_WRITE_FIRST =>
                o_address_next <= std_logic_vector(shift_left(unsigned(o_address_read), 1) + to_unsigned(998, 16));
                o_en_next <= '1';
                o_we_next <= '1';
                o_data_next <= o_data_tmp(15 downto 8);
                next_state <= MEM_WRITE_SECOND;
            when MEM_WRITE_SECOND =>
                o_address_next <= std_logic_vector(shift_left(unsigned(o_address_read), 1) + to_unsigned(999, 16));
                o_en_next <= '1';
                o_we_next <= '1';
                o_data_next <= o_data_tmp(7 downto 0);
                next_state <= SET_ADDR;
            when DONE =>
                if i_start = '0' then
                    next_state <= RST;
                else
                    o_done_next <= '1';
                end if;
        end case;
    end process; 
end Behavioral;
