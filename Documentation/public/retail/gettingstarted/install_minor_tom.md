# Install Minor Tom

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

### Related links

- [Install Major Tom](install_major_tom.md)