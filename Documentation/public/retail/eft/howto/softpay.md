# Set up integration with Softpay in NP Retail

[Softpay](https://www.softpay.io/) is an app-based terminal which can be intregrated into Point Of Sales (POS) systems.

From the customer’s side, the payment flow when purchasing from a local store is as follows:

 - The customer brings the items to the register.
 - When all items are scanned, the payment is initiated, and the POS app switches to the Softpay app.
 - The customer puts a credit card close to the device's NFC reader, and is prompted to provide a PIN if the amount is high enough, or if they have completed purchases without using a PIN for some time.

However, to enable Softpay, the following procedure needs to be performed in NP Retail first:

1. Click the ![Spyglass that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup**, and choose the related link.         
   The **EFT Setup** window is displayed.
2. Create a new entry by clicking the **+** button. 
3. Open the **Payment Type POS** dropdown and link the selected the EFT configuration **T**.    
4. Select the appropriate **POS Unit No.** and set the **EFT Integration Type** to **SOFTPAY**.
5. Navigate to the **POS Unit Parameters** in the ribbon.    
   The **Softpay POS Merchant List** page is displayed.
6. Create a new POS unit and merchant combination entry by clicking **+** in the ribbon.   
   The **Softpay POS Merchant Card** is displayed.
7. Select the desired POS unit, and select which merchant to use form the dropdown menu.    
   - New POS units can be created.
   - New merchants are created with the following information:
     - **Softpay Merchant ID** - the ID/Username supplied by Softpay.
     - **Softpay Merchant Password** - the password corresponding to the supplied **Merchant ID**/**Username**, also supplied by Softpay.
     - **Merchant Description** - a comment or description of the merchant account; helpful if you have multiple merchant accounts, with different configurations.
     - **Environment**: Select one of two options: **Sandbox** is the test environment where all transactions are simulated with test cards; **Production** is the normal environment which handles real transactions.
  
     > [!CAUTION]
     > Do not use Test cards in Production environment, and vice versa.

     >[!IMPORTANT] 
     > Remember that Sandbox and Production use seperate apps. Production is distributed via Google Play, and the Sandbox is distributed via Firebase, contact Softpay to get access.

8. Close the **EFT Setup**.

### Next Steps

Now that Softpay is configured, the last step you need to complete the setup is to set the correct payment flow on the POS unit.

1. Click the ![Spyglass that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button,  enter **POS Unit List**, and choose the related link.    
   The **POS Unit List** is now displayed.
2. Select the POS you configured to use Softpay, and navigate to its card by clicking **No.**.
3. Under **Profiles** section open the dropdown menu on **POS Named Actions Profile**, and click **select from full list**.   
   The **POS Actions Profiles** page is displayed.
4. Edit the selected profile by clicking on the three vertical dots, and selecting **Edit**.
5. Go to **Payment Action Code** under the **Actions** section, and select from the dropdown menu **PAYMENT_2**.
  

### Related links

- [Electronic Funds Transfer](../intro.md)
- [Introduction to Softpay](../explanation/softpay.md)