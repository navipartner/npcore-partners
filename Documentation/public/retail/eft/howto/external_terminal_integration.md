# Set up external terminal integration

You can use the External Terminal integration, either as an additional security measure when using terminals that are not integrated with NP Retail or as backup with additional information. It can also be used if another EFT Transaction is lost between the EFT Terminal and the POS where you can see that the terminal has accepted the transaction, but there are no other ways to transfer from the EFT Terminal to the POS.

To set up POS Unit 01 to use the External Terminal that requires the card numbers, but not the cardholder’s name, follow the provided steps:

## Prerequisite

- Have a **POS Payment Method TMAN** with the **EFT Processing Type**.

## Procedure

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup**, and choose the related link.       
2.	In **Payment Type POS** insert **TMAN**.      
    **TMAN** is used as a POS Payment Method to separate it from the regular **T** **POS Payment Method**.
3.	In **POS Unit No.** insert **01**.
4.	In the **EFT Integration Type**, open the pop-up by clicking ![Elipsis icon](../../../images/Icons/elipsis_icon.png "Three dots") and select **EXTERNAL_TERMINAL**.
5.	With the line selected, navigate to the **Payment Type Parameters** and disable the **Enable Cardholder Popup** checkmark.
6.	Close the page to complete the setup.
