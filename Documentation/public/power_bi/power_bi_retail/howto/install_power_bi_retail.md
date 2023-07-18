# Install NP Power BI for Retail

Take control over your operations by using the Power BI app for retail business. To install the application, make sure the prerequisite is met, and follow the provided steps:

## Prerequisite

- Prior to initiating the installation process, it is imperative to ensure that you have an active Power BI account associated with the same business email address used for logging into Business Central. This alignment of email addresses will facilitate a seamless integration and ensure a smooth installation experience.

## Procedure

1. Log into your Power BI account. 
2. Go to the [Microsoft app store](https://apps.microsoft.com/store/apps) and find our product **NP Power BI for Retail**. Click **Free trial** to run the installation wizard.    
   
   <img src="./../images/power_bi_retail.png" width="270">
   
3. Once the installation wizard is displayed, click **Install**.     
   ![Install_Power_BI](./../images/power_bi_retail2.png)              
   When the application is installed, it will be added to your list in the **Apps** section.      
   ![Microsoft_Apps](./../images/power_bi_retail3.png)
4. If you've already installed the application, you can update it to the new version by selecting the first option in the update app pop-up window, or install a new copy by selecting the third option. After selecting the third option, you need to add a new name of the installation app, and confirm it.    
   ![Update_app](./../images/power_bi_retail4.png)
5. Once the app is installed, click on the application name to initiate its activation.     
   You can review the contents with the test data or connect to your test database from Business Central. 
6. If you determine that the app suits your business and organization needs, contact us to obtain the app link with unlocked parameter fields.    
   This specialized version facilitates seamless integration with the Business Central version 22 and newer.
7. To connect to your data from the Business Central, click **Connect your data** in the alert ribbon.      
    ![Power_BI_alert](./../images/power_bi_retail5.png)
8. In the **Connect to NP Power BI for Retail** pop-up, refer to the relevant URL (e.g. *https://businesscentral.dynamics.com/3850537a-9e72-423a-9ff9-asdasd345322/EnviromentName-Prod?company=Test%20Company%20Aps&node=0000233e*), and provide the data for the following required parameters:
   - **Environment** - provide the environment name from the URL using capital letters (e.g. ENVIRONMENTNAME-PROD)
   - **Company** - provide the company name from the URL without extra characters (e.g Company Aps)
   - **Store Code** - provide the code from the **Dimensions** table (e.g BUTIK)

   > [!Note]
   > If your Global Dimension Code 1 does not refer to shops, or starting month of your fiscal year is different from the calendar year, please get in touch with us.

   ![dimensions-bi](../images/dimensions-bi.PNG)

   > [!Note]
   > Ensure that you don't have any blank characters in the beginning and the end of the text you provide.

9. Click **Next**.
10. Choose the **OAuth2** authentication method, and the **Organizational** privacy level settings.
11. Click **Sign in and connect** to synchronize your Power BI app with the data from Business Central.     
    This step may take some time, and after it's completed you will be able to see your own data in the report.    
    The data will be automatically refreshed once per day by default, but this can be changed in the dataset settings, based on your preferences. 

### Related links

- [NP Power BI for Retail](../intro.md)