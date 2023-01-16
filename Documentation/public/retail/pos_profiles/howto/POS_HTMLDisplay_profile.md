# Set up the POS HTML Display

This guide pertains to the newer version of the [POS Display Profile](../reference/POS_Display_profile.md). While it shares the same purpose as displaying the specified media content and the receipt view, the main difference between them is the fact that this profile can do much more, like returning input from the customer display if the screen is a touch screen, and the HTML file is equipped to handle the customer's input.

There is a [standard HTML file](https://npcorehtmldisplay.blob.core.windows.net/standard-html/Media_Receipt_Input.html) which supports showing display content lines, receipt view, and input for both phone and signature. This HTML file can: 

- Display the media content defined in the **Display Content Lines**.
- Show the receipt to the customer with prices both including and excluding VAT.
- Collect the phone number and signature.

To collect input when a sale is finalized, and the total amount is negative (i.e. the customer gets money back) set the **Customer Input Option: Money Back** field to **Phone & Signature**.
When this option is used the customer is presented with the digital input on the customer display, and when the **Submit** button is clicked, the information is sent back to the sales screen, where the cashier can verify the phone number and signature. The cashier has three options here:

- Hit the red button to reattempt the input, so the customer gets the possibility to try again. This could be relevant if the signature is declined or the phone number was incorrect. 
- Hit the green button to verify and accept the provided input.
- Hit the **Cancel** button at the top, to cancel the input collection. As the result, nothing will be stored and the input will not be retried. 

## Prerequisites

- Have at least one POS unit set up for sales in the system.
- Have a dedicated customer display hardware attached to POS units that will inherit this configuration.
   - The [Hardware Connector](../../gettingstarted/hw_connector.md) needs to be installed and run.
   - The POS Unit needs to be run in Windows.
- If input is required from the customer, a touch screen is also required.

## Procedure 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Unit List**, and choose the related link.      
   A list of all existing POS units is displayed. 
2. Click the POS unit you wish to set up the **POS HTML Display** for.     
   The **POS Unit Card** popup window is displayed.
3. In the **Profiles** panel, open the dropdown list next to the **POS HTML Display Profile**, and then click **New**.      
   A new **POS HTML Display Profile** will be opened and ready for input.
4. Fill out the **Code** field.
5. Open the dropdown list next to the **Display Content Code**, and then click the **Select from full list** button.
6. From the page **Select - Display Content**, click the **Content Line** field on the far right to open the **Display Content Lines** page.
7. Click **New** to input a URL or to upload an image.     
   Add more lines for an image slideshow.
8. Go back to the **POS HTML Display Profile**, and use the **Upload HTML** action to upload the desired [HTML file](https://npcorehtmldisplay.blob.core.windows.net/standard-html/Media_Receipt_Input.html).       
  The **HTML File** toggle switch is enabled.
9. Start or restart the POS unit.   
   The customer display now contains the specified screen layout.

> [!NOTE]
> If the customer display is displayed on the wrong screen, go to [**POS Unit Display**](../../posunit/reference/POS_Unit_Display.md) and update the information.


### Related links

- [Create a new POS unit (by using the existing one for reference)](../../posunit/howto/createnew.md)   
- [Configure an opening mechanism for a POS unit cash drawer](../../posunit/howto/ConfigureCashDrawerOpening.md)
- [POS menu](../../posunit/explanation/POS_menu.md)