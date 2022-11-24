# POS self-service actions

There are specific POS actions intended for the self-service mode. On the POS unit dedicated for self-service, the POS setup is configured from the **POS Named Action Profile** located in the **POS Unit Card**. 

Other than that, it needs to be specified that the POS unit is going to be used for a normal cash register or as an unattended self-service register. 

> [!Note]
> All POS actions for self-service have the "SS" prefix.

## SS-ADMIN-MENU - brings up the self-service admin menu

The POS is initially locked and self-service users aren't able to perform any configurations or administrative work (like changing the salesperson's code etc.).

However, administrators who provide a password or a keycard can access a hidden administration menu, or **Admin View**. The **Admin View** contains some functions previously defined in **POS Menus**.

The POS admin menu is implemented in Major Tom so you can switch to the POS and run a preconfigured POS action. In the backend, it is configured in the [**POS Named Action Profile**](../howto/Named_Action_Code.md) of an unattended POS unit. 

## SS-DELETE-LINE - deletes sales or payment lines from the POS

The function is used to delete a line both in the Sale and Payment POS view. Hence, we can set a button in POS Menus to delete a line. 

> [!Note]
> We also use the SS-DELETE-LINE action to trigger the removal of a line in the **Cart View**. This is set in the JSON file for the cart as defined in the view. 

## SS-IDLE-TIMEOUT - handles idle timeout in the self-service POS

The **User Inactivity Timeout** parameter affects the functionality and determines the number of seconds that a self-service action remains idle before the user is automatically logged out. 

The **SS-IDLE-TIMEOULT** is the action that triggers the system to log a user out automatically after a period of inactivity. 

In our self-service, after some idle time a message displays, notifying users that they can either continue their transaction, or leave the system to log out on its own. The message is displayed after the timeout (the number of seconds that a self-service screen remains idle for before logout), for the duration of a grace period in which users can respond to the prompt. Both the **User Inactivity Timeout** and the **Grace Time** can be defined in the JSON file for the sale view/payment view, as well as the message that you wish to appear on the screen.

## SS-ITEM - inserts an item line to the current transaction

This action resembles the **Item POS Action**, but is built-in for self-service. It is used for inserting an item line into the current transaction. 

## SS-ITEM-ADDON - sets the item add-on values

This function resembles the [**Item AddOns**](item_addons.md) POS action, which allows you to add a popup which contains a list of items in a menu format (a Burger Menu, for example).

It is also possible to associate a list of items to a main item, whereby when you sell the main item, the menu is automatically shown on the screen for you to select from. This is used for extras that can be ordered when buying the main item. 

## SS-LOGIN-SCREEN - locks the POS

This function is built-in. It is used for locking the POS, and redirection to the login screen. If you wish to exit the sales or payment view, and back to the login view, you can use the **Cancel Sale** button.

![ss-login-screen](../images/ss-login-screen.png)

## SS-PAYMENT - unattended payment

This function is used for unattended payment, and it works with Credit Cards (EFT). As a prerequisite, the EFT interface needs to be connected to the payment type **Terminal** (T). The payment method button is set in the **POS Menu**.

## SS-PAY-SCREEN - switches to the payment view

This function is built-in, and it switches the current view to the payment view. 

## SS-QTY-/SS-QTY+ - change the quantity

This is a built-in function for changing quantity in the **Item POS Action**, **Item AddOn**, and the **Cart View**. In the **Cart View**, you can find the configuration in the JSON for the **Cart View**. 

This is what the code snippet looks like: 

    "cart": {
        "dataSource": "BUILTIN_SALELINE",
        "setup": {
            "actions": {
                            "checkout": "SS-PAY-SCREEN",
                            "delete": "SS-DELETE-LINE",
                            "increase": "SS-QTY+"
                                },
            "fields": {
            "caption": 10,
            "quantity": 12
                }
            }
        },

This is what the output is displayed as:

![ss_qty](../images/ss_qty.png)


> [!Note]
> The POS actions **SS-QTY+** & **SS-QTY-** can also be used in the button format as **Increase Quantity** and **Decrease Quantity**.

![ss_qty_button](../images/ss_qty_button.png)

## SS-SALE-SCREEN - changes the order

This function is used to change to the sale view. Any caption can be defined for the POS button, but if you want to navigate back to the sales screen, then the POS action which will be used is **SS-SALE-SCREEN**.

## SS-START-POS - starts the POS in self-service mode

This built-in action starts the POS in the self-service mode. You can set it up on the POS menus, as well as in the POS Setup for unattended POS unit. The same POS action is set up in the POS Named Action Profile for the self-service POS unit, and used as the login action code. 

## SS-VOUCHER-APPLY - applies a retail voucher as payment

This is a built-in action for self-service, applying a retail voucher as payment for the current transaction. A customer can use a voucher to purchase the items or tickets from a kiosk. When they press a button, the pop-up screen displays, and they can scan or type the voucher reference number.

## PTE_SS_START_EMP_POS - prompts for an customer number prior to starting the POS

This action prompts for a customer number prior to starting the POS. On pressing the button for login, a prompt to insert a customer number is displayed. When we move to the **Sales Line**, the customer is set to that sale.

![pte_ss](../images/pte_ss_start_emp.png)

In this situation, the same POS action is set in the POS Named Action Profile for a POS unit that is used for self service, and used as the **Login Action Code**.

> [!Note]
> It is a similar function to SS-START-POS, with the difference being that it has a prompt to scan or insert a customer number prior to initiating the sale.

### Related links

- [POS units](POSUnit.md)
- [Configure cash drawer options](../howto/ConfigureCashDrawerOpening.md)
- [Create a new POS unit](../howto/createnew.md)