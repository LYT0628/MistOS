import os.path as op
basedir = op.dirname(__file__)


outf = open(op.join(basedir, '../kernel.bin'), 'wb')

# 读取 boot16
inf = open(op.join(basedir, '../boot/boot16.bin'), 'rb')
loc = outf.seek(0, 0)
content = inf.read()
n = outf.write(content)
print('向 地址',loc , '加载',n,'个字节')
inf.close()

# 读取 boot32
inf = open(op.join(basedir, '../boot/boot32.bin'), 'rb')
content = inf.read()
loc = outf.seek(512, 0)
n = outf.write(content)
print('向 地址',loc , '加载',n,'个字节')
inf.close()


# 读取 system.bin
inf = open(op.join(basedir, '../boot/system.bin'), 'rb')
content = inf.read()
loc = outf.seek(512 * 2 * 18 * 3 , 0) # 加载在第4个柱面的位置
n = outf.write(content)
print('向 地址',loc , '加载',n,'个字节')
inf.close()
