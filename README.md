## Smart Switching Converter

The main idea of this project is to design a high efficiency buck converter that will supply the Apertus AXIOM camera system. The three main features of the converter are:
* efficiency
* accuracy
* ripple

This converter is an adjustable one, because multiple voltages are required on the AXIOM board, so a programable solution is preferred. In order to obtain these voltages, multiple instances of the same converter will be included on the board, and each one will be programmed to output the right value. In this way, no hardware modifications are required when modifying the converter parameters.

The goals are:
* obtaining an efficiency as close as or above 90%
* obtaining an accuracy below 100mV
* obtaining a ripple voltage below 50mV

For building instructions, read "Documentnation.pdf".
