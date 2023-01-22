library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;


entity hub75_driver_wrapper is
    generic (
        hpixel_p : integer := 64;
        vpixel_p : integer := 64;
        bpp_p : integer := 8;
        segments_p : integer := 2;
        addr_width_p : integer := 12
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;

        i_enable : in std_logic;
        i_clk_div : in std_logic_vector (3 downto 0);

        i_framebuf_wr_addr : in std_logic_vector(addr_width_p-1 downto 0);
        i_framebuf_wr_data : in std_logic_vector(3*bpp_p-1 downto 0);
        i_framebuf_wr_en : in std_logic;

        -- HUB75 Outputs --
        -- Control signals
        O_CLK : out std_logic;
        STB : out std_logic;
        OE : out std_logic;

        A : out std_logic;
        B : out std_logic;
        C : out std_logic;
        D : out std_logic;
        E : out std_logic;

        R1 : out std_logic;
        R2 : out std_logic;
        G1 : out std_logic;
        G2 : out std_logic;
        B1 : out std_logic;
        B2 : out std_logic
    );
end entity;

architecture rtl of hub75_driver_wrapper is

    component hub75_driver is
        generic (
            hpixel_p : integer := 64;
            vpixel_p : integer := 64;
            bpp_p : integer := 8;
            segments_p : integer := 2
        );
        port (
            clk : in std_logic;
            rst_n : in std_logic;
    
            i_enable : in std_logic;
            i_clk_div : in std_logic_vector (3 downto 0);
    
            i_framebuf_wr_addr : in std_logic_vector(integer(ceil(log2(real(hpixel_p*vpixel_p))))-1 downto 0);
            i_framebuf_wr_data : in std_logic_vector(3*bpp_p-1 downto 0);
            i_framebuf_wr_en : in std_logic;
    
            -- HUB75 Outputs --
            -- Control signals
            O_CLK : out std_logic;
            STB : out std_logic;
            OE : out std_logic;
    
            A : out std_logic;
            B : out std_logic;
            C : out std_logic;
            D : out std_logic;
            E : out std_logic;
   
            R1 : out std_logic;
            R2 : out std_logic;
            G1 : out std_logic;
            G2 : out std_logic;
            B1 : out std_logic;
            B2 : out std_logic
        );
    end component hub75_driver;

    begin

    hub75_driver_i : hub75_driver
    generic map (
        hpixel_p => hpixel_p,
        vpixel_p => vpixel_p,
        bpp_p => bpp_p,
        segments_p => segments_p
    )
    port map (
        clk => clk,
        rst_n => rst_n,
        i_enable => i_enable,
        i_clk_div => i_clk_div,
        i_framebuf_wr_addr => i_framebuf_wr_addr,
        i_framebuf_wr_data => i_framebuf_wr_data,
        i_framebuf_wr_en => i_framebuf_wr_en,
        
        O_CLK => O_CLK,
        STB => STB,
        OE => OE,
    
        A => A,
        B => B,
        C => C,
        D => D,
        E => E,
    
        R1 => R1,
        R2 => R2,
        G1 => G1,
        G2 => G2,
        B1 => B1,
        B2 => B2
    );
end architecture rtl;