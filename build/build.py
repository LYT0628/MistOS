import os.path as op
basedir = op.dirname(__file__)


outf = open(op.join(basedir, '../kernel.bin'), 'wb')

# 读取 boot16
inf = open(op.join(basedir, '../boot/boot16.bin'), 'rb')
loc = outf.seek(0, 0)
print(loc)
content = inf.read()
n = outf.write(content)
print(n)
inf.close()

# 读取 boot32
inf = open(op.join(basedir, '../boot/boot32.bin'), 'rb')
content = inf.read()
loc = outf.seek(512, 0)
print(loc)
n = outf.write(content)
print(n)
inf.close()
