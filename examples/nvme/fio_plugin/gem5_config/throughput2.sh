export THR=1
export SZ=1g
export MODE=1
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=8 BS=128k MIN=1 fio basic.fio | tee 211.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=8 BS=128k MIN=2 fio basic.fio | tee 212.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=8 BS=128k MIN=1 fio basic.fio | tee 221.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=8 BS=128k MIN=2 fio basic.fio | tee 222.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=64 BS=4k MIN=1 fio basic.fio | tee 231.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=64 BS=4k MIN=8 fio basic.fio | tee 232.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=64 BS=4k MIN=1 fio basic.fio | tee 241.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=64 BS=4k MIN=8 fio basic.fio | tee 242.txt
export SZ=1g
export MODE=0
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=read DEPTH=8 BS=128k MIN=1 fio basic.fio | tee 213.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=write DEPTH=8 BS=128k MIN=1 fio basic.fio | tee 223.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randread DEPTH=64 BS=4k MIN=1 fio basic.fio | tee 233.txt
LD_PRELOAD=/root/spdk/examples/nvme/fio_plugin/fio_plugin RW=randwrite DEPTH=64 BS=4k MIN=1 fio basic.fio | tee 243.txt
