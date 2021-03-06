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

with STM32F4.USARTs;  use STM32F4.USARTs;

package body STM32F4_DMA_Interrupts is

   -------------------------------
   -- Finalize_DMA_Transmission --
   -------------------------------

   procedure Finalize_DMA_Transmission (Transceiver : in out USART) is
   begin
      loop
         exit when Status (Transceiver, Transmission_Complete_Indicated);
      end loop;
      Clear_Status (Transceiver, Transmission_Complete_Indicated);
      Disable_DMA_Transmit_Requests (Transceiver);
   end Finalize_DMA_Transmission;

   -------------
   -- Handler --
   -------------

   protected body Handler is

      -----------------
      -- Await_Event --
      -----------------

      entry Await_Event (Occurrence : out DMA_Interrupt) when Event_Occurred is
      begin
         Occurrence := Event_Kind;
         Event_Occurred := False;
      end Await_Event;

      -----------------
      -- IRQ_Handler --
      -----------------

      procedure IRQ_Handler is
      begin
         --  Transfer Error Interrupt management
         if Status (Controller, Tx_Stream, Transfer_Error_Indicated) then
            if Interrupt_Enabled (Controller, Tx_Stream, Transfer_Error_Interrupt) then
               Disable_Interrupt (Controller, Tx_Stream, Transfer_Error_Interrupt);
               Clear_Status (Controller, Tx_Stream, Transfer_Error_Indicated);
               Event_Kind := Transfer_Error_Interrupt;
               Event_Occurred := True;
               return;
            end if;
         end if;

         --  FIFO Error Interrupt management
         if Status (Controller, Tx_Stream, FIFO_Error_Indicated) then
            if Interrupt_Enabled (Controller, Tx_Stream, FIFO_Error_Interrupt) then
               Disable_Interrupt (Controller, Tx_Stream, FIFO_Error_Interrupt);
               Clear_Status (Controller, Tx_Stream, FIFO_Error_Indicated);
               Event_Kind := FIFO_Error_Interrupt;
               Event_Occurred := True;
               return;
            end if;
         end if;

         --  Direct Mode Error Interrupt management
         if Status (Controller, Tx_Stream, Direct_Mode_Error_Indicated) then
            if Interrupt_Enabled (Controller, Tx_Stream, Direct_Mode_Error_Interrupt) then
               Disable_Interrupt (Controller, Tx_Stream, Direct_Mode_Error_Interrupt);
               Clear_Status (Controller, Tx_Stream, Direct_Mode_Error_Indicated);
               Event_Kind := Direct_Mode_Error_Interrupt;
               Event_Occurred := True;
               return;
            end if;
         end if;

         --  Half Transfer Complete Interrupt management
         if Status (Controller, Tx_Stream, Half_Transfer_Complete_Indicated) then
            if Interrupt_Enabled (Controller, Tx_Stream, Half_Transfer_Complete_Interrupt) then
               if Double_Buffered (Controller, Tx_Stream) then
                  Clear_Status (Controller, Tx_Stream, Half_Transfer_Complete_Indicated);
               else -- not double buffered
                  if not Circular_Mode (Controller, Tx_Stream) then
                     Disable_Interrupt (Controller, Tx_Stream, Half_Transfer_Complete_Interrupt);
                  end if;
                  Clear_Status (Controller, Tx_Stream, Half_Transfer_Complete_Indicated);
               end if;
--                 Event_Kind := Half_Transfer_Complete_Interrupt;
--                 Event_Occurred := True;
            end if;
         end if;

         --  Transfer Complete Interrupt management
         if Status (Controller, Tx_Stream, Transfer_Complete_Indicated) then
            if Interrupt_Enabled (Controller, Tx_Stream, Transfer_Complete_Interrupt) then
                if Double_Buffered (Controller, Tx_Stream) then
                   Clear_Status (Controller, Tx_Stream, Transfer_Complete_Indicated);
                   --  TODO: handle the difference between M0 and M1 callbacks
                else
                   if not Circular_Mode (Controller, Tx_Stream) then
                      Disable_Interrupt (Controller, Tx_Stream, Transfer_Complete_Interrupt);
                   end if;
                  Clear_Status (Controller, Tx_Stream, Transfer_Complete_Indicated);
                end if;
               Finalize_DMA_Transmission (Transceiver);
               Event_Kind := Transfer_Complete_Interrupt;
               Event_Occurred := True;
            end if;
         end if;
      end IRQ_Handler;

   end Handler;

end STM32F4_DMA_Interrupts;
