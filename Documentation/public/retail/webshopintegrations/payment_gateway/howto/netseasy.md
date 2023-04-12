# Set up Nets Easy payment integration

To set up the Nets Easy payment integration in NP Retail, make sure the prerequisites are met, and follow the provided steps:

## Prerequisite

- Create a Nets Easy account.        
    Follow the [Nets Easy setup](https://developers.nets.eu/nets-easy/en-EU/docs/create-nets-easy-portal-account/) guide to create a Nets Easy account.

- Acquire the API key information.    
    The API keys are necessary for testing and using Nets Easy, and making the integration secure. Two sets of integration keys are generated - one for the test environment and one for the production environment. Refer to the [integration key setup guide](https://developers.nets.eu/nets-easy/en-EU/docs/access-your-integration-keys/) to obtain your keys. Note that Business Central requires the **Secret Key**.

## Procedure

1. Click the ![Lightbulb that opens the Tell Me feature](../../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Payment Gateways**, and select the related link.      
 
2. Click **New** to create a code for the NetsEasy integration.    

    ![Payment Gateway List](../images/bambora_integration_list.PNG)  

3. Click **Show Setup Card** to edit the details.

    The following values needs to be defined: 
    - **Environment** - Select **Test** for the test environment or **Production** for the live environment.
    - **API Authorization Token** - The secret key obtained during the prerequisite.

### Related links

- [Payment Gateways](../paymentgateway.md)