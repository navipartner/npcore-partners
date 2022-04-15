# POS self-service actions

There are specific POS actions intended for the self-service mode. On the POS unit dedicated for self-service, the POS setup is configured from the **POS Named Action Profile** located in the **POS Unit Card**. 

Other than that, it needs to be specified that the POS unit is going to be used for a normal cash register or as an unattended self-service register. 

> [!Note]
> All POS actions for self-service have the "SS" prefix.

## SS-ADMIN-MENU - brings up the self-service admin menu

The POS is initially locked and self-service users aren't able to perform any configurations or administrative work (like changing the salesperson's code etc.).

However, administrators who provide a password or a keycard can access a hidden administration menu, or **Admin View**. The **Admin View** contains some functions previously defined in **POS Menus**.

The POS admin menu is implemented in Major Tom so you can switch to the POS and run a preconfigured POS action. In the backend, it is configured in the **POS Named Action Profile** of an unattended POS unit. 

## SS-DELETE-LINE - deletes sales or payment lines from the POS

The function is used to delete a line both in the Sale and Payment POS view. 

> [!Note]
> The SS-DELETE-LINE action can be also used to trigger removal of the line in the **Cart View** if this is set up in the JSON for the Cart as defined in a View. 

## SS-IDLE-TIMEOUT - handles idle timeout in the self-service POS

The function is used for setting up the attributes of the popup window which displays if users are idle for too long. You can set up the time left until the timeout popup is displayed, the message and the buttons that the popup will contain, as well as the duration for which the window will be displayed on the screen.

## SS-ITEM - inserts an item line to the current transaction

This action resembles the **Item POS Action**, but is built-in for self-service. It is used for inserting an item line into the current transaction. 

## SS-ITEM-ADDON - sets the item add-on values

This function resembles the **AddOns** POS action, which allows you to add a popup which contains a list of items in a menu format (a Burger Menu, for example).

It is also possible to associate a list of items to a main item, whereby when you sell the main item, the menu is automatically shown on the screen for you to select from. This is used for extras that can be ordered when buying the main item. 

## SS-LOGIN-SCREEN - locks the POS

This function is built-in. It is used for locking the POS, and redirection to the login screen. If you wish to exit the sales or payment view, and back to the login view, you can use the **Cancel Sale** button.

## SS-PAYMENT - unattended payment

This function is used for unattended payment, and it works with Credit Cards (EFT). As a prerequisite, the EFT interface needs to be connected to the payment type **Terminal** (T). The payment method button is set in the **POS Parameter Values**.

## SS-PAY-SCREEN - switches to the payment view

This function is built-in, and is associated with the **Go to Payment** button on the POS.

## SS-QTY-/SS-QTY+ - change the quantity

This is a built-in function for changing quantity in the **Item POS Action**, **Item AddOn**, and the **Cart View**. In the **Cart View**, you can find the configuration in the JSON for the **Cart View**. 

> [!Note]
> The POS actions **SS-QTY+** & **SS-QTY-** can also be used in the button format as **Increase Quantity** and **Decrease Quantity**.

## SS-SALE-SCREEN - changes the order

This function is used to change to the sale view. Any caption can be defined for the POS button, but if you want to navigate back to the sales screen, then the POS action which will be used is **SS-SALE-SCREEN**.

## SS-START-POS - starts the POS in self-service mode

This built-in action starts the POS in the self-service mode. You can set it up on the POS menus, as well as in the POS Setup for unattended POS unit. The same POS action is set up in the POS Named Action Profile for the self-service POS unit, and used as the login action code. 

## PTE_SS_START_EMP_POS - prompts for an customer number prior to starting the POS

When you click **Login**, you will be prompted to insert a customer number. When navigating to the **SAles Line**, the customer is assigned to that sale. The action is similar to **SS-START-POS**, except for the prompt to scan or insert a customer number prior to initiating the sale.

> [!Note]
> The same **POS Action** is set in the **POS Named Action Profile** for a POS unit used for self-service, and as a **Login Action Code**.

### Related links

- [POS units](POSUnit.md)
- [Configure cash drawer options](../howto/ConfigureCashDrawerOpening.md)
- [Create a new POS unit](../howto/createnew.md)