------------------------------------------------------------------------------
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY sWARRANTY; without even the implied warranty of
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
-- VENDOR:      VENDOR_GAISLER
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
-- FYI: code from misc.vhd
-------------------------------------------------------------------------------
----  type gpio_in_type is record
----    din      : std_logic_vector(31 downto 0);
----    sig_in   : std_logic_vector(31 downto 0);
----    sig_en   : std_logic_vector(31 downto 0);
----  end record;

--  type gpio_out_type is record
--    dout     : std_logic_vector(31 downto 0);
----    oen      : std_logic_vector(31 downto 0);
--    val      : std_logic_vector(31 downto 0);
----    sig_out  : std_logic_vector(31 downto 0);
--  end record;
  
entity the_fifo is
generic (fbits : integer := 16);
port (
	clr_fifo, rd_fifo, wr_fifo  : in std_ulogic;  
      	data_in : in std_logic_vector(fbits-1 downto 0);
        data_out : out std_logic_vector(fbits-1 downto 0)
);
end the_fifo;

architecture rtl of the_fifo is
signal fifo_data : std_logic_vector(fbits-1 downto 0) := (others => '0');
begin  -- rtl
act_as_a_fifo : process (clr_fifo, wr_fifo, rd_fifo)
begin  -- process
  if clr_fifo = '0' then                -- asynchronous reset (active low)
    fifo_data <= (others => '0');
  elsif wr_fifo'event and wr_fifo = '1' then
    fifo_data <= data_in;
  end if;
  data_out <= fifo_data;
end process;
end rtl;

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
    gpioo  : out gpio_out_type
  );
end;

architecture rtl of grgpio is

constant REVISION : integer := 1;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GPIO, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

component the_fifo
    generic (fbits : integer := 16);
    port (
	clr_fifo, rd_fifo, wr_fifo  : in std_ulogic;  
      	data_in : in std_logic_vector(fbits-1 downto 0);
        data_out : out std_logic_vector(fbits-1 downto 0)
    );
end component;

signal wr, rd : std_ulogic := '0';
signal arst   : std_ulogic := '1';

begin
  data_fifo : the_fifo
	  generic map (fbits => nbits)
          port map (clr_fifo => '1', rd_fifo => rd, wr_fifo => wr, data_in => apbi.pwdata(nbits-1 downto 0), data_out => apbo.prdata(nbits-1 downto 0)); 
  arst <= apbi.testrst when (scantest = 1) and (apbi.testen = '1') else rst;
  action : process (arst, apbi)
  variable xirq : std_logic_vector(NAHBIRQ-1 downto 0);
  begin
    apbo.prdata(31 downto nbits) <= (others => '0');
-- write
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(5 downto 2) is
      when "0001" => wr <= '1';
      when others => wr <= '0';
      end case;
    else
      wr <= '0';
    end if;
-- read registers
    if (apbi.psel(pindex) and apbi.penable and not apbi.pwrite) = '1' then
      case apbi.paddr(5 downto 2) is
      when "0000" => rd <= '1'; 
      when others => rd <= '0';
      end case;
    else
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
