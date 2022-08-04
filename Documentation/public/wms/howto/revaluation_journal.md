# Revalue items (Item Revaluation Journal)

There are several instances in which it's necessary to perform inventory revaluation - for instance if you wish to revalue the remaining quantity of a certain item in inventory, or if you wish to check validity of a single decrease/increase in inventory levels. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Revaluation Journals** and choose the related link.        
    Once you're in the **Item Revaluation Journal** administrative section, you can see the posting lines with respective unit costs that need to be revalued. 

> [!Note]
> Make sure that all items are adjusted via the **Adjust Cost - Item Entries** action before you start revaluing them. 

2. Click **Process** in the ribbon, and then **Calculate Inventory Value**.    
   The **Calculate Inventory Value** popup is displayed.

<img src="../images/calculate_inventory_value.PNG" width="550">

3. Once you've set up the calculation parameters according to your business needs, click **OK**.    
   
   > [!Note]
   > Bear in mind that the **Average Costing Method** isn't compatible with the calculations per **Item Ledger Entry**.

This function populates the journal with a line for all item or item ledger entries for this item that have a remaining quantity greater than zero. After this, the value of the **Unit Cost** field will be changed to the value of your selection.

4. When you're done with the revaluation, click **Post/Print** from the ribbon, followed by **Post**.      
   Once the revaluation journal entries are posted, you can see that the **Unit Cost** value has been changed in the relevant **Item Card**.