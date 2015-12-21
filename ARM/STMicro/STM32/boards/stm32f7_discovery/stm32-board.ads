------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2015, AdaCore                           --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of STMicroelectronics nor the names of its       --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

--  This file provides declarations for devices on the STM32F7 Discovery kits
--  manufactured by ST Microelectronics.

with STM32.Device;  use STM32.Device;

with STM32.GPIO;    use STM32.GPIO;
--  with STM32.SPI;     use STM32.SPI;
with STM32.ADC;     use STM32.ADC;
with STM32.FMC;     use STM32.FMC;

with Ada.Interrupts.Names;  use Ada.Interrupts;

use STM32;  -- for base addresses

package STM32.Board is
   pragma Elaborate_Body;

   subtype User_LED is GPIO_Point;

   Green : User_LED renames PI1;

   All_LEDs  : constant GPIO_Points := (1 => Green);
   LCH_LED   : constant User_LED := Green;

   procedure Initialize_LEDs;
   --  MUST be called prior to any use of the LEDs

   procedure Turn_On (This : User_LED)
     renames STM32.GPIO.Set;
   procedure Turn_Off (This : User_LED)
     renames STM32.GPIO.Clear;

   procedure All_LEDs_Off with Inline;
   procedure All_LEDs_On  with Inline;
   procedure Toggle_LEDs (These : GPIO_Points)
     renames STM32.GPIO.Toggle;

   --  GPIO Pins for FMC

   FMC_A : constant GPIO_Points :=
             (PF0, PF1, PF2, PF3, PF4, PF5, PF12, PF13, PF14, PF15, PG0, PG1);

   FMC_D : constant GPIO_Points :=
             (PD14, PD15, PD0, PD1, PE7, PE8, PE9, PE10,
              PE11, PE12, PE13, PE14, PE15, PD8, PD9, PD10);

   FMC_SDNWE     : GPIO_Point renames PH5;
   FMC_SDNRAS    : GPIO_Point renames PF11;
   FMC_SDNCAS    : GPIO_Point renames PG15;
   FMC_SDCLK     : GPIO_Point renames PG8;
   FMC_BA0       : GPIO_Point renames PG4;
   FMC_BA1       : GPIO_Point renames PG5;
   FMC_SDNE0     : GPIO_Point renames PH3;
   FMC_SDCKE0    : GPIO_Point renames PC3;
   FMC_NBL0      : GPIO_Point renames PE0;
   FMC_NBL1      : GPIO_Point renames PE1;

   SDRAM_PINS    : constant GPIO_Points :=
                     FMC_A & FMC_D & FMC_SDNWE & FMC_SDNRAS & FMC_SDNCAS &
                     FMC_SDCLK & FMC_BA0 & FMC_BA1 & FMC_SDNE0 & FMC_SDCKE0 &
                     FMC_NBL0 & FMC_NBL1;

   --  SDRAM CONFIGURATION Parameters
   SDRAM_Base         : constant := 16#C0000000#;
   SDRAM_Size         : constant := 16#800000#;
   SDRAM_Bank         : constant STM32.FMC.FMC_SDRAM_Cmd_Target_Bank :=
                          STM32.FMC.FMC_Bank1_SDRAM;
   SDRAM_Mem_Width    : constant STM32.FMC.FMC_SDRAM_Memory_Bus_Width :=
                          STM32.FMC.FMC_SDMemory_Width_16b;
   SDRAM_CAS_Latency  : constant STM32.FMC.FMC_SDRAM_CAS_Latency :=
                          STM32.FMC.FMC_CAS_Latency_2;
   SDRAM_CLOCK_Period : constant STM32.FMC.FMC_SDRAM_Clock_Configuration :=
                          STM32.FMC.FMC_SDClock_Period_2;
   SDRAM_Read_Burst   : constant STM32.FMC.FMC_SDRAM_Burst_Read :=
                          STM32.FMC.FMC_Read_Burst_Disable;
   SDRAM_Read_Pipe    : constant STM32.FMC.FMC_SDRAM_Read_Pipe_Delay :=
                          STM32.FMC.FMC_ReadPipe_Delay_0;
   SDRAM_Refresh_Cnt  : constant := 1539;

   ------------------------
   --  GPIO Pins for LCD --
   ------------------------

   LCD_BL_CTRL   : GPIO_Point renames PK3;
   LCD_ENABLE    : GPIO_Point renames PI12;

   LCD_HSYNC     : GPIO_Point renames PI10;
   LCD_VSYNC     : GPIO_Point renames PI9;
   LCD_CLK       : GPIO_Point renames PI14;
   LCD_DE        : GPIO_Point renames PK7;
   LCD_INT       : GPIO_Point renames PI13;

   LCD_SDA       : GPIO_Point renames PH8;
   LCD_SCL       : GPIO_Point renames PH7;
   NC1           : GPIO_Point renames PI8;

   LCD_CTRL_PINS : constant GPIO_Points :=
                     (LCD_VSYNC, LCD_HSYNC, LCD_INT,
                      LCD_CLK, LCD_DE, NC1);
   LCD_RGB_AF14  : constant GPIO_Points :=
                     (PI15, PJ0, PJ1, PJ2, PJ3, PJ4, PJ5, PJ6, --  Red
                      PJ7, PJ8, PJ9, PJ10, PJ11, PK0, PK1, PK2, --  Green
                      PE4, PJ13, PJ14, PJ15, PK4, PK5, PK6); --  Blue
   LCD_RGB_AF9   : constant GPIO_Points :=
                     (1 => PG12); -- B4



   TP_Pins : constant GPIO_Points := (LCD_SDA, LCD_SCL);


   --  User button

   User_Button_Point     : GPIO_Point renames PA0;
   User_Button_Interrupt : constant Interrupt_Id := Names.EXTI0_Interrupt;

   procedure Configure_User_Button_GPIO;
   --  Configures the GPIO port/pin for the blue user button. Sufficient
   --  for polling the button, and necessary for having the button generate
   --  interrupts.

end STM32.Board;