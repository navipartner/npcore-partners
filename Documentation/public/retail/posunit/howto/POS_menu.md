# POS menu

POS menus are used for defining buttons used in POS.
All menus can be divided into main menus and supporting menus.
Main menus are used in POS view and those are:

1. LOGIN

![POSmenu](../images/LOGIN.png)

This menu is shown in login view. In this menu usually are created buttons for prints and switch POS units.

2. SALE-LEFT
3. SALE-TOP
4. SALE-BOTTOM

![SALE](../images/SALE.png)

Sale menus are used for adding buttons which will allow user to create, modify and delete sales lines, create sales documents, make prints.

5. PAYMENT-LEFT
6. PAYMENT-TOP
7. PAYMENT-BOTTOM

![PAYMENT](../images/PAYMENT.png)

Payment menus are used for adding buttons which will allow user to create, modify and delete payment lines.

Except main menus, supporting menus can be created too. Those menus are used as Popup menus.

![POPUP](../images/POPUP%20MENU.png)

All these menus are created in **POS menu** page in Business central.
When this page is opened, it will be shown list of all created menus. Menus can be defined for all POS units or for special one in which case it will be needed to enter **POS unit No.** for that menu. Also, menu can be set just for some of salespeople in which case for that menu must be entered **Salesperson code**.     
For adding buttons in menu, select the row in which menu is and choose **Buttons**.

![ADDBUTTONS](../images/ADD%20BUTTONS.png)

To create new button, choose **New** and insert necessary data for button:

![NEWBUTTON](../images/NEW%20BUTTON.png)

-  **Caption** - caption that will appear on the button in the POS
- **Tooltip** - Text that will appear if the cursor is placed on the button
- **Action type** - Type of action that will be triggered when someone click on button. There are five different types:
    1. Popup menu
    2. Action
    3. Item
    4. Customer
    5. Payment type
- **Action code** - action that will be triggered by clicking on button.
- **Block** - if action is blocked this field needs to be checked.
- **Background Color** - Color of button in POS unit.
- **Caption Position** -  the position of caption on button (options – Top, Center, Bottom).
- **Position X** - the number of position in x axis of menu where this button will be positioned.
- **Position Y** – the number of position in y axis of menu where this button will be positioned.
- **Enabled** - Shows if the field is enabled in POS (options – Yes, No, Auto (if some of necessary actions has been done button will be enabled, for example if sales line is entered, button “delete line” will be enabled))
- **POS unit No.** - if button needs to be seen only in one POS unit, POS unit has to be chosen here.
- **Salesperson Code** - if button needs to be seen only by one salesperson,salesperson has to be chosen here.