# Set up NP Retail demo environment

There's a trial version of the NP Retail solution that is readily available on the [NaviPartner portal](https://www.navipartner.com/get-trial/). To request the free trial of the solution, follow the provided steps:

1. Navigate to the [NaviPartner portal](https://www.navipartner.com/get-trial/).
2. Provide all the necessary information, such as name, company, email and phone number.     
   Note that you should select the version of the trial according to the region you are in. 
3. Select the design theme for the trial web shop that you want to use.     
   The demo environment is created, and opened in your browser. There are four demo segments you can choose from.     
   You will also receive a confirmation email containing your credentials and a login token.
4. Open one of the available solutions in your browser to get started.   
   A set of instructions is displayed. Follow these instructions to set up the application on your smart device.
> [!Note]
> If you need assistance in using the free trial version, click the **Help** button in the bottom right corner or visit the [support page](https://www.navipartner.com/trial-test?utm_source=Welcome&utm_medium=email&utm_campaign=welcome).

5. Download the **NP Retail Cloud POS** app from the App Store, and install it. 
6. Open the app and click **I have a QR code**.     
   It's also possible to request a trial account directly from the app by clicking **Create account** if you haven't completed any of the previous steps yet. 
7. Scan the QR code with your device.
8. Enter your salesperson code in the indicated field, and click **OK**.      
   The trial environment is now open.

## Next steps (Advanced setup)

Once you've completed the initial setup, there some additional configurations that you might be interested in.

### Install Major Tom

Major Tom is Windows desktop POS software which embeds the web client and serves as a middleware between the web browser and the local hardware. Follow these steps to set up Major Tom:

1. [Download](https://clickonce.dynamics-retail.com/clickonce/majortom/install.html), and install the user interface.     
   You can choose between the 32-bit and the 64-bit version.   
2. Configure the URL to where the database is.      
   If this is a multi-tenant database environment, you need to configure the tenant as well.
3. To define which company a user will have access to, open **User Personalization**.
4. From **My settings** menu, navigate to the company list that the user has access to and select the company the user works in.        
   This action also changes the default company attached to the user in the **User Personalization** menu.   

### Install Minor Tom

Minor Tom is an abbreviated version of Major Tom, which offers only the essential POS features. Due to its limited functionality, it is faster and intended for wider usage. Follow these steps to set up Minor Tom:

1. Download Minor Tom either from the NP Retail Role Center dashboard, or from the [direct link](https://npminortom.blob.core.windows.net/prod/Setup.exe), and install it.     
   The desktop shortcut is automatically created as soon as installation is finished.
2. Open Minor Tom.    
   When you enter the app for the first time, you will be presented with the setup page. 
3. Depending on which environment you're using, do one of the following:
   
   **On-Prem**
   - Both **Username** and **Password** are optional, but you can provide them if you wish to enable the auto-login feature. 
   - In the **BaseURL** field paste the URL of the Business Central instance in the following form: https://www.examplecustomer.dynamics-retail.net.
   - Make sure that the **IsSSO** toggle switch is deactivated. 

   **Cloud (SaaS)**
   - Leave the **Username** and **Password** fields empty. 
   - Paste the URL for the Business Central instance into the **BaseURL** field, while using the following form: https://businesscentral.dynamics/[TenantID]/[Environment]. The POS page will be automatically appended to the provided URL.
   - Enable the **IsSSO** toggle switch.
   
   > [!Note]
   > The customers' Azure tenant needs to be [configured](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-session-lifetime) prior to using the cloud version so that their session can be automatically extended on the following login.

4. Once the installation is complete, you can click **New Sale** in the sidebar to start using the POS features.

   > [!Note]
   > Whenever a new Minor Tom version is available, it will be automatically detected and downloaded as soon as you launch the app.

### Install ClickOnce

ClickOnce is a deployment technology that enables you to create self-updating Windows-based applications that can be installed and run with minimal user interaction. 

1. Click the **ClickOnce Client Installation** link from the email you received from NaviPartner when you requested a trial version of NP Retail.    
   The page containing the installation links is displayed.
2. Click **Install now**.
3. During the installation, you will need to provide credentials to log into Microsoft Dynamics NAV.   
   It takes a few minutes to run for the first time, as all necessary .dll files need to be properly installed on your PC.
   After the installation is complete, you will be able to access Microsoft Dynamics NAV via ClickOnce.