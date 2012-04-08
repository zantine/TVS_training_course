------------------------------------------------------------------------------
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	gpio
-- File:	gpio.vhd
-- Author:	Jiri Gaisler - Gaisler Research and Mike Benjamin - TVS
-- Description:	Scalable general-purpose I/O port
--              Hacked to simplify functionality and embed a FIFO
------------------------------------------------------------------------------
-- GRLIB2 CORE
-- VENDOR:      VENDORo_GAISLER
-- DEVICE:      GAISLER_GPIO
-- VERSION:     0
-- APB:         0
-- BAR: 0       TYPE: 0010      PREFETCH: 0     CACHE: 0        DESC: IO_AREA
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

-------------------------------------------------------------------------------
-- FYI: definition of gpio I/F data types from misc.vhd
-------------------------------------------------------------------------------
-- type gpio_in_type is record
--    ext_rd_fifo  : std_ulogic;
-- end record;

--  type gpio_out_type is record
--    data_out : std_logic_vector(31 downto 0);
--    val      : std_logic_vector(31 downto 0);
--    data_out_valid : std_ulogic;
--    fifo_empty     : std_ulogic;
--    fifo_full      : std_ulogic;
--  end record;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity grgpio is
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    nbits    : integer := 16;			-- GPIO bits
    syncrst  : integer := 0;                    -- Only synchronous reset
    scantest : integer := 0;
    pirq     : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpioi  : in  gpio_in_type;
    gpioo  : out gpio_out_type
  );
end;

architecture rtl of grgpio is

constant REVISION : integer := 1;

constant pointer_width : integer := 3;  -- define pointer width for data FIFO
constant fifo_depth : integer := 8;     -- defined by pointer width (1<<pointer_width)

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GPIO, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

component the_fifo
    generic (fbits : integer := nbits;
             pwidth : integer := pointer_width;
             fdepth : integer := fifo_depth);
    port (
	clk, clr_fifo, rd_fifo, wr_fifo  : in std_ulogic;  
      	data_in : in std_logic_vector(fbits-1 downto 0);
        data_out : out std_logic_vector(fbits-1 downto 0);
        data_counter: out std_logic_vector(pwidth downto 0);
        data_out_valid, empty, full : out std_ulogic
    );
end component;

signal wr, rd : std_ulogic := '0';
signal arst   : std_ulogic := '1';
signal frst   : std_ulogic := '1';        -- FIFO reset (active high unlike arst)
signal en_int : std_ulogic := '0';        -- In future this will be used to enable interrupts

signal fifo_empty, fifo_full : std_ulogic;
signal data_counter : std_logic_vector(31 downto 0);
signal dout : std_logic_vector(nbits-1 downto 0);

-- Instantiate the Verilog FIFO via a component declaration
begin
  data_fifo : the_fifo
	  generic map (fbits => nbits, pwidth => pointer_width, fdepth => fifo_depth)
          port map (clk => clk, clr_fifo => frst, rd_fifo => rd, wr_fifo => wr,
                    data_in => apbi.pwdata(nbits-1 downto 0), data_out => dout,
                    data_counter => data_counter(pointer_width downto 0), data_out_valid => gpioo.data_out_valid, empty => fifo_empty, full => fifo_full); 
  arst <= apbi.testrst when (scantest = 1) and (apbi.testen = '1') else rst;

  action : process (clk, arst, apbi)
  variable xirq : std_logic_vector(NAHBIRQ-1 downto 0);
  begin
    apbo.prdata(31 downto nbits) <= (others => '0');
    gpioo.dout(31 downto nbits) <= (others => '0');
    data_counter(31 downto pointer_width) <= (others => '0');
    gpioo.fifo_empty <= fifo_empty;
    gpioo.fifo_full <= fifo_full;
-- write
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(5 downto 2) is
      when "0001" => wr <= '1';
      when "0010" =>
        frst <= '1';
      when "1000" => en_int <=  apbi.pwdata(0);
      when others =>
          wr <= '0';
          frst <= not arst;
      end case;
    else
      wr <= '0';
      frst <= not arst;
    end if;
-- read registers
    if (apbi.psel(pindex) and apbi.penable and not apbi.pwrite) = '1' then
      case apbi.paddr(5 downto 2) is
        when "0000" =>
          rd <= '1';
          gpioo.dout(nbits-1 downto 0) <= dout(nbits-1 downto 0);
          apbo.prdata(nbits-1 downto 0) <= dout(nbits-1 downto 0);
        when "0100" =>
          apbo.prdata <= data_counter;
        when "1000" =>
          apbo.prdata <= (others => '0');
          if (en_int = '1') then
            apbo.prdata(0) <= '1';
          end if;
          when "0011" =>
            apbo.prdata <= (others => '0');
            if (fifo_empty = '1') then
              apbo.prdata(0) <= '1';
            end if;
            if (fifo_full = '1') then
              apbo.prdata(1) <= '1';              
            end if;
        when others =>
          rd <= '0';
      end case;
    else
-- If GPIO not being accessed over APB then external interface can perform reads
-- To be enabled once top level test bench is able to control ext_rd
--    rd <= gpioi.ext_rd;
--    gpioo.dout(nbits-1 downto 0) <= dout(nbits-1 downto 0);
      rd <= '0';
    end if;
-- interrupt filtering and routing
    xirq := (others => '0');
-- drive filtered inputs on the output record
    apbo.pirq <= xirq;
end process;         

  apbo.pindex <= pindex;
  apbo.pconfig <= pconfig;

-- boot message

-- pragma translate_off
    bootmsg : report_version
    generic map ("grgpio" & tost(pindex) &
	": " &  tost(nbits) & "-bit GPIO Unit rev " & tost(REVISION));
-- pragma translate_on

end rtl;
