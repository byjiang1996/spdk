export THR=1
export SZ=1g
export MODE=1
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=2 BS=128k MIN=1 fio basic.fio | tee 111.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=2 BS=128k MIN=1 fio basic.fio | tee 121.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=16 BS=4k MIN=1 fio basic.fio | tee 131.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=16 BS=4k MIN=2 fio basic.fio | tee 132.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=16 BS=4k MIN=1 fio basic.fio | tee 141.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=16 BS=4k MIN=2 fio basic.fio | tee 142.txt
export SZ=1g
export MODE=0
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=2 BS=128k MIN=1 fio basic.fio | tee 113.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=2 BS=128k MIN=1 fio basic.fio | tee 123.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=16 BS=4k MIN=1 fio basic.fio | tee 133.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=16 BS=4k MIN=1 fio basic.fio | tee 143.txt
