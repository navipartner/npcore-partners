# Set up NP Retail demo environment

There's a trial version of the NP Retail solution that is readily available on the [NaviPartner portal](https://www.navipartner.com/get-trial/). To request the free trial of the solution, follow the provided steps:

1. Navigate to the [NaviPartner portal](https://www.navipartner.com/get-trial/).
2. Provide all the necessary information, such as name, company, email and phone number.     
   Note that you should select the version of the trial according to the region you are in. 
4. Select the design theme for the trial web shop that you want to use.     
   The demo environment is created, and opened in your browser. There are four demo segments you can choose from.     
   You will also receive a confirmation email containing your credentials and a login token.
5. Open one of the available solutions in your browser to get started.   
   A set of instructions is displayed. Follow these instructions to set up the application on your smart device.
> [!Note]
> If you need assistance in using the free trial version, click the **Help** button in the bottom right corner or visit the [support page](https://www.navipartner.com/trial-test?utm_source=Welcome&utm_medium=email&utm_campaign=welcome).

6. Download the **NP Retail Cloud POS** app from the App Store, and install it. 
7. Open the app and click **I have a QR code**.     
   It's also possible to request a trial account directly from the app by clicking **Create account** if you haven't completed any of the previous steps yet. 
8. Scan the QR code with your device.
9. Enter your salesperson code in the indicated field, and click **OK**.      
   The trial environment is now open.

## Next steps (Advanced setup)

Once you've completed the initial setup, there some additional configurations that you might be interested in.

### Install Major Tom

Major Tom is Windows desktop POS software which embeds the web client and serves as a middleware between the web browser and the local hardware. Follow these steps to set up Major Tom:

1. [Download](https://clickonce.dynamics-retail.com/clickonce/majortom/install.html) and install the user interface.     
   You can choose between 32-bit and 64-bit version.   
2. Configure the URL to where the database is.      
   If this is a multi-tenant database environment, you need to configure the tenant as well.
3. To define which company a user will have access to, open **User Personalization**.
4. From **My settings** menu, navigate to the company list that the user has access to and select the company the user works in.        
   This action also changes the default company attached to the user in the **User Personalization** menu.   

### Install ClickOnce

ClickOnce is a deployment technology that enables you to create self-updating Windows-based applications that can be installed and run with minimal user interaction. 

1. Click the **ClickOnce Client Installation** link from the email you received from NaviPartner when you requested a trial version of NP REtail.    
   The page containing the installation links is displayed.
2. Click **Install now**.
3. During the installation, you will need to provide credentials to log into Microsoft Dynamics NAV.   
   It takes a few minutes to run for the first time, as all necessary .dll files need to be properly installed on your PC.
   After the installation is complete, you will be able to access Microsoft Dynamics NAV via ClickOnce.