# Set up Flexiiterm integration (EFT)

Flexiiterm is used for integrating NaviPartner with the older NETS PSAM terminals, e.g., Ingenico IPP350 terminals. 

To set up POS Unit 04 to use Flexiiterm integration, follow the provided steps:

## Prerequisites

- Have a **POS Payment Method T** with the **EFT Processing Type**. 
- Install the **Flexiiterm** app on the local POS PC.

## Procedure

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup**, and choose the related link.     
2.	Provide **T** in the **Payment Type POS**.       
    The **T** is used as a general **POS Payment Method** for making the terminal calls.
3.	Insert **04** in **POS Unit No**.
4.	In **EFT Integration Type** open the pop-up window by clicking ![Elipsis icon](../../../images/Icons/elipsis_icon.png "Three dots") and select **Flexiiterm**.

> [!Note]
> Since the connection method is set up in the Flexiiterm application, and everything is handled through files locally on the POS, no further setup is required. In the **Payment Type Parameters** there are options to set **CVM** (for example force Signature) or force terminal to work offline.

