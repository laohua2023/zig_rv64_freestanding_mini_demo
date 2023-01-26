#!/bin/bash
#2023.01.26 by Y

CACHE_DIR=./zig-cache
OUTPUTDIR=./zig-out/bin

showHelp(){
	echo "请使用如下指令运行"
	echo "./build $PRJ__NAME "
	exit -1
}

checkCompileRlt(){
	if [ $? -ne 0 ]; then
		echo -e "\e[1;31m\r\n编译出错，请查看上面的信息!\r\n\e[0m"
		exit -1
	fi
}

#编译、打包
zig build elf 
checkCompileRlt

echo -e '\e[1;36m 正在启动 qemu\e[0m，通过按住 CTRL+C 组合键来退出 qemu(首次运行qemu比较慢，要等两三秒钟)'
#WSL中直接启动 qemu.exe 中文会乱码，所以用 powershell 中转一下

QEMUEXE="d:\Program Files\qemu\qemu-system-riscv64.exe"
QEMUARG="-nographic -machine virt -bios none -m 800M "
echo ''                                                                                                 >  $CACHE_DIR/startQemu.ps1	
echo '[System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8'>> $CACHE_DIR/startQemu.ps1
echo '& "'$QEMUEXE'" '$QEMUARG' -kernel ".\zig-out\bin\out.elf"'                                        >> $CACHE_DIR/startQemu.ps1
powershell.exe $CACHE_DIR/startQemu.ps1


# windows command: to dump dtb of virt
# "d:\Program Files\qemu\qemu-system-riscv64.exe"  -machine virt,dumpdtb=qemu-riscv64-virt.dtb