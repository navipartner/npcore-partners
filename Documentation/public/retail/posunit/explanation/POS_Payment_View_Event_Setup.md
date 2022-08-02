# POS Payment View Event Setup

**POS Payment View Event Setup** can be used for entering a certain dimension in a POS transaction. For example, you can create a setup in which you can analyze each transaction based on the postal code you provide. You can also define how often the dimension popup is going to be displayed in POS transactions. 

The **POS Payment View Event Setup** page consists of two sections:

In the **General** section you can define which dimension will be used, and how often it will be displayed in POS transactions:

| Field Name      | Description |
| ----------- | ----------- |
| **Dimension Popup Enabled**       | If this field is checked a pop-up window will be displayed when the view is switched from sales to payment in the POS unit.   |
| **Dimension Code**   | Specifies which dimension will pop up in the POS.        |
| **Popup per**  | A popup can be displayed per a **POS Store**, **POS unit** or **All**. |
| **Popup every** | Specifies the time interval after which the popup will recur. |
| **Popup Start time** | Specifies the starting time for the popup. |
| **Popup End time** | Specifies the ending time for the popup. |
| **Dimension Popup Mode** | Specifies what the popup looks like. You can select between the following layouts: **List**, **Input**, and **Numpad**. |
| **Create New Dimension Values** | If enabled, a new dimension will be created if it doesn't exist in the dimension values list when the user inputs the value in the dimension popup. |

![POS_payment_view_event_setup](../images/POS_payment_view_event_setup.PNG)


In **Popup Dimension Filter** section you can set up an **Item** or an **Item Category** which needs to be in the sales lines so the popup is displayed in the POS.

> [!Note]
> To be able to use this functionality in POS transactions, in **POS scenarios** for **PAYMENT_VIEW**, you need to check the **Popup Dimension** checkbox.

![payment_view_scen](../images/Payment_view_scen.PNG)
