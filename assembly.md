# BOM

1x ATtiny4-TS
1x 0806 100kΩ resistor
1x 0806 200Ω resistor
1x 0806 100nF capacitor
1x CR927 lithium cell
1x RCA/cinch style jack; 10mm inner diameter
1x random paper staple

<!--
AliExpress search term:
- "Luxury Soldering RCA Plug Jack Connector Speaker Audio"
Example Listings:
- https://www.aliexpress.com/item/33034854833.html
- https://www.aliexpress.com/item/4000878449744.html
- https://www.aliexpress.com/item/4000908254836.html
Possible actual manufacturer:
- https://www.xinwotong.com/
- https://xinwotong.en.alibaba.com/
-->

# Tools

- AVR programmer (e.g. [USBasp](https://fischl.de/usbasp/))
- ZIF SOT23-6 socket
- Soldering equipment
- Side cutters
- Kapton Tape
- Abrasive paper, ~200 grit XXX/TODO: welche körnung?

# Software

`avr-gcc`, `avr-size` (optional), `avrdude`, `make`

# Assembly Instructions

1.  Insert MCU in ZIF socket and flash it using `make flash`.  
    Note: the MCU requires 5V VCC for flashing!  
    Note: to flash e.g. an ATtiny9, append `CHIP=9` to the command.
2.  With the chip still in the socket and powered through the programmer, switch
    the supply voltage to 3v3 and attach an oscilloscope to the DEBUG pin.
3.  Measure the frequency of the DEBUG signal and adjust the `CAL_MAGIC` value
    until it reads 8kHz.
4.  Solder all components to the (flat) flex PCB.
5.  Insulate the barrel/jacket side of the battery with a thin strip of kapton
    tape.
6.  Bend the staple into a U-shaped clip.  
    The clip shall be slid over the GND via between the MCU and C1.  
    a) roll over on one end  
    b) ca. 7mm down, bend 95°  
    c) ca. 2.75mm down, bend another 95°  
    d) flare open the ends and test/adjust fitment on PCB and battery  
    e) cut off extra length on other end and roll it over  
    f) place a kapton tape flag over the arm that sits on the component side  
7.  Twist together 8 strands of .1mm² enameled copper wire and cut off two ca.
    15mm pieces. Solder onto the PCB pads.
8.  Cut down ground clip of the RCA jack; sand off both terminals until they are
    about 1.5mm proud off the surface.
9.  Solder PCB to RCA jack; insulate component side with kapton tape.
10. Push assembly text-side first deep into RCA jack housing. Test for shorts.
11. Counter-rotate the RCA jack halfs about 3 times. This makes the wires
    untwist when screwing the halfs together.
12. Fully close the RCA jack. Should take about 3.5 turns. Test for shorts and
    severing of the wires.
