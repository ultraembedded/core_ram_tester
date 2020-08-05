### AXI-4 RAM Tester

Github: [https://github.com/ultraembedded/core_ram_tester](https://github.com/ultraembedded/core_ram_tester)

This core can be used to test read/write performance of a 32-bit AXI-4 memory.  
It can also be used to validate read data.  
Accesses are performed as pipelined AXI-4 burst operations.

#### Example Usage
```
##################################################################
# run_ram_test: Write pattern to RAM array
##################################################################
def run_ram_test(bus_if, base, size, pattern, clock_ns, burst_len=32):

    # Configure
    bus_if.write32(RAM_TEST_BASE,  base)
    bus_if.write32(RAM_TEST_END,   base + size)

    if pattern != None:
        bus_if.write32(RAM_TEST_WRITE, pattern)

    # Burst length
    cfg = ((burst_len/4)-1) << RAM_TEST_CFG_BURST_LEN_SHIFT

    # Type
    if pattern != None:
        cfg |= (1 << RAM_TEST_CFG_USER_SHIFT)
    else:
        cfg |= (1 << RAM_TEST_CFG_INCR_SHIFT)

    if pattern != None:
        print "# Write RAM to 0x%08x" % pattern
    else:
        print "# Write RAM to INCR"

    bus_if.write32(RAM_TEST_CFG, cfg)
    while True:
        status = bus_if.read32(RAM_TEST_STS)
        if (status & (1 << RAM_TEST_STS_BUSY_SHIFT)) == 0:
            break

    cycles   = bus_if.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000.0 / time_ns) * size
    print "|- %d bytes written in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)

    print "# Read RAM and compare"
    bus_if.write32(RAM_TEST_CFG, cfg | (1 << RAM_TEST_CFG_READ_SHIFT))
    while True:
        status = bus_if.read32(RAM_TEST_STS)
        if (status & (1 << RAM_TEST_STS_BUSY_SHIFT)) == 0:
            break

    errors   = bus_if.read32(RAM_TEST_ERRORS)
    cycles   = bus_if.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000.0 / time_ns) * size
    print "|- %d bytes read in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)
    print "|- Errors: %d" % errors
    if errors > 0:
        print "ERROR: RAM read errors encountered"
        sys.exit(1)

##################################################################
# Test sequence
##################################################################
    clock_ns  = 20
    burst_len = 64
    print "# User clock: %fns (%fMHz)" % (clock_ns, 1000/clock_ns)
    print "# Burst Length: %d bytes" % (burst_len)

    base = 0x80000000
    size = (1 * 1024 * 1024)

    run_ram_test(bus_if, base, size, 0x00000000, clock_ns, burst_len)
    run_ram_test(bus_if, base, size, 0xFFFFFFFF, clock_ns, burst_len)
    run_ram_test(bus_if, base, size, 0x5555aaaa, clock_ns, burst_len)
    run_ram_test(bus_if, base, size, None,       clock_ns, burst_len)
```


##### Register Map

| Offset | Name | Description   |
| ------ | ---- | ------------- |
| 0x00 | RAM_TEST_CFG | [RW] Configuration Register |
| 0x04 | RAM_TEST_BASE | [RW] Buffer Base Address |
| 0x08 | RAM_TEST_END | [RW] Buffer End Address |
| 0x0c | RAM_TEST_STS | [R] Status Register |
| 0x10 | RAM_TEST_CURRENT | [R] Buffer Current address |
| 0x14 | RAM_TEST_WRITE | [RW] User specified write pattern |
| 0x18 | RAM_TEST_TIME | [R] Operation completion cycles |
| 0x1c | RAM_TEST_ERRORS | [R] Operation errors |
| 0x20 | RAM_TEST_LAST | [R] Last read data |

##### Register: RAM_TEST_CFG

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:28 | BURST_LEN | Burst length - 1 (0 = singles, 1 = 8 bytes, 3 = 16 bytes) |
| 8 | READ | Perform read operation (with error checking) |
| 7 | RND_DELAY | Enable short psuedo random delay between accesses |
| 3 | USER | Execute - write/compare user data word to RAM (RAM_TEST_WRITE_PATTERN) |
| 2 | INCR | Execute - incrementing pattern 0x33221100, 0x77665544, ... |
| 1 | ONES | Execute - all ones pattern |
| 0 | ZERO | Execute - all zeros pattern |

##### Register: RAM_TEST_BASE

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | Base address (should be 4 byte aligned) |

##### Register: RAM_TEST_END

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | End address (size of test = RAM_TEST_END - RAM_TEST_BASE) |

##### Register: RAM_TEST_STS

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 0 | BUSY | Busy executing operation |

##### Register: RAM_TEST_CURRENT

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | ADDR | Current read / write pointer |

##### Register: RAM_TEST_WRITE

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | PATTERN | Data word to be written on RAM_TEST_CFG.USER |

##### Register: RAM_TEST_TIME

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | CYCLES | Number of cycles operation took |

##### Register: RAM_TEST_ERRORS

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | COUNT | For READ tests, number of data mismatches |

##### Register: RAM_TEST_LAST

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:0 | RD_DATA | For READ tests, last word read from RAM |

