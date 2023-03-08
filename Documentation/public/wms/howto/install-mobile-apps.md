# Install WMS and RFID apps on mobile devices

There are two available apps - NP WMS and NP RFID. NP WMS contains warehouse management features, and is also used for barcode scanning, while NP RFID is useful when RFID tags are attached to items. To install the apps and connect devices to the WMS environment, follow the provided steps. 

1. To download and install the necessary WMS apps, you first need to find them in the Google Play store.      
   The apps you need are called **NP WMS** and **NP RFID**, both produced by **Navi Partner**, as indicated in the following screenshot.           

<img src="../images/npwms-play-store.jpg" width="300">

> [!Note]
> Both NP WMS and NP RFID are Android-exclusive apps.

2. Once downloaded and installed, open the **NP WMS**/**NP RFID** app and select whether you wish to use the SaaS or on-prem version. 

3. Use the necessary authentication to proceed, and then select the tenant and company that you want to use.

4. Press **SETUP**.         
   A window for setting up the profile is displayed.

5. In the **PROFILE** window, press **SETUP ACCOUNT**.

5. In NP WMS, press the camera icon in the upper right corner to scan the [QR Code](create-qr-codes.md) that was previously created in Business Central.              
   Following the successful QR scan, the required parameters will be saved in the **Setup**.

6. In the NP RFID app, press **CONNECT A SCANNER** to select how the scanning will be performed.    
   You can choose between a phone camera, or one of the listed scanners.
   If you selected a camera, you also need to **REQUEST A SCANNER LICENSE**. Scanner licenses are then distributed to new devices by NaviPartner employees.

> [!Note]
> The only difference between the NP WMS and NP RFID scanner configuration is that the NP RFID app is connected to the Bluetooth scanner in the **SCANNER** portion of **SETUP**, where you can see the type of scanner in use, along with the RFID scanner ID, and multiple options for configuring the RFID scanner settings. 

   Once the necessary steps are completed, you will be ready to log in and start using the app.
### Related links

- [Warehouse Management System](../intro.md)
- [Download and install NP WMS extension](../howto/Install-NP-WMS.md)
- [Create QR codes](create-qr-codes.md)