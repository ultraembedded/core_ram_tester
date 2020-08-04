### AXI-4 RAM Tester

Github: [https://github.com/ultraembedded/core_ram_tester](https://github.com/ultraembedded/core_ram_tester)

This core can be used to test read/write performance of a 32-bit AXI-4 memory.  
It can also be used to validate read data.  
Accesses are performed as pipelined AXI-4 burst operations.

#### Example Usage
```
    clock_ns  = 20
    burst_len = 64
    print "# User clock: %fns (%fMHz)" % (clock_ns, 1000/clock_ns)
    print "# Burst Length: %d bytes" % (burst_len)

    # Configure Buffer
    base = 0x80000000
    size = (1 * 1024 * 1024)
    ram_tester.write32(RAM_TEST_BASE, 0x80000000)
    ram_tester.write32(RAM_TEST_END, base + size)

    burst_cfg = (burst_len-1) << RAM_TEST_CFG_BURST_LEN_SHIFT

    ###########################################################################
    # Write RAM to ZEROS
    ram_tester.write32(RAM_TEST_CFG, burst_cfg | (1 << RAM_TEST_CFG_ZERO_SHIFT))
    while True:
        status = ram_tester.read32(RAM_TEST_STS)
        if (status & (1 << RAM_TEST_STS_BUSY_SHIFT)) == 0:
            break

    cycles   = ram_tester.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000 / time_ns) * size
    print "|- %d bytes written in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)

    # Checking
    ram_tester.write32(RAM_TEST_CFG, burst_cfg | (1 << RAM_TEST_CFG_ZERO_SHIFT) | (1 << RAM_TEST_CFG_READ_SHIFT))
    errors   = ram_tester.read32(RAM_TEST_ERRORS)
    cycles   = ram_tester.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000 / time_ns) * size
    print "|- %d bytes read in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)    
    print "|- Errors: %d" % errors

    ###########################################################################
    # Write RAM to ONES
    ram_tester.write32(RAM_TEST_CFG, burst_cfg | (1 << RAM_TEST_CFG_ONES_SHIFT))
    while True:
        status = ram_tester.read32(RAM_TEST_STS)
        if (status & (1 << RAM_TEST_STS_BUSY_SHIFT)) == 0:
            break

    cycles   = ram_tester.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000 / time_ns) * size
    print "|- %d bytes written in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)

    # Checking
    ram_tester.write32(RAM_TEST_CFG, burst_cfg | (1 << RAM_TEST_CFG_ONES_SHIFT) | (1 << RAM_TEST_CFG_READ_SHIFT))
    errors   = ram_tester.read32(RAM_TEST_ERRORS)
    cycles   = ram_tester.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000 / time_ns) * size
    print "|- %d bytes read in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)    
    print "|- Errors: %d" % errors

    ###########################################################################
    # Write RAM to INCR
    ram_tester.write32(RAM_TEST_CFG, burst_cfg | (1 << RAM_TEST_CFG_INCR_SHIFT))
    while True:
        status = ram_tester.read32(RAM_TEST_STS)
        if (status & (1 << RAM_TEST_STS_BUSY_SHIFT)) == 0:
            break

    cycles   = ram_tester.read32(RAM_TEST_TIME)    
    time_ns  = clock_ns * cycles
    bw       = (1000000000 / time_ns) * size
    print "|- %d bytes written in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)

    # Checking
    ram_tester.write32(RAM_TEST_CFG, burst_cfg | (1 << RAM_TEST_CFG_INCR_SHIFT) | (1 << RAM_TEST_CFG_READ_SHIFT))
    errors   = ram_tester.read32(RAM_TEST_ERRORS)
    cycles   = ram_tester.read32(RAM_TEST_TIME)
    time_ns  = clock_ns * cycles
    bw       = (1000000000 / time_ns) * size
    print "|- %d bytes read in %d cycles (%dMB/s)" % (size, cycles, bw / 1000000)    
    print "|- Errors: %d" % errors
```

##### Register Map

| Offset | Name | Description   |
| ------ | ---- | ------------- |
| 0x00 | RAM_TEST_CFG | [RW] Configuration Register |
| 0x04 | RAM_TEST_BASE | [RW] Buffer Base Address |
| 0x08 | RAM_TEST_END | [RW] Buffer End Address |
| 0x0c | RAM_TEST_STS | [R] Status Register |
| 0x10 | RAM_TEST_CURRENT | [R] Buffer Current address |
| 0x14 | RAM_TEST_TIME | [R] Operation completion cycles |
| 0x18 | RAM_TEST_ERRORS | [R] Operation errors |
| 0x1c | RAM_TEST_LAST | [R] Last read data |

##### Register: RAM_TEST_CFG

| Bits | Name | Description    |
| ---- | ---- | -------------- |
| 31:28 | BURST_LEN | Burst length - 1 (0 = singles, 1 = 8 bytes, 3 = 16 bytes) |
| 8 | READ | Perform read operation (with error checking) |
| 3 | RND_DELAY | Enable short psuedo random delay between accesses |
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
