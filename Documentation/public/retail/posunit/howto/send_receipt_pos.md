# Send email receipts from the POS sale

You can set up a functionality which sends the POS sale receipts to customers' emails. To do so, follow the indicated prerequisites and operating steps:

## Prerequisites

- Create the necessary email accounts.
- Create an e-mail template that will be sent to users.    
  The relevant **Report ID** needs to be specified within the e-mail template.
- Add the **Send Email Receipt** [button to the POS menu](add_button_to_pos_menu.md) you want it to be displayed in.       
  The action you need to attach to the button is **SEND_RECEIPT**.
- Configure the **POS Parameter Values** for the button you've added to the POS menu - provide the name of the e-mail template you've created for receipts, and specify whether the e-mail is automatically sent for the last created receipt, of if you can choose the specific receipt to be sent.

    > [!Tip]
    > If you wish to create two buttons - one that always sends the last created receipt (e.g. *Send Receipt - Last*), and the other that opens a list of available receipts you can choose to send(e.g. *Send Receipt - Choose*), it's recommended to name them accordingly.

## Procedure

1. Click **POS** in the Role Center's ribbon, followed by **Open POS**.     
   The POS login screen is displayed.
2. Enter the **Salesperson Code** in the provided field to log in.
3. Click the **SEND_RECEIPT** button.     
   Either the last created receipt is sent to the customer or a list of the available receipts is displayed. Once you select a receipt, it is sent to the customer's e-mail.