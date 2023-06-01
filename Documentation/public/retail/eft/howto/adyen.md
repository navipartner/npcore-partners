# Set up Adyen Cloud integration (EFT)

Adyen as the terminal provider is set up with the Adyen Cloud integration. Both the terminal and the POS are required to establish the connection to the Adyen Cloud. 

To set up POS Unit 03 to use Adyen Cloud integration, follow the provided steps:

## Prerequisites

- Have a terminal from Adyen.
- Create the API credentials connected to the store and the terminal via the Adyen Web admin menu

## Procedure

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup**, and choose the related link.     
2.	In **Payment Type POS** provide **T**.       
    The T is used as a general **POS Payment Method** for making terminal calls.
3.	Provide **03** in **POS Unit No**. 
4.	In **EFT Integration Type** open the pop-up by clicking ![Elipsis icon](../../../images/Icons/elipsis_icon.png "Three dots") and select **ADYEN_CLOUD**.
5.	With the line selected, navigate to the **Payment Type Parameters**.
6.	Insert the value from **Adyen API Credentials** in the **API Key** field.
7.	Close the page and navigate to** POS Unit Parameters**.
8.	In the **POI ID** insert the ID of the terminal from Adyen.      
    The ID is usually expressed in the following format: [Terminal Type] - [Serial Number] - for example P400Plus-123123123.

### Related links

- [Set up Adyen payment integration](../../webshopintegrations/payment_gateway/howto/adyen.md)
- [Set up EFT operations](eft_operation.md)
