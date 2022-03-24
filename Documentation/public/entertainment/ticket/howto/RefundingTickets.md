# Refunding tickets

There are several ways in which tickets can be refunded.
Refunding can happen:

- In **POS**
- In **Business Central**

## Refunding tickets in POS

In the POS system you can revoke and refund tickets:  

1. Go to **POS Menus** and open the menu code where you wish to add your refund button.
2. Create a new line and set **Action Code** to **TM_TICKETMGMT**
3. Click **Parameters** in the home tab. 
4. In **Function, option** and choose **Revoke Reservation**.     
   Make sure that **Boolean** is set to **False**.
5. When you click the button in the POS system a popup window will open, and you need to input the customers external ticket number.

## Refunding tickets in BC17

You can refund tickets (weborders) directly from BC without accessing (e.g. quickpay):

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Posted Sales Invoices** and choose the related link.   
   The list of currently posted sales invoices is displayed.
2. Choose the sales invoice that you wish to refund.
3. Click the **Correct** button in the ribbon, and then **Create Corrective Credit Memo**.
4. When you post the credit memo the amount will automatically be refunded.

>[!IMPORTANT] 
>Some integrations require additional manual setup on the **Payment Providers** web interface before the amount can be refunded.

### Related links
- [Set up refund policy](./SetUpRefundPolicy.md)
