
/*
 * Copyright (c) 2024, Qualcomm Innovation Center, Inc. All rights reserved.
 * SPDX-License-Identifier: ISC
 */

 

 
 
 
 
 
 
 
 


#ifndef _TX_FES_STATUS_USER_RESPONSE_H_
#define _TX_FES_STATUS_USER_RESPONSE_H_
#if !defined(__ASSEMBLER__)
#endif

#include "phytx_abort_request_info.h"
#define NUM_OF_DWORDS_TX_FES_STATUS_USER_RESPONSE 2

#define NUM_OF_QWORDS_TX_FES_STATUS_USER_RESPONSE 1


struct tx_fes_status_user_response {
#ifndef WIFI_BIT_ORDER_BIG_ENDIAN
             uint32_t fes_transmit_result                                     :  4,  
                      reserved_0                                              : 28;  
             struct   phytx_abort_request_info                                  phytx_abort_request_info_details;
             uint16_t reserved_after_struct16                                 : 16;  
#else
             uint32_t reserved_0                                              : 28,  
                      fes_transmit_result                                     :  4;  
             uint32_t reserved_after_struct16                                 : 16;  
             struct   phytx_abort_request_info                                  phytx_abort_request_info_details;
#endif
};


 

#define TX_FES_STATUS_USER_RESPONSE_FES_TRANSMIT_RESULT_OFFSET                      0x0000000000000000
#define TX_FES_STATUS_USER_RESPONSE_FES_TRANSMIT_RESULT_LSB                         0
#define TX_FES_STATUS_USER_RESPONSE_FES_TRANSMIT_RESULT_MSB                         3
#define TX_FES_STATUS_USER_RESPONSE_FES_TRANSMIT_RESULT_MASK                        0x000000000000000f


 

#define TX_FES_STATUS_USER_RESPONSE_RESERVED_0_OFFSET                               0x0000000000000000
#define TX_FES_STATUS_USER_RESPONSE_RESERVED_0_LSB                                  4
#define TX_FES_STATUS_USER_RESPONSE_RESERVED_0_MSB                                  31
#define TX_FES_STATUS_USER_RESPONSE_RESERVED_0_MASK                                 0x00000000fffffff0


 


 

#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_PHYTX_ABORT_REASON_OFFSET 0x0000000000000000
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_PHYTX_ABORT_REASON_LSB 32
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_PHYTX_ABORT_REASON_MSB 39
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_PHYTX_ABORT_REASON_MASK 0x000000ff00000000


 

#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_USER_NUMBER_OFFSET 0x0000000000000000
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_USER_NUMBER_LSB 40
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_USER_NUMBER_MSB 45
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_USER_NUMBER_MASK 0x00003f0000000000


 

#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_RESERVED_OFFSET 0x0000000000000000
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_RESERVED_LSB   46
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_RESERVED_MSB   47
#define TX_FES_STATUS_USER_RESPONSE_PHYTX_ABORT_REQUEST_INFO_DETAILS_RESERVED_MASK  0x0000c00000000000


 

#define TX_FES_STATUS_USER_RESPONSE_RESERVED_AFTER_STRUCT16_OFFSET                  0x0000000000000000
#define TX_FES_STATUS_USER_RESPONSE_RESERVED_AFTER_STRUCT16_LSB                     48
#define TX_FES_STATUS_USER_RESPONSE_RESERVED_AFTER_STRUCT16_MSB                     63
#define TX_FES_STATUS_USER_RESPONSE_RESERVED_AFTER_STRUCT16_MASK                    0xffff000000000000



#endif    
