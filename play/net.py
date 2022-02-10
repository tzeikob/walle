import psutil

io = psutil.net_io_counters(pernic=True)['enp6s0']

print(io.bytes_sent)
print(io.bytes_recv)
print(io.packets_sent)
print(io.packets_recv)
