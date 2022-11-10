# System requirements 

The following article lists all system requirements for running our solutions. They are minimal, as solutions are cloud-based, and the Retail POS is operated through a browser. 

## Network

### Internet speed

| No. of Users | Minimum Speed |
| ----------- | ----------- |
| 1-5 simultaneous users    | 10/2Mbit |
| 6-9 simultaneous users    | 15/2Mbit |
| 10-14 simultaneous users  | 20/2Mbit |
| 15+ simultaneous users    | 20/2Mbit |
| Mobile broadband per user   |  2/2Mbit |

### Internet failover (recommended)

It's recommended to have a failover solution in case the Internet is down. It should be using an independent network. The solutions for this are as follows:

- A router with integrated 4G fallback, which switches the cabled Internet connection to 4G when it goes down, and/or
- A backup Internet connection which you can automatically switch over to when the primary Internet connection goes down. 

### Web client

The web client isn't latency-sensitive. However, keeping latency under 100ms between the web client and the BC/NAV Web server is best (the lower the better).

## Firewall setup

### Software

| Software   | WAN IP | Port(s) |
| ----------- | ----------- | ----------- | 
| Baxi (Viking) | 91.102.24.142; 212.226.157.243 | TCP: 9670/9680; TCP: 6001 | 
| BC/NAV RTC Client |  ALL | Different Per Customer | 
| BC/NAV SOAP | ALL | TCP: Different Per Customer | 
| BC/NAV ODATA | ALL | TCP: Different Per Customer | 
| FlexIITerm | 193.142.211.21/22 | TCP: 19000 |
| NP Deploy | ALL |  TCP: 7087 |
| NP Helper | 94.127.52.122 | TCP: 49000 |
| NP System Callback | ALL |  TCP: 7047 | 
| Remote Desktop | 81.27.209.0/24 | TCP: 3389 |
| TeamViewer | ALL | TCP: 80/433/5938 UDP: 5938 | 


### Hardware

| Hardware    | LAN IP | Port(s) |
| ----------- | ----------- | ----------- |
| Label Print (Zebra) | Fixed  | TCP: 9100 (LAN - Outbound) |
| Payment Terminal (Adyen) | DHCP | TCP: 443 (WAN) |
| Payment Terminal (Nets - PSAM) | Fixed |  TCP: 1234 (LAN - Outbound) |
| Payment Terminal (Verifone Denmark) | DHCP | TCP: 9600 (LAN - Inbound) |
| Receipt Print (Epson) | Fixed | TCP: 9100 (LAN - Outbound) | 

## Device connectivity

**Stationary PCs**

The basic POS setup requires up to 7 network ports. They are used for the label printer, receipt printer, payment terminal etc. The PC needs to be connected with a LAN cable. 

**Mobile Point of Sales (MPOS)**

MPOS devices such as phones and tablets should be connected via Wi-Fi with the 4G network at least. 

**Other devices**

Label printers, receipt printers, payment terminals, and other hardware need to be connected via LAN. They need to be on the same network as the PC used for the POS. We do not support devices connected via Direct Connect. 

**Wi-Fi** 

LAN and Wi-Fi need to be on the same subnet. It's recommended that all POS/MPOS equipment that runs on Wi-Fi gets its own SSID. All hardware that is connected via Wi-Fi needs to be on a stable connection. Devices that continuously switch between different Wi-Fi connections are at risk of causing errors. 

## Supported hardware

Our solution works with a wide variety of hardware. Feel free to reach out to us if you have hardware that isn't mentioned on this page. We will be happy to assess whether it can be used or not. 

> [!Important]
> While many hardware devices can run on our solutions, we only offer Support and Hotline on a [limited list](https://image.navipartner.dk/wp-content/uploads/support-service-level-agreement.pdf). 

### Barcode scanners

You can use all Zebra scanners with our solution. 

### Cash drawers

All payment terminals can be used as stand-alone solutions. For integrated solutions, see the list below: 

**Adyen**

- All terminals that support the [Adyen Cloud Integration](https://www.adyen.com/pos-payments/terminals) (Android 4.4 or newer, iOS 11 or newer, and Windows 10).

**Nets**

- Ingenico iPP350 PSAM terminal 
- Ingenico iPP350 BAXI terminal 
- Ingenico Move3500 BAXI terminal 
- Ingenico Lane3000 BAXI terminal 
- Ingenico iSMP4 BAXI terminal

**Verifone**

- Not supported at this time, but we are actively working on the solution. 

### Printers

**Receipt printers**

- Epson TM-m30
- Epson TM-P20 
- Epson TM-P80
- Epson TM-T88V
- Epson TM-T88VI

**Label printers**

- Zebra ZD410
- Zebra ZD420
- Zebra ZD421

**Card printer**

- Magicard Pronto 100

**Ticket printer** 

- Zebra ZT230
- Zebra ZT411

**RFID hardware**

- Zebra RFD8500 (RFID scanner)
- Impinj xSpan Gateway (RFID readers)
- Impinj xArrary Gateway (RFID readers)
- Zebra ZD500R (RFID printer)
- Zebra ZD621R (RFID printer)

**Warehouse scanners**

- Motorola MT2070
- Motorola P460

**PC for running POS**

Minimum requirements:

CPU: Intel i3 5th gen
RAM: 4GB
HDD: 120GB
Operating system: Windows 10

Recommended requirements:

CPU: Intel i5 10th gen
RAM: 8GB
SSD: 512GB
Operating system: Windows 10 Pro

**SmartPhones**

Our system can be operated on Apple and Android smartphones and tablets.
Hardware requirements: integrated camera
Software requirements: the latest three major versions and their updates




