# Set up CleanCash in Business Central

There are several configurations required for CleanCash to enable it running with the Retail solution.

## Prerequisites

There's a setup segment that needs to be performed in the Case System before you can start configuring options in Business Central. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Unit List**, and open the related link.   
2. Select the POS unit you want to edit, or create a new one.
3. Edit the POS unit's **Audit Profile**, and select *SE_CleanCash-xccsp* in the **Audit Handler** field.
4. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **CleanCash POS Unit Setup**, and open the related link.   
5. Provide the following information: 
   - **POS Unit** - the POS unit number from Business Central
   - **Connection String** - the URL from the Case System or the registration form from Retail Innovation
   - **Organization ID** - customer business number (VAT number)
   - **CleanCash Unit No.** - this number is taken from the relevant field in the Case System
   - **CleanCash No. Series** - this number is taken from the **No. Series** field in Business Central; note that **CLEANCASH** needs to be created if it's not already in the list.
   - **Training** - used for testing the connection
   - **Show Error Message** - Business Central indicates if errors occur in the communication with CleanCash (RI).
  
  When the shop/POS is live, the transactions done with CleanCash codes can be viewed in the **CleanCash Transactions** administrative section in Business Central.

## Next steps

### Configure testing environment

To test the solution in a pre-live database or a test company, you need to use the following settings (beside the basic CleanCash setup in Business Central):

- **Organization ID** = 1234567890
- **CleanCash Register No.** = retailtest (all lowercase, else it fails)
- **Training** = false

To check if the solution behaves as expected, navigate to the **CleanCash Transactions** page, and check if the following columns are populated:

- **CleanCash POS Id** = retailtest
- **CleanCash Unit Id**
- **CleanCash Code** = A unique number provided by the box.

