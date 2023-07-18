# Set up prepayment in Business Central (Click & Collect)

To add the Click & Collect prepayment option on the POS, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Menus**, and choose the related link.    
2. Select the menu section in which you want the button to be placed and click **Buttons** in the ribbon.
3. Click **New**, and name the button **Create Click & Collect with Prepayment**.
4. Set the **Action Type** to **Action**, and the **Action Code** to **CREATE_COLLECT_ORD**.
5. Set the following parameters should be set in **POS Parameter Values**:
   - in case of the prepayment expressed in a fixed amount
     - **Prepayment Amount Input** to **TRUE**
     - **Prompt Prepayment** to **TRUE**
   - in case of the prepayment expressed as a percentage
     - **Prepayment Amount Input** to **FALSE**
6. Specify whether there is a **Fixed Prepayment Value** in **POS Parameter Values**.
7. Open the POS, and click the newly created button.     
8. Select the customer who will perform the prepayment.    
   A pop-up window for entering the prepayment amount/percentage is displayed.
9. Enter the amount/percentage of the deposited prepayment and press **OK**.    
    The Click & Collect order has been processed.