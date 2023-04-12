# Set up Bambora payment integration

To set up the Bambora payment integration in NP Retail, make sure the prerequisites are met, and follow the provided steps:

## Prerequisites

- Get a Bambora merchant.     
    Before you can get the required information to integrate Business Central and Bambora,
    you need to have a [merchant account created with Bambora](https://developer.bambora.com/europe/checkout/getting-started/create-account).

- Acquire the API key information.     
    Business Central uses the [Bambora Transaction API](https://developer.bambora.com/europe/checkout/api-reference/transaction)
    to interact with Bambora. Access to the API is required to capture, refund, or cancel a transaction from Business Central.

    Follow [Bambora's guide](https://developer.bambora.com/europe/checkout/getting-started/access-api#get-access-to-the-api) to get the access credentials.
    Business Central needs the following information: **Access token**, **Merchant ID**, and **Secret token**.

    > [!Note]
    > NaviPartner advises that you give the key an appropriate name, for example "Business Central". In that way, you can differentiate the keys more easily afterwards.

## Procedure

1. Click the ![Lightbulb that opens the Tell Me feature](../../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Payment Gateways**, and select the related link.      
 
2. Click **New** to create a code for Bambora integration.    

    ![bambora_1](../images/bambora_integration_list.PNG)

3. Click **Show Setup Card** to edit details.  
   The following values are required, and need to contain the appropriate values:     
   - **Access Token** - This is the **Access Token** obtained during the second prerequisite.
   - **Secret Token** - This is the **Secret Token** obtained during the second prerequisite.
   - **Merchant ID** - Your merchant ID with Bambora. The letter T stands for test account, while the letter P stands for the production account.    

    ![bambora_2](../images/bambora_integration_list_2.PNG)

### Related links

- [Payment Gateways](../paymentgateway.md)