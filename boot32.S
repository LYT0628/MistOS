.text
.code32
start32:
  mov $0x3f8, %dx # location of serial port 
  mov $'P', %al # content 
  out %al, %dx # send content to serial port

  hlt # rest cpu