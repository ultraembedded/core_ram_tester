//-----------------------------------------------------------------
//                         RAM Tester
//                            V0.1
//                     Ultra-Embedded.com
//                       Copyright 2020
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

#ifndef __RAM_TESTER_DEFS_H__
#define __RAM_TESTER_DEFS_H__

#define RAM_TEST_CFG      0x0
    #define RAM_TEST_CFG_BURST_LEN_SHIFT         28
    #define RAM_TEST_CFG_BURST_LEN_MASK          0xf

    #define RAM_TEST_CFG_READ                    8
    #define RAM_TEST_CFG_READ_SHIFT              8
    #define RAM_TEST_CFG_READ_MASK               0x1

    #define RAM_TEST_CFG_RND_DELAY               3
    #define RAM_TEST_CFG_RND_DELAY_SHIFT         3
    #define RAM_TEST_CFG_RND_DELAY_MASK          0x1

    #define RAM_TEST_CFG_INCR                    2
    #define RAM_TEST_CFG_INCR_SHIFT              2
    #define RAM_TEST_CFG_INCR_MASK               0x1

    #define RAM_TEST_CFG_ONES                    1
    #define RAM_TEST_CFG_ONES_SHIFT              1
    #define RAM_TEST_CFG_ONES_MASK               0x1

    #define RAM_TEST_CFG_ZERO                    0
    #define RAM_TEST_CFG_ZERO_SHIFT              0
    #define RAM_TEST_CFG_ZERO_MASK               0x1

#define RAM_TEST_BASE     0x4
    #define RAM_TEST_BASE_ADDR_SHIFT             0
    #define RAM_TEST_BASE_ADDR_MASK              0xffffffff

#define RAM_TEST_END      0x8
    #define RAM_TEST_END_ADDR_SHIFT              0
    #define RAM_TEST_END_ADDR_MASK               0xffffffff

#define RAM_TEST_STS      0xc
    #define RAM_TEST_STS_BUSY                    0
    #define RAM_TEST_STS_BUSY_SHIFT              0
    #define RAM_TEST_STS_BUSY_MASK               0x1

#define RAM_TEST_CURRENT  0x10
    #define RAM_TEST_CURRENT_ADDR_SHIFT          0
    #define RAM_TEST_CURRENT_ADDR_MASK           0xffffffff

#define RAM_TEST_TIME     0x14
    #define RAM_TEST_TIME_CYCLES_SHIFT           0
    #define RAM_TEST_TIME_CYCLES_MASK            0xffffffff

#define RAM_TEST_ERRORS   0x18
    #define RAM_TEST_ERRORS_COUNT_SHIFT          0
    #define RAM_TEST_ERRORS_COUNT_MASK           0xffffffff

#define RAM_TEST_LAST     0x1c
    #define RAM_TEST_LAST_RD_DATA_SHIFT          0
    #define RAM_TEST_LAST_RD_DATA_MASK           0xffffffff

#endif