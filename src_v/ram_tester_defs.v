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

`define RAM_TEST_CFG    8'h0

    `define RAM_TEST_CFG_BURST_LEN_DEFAULT    0
    `define RAM_TEST_CFG_BURST_LEN_B          28
    `define RAM_TEST_CFG_BURST_LEN_T          31
    `define RAM_TEST_CFG_BURST_LEN_W          4
    `define RAM_TEST_CFG_BURST_LEN_R          31:28

    `define RAM_TEST_CFG_READ      8
    `define RAM_TEST_CFG_READ_DEFAULT    0
    `define RAM_TEST_CFG_READ_B          8
    `define RAM_TEST_CFG_READ_T          8
    `define RAM_TEST_CFG_READ_W          1
    `define RAM_TEST_CFG_READ_R          8:8

    `define RAM_TEST_CFG_RND_DELAY      7
    `define RAM_TEST_CFG_RND_DELAY_DEFAULT    0
    `define RAM_TEST_CFG_RND_DELAY_B          7
    `define RAM_TEST_CFG_RND_DELAY_T          7
    `define RAM_TEST_CFG_RND_DELAY_W          1
    `define RAM_TEST_CFG_RND_DELAY_R          7:7

    `define RAM_TEST_CFG_USER      3
    `define RAM_TEST_CFG_USER_DEFAULT    0
    `define RAM_TEST_CFG_USER_B          3
    `define RAM_TEST_CFG_USER_T          3
    `define RAM_TEST_CFG_USER_W          1
    `define RAM_TEST_CFG_USER_R          3:3

    `define RAM_TEST_CFG_INCR      2
    `define RAM_TEST_CFG_INCR_DEFAULT    0
    `define RAM_TEST_CFG_INCR_B          2
    `define RAM_TEST_CFG_INCR_T          2
    `define RAM_TEST_CFG_INCR_W          1
    `define RAM_TEST_CFG_INCR_R          2:2

    `define RAM_TEST_CFG_ONES      1
    `define RAM_TEST_CFG_ONES_DEFAULT    0
    `define RAM_TEST_CFG_ONES_B          1
    `define RAM_TEST_CFG_ONES_T          1
    `define RAM_TEST_CFG_ONES_W          1
    `define RAM_TEST_CFG_ONES_R          1:1

    `define RAM_TEST_CFG_ZERO      0
    `define RAM_TEST_CFG_ZERO_DEFAULT    0
    `define RAM_TEST_CFG_ZERO_B          0
    `define RAM_TEST_CFG_ZERO_T          0
    `define RAM_TEST_CFG_ZERO_W          1
    `define RAM_TEST_CFG_ZERO_R          0:0

`define RAM_TEST_BASE    8'h4

    `define RAM_TEST_BASE_ADDR_DEFAULT    0
    `define RAM_TEST_BASE_ADDR_B          0
    `define RAM_TEST_BASE_ADDR_T          31
    `define RAM_TEST_BASE_ADDR_W          32
    `define RAM_TEST_BASE_ADDR_R          31:0

`define RAM_TEST_END    8'h8

    `define RAM_TEST_END_ADDR_DEFAULT    0
    `define RAM_TEST_END_ADDR_B          0
    `define RAM_TEST_END_ADDR_T          31
    `define RAM_TEST_END_ADDR_W          32
    `define RAM_TEST_END_ADDR_R          31:0

`define RAM_TEST_STS    8'hc

    `define RAM_TEST_STS_BUSY      0
    `define RAM_TEST_STS_BUSY_DEFAULT    0
    `define RAM_TEST_STS_BUSY_B          0
    `define RAM_TEST_STS_BUSY_T          0
    `define RAM_TEST_STS_BUSY_W          1
    `define RAM_TEST_STS_BUSY_R          0:0

`define RAM_TEST_CURRENT    8'h10

    `define RAM_TEST_CURRENT_ADDR_DEFAULT    0
    `define RAM_TEST_CURRENT_ADDR_B          0
    `define RAM_TEST_CURRENT_ADDR_T          31
    `define RAM_TEST_CURRENT_ADDR_W          32
    `define RAM_TEST_CURRENT_ADDR_R          31:0

`define RAM_TEST_WRITE    8'h14

    `define RAM_TEST_WRITE_PATTERN_DEFAULT    0
    `define RAM_TEST_WRITE_PATTERN_B          0
    `define RAM_TEST_WRITE_PATTERN_T          31
    `define RAM_TEST_WRITE_PATTERN_W          32
    `define RAM_TEST_WRITE_PATTERN_R          31:0

`define RAM_TEST_TIME    8'h18

    `define RAM_TEST_TIME_CYCLES_DEFAULT    0
    `define RAM_TEST_TIME_CYCLES_B          0
    `define RAM_TEST_TIME_CYCLES_T          31
    `define RAM_TEST_TIME_CYCLES_W          32
    `define RAM_TEST_TIME_CYCLES_R          31:0

`define RAM_TEST_ERRORS    8'h1c

    `define RAM_TEST_ERRORS_COUNT_DEFAULT    0
    `define RAM_TEST_ERRORS_COUNT_B          0
    `define RAM_TEST_ERRORS_COUNT_T          31
    `define RAM_TEST_ERRORS_COUNT_W          32
    `define RAM_TEST_ERRORS_COUNT_R          31:0

`define RAM_TEST_LAST    8'h20

    `define RAM_TEST_LAST_RD_DATA_DEFAULT    0
    `define RAM_TEST_LAST_RD_DATA_B          0
    `define RAM_TEST_LAST_RD_DATA_T          31
    `define RAM_TEST_LAST_RD_DATA_W          32
    `define RAM_TEST_LAST_RD_DATA_R          31:0

