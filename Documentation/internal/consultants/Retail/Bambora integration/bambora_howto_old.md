# Set up Bambora payment integration

To set up the Bambora payment integration in NP Retail, make sure the prerequisites are met, and follow the provided steps:

### Prerequisites

1. Get a Bambora merchant.

    Before you can get the required information to integrate Business Central and Bambora,
    you need to have a merchant account with Bambora.

2. Acquire the API key information.

    Business Central uses the [Bambora Transaction API](https://developer.bambora.com/europe/checkout/api-reference/transaction)
    to interact with Bambora. In order for Business Central to capture, refund, or cancel a transaction, it needs access to the API.

    Follow [Bambora's guide](https://developer.bambora.com/europe/checkout/getting-started/access-api#get-access-to-the-api) to get the access credentials.
    Business Central will need the following information: **Access token**, **Merchant ID**, and **Secret token**.

    > [!Note]
    > NaviPartner advises that you give the key an appropriate name, for example "Business Central". This will help you differentiate the keys afterwards.

3. Set up payment method mapping.

    For the payment gateway to be used it will have to be assigned to specific payment method mappings. These should be created beforehand.

### Procedure

1. Click the ![Lightbulb that opens the Tell Me feature](../../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Payment Gateways**, and select the related link.      
 
2. Create a new entry for the Bambora integration. The following fields are required and must contain the appropriate values:
    - **Code**
    - **API Username** - This field needs to contain the **Access token**.
    - **API Password** - This field needs to contain the **Secret token**.
    - **Merchant ID** - This field needs to contain the **Merchant ID**.

    Depending on your desired setup, fill out the following three fields:
    - **Capture Codeunit Id** - The value should be **6014405**.
    - **Refund Codeunit Id** - The value should be **6014405**.
    - **Cancel Codeunit Id** - The value should be **6014405**.

    > [!Note]
    > If you don't want the integration to do one or more of the three actions leave the field empty.
    > This will cause the integration to skip handling the corresponding action.

3. Click the ![Lightbulb that opens the Tell Me feature](../../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Payment Method Mapping**, and select the related link.      

4. Add the **Code** of the entry you create in step 2 to the **Payment Gateway Code** field of the appropriate mapping lines.