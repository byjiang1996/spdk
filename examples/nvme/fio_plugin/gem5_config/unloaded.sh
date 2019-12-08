export THR=0
export SZ=1g
export MODE=1
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=1 BS=128k MIN=1 fio basic.fio | tee 11.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=1 BS=128k MIN=1 fio basic.fio | tee 21.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=1 BS=4k MIN=1 fio basic.fio | tee 31.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=1 BS=4k MIN=1 fio basic.fio | tee 41.txt
export SZ=1g
export MODE=0
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=1 BS=128k MIN=1 fio basic.fio | tee 13.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=1 BS=128k MIN=1 fio basic.fio | tee 23.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=1 BS=4k MIN=1 fio basic.fio | tee 33.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=1 BS=4k MIN=1 fio basic.fio | tee 43.txt
