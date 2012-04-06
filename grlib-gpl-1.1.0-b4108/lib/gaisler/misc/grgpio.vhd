------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2010, Aeroflex Gaisler
--
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
--    gpioi  : in  gpio_in_type;
    gpioo  : out gpio_out_type
  );
end;

architecture rtl of grgpio is

constant REVISION : integer := 1;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GPIO, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

type registers is record
  din1  	:  std_logic_vector(nbits-1 downto 0);
  din2  	:  std_logic_vector(nbits-1 downto 0);
--  dout   	:  std_logic_vector(nbits-1 downto 0);
end record;

type fifo is record
               dout : std_logic_vector(nbits-1 downto 0);
             end record;

signal r, rin : registers;
signal f, fin : fifo;
signal arst     : std_ulogic;

begin

  arst <= apbi.testrst when (scantest = 1) and (apbi.testen = '1') else rst;
  
  
--  comb : process(rst, r, f, apbi, gpioi)
  comb : process(rst, r, f, apbi)
    variable readdata, dout, pval : std_logic_vector(31 downto 0);
  variable v : registers;
  variable w : fifo;
  variable xirq : std_logic_vector(NAHBIRQ-1 downto 0);
  begin

    dout := (others => '0');
    dout(nbits-1 downto 0) := f.dout(nbits-1 downto 0);
    v := r; w := f; v.din2 := r.din1; v.din1 := dout(nbits-1 downto 0);  -- loop back dout to din

-- read registers
    readdata := (others => '0');
    case apbi.paddr(5 downto 2) is
    when "0000" => readdata(nbits-1 downto 0) := r.din2;
    when "0001" => readdata(nbits-1 downto 0) := f.dout;
    when others =>
      null;
    end case;

-- write registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(5 downto 2) is
      when "0000" => null;
      when "0001" => w.dout := apbi.pwdata(nbits-1 downto 0);
      when others =>
          null;
      end case;
    end if;

-- interrupt filtering and routing
    xirq := (others => '0');

-- drive filtered inputs on the output record

   pval := (others => '0');
   pval(nbits-1 downto 0) := r.din2;

    if rst = '0' then
      w.dout := (others => '0');
    end if;
    
    rin <= v;
    fin <= w;

    apbo.prdata <= readdata; 	-- drive apb read bus
    apbo.pirq <= xirq;

    gpioo.dout <= dout;
--    gpioo.oen <= (others => '0');       -- tie the gpioo.oen to an arbitary '0'
    gpioo.val <= pval;

--    gpioo.sig_out <= dout;

  end process;

  apbo.pindex <= pindex;
  apbo.pconfig <= pconfig;

-- registers

  regs : process(clk, arst)
  begin
    if rising_edge(clk) then r <= rin; f <= fin; end if;
  end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version
    generic map ("grgpio" & tost(pindex) &
	": " &  tost(nbits) & "-bit GPIO Unit rev " & tost(REVISION));
-- pragma translate_on

end;
