EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MCU_Microchip_ATtiny:ATtiny4-TS U1
U 1 1 5F194EBF
P 4850 3600
F 0 "U1" H 4320 3646 50  0000 R CNN
F 1 "ATtiny4-TS" H 4320 3555 50  0000 R CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 4850 3600 50  0001 C CIN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-8127-AVR-8-bit-Microcontroller-ATtiny4-ATtiny5-ATtiny9-ATtiny10_Datasheet.pdf" H 4850 3600 50  0001 C CNN
	1    4850 3600
	1    0    0    -1  
$EndComp
$Comp
L Device:R R1
U 1 1 5F195255
P 5650 3000
F 0 "R1" H 5720 3046 50  0000 L CNN
F 1 "100k" H 5720 2955 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 5580 3000 50  0001 C CNN
F 3 "~" H 5650 3000 50  0001 C CNN
	1    5650 3000
	1    0    0    -1  
$EndComp
$Comp
L Device:Battery_Cell #BT1
U 1 1 5F1956B2
P 7450 3600
F 0 "#BT1" H 7333 3696 50  0001 R CNN
F 1 "CR927" H 7850 3650 50  0000 R CNN
F 2 "" V 7450 3660 50  0001 C CNN
F 3 "~" V 7450 3660 50  0001 C CNN
	1    7450 3600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0101
U 1 1 5F1959C5
P 7450 3700
F 0 "#PWR0101" H 7450 3450 50  0001 C CNN
F 1 "GND" H 7455 3527 50  0000 C CNN
F 2 "" H 7450 3700 50  0001 C CNN
F 3 "" H 7450 3700 50  0001 C CNN
	1    7450 3700
	1    0    0    -1  
$EndComp
$Comp
L power:+3V0 #PWR0102
U 1 1 5F195F35
P 7450 3400
F 0 "#PWR0102" H 7450 3250 50  0001 C CNN
F 1 "+3V0" H 7465 3573 50  0000 C CNN
F 2 "" H 7450 3400 50  0001 C CNN
F 3 "" H 7450 3400 50  0001 C CNN
	1    7450 3400
	1    0    0    -1  
$EndComp
$Comp
L power:+3V0 #PWR0103
U 1 1 5F196204
P 4850 3000
F 0 "#PWR0103" H 4850 2850 50  0001 C CNN
F 1 "+3V0" H 4865 3173 50  0000 C CNN
F 2 "" H 4850 3000 50  0001 C CNN
F 3 "" H 4850 3000 50  0001 C CNN
	1    4850 3000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 5F196445
P 4850 4200
F 0 "#PWR0104" H 4850 3950 50  0001 C CNN
F 1 "GND" H 4855 4027 50  0000 C CNN
F 2 "" H 4850 4200 50  0001 C CNN
F 3 "" H 4850 4200 50  0001 C CNN
	1    4850 4200
	1    0    0    -1  
$EndComp
$Comp
L Device:Speaker #LS1
U 1 1 5F196D45
P 6800 3300
F 0 "#LS1" H 6763 3617 50  0001 C CNN
F 1 "Speaker" H 6763 3525 50  0001 C CNN
F 2 "" H 6800 3100 50  0001 C CNN
F 3 "~" H 6790 3250 50  0001 C CNN
	1    6800 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 3300 5650 3300
Wire Wire Line
	5450 3500 5650 3500
Wire Wire Line
	5650 3500 5650 3300
Connection ~ 5650 3300
Wire Wire Line
	5650 3300 5650 3150
$Comp
L power:GND #PWR0105
U 1 1 5F1981AF
P 6600 3450
F 0 "#PWR0105" H 6600 3200 50  0001 C CNN
F 1 "GND" H 6605 3277 50  0000 C CNN
F 2 "" H 6600 3450 50  0001 C CNN
F 3 "" H 6600 3450 50  0001 C CNN
	1    6600 3450
	1    0    0    -1  
