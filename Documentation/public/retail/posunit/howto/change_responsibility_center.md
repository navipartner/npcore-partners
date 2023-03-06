# Change Responsibility Center from the POS sale

[Responsibility centers](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-responsibility-centers) provide you with the ability of handling administrative centers (cost centers, profit centers, investment centers and other company-defined administrative centers). Different responsibility center usually correspond to different areas of operations. To change the selected responsibility center from the POS sale, follow the provided steps:

## Prerequisites

- Add the **Change Responsibility Center** [button to the POS menu](add_button_to_pos_menu.md) you want it to be displayed in.       
  The action you need to attach to the button is **CHANGE_RESP_CENTER**.     
- In the **POS Parameter Values** specify the name of the responsibility center you want to switch to in the **Fixed Resp Center** parameter.
- In the **POS Parameter Values** set the **Lookup Resp Center** either to **FALSE** to ensure that you are instantly switched to the selected responsibility center when the button is clicked on the POS, or set it to **TRUE** if you want to select the responsibility center from the list instead. 

    > [!Tip]
    > If you wish to create two buttons - one that always switches the current responsibility to a specific one (e.g. *Change Responsibility Center to London*), and the other that opens a list of available responsibility centers you can choose from (e.g. *Choose Responsibility Center*), it's recommended to name them accordingly.

## Procedure

1. Click **POS** in the Role Center's ribbon, followed by **Open POS**.     
   The POS login screen is displayed.
2. Enter the **Salesperson Code** in the provided field to log in.
3. Click the **CHANGE_RESP_CENTER** button.     
   You are either automatically switched to the specified responsibility center or prompted to select one. 