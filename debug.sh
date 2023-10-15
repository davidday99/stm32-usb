openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg &> .debug.log &

arm-none-eabi-gdb --tui build/main.elf -ex "target remote :3333" -ex "monitor reset halt"

pkill -P $$

