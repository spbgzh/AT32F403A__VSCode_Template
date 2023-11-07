# ------------------------------------------------
# Generic Makefile (based on gcc)
#
# ChangeLog :
#   2022-05-11 - first version
# ------------------------------------------------

SHELL=cmd.exe

######################################
# target
######################################
TARGET = at32f403a_vscode_template


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -Og


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build


######################################
# source
######################################
# C sources
C_SOURCES =  \
./project/src/main.c \
./project/src/at32f403a_407_int.c \
./project/src/at32f403a_407_clock.c \
./project/board/at32f403a_407_board.c \
./libraries/cmsis/cm4/device_support/system_at32f403a_407.c \
./libraries/drivers/src/at32f403a_407_acc.c \
./libraries/drivers/src/at32f403a_407_adc.c \
./libraries/drivers/src/at32f403a_407_bpr.c \
./libraries/drivers/src/at32f403a_407_can.c \
./libraries/drivers/src/at32f403a_407_crc.c \
./libraries/drivers/src/at32f403a_407_crm.c \
./libraries/drivers/src/at32f403a_407_dac.c \
./libraries/drivers/src/at32f403a_407_debug.c \
./libraries/drivers/src/at32f403a_407_dma.c \
./libraries/drivers/src/at32f403a_407_exint.c \
./libraries/drivers/src/at32f403a_407_flash.c \
./libraries/drivers/src/at32f403a_407_gpio.c \
./libraries/drivers/src/at32f403a_407_i2c.c \
./libraries/drivers/src/at32f403a_407_misc.c \
./libraries/drivers/src/at32f403a_407_pwc.c \
./libraries/drivers/src/at32f403a_407_rtc.c \
./libraries/drivers/src/at32f403a_407_sdio.c \
./libraries/drivers/src/at32f403a_407_spi.c \
./libraries/drivers/src/at32f403a_407_tmr.c \
./libraries/drivers/src/at32f403a_407_usart.c \
./libraries/drivers/src/at32f403a_407_usb.c \
./libraries/drivers/src/at32f403a_407_wdt.c \
./libraries/drivers/src/at32f403a_407_wwdt.c \
./libraries/drivers/src/at32f403a_407_xmc.c \

# ASM sources
ASM_SOURCES =  \
./project/src/startup_at32f403a_407.s


#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
FPU = -mfpu=fpv4-sp-d16

# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DAT_START_F403A_V1 \
-DAT32F403AVGT7 \
-DUSE_STDPERIPH_DRIVER

# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-I./project/inc \
-I./project/board \
-I./libraries/cmsis/cm4/core_support \
-I./libraries/cmsis/cm4/device_support \
-I./libraries/drivers/inc


# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = project/misc/AT32F403AxG_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# clean up
#######################################
clean:
	-rd /s /q $(BUILD_DIR)
  
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***