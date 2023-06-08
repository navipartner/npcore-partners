# Set up price worksheet

If you want to update prices for multiple items without having to change settings in each Item Card individually, you can create a **Default Price List** in the **Price Worksheet** administrative section.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Price Worksheet** and open the related link.      
2. Populate the following fields in the **General** section:

| Field Name      | Description |
| ----------- | ----------- |
| **Price Type** | Specifies a filter which determines whether the sale or purchase prices are displayed. |
| **Defaults** | Specifies the fields of the price list header that are used as defaults for new lines created in the worksheet. You can set different filters at this level. |
| **Assign-to Group** | Specifies a filter for which group the prices apply to. |
| **Update Multiple Price Lists** | Specifies whether users can add new lines and modify the existing lines in the worksheet suggested by the **Copy Lines** action. |
 
3. Populate the following fields in the **Worksheet** section.

| Field Name      | Description |
| ----------- | ----------- |
| **Manage** | You can select 1 line or multiple line & then apply the delete function to clear the lines from the worksheet. |
| **Suggest Lines** | Create a list of items, based on defined criteria and at the same time establish a Default Price List, using adjustment factors on the Unit Price of the items. When the worksheet is filled, the price list can be also manually modified if necessary. |
| **Copy Lines** | Lines can be copied from an existing **Price List**. |
| **Implement Price Change** | Update the **Price List** with the one provided in the worksheet. |
| **Open Price List** | If a price list is already assigned to the worksheet, you will see the **Price List Code** on the first column in the details. |

### Example

If you create a default sales price for the item 1150 using the unit price of 500.00 and applying a factor of 1.20 on it, the new sales price will be 600.00. Then, you can run the **Implement Price Change** action to update the sales price list for the item. 