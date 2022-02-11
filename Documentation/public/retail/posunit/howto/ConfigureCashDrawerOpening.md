# Configure an opening mechanism for a POS unit cash drawer

The following procedure walks you through the process of setting up the cash drawer to automatically open after each sale using the **POS Scenarios Profile** on the POS unit.

### Prerequisites

 - Have at least one existing POS unit in the system.
 - Have a POS bayment bin linked to the POS unit.
 - Have the cash drawer connected to the receipt printer.
 > [!NOTE]
 >  The cable between the cash drawer and receipt printer needs to be installed correctly. The end with the label "Printer" has to go into the receipt printer.


1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Unit List** and choose the related link.     
   A list of all existing POS units is displayed.  
2. Click on the POS unit you wish to configure the cash drawer opening mechanism for.
3. Click on the dropdown next to the **POS Scenarios Profile** and then **Select from full list**.  
4. Click **New**, or select an existing profile, then click **Manage** followed by **Edit**.
5. Select the **POS Scenarios Set Entries** line with **Workflow Code** FINISH_SALE.
6. Click **Manage** and then click on **POS Scenario Steps**.
7. Add the **Subscriber Function** EjectPaymentBin.
8. Go back and select the edited **POS Scenarios Profile** for the POS unit.
9. Go back to the POS unit card.
10. Click on the dropdown next to the **Default POS Payment Bin** and then **Select from full list**.  
11. Click **Edit List**.
12. Go to the field **Eject Method** and input TEMPLATE, then click OK.

### Related links
- [**POS units**](../explanation/POSUnit.md)
- [**Create a new POS unit (by using the existing one for reference)**](./createnew.md)  
- [**How to set up the POS Customer Display**](./POSCustomerDisplay.md)