$EndComp
$Comp
L power:+3V0 #PWR0106
U 1 1 5F198416
P 5650 2850
F 0 "#PWR0106" H 5650 2700 50  0001 C CNN
F 1 "+3V0" H 5665 3023 50  0000 C CNN
F 2 "" H 5650 2850 50  0001 C CNN
F 3 "" H 5650 2850 50  0001 C CNN
	1    5650 2850
	1    0    0    -1  
$EndComp
NoConn ~ 5450 3400
NoConn ~ 5450 3600
Wire Wire Line
	6600 3450 6600 3400
$Comp
L Connector:TestPoint_Small TP3
U 1 1 5F19A878
P 6600 3300
F 0 "TP3" H 6700 3400 50  0000 L CNN
F 1 "audio+" H 6950 3300 50  0001 L CNN
F 2 "TestPoint:TestPoint_Pad_D2.0mm" H 6800 3300 50  0001 C CNN
F 3 "~" H 6800 3300 50  0001 C CNN
	1    6600 3300
	1    0    0    -1  
$EndComp
Connection ~ 6600 3300
$Comp
L Connector:TestPoint_Small TP4
U 1 1 5F19AD90
P 6600 3400
F 0 "TP4" H 6700 3300 50  0000 L CNN
F 1 "audio-" H 6950 3400 50  0001 L CNN
F 2 "TestPoint:TestPoint_Pad_D2.0mm" H 6800 3400 50  0001 C CNN
F 3 "~" H 6800 3400 50  0001 C CNN
	1    6600 3400
	1    0    0    -1  
$EndComp
Connection ~ 6600 3400
$Comp
L Connector:TestPoint_Small TP1
U 1 1 5F19AF7A
P 7450 3400
F 0 "TP1" H 7600 3350 50  0000 L CNN
F 1 "bat+" H 7498 3355 50  0001 L CNN
F 2 "TestPoint:TestPoint_Pad_D2.0mm" H 7650 3400 50  0001 C CNN
F 3 "~" H 7650 3400 50  0001 C CNN
	1    7450 3400
	1    0    0    -1  
$EndComp
Connection ~ 7450 3400
$Comp
L Connector:TestPoint_Small TP2
U 1 1 5F19B282
P 7450 3700
F 0 "TP2" H 7600 3750 50  0000 L CNN
F 1 "bat-" H 7498 3655 50  0001 L CNN
F 2 "TestPoint:TestPoint_Pad_D2.0mm" H 7650 3700 50  0001 C CNN
F 3 "~" H 7650 3700 50  0001 C CNN
	1    7450 3700
	1    0    0    -1  
$EndComp
Connection ~ 7450 3700
$Comp
L Device:R R2
U 1 1 5F1D9E27
P 6000 3300
F 0 "R2" V 5793 3300 50  0000 C CNN
F 1 "200" V 5884 3300 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 5930 3300 50  0001 C CNN
F 3 "~" H 6000 3300 50  0001 C CNN
	1    6000 3300
	0    1    1    0   
$EndComp
$Comp
L Device:C C1
U 1 1 5F1DA44F
P 6150 3450
F 0 "C1" H 6265 3496 50  0000 L CNN
F 1 "100n" H 6265 3405 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 6188 3300 50  0001 C CNN
F 3 "~" H 6150 3450 50  0001 C CNN
	1    6150 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 3300 5850 3300
Wire Wire Line
	6150 3300 6600 3300
Connection ~ 6150 3300
$Comp
L power:GND #PWR0107
U 1 1 5F1E259E
P 6150 3600
F 0 "#PWR0107" H 6150 3350 50  0001 C CNN
F 1 "GND" H 6155 3427 50  0000 C CNN
F 2 "" H 6150 3600 50  0001 C CNN
F 3 "" H 6150 3600 50  0001 C CNN
	1    6150 3600
	1    0    0    -1  
$EndComp
Text Notes 5700 4300 0    50   ~ 0
To remove the 16kHz noise (base \nfrequency of the PWM), we use this \nlow-pass filter that has a cut-off \nfrequency of ca. 8kHz.
Text Notes 5850 2750 0    50   ~ 0
Typical impedance of a line input is \n10-100kOhm, so we can't use the \nAtTiny's internal pull-ups (20-50kOhm).
$EndSCHEMATC
