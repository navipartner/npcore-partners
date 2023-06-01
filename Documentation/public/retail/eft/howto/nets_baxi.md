# Set up NETS BAXI integration (EFT)

When using NETS BAXI/Viking integrations, there are two different ways of communicating with the terminal, either through the NETS Cloud, or directly between the terminal and the POS.

## Set up NETS BAXI Native integration

To set up POS Unit 1 to use Native BAXI integration, follow the provided steps:

### Prerequisites

- Have a terminal from NETS which uses Viking/BAXI, that is connected to the POS via USB, while using the default COM port 9. 
- Have a **POS Payment Method** with the **EFT Processing Type**. 

### Procedure

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup**, and choose the related link.     
2.	In **Payment Type POS** insert **T**.      
    **T** is used as a general **POS Payment Method** to make our terminal calls.
3.	In **POS Unit No.** insert **01**.
4.	In the **EFT Integration Type** open the pop-up by clicking ![Elipsis icon](../../../images/Icons/elipsis_icon.png "Three dots") and select **NETS_BAXI_NET**.
5.	With the line selected, navigate to the **Payment Type Parameters**.
6.	Disable the **Socket Listener** in the pop-up window.      
    The socket listener is only used when the terminal is connected through the network, so if the connection is established via IP, you can leave this option enabled.

## Set up NETS BAXI Cloud integration

To set up POS Unit 02 to use the NETS Cloud integration, follow the provided steps:

### Prerequisites

- Set up a terminal from NETS which uses Viking/BAXI.
- Have a NETS Cloud Account in place, as well as a terminal which is connected to it.

### Procedure

1.	Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup**, and choose the related link.     
2.	In **Payment Type** POS insert **T**.     
    **T** is used as a general **POS Payment Method** for making the terminal calls.
3.	Provide **02** in **POS Unit No**.
4.	In **EFT Integration Type** open the pop-up by clicking ![Elipsis icon](../../../images/Icons/elipsis_icon.png "Three dots") and select **NETS_CLOUD**.
5.	With the line selected, navigate to the **Payment Type Parameters**.
6.	In the pop-up window state your **API Username** and **API Password**, as provided by NETS, and close the page.

    ![nets_baxi_cloud](../images/nets_baxi_cloud.PNG)
