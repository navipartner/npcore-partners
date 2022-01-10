# Set up integration with MobilePay in NP Retail

[MobilePay](https://www.mobilepay.dk/) is a digital-wallet software used in Finland and Denmark. It is best-suited for online purchases, as it enables online purchase with just one swipe. 

From the customer’s side, the payment flow when purchasing from an online store is as follows: 
 - The customer enters the mobile phone number connected to the MobilePay application 
 - Customer accepts the payment in the MobilePay application
 - The payment is charged to the card the customer linked to the MobilePay application 

However, to enable MobilePay, the following procedure needs to be performed in NP Retail first:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Setup** and choose the related link.         
   The **EFT Setup** window is displayed.
2. Open the **Payment Type POS** dropdown and link the selected POS unit with EFT configurations for MobilePay.    
3. Select the appropriate **POS Unit No.** and the **EFT Integration Type**.     
   For example, **MOBILEPAY_V10** will enable MobilePay V10 for the selected POS unit).
4. Navigate to the **Payment Type Parameters** in the ribbon.  
5. Fill in all the fields.   
    - Environment can be either **Production** or **Sandbox**, depending on whether you wish all customers to have access to the MobilePay setup or not. 
    - An appropriate **Merchant VAT Number** should be populated for the MobilePay setup to be operational.
    - The **Log Level** option should ideally be set to **Errors** in production environments to avoid logging of all details.
6. Click **Close**.
7. Open the **POS Unit Parameters**.  
   These parameters need to be configured for each POS unit.
8. Select the store by clicking the ellipsis button next to the **Store ID** field and finding the one you want in the list.
> [!NOTE]
> The list is populated according to the data in the MobilePay database.  
  
9. Proceed to the registration of the POS unit in the MobilePay backend.  
  
> [!NOTE]
> Mobile payments can be integrated via existing payment systems or automatic payment points on-site.  

- If you are using a Bluetooth device or an existing QR code, and you have a **Beacon ID (Box/QR)**, enter it into the corresponding field.
- If you’re using an MPOS, or another setup able to render QR code automatically, keep the field blank, as it will be automatically populated.
- You can also leave it empty if you don’t use a physical device, and print it once it’s being set in MobilePay.
10. Enable the **Only QR** toggle switch if you’re sure you’re only using the QR code (no physical device). 
11. Once you’re finished with the creation of the MobilePay unit, click **Create in MobilePay** in **Actions**.   
    A confirmation message is displayed.

**Next steps:**
 - If you decide you need to unregister a POS unit in MobilePay, you simply need to click **Delete in MobilePay** option in **Actions**. The **Beacon ID (Box/QR)** will be preserved locally, and it will be possible to reuse it.
