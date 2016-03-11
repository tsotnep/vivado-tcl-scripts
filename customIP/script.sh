#checksum of file or folder
checksum(){
  find $1 -type f -exec md5sum {} \; | sort -k 34 | md5sum
}

devicetree(){

}

uboot(){

}

fsbl(){

}

bitstream(){

}

bootbif(){

}

bootbin(){

}

uimage(){

}

uramdisk(){

}

kernelmodule(){

}



sum=$(checksum $1)
echo $sum
