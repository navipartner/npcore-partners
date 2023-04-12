# Set up Adyen payment integration

To set up the Adyen payment integration in NP Retail, make sure the prerequisites are met, and follow the provided steps:

## Prerequisite

- Create an API key for Adyen.     
     To allow Business Central to interact with Adyen's API it requires a set of access credentials. The integration uses basic authentication
    and therefore requires a **username** and a **password**. Please follow Adyen's documentation on how to [generate a basic authentication password](https://docs.adyen.com/development-resources/api-credentials#basic-authentication).

    > [!Important]
    > Ensure that the webservice user is enabled and has the both the **Merchant PAL webservice** role and the **Checkout webservice** role enabled.

    > [!Note]
    > It's recommended to create a new user which will not interfere with any other integrations.

## Procedure in Business Central

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Payment Gateways**, and select the related link.

2. Click **New** to create a code for Adyen.      

   ![Payment Gateway List](../images/bambora_integration_list.PNG)   

     > [!Note] 
     > Depending the required setup, the options to enable **Capture**, **Refund** and **Cancel** need to be flagged as illustrated in the screenshot above.
 
3.	Click **Show Setup Card** to update the fields listed below:

    - **Merchant Name** - The name of your merchant with Adyen.
    - **Environment** - You can choose either  the **Test** or the **Production** environment.   
    - **API URL Prefix** - The URL prefix for your live Adyen account.     
        Follow [the guide on finding the endpoint URL for the live account](https://help.adyen.com/knowledge/ecommerce-integrations/integrations-basics/how-can-i-find-the-endpoint-url-for-my-live-account) to find this value. This configuration is only required if **Environment** is set to **Production**.
    - **API Username** - The **username** obtained during the API credential generation.
    - **API Password** - The **password** obtained during the API credential generation.

## Related links

- [Payment Gateways](../paymentgateway.md)