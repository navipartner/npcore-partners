# Set up the POS HTML Display
This is the newer version of the POS Display Profile, it share the same purpose as showing some media content and also the receipt view.
The main difference between them is the fact that this profile can do much more, like returning input from the costumer display if the screen is a touch screen and the HTML file contains logic to handle the costumers input.

There is standard HTML which can be used for the display, which is compatible with the Display Content Lines, which can be added by clicking the action **Download Template Data**: 
This HTML file can:
- Show the display the media content defined in the **Display Content Lines**
- Show the receipt to the costumer with prices both including and excluding VAT.
- Collect Phone Number and Signature.

To collect input when a sale finishes and the total amount is negative (i.e. the costumer gets money back) set the field **Costumer Input Option: Money Back** to **Phone & Signature**.
When this option is used the costumer is presented with the digital input on the costumer display, and when the **submit** button is pressed, the information is sent back to the sales screen, where the cashier can verify the phone number and signature. The Cashier has three option here:
- Hit the red button to retry the input, so the costumer gets the possibility to try again. This could be relevant if the signature is declined or the phone number was incorrect. 
- Hit the green button to verify and accept the input given.
- Hit the Cancel/Close button in the top, to cancel the input collection. Meaning nothing will be stored and the input will not be retried. 

## Prerequisites

 - Have at least one POS unit set up for sales in the system.
 - Have a dedicated customer display hardware attached to POS units that will inherit this configuration.
    - Hardware Connector needs to be installed and run. 
    - The POS Unit must run on Windows.
 - If input is needed from the costumer, then a screen with touch is required.

## Procedure 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Unit List**, and choose the related link. 
   A list of all existing POS units is displayed. 
2. Click on the POS unit you wish to set up the **POS HTML Display** for.  
   The **POS Unit Card** popup window is displayed.
3. In the **Profiles** panel, click the dropdown next to the **POS HTML Display Profile**, and then **New**.  
   A new **POS HTML Display Profile** will be opened and ready for input.
4. Fill out the **Code** field.
5. Click the dropdown next to the **Display Content Code**, and then click the **Select from full list** button.
6. From the page **Select - Display Content**, you click on the **Content Line** field on the far right to open another page called **Display Content Lines**.
7. Click **New** to input a URL or to upload an image.    
   Add more lines for a slideshow of images.
8. Go back to the **POS HTML Display Profile**, and either use the **Download Template Data** action to use a standard HTML or **Upload HTML** action under actions to use a specialized HTML.
The HTML file toggle is enabled.
9. Start or restart the POS unit.   
   The costumer display should now show the screen specified.

> [!NOTE]
> If the customer display is displayed on the wrong screen, go to [**POS Unit Display**](../../posunit/reference/POS_Unit_Display.md) and update the information. The numbers displayed on the screens in Windows settings under *System>Display* does not correlate to the number specified in **POS Unit Display**


### Related links

- [Create a new POS unit (by using the existing one for reference)](../../posunit/howto/createnew.md)   
- [Configure an opening mechanism for a POS unit cash drawer](../../posunit/howto/ConfigureCashDrawerOpening.md)
- [POS menu](../../posunit/explanation/POS_menu.md)