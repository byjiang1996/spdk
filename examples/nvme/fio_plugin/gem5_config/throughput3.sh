export THR=1
export SZ=1g
export MODE=1
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=32 BS=128k MIN=1 fio basic.fio | tee 311.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=32 BS=128k MIN=8 fio basic.fio | tee 312.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=32 BS=128k MIN=1 fio basic.fio | tee 321.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=32 BS=128k MIN=8 fio basic.fio | tee 322.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=256 BS=4k MIN=1 fio basic.fio | tee 331.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=256 BS=4k MIN=32 fio basic.fio | tee 332.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=256 BS=4k MIN=1 fio basic.fio | tee 341.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=256 BS=4k MIN=32 fio basic.fio | tee 342.txt
export SZ=1g
export MODE=0
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=32 BS=128k MIN=1 fio basic.fio | tee 313.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=32 BS=128k MIN=1 fio basic.fio | tee 323.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=256 BS=4k MIN=1 fio basic.fio | tee 333.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=256 BS=4k MIN=1 fio basic.fio | tee 343.txt
