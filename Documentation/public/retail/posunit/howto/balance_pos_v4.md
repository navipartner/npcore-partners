# Configure the POS balancing feature

The setup of the POS balancing feature is mainly done in the **POS End of Day Profile**. You can define different profiles, and attach them to an individual POS unit, giving it its own profile.

To configure the POS balancing feature, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS End of Day Profile**, and choose the related link.
2. Click **New** to open a blank **NPR POS End of Day Profile Card**. 
3. Populate the fields while referring to the EOD [reference table](../../pos_profiles/reference/POS_End_of_Day_Profile.md).
4. Search for **POS Actions Profiles**, and create a new **POS Named Action Profile** (or edit an existing one).
5. In the **End of Day Action Code** field, provide **POS Action BALANCE V4**.     
   In this way, you're notifying the system that the new balancing function is used.
6. (Optional) If you want to have a screen in which you can count the denomination one by one, and insert the counted quantity, navigate to the specific **POS Payment Method Card** that you wish to configure.
7. Click **Denominations**, and set up denomination for each type of currency that you're going to accept on the POS in the window that is displayed.   

> [!Note]
> On counting, you can update the page with predefined denomination with the count.

8. Open the **POS Payment Bin** for the POS unit that needs to be balanced, and click **Insert Initial Float** in the ribbon.   

> [!Note]
> This function doesn't provide any accounting entries. If money needs to be transferred from a bank into that cash float G/L account, this needs to be done in the back office using a general journal or a payment journal from a bank. This function is also used when we land from a different system into our system. The float account already contains the figure, so it's not necessary to add any accounting entries in this scenario.

9. Open **Report Selection - Retail**.
10. Select **Balancing Receipt** in the **Report Type**, and set the print template to **EPSON_END_OF_DAY_X**.
11. Select **Large Balancing Receipt**, and set the **Report ID : 6014459 – Balancing Report -A4-POS**.    

![report_selection_retail](../images/report_selection_retail_v4.png)

## Next steps

### Set up the counting and transfer process

When you click **Cash Count** on the POS, you are presented with the counting screen. In the top-right corner, you can see which currencies have been received in the POS, that require counting and balancing of the POS unit. 

If the button is marked in read, that means that the currency hasn't yet been counted. After the count is completed, there will be a green tick next to it. 

![counting_transfer_v4](../images/counting_transfer_v4.png)

For more information about individual fields and options on the **Counting** screen, refer to the [reference guide](../reference/counting_reference.md).

### Generate end-of-day report (POS balance)

Once the necessary configurations are complete, you can move on to [balancing the POS](balance_the_pos.md) at the end of the work shift.
