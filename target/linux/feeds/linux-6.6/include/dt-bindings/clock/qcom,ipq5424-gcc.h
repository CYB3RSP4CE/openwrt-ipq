/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Copyright (c) 2018,2020 The Linux Foundation. All rights reserved.
 * Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
 */

#ifndef _DT_BINDINGS_CLOCK_IPQ_GCC_IPQ5424_H
#define _DT_BINDINGS_CLOCK_IPQ_GCC_IPQ5424_H

#define GPLL0					0
#define GPLL4					1
#define GPLL2					2
#define GPLL2_OUT_MAIN                          3
#define GCC_SLEEP_CLK_SRC			4
#define GCC_APSS_DBG_CLK                        5
#define GCC_USB0_EUD_AT_CLK			6
#define GCC_PCIE0_AXI_M_CLK_SRC			7
#define GCC_PCIE0_AXI_M_CLK			8
#define GCC_PCIE1_AXI_M_CLK_SRC			9
#define GCC_PCIE1_AXI_M_CLK			10
#define GCC_PCIE2_AXI_M_CLK_SRC			11
#define GCC_PCIE2_AXI_M_CLK			12
#define GCC_PCIE3_AXI_M_CLK_SRC			13
#define GCC_PCIE3_AXI_M_CLK			14
#define GCC_PCIE0_AXI_S_CLK_SRC			15
#define GCC_PCIE0_AXI_S_BRIDGE_CLK		16
#define GCC_PCIE0_AXI_S_CLK			17
#define GCC_PCIE1_AXI_S_CLK_SRC			18
#define GCC_PCIE1_AXI_S_BRIDGE_CLK		19
#define GCC_PCIE1_AXI_S_CLK			20
#define GCC_PCIE2_AXI_S_CLK_SRC			21
#define GCC_PCIE2_AXI_S_BRIDGE_CLK		22
#define GCC_PCIE2_AXI_S_CLK			23
#define GCC_PCIE3_AXI_S_CLK_SRC			24
#define GCC_PCIE3_AXI_S_BRIDGE_CLK		25
#define GCC_PCIE3_AXI_S_CLK			26
#define GCC_PCIE0_PIPE_CLK_SRC			27
#define GCC_PCIE0_PIPE_CLK			28
#define GCC_PCIE1_PIPE_CLK_SRC			29
#define GCC_PCIE1_PIPE_CLK			30
#define GCC_PCIE2_PIPE_CLK_SRC			31
#define GCC_PCIE2_PIPE_CLK			32
#define GCC_PCIE3_PIPE_CLK_SRC			33
#define GCC_PCIE3_PIPE_CLK			34
#define GCC_PCIE_AUX_CLK_SRC			35
#define GCC_PCIE0_AUX_CLK			36
#define GCC_PCIE1_AUX_CLK			37
#define GCC_PCIE2_AUX_CLK			38
#define GCC_PCIE3_AUX_CLK			39
#define GCC_PCIE0_AHB_CLK			40
#define GCC_PCIE1_AHB_CLK			41
#define GCC_PCIE2_AHB_CLK			42
#define GCC_PCIE3_AHB_CLK			43
#define GCC_USB0_AUX_CLK_SRC			44
#define GCC_USB0_AUX_CLK			45
#define GCC_USB0_MASTER_CLK			46
#define GCC_USB0_MOCK_UTMI_CLK_SRC		47
#define GCC_USB0_MOCK_UTMI_DIV_CLK_SRC		48
#define GCC_USB0_MOCK_UTMI_CLK			49
#define GCC_USB0_PIPE_CLK_SRC			50
#define GCC_USB0_PIPE_CLK			51
#define GCC_USB0_PHY_CFG_AHB_CLK		52
#define GCC_USB0_SLEEP_CLK			53
#define GCC_SDCC1_APPS_CLK_SRC			54
#define GCC_SDCC1_APPS_CLK			55
#define GCC_SDCC1_ICE_CORE_CLK_SRC		56
#define GCC_SDCC1_ICE_CORE_CLK			57
#define GCC_SDCC1_AHB_CLK			58
#define GCC_PCNOC_BFDCD_CLK_SRC			59
#define GCC_NSSCFG_CLK				60
#define GCC_NSSNOC_NSSCC_CLK			61
#define GCC_NSSCC_CLK				62
#define GCC_NSSNOC_PCNOC_1_CLK			63
#define GCC_QPIC_AHB_CLK			64
#define GCC_QPIC_CLK				65
#define GCC_MDIO_AHB_CLK			66
#define GCC_PRNG_AHB_CLK			67
#define GCC_UNIPHY0_AHB_CLK			68
#define GCC_UNIPHY1_AHB_CLK			69
#define GCC_UNIPHY2_AHB_CLK			70
#define GCC_CMN_12GPLL_AHB_CLK			71
#define GCC_SYSTEM_NOC_BFDCD_CLK_SRC		72
#define GCC_NSSNOC_SNOC_CLK			73
#define GCC_NSSNOC_SNOC_1_CLK			74
#define GCC_WCSS_AHB_CLK_SRC			75
#define GCC_QDSS_AT_CLK_SRC			76
#define GCC_NSSNOC_ATB_CLK			77
#define GCC_QDSS_AT_CLK				78
#define GCC_QDSS_TSCTR_CLK_SRC			79
#define GCC_NSS_TS_CLK				80
#define GCC_QPIC_IO_MACRO_CLK_SRC		81
#define GCC_QPIC_IO_MACRO_CLK			82
#define GCC_LPASS_AXIM_CLK_SRC			83
#define GCC_LPASS_CORE_AXIM_CLK			84
#define GCC_LPASS_SWAY_CLK_SRC			85
#define GCC_LPASS_SWAY_CLK			86
#define GCC_CNOC_LPASS_CFG_CLK                  87
#define GCC_SNOC_LPASS_CLK                      88
#define GCC_ADSS_PWM_CLK_SRC			89
#define GCC_ADSS_PWM_CLK			90
#define GCC_XO_CLK_SRC				91
#define GCC_NSSNOC_XO_DCD_CLK			92
#define GCC_NSSNOC_QOSGEN_REF_CLK		93
#define GCC_NSSNOC_TIMEOUT_REF_CLK		94
#define GCC_UNIPHY0_SYS_CLK			95
#define GCC_UNIPHY1_SYS_CLK			96
#define GCC_UNIPHY2_SYS_CLK			97
#define GCC_CMN_12GPLL_SYS_CLK			98
#define GCC_UNIPHY_SYS_CLK_SRC			99
#define GCC_NSS_TS_CLK_SRC			100
#define GCC_ANOC_PCIE0_1LANE_M_CLK		101
#define GCC_ANOC_PCIE1_1LANE_M_CLK		102
#define GCC_ANOC_PCIE2_2LANE_M_CLK		103
#define GCC_ANOC_PCIE3_2LANE_M_CLK		104
#define GCC_CNOC_PCIE0_1LANE_S_CLK		105
#define GCC_CNOC_PCIE1_1LANE_S_CLK		106
#define GCC_CNOC_PCIE2_2LANE_S_CLK		107
#define GCC_CNOC_PCIE3_2LANE_S_CLK		108
#define GCC_CNOC_USB_CLK			109
#define GCC_CNOC_WCSS_AHB_CLK			110
#define GCC_QUPV3_AHB_MST_CLK			111
#define GCC_QUPV3_AHB_SLV_CLK			112
#define GCC_QUPV3_I2C0_CLK			113
#define GCC_QUPV3_I2C1_CLK			114
#define GCC_QUPV3_SPI0_CLK			115
#define GCC_QUPV3_SPI1_CLK			116
#define GCC_QUPV3_UART0_CLK			117
#define GCC_QUPV3_UART1_CLK			118
#define GCC_QPIC_CLK_SRC			119
#define GCC_QUPV3_I2C0_CLK_SRC			120
#define GCC_QUPV3_I2C1_CLK_SRC			121
#define GCC_QUPV3_I2C0_DIV_CLK_SRC              122
#define GCC_QUPV3_I2C1_DIV_CLK_SRC              123
#define GCC_QUPV3_SPI0_CLK_SRC			124
#define GCC_QUPV3_SPI1_CLK_SRC			125
#define GCC_QUPV3_UART0_CLK_SRC			126
#define GCC_QUPV3_UART1_CLK_SRC			127
#define GCC_USB1_MASTER_CLK			128
#define GCC_USB1_MOCK_UTMI_CLK_SRC		129
#define GCC_USB1_MOCK_UTMI_DIV_CLK_SRC		130
#define GCC_USB1_MOCK_UTMI_CLK			131
#define GCC_USB1_SLEEP_CLK			132
#define GCC_USB1_PHY_CFG_AHB_CLK		133
#define GCC_USB0_MASTER_CLK_SRC			134
#define GCC_QDSS_DAP_CLK			135
#define GCC_PCIE0_RCHNG_CLK_SRC			136
#define GCC_PCIE0_RCHNG_CLK			137
#define GCC_PCIE1_RCHNG_CLK_SRC			138
#define GCC_PCIE1_RCHNG_CLK			139
#define GCC_PCIE2_RCHNG_CLK_SRC			140
#define GCC_PCIE2_RCHNG_CLK			141
#define GCC_PCIE3_RCHNG_CLK_SRC			142
#define GCC_PCIE3_RCHNG_CLK			143
#define GCC_IM_SLEEP_CLK			144
/* Add new clocks on top of q6 bring up clocks
 * and update MAX_GCC_CLOCKS macro
 */
#define MAX_GCC_CLOCKS				144
#if defined(CONFIG_QCOM_NON_SECURE_PIL) || defined(__QCOM_NON_SECURE_PIL__)
#define GCC_Q6_TSCTR_1TO2_CLK			(MAX_GCC_CLOCKS + 1)
#define GCC_Q6SS_TRIG_CLK			(MAX_GCC_CLOCKS + 2)
#define GCC_Q6_AHB_S_CLK			(MAX_GCC_CLOCKS + 3)
#define GCC_Q6_AHB_CLK				(MAX_GCC_CLOCKS + 4)
#define GCC_Q6SS_ATBM_CLK			(MAX_GCC_CLOCKS + 5)
#define GCC_Q6_AXIM_CLK				(MAX_GCC_CLOCKS + 6)
#define	GCC_Q6SS_BOOT_CLK			(MAX_GCC_CLOCKS + 7)
#define GCC_WCSS_ECAHB_CLK			(MAX_GCC_CLOCKS + 8)
#define GCC_Q6SS_PCLKDBG_CLK			(MAX_GCC_CLOCKS + 9)
#endif

#endif