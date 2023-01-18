# POS Menu Buttons Setup (reference guide)

Refer to the following table to see what each [POS menu button](../howto/add_button_to_pos_menu.md) setting can be used for:

| Field Name      | Description |
| ----------- | ----------- |
| **Caption** | The button description that can be seen in the POS. |
| **Tooltip** | The text that will be displayed if the cursor is placed on the button.
| **Action type** | The type of action that will be triggered when the button is clicked. **Popup Menu** is used for defining a submenu which contains its own set of buttons; **Action** - when selected, you can define what the POS action will do; **Item** - you can insert a specific item on the sales line; **Customer** - you can set a button to attach a specific customer to the sale; **Payment Type** - you can set which POS payment method is going to be used when the button is clicked. |
| **Action code** | The code of the action that will be triggered by clicking the button. |
| **Data Source Code** | The data source field is filled automatically in certain circumstances. If a POS action acts upon a POS sales line, the code unit sets the **BUILTIN_SALELINE** automatically, and the same goes for **BUILTIN_SALE**, **BUILTIN_PAYMENTLINE**, and **BUILTIN_PAYMENT**. |
| **Block** | This field needs to be enabled or disabled. |
| **Background Color** | You can set the background color of the button in the POS unit. |
| **Icon Class** | You can place small [icons](https://fontawesome.com/v6/search?o=r&m=free) on the button instead of the captions. |
| **Background Image URL** | You can set a picture to be displayed on the button using a URL to the picture's location. |
| **Caption Position** | The position of the caption on the button (options – **Top**, **Center**, **Bottom**). |
| **Custom Class Attribute** | You can customize the attribute to the button. For example, we can use multiline, so that if the caption is too long, it will be displayed in three lines instead of being truncated. |
| **Position X** | The number of the position in the x axis of the menu where this button will be positioned. | 
| **Position Y** | The number of the position in the y axis of the menu where this button will be positioned. |
| **Enabled** | You can determine whether the field is enabled in the POS. If some of the necessary actions have been performed, the button will be enabled. For example, if the sales line is entered, the button **Delete Line** will be enabled. |
| **Secure Method Code** | You can set security password levels on any POS action. The security is set at group levels, and not on individual ones like users. A user or a salesperson are then placed to a group of security level. The parameter which is referred to as **Security** has the following options: **BLANK** - anybody is able to use the function without any access control (no security restrictions); **ANY SALESP** - any salesperson with a register and supervisor password will be able to use the function; **CUR-SALESP** - only the salesperson who has logged on the POS at that time can use their password and supervisor password to be able to use the function; **ADMIN-PWD** - the highest level of security - only the person with the admin password is able to execute the POS action. |
| **POS Unit No.** | If the button needs to be visible only in one POS unit, that POS unit's number needs to be stated here. | 
| **Salesperson Code** | If the button needs to be seen and accessed only by one salesperson, the salesperson's code needs to be stated here. |