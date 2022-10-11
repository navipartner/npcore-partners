# Set up POS Payment Bins

Each POS unit can have multiple payment bins and different setup. You can set cash drawers and virtual drawers.

## Create cash drawers/banks/safes

To create cash drawers, banks, or safes, follow the provided steps:

1.  Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Payment Bins** and open the related link.
2. Create **New**.
3. Add a number of cash drawers in the **No.** field.
4. Add **Description** (e.g. *Cash Drawer*)
5. Choose the POS store and POS unit that will have the cash drawer in the **POS Store** and **POS unit** fields.
6. Select **Cash Drawer** in the **Bin Type** dropdown.   

> [!NOTE]
> For the **Bin Type** there are also **Bank** and **Safe** options that have the same function as the **Cash Drawer**. If you need to create a bank, or a safe instead of a cash drawer, choose one of those options instead.

7. In the **Eject Method** field set **TEMPLATE** as the method in which the cash drawer will be ejected.     
    After selecting the template eject method, the **Eject Method Parameters** need to be set.

![POS_eject](../images/POS_Eject.png)

8. Click **Eject Method Parameters**.     
    **Name**, **Description**, and **Data Type** are automatically populated.  
9. Set the value to **EPSON_CASH_DRAWER**.

![POS_eject1](../images/POS_Eject1.png)

## Create virtual bins

To create virtual bins, follow the provided steps:

> [!Note]
> Virtual bins are used for payment by card.

1.  Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Payment Bins** and open the related link.
2. Create **New**.
3. In the **No.** field add *Auto_Bin*.
4. Add **Description** (e.g. *Virtual Bin*).
5. Choose the POS store and POS unit that will have the cash drawer in the **POS Store** and **POS unit** fields.
6. Select **Virtual** in the **Bin Type** dropdown.

![POS_virtual](../images/POS_Virtual.png)

## Next steps

### POS Posting setup

Each cash drawer or virtual drawer can be posted on a different G/L account.

1. Open the **POS Posting Setup**
2. Select the **POS Store Code**.
3. Select the **POS Payment Method Code**.
4. Add an **Account**.

![POS_GL](../images/POS_Gl.png)