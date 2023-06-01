# Set up additional Pepper Card types

When paying through the terminal that uses Pepper, it’s recommended to use a single POS Payment Method for triggering the Terminal Payment (the one set up in the EFT Setup administrative section). However, if you want to be able to see that your POS Entry List is using specific cards and post the payments in different G/L accounts, you can set up the **Pepper Card Types** for specific cards and map them to the specific POS Payment Methods.

To set up China Union Pay as a new **Pepper Card Type**, follow the provided steps:

## Prerequisites

- Create a **POS Payment Method** called **CUP**, which stands for the China Union Pay. 

## Procedure

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Pepper Card Types**, and choose the related link.         	
2.	On a new line provide **12** in **Code**.      
    The number 12 is what Pepper uses as an identifier for China Union Pay payments.

> [!Note]
> If you receive a payment that isn’t mapped correctly, you can check what Card Type is used in the EFT Transaction Requests and create a new one/edit an existing one.

3.	Provide **China Union Pay** in the **Description**.
4.	Open the drop-down menu in **Payment Type POS** and select the **CUP** **POS Payment Method**.       
    The setup is complete. When accepting payments on the terminal with the Card Type 12 you will be using the CUP POS Payment Method.
