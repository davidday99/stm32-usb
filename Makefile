PROJECT=main

SRCS=$(wildcard src/app/*.c) \
	 $(wildcard src/platform/stm32f4/hal/*.c) \
	 $(wildcard src/platform/stm32f4/usb_core/*.c) \
	 $(wildcard src/platform/stm32f4/usb_cdc/*.c) \
	 src/CMSIS/Device/ST/stm32f4/system_stm32f4xx.c \
	 src/CMSIS/Device/ST/stm32f4/gcc/startup_stm32f407xx.s

OBJ=obj
OBJS=$(addprefix $(OBJ)/, \
	   $(filter-out %.c %.S,$(SRCS:.s=.o)) \
	   $(filter-out %.s %.S, $(SRCS:.c=.o)) \
	   $(filter-out %.c %.s, $(SRCS:.S=.o)))
BIN=build
INC= -Iinc -Iinc/CMSIS/Core/Include -Iinc/CMSIS/Device/ST/STM32F4xx/Include \
	 -Iinc/app -Iinc/platform/stm32f4/hal -Iinc/platform/stm32f4/usb_cdc \
	 -Iinc/platform/stm32f4/usb_core

LD_SCRIPT=STM32F407VGTx_FLASH.ld
DEV=/dev/ttyACM0
FLASHER=lm4flash

CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

CFLAGS = -g -mcpu=cortex-m4 -mfloat-abi=soft -ffreestanding
CFLAGS += -std=c99 -Wextra -Wall -Wno-missing-braces
LDFLAGS = -Wl,-T$(LD_SCRIPT) 
DEPFLAGS = -MT $@ -MMD -MP

RM = rm -rf
MKDIR = @mkdir -p $(@D)

$(info $(OBJS))

all: $(BIN)/$(PROJECT).elf $(BIN)/$(PROJECT).bin

clean:
	-$(RM) $(OBJ) 
	-$(RM) $(BIN) 

$(OBJ)/%.o: %.c          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)
	
$(OBJ)/%.o: %.s          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)

$(OBJ)/%.o: %.S          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)

$(BIN)/$(PROJECT).elf: $(OBJS)
	$(MKDIR)           
	$(CC) -o $@ $^ $(INC) $(CFLAGS) $(DEPFLAGS) $(LDFLAGS) 

$(BIN)/$(PROJECT).bin: $(BIN)/$(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

-include $(OBJS:.o=.d)

.PHONY: all docs clean flash

