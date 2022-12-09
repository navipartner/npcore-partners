# POS actions (reference guide)

POS actions are sets of workflows that trigger specific actions on the POS. These workflows are developed, and the setup and parameters are parts of the objects. 

| Field Name      | Description |
| ----------- | ----------- |
| **Code** | Specifies the identification code of the function. |
| **Description** | Specifies a brief description of the function. |
| **Blocked** | The code unit can be blocked if it's no longer used. |
| **Workflow Defined** | Specifies whether a workflow has been defined for the action. |
| **Data Source Name** | Specifies if the function is related to a specific data source. The following functions are available: **BUILTIN_SALELINE** - it applies specifically to the sale line in the POS; **BUILTIN_SALE** - it applies specifically to the total of the sales lines; **BUILTIN_PAYMENTLINE** - it applies specifically to the payment line in the POS; **BUILTIN_PAYMENT** - it applies specifically to the total of the payment lines. | 
| **Workflow Implementation** | Determines which workflow is defined for the POS action. |

## Parameters on the POS actions

A single POS action can be used for more than one function or output. This behavior is controlled by setting adequate parameters on the POS actions. You can do this in the **POS Parameter Values** page, that can be opened via the **Parameters** action in the **Menu Buttons Setup** administrative section. We will use the **DISCOUNT** POS action as an example in following text.

![pos_action_parameters](../images/pos_action_parameters.png)

The **DISCOUNT** POS action is used for multiple types of discount, and it is the selected parameters that determine which types will take effect. 


| Field Name      | Description |
| ----------- | ----------- |
| **Amount Incl. VAT/Tax** | Specifies whether the amount entered is VAT/tax-inclusive. The parameter is ignored if the **Discount Type** is set to **LineUnitPrice**. |
| **DimensionCode** | When using this POS action, you can preset a dimension that will be attached to the sales and the general ledger entries. |
| **DimensionValue** | When using this POS action, you can preset a dimension value that will be inserted in the sales and the general ledger entries. |
| **DiscountGroupFilter** | You can preset a discount group on a customer, and use it as a filter to apply the discount. |
| **DiscountType** | Here, you have different options to make the buttons work the way you want. For more information, refer to the **Discount Table** below. |
| **FixedDiscountNumber** | You can configure the button to apply a fixed amount or percentage. If this is done, there won't be a popup in which the amount or percentage is inserted. | 
| **Reason:Fixed Code** | Preset a reason code, which will be assigned automatically to the sales lines. | 
| **Reason:Lookup** | You need to select a reason code from the list, and it will be assigned to sales lines. |
| **Reason:Mandatory** | Defines whether a reason code needs to be provided in order for the discount to be successfully applied to sales lines. |
| **Security** | This parameter is obsolete. It has been replaced by **Secure Method Code** on the POS menu line setup. |
| **Total Discount Target** | Select target line that multiline discounts will be applied to. The following options are available: **Auto** - applies to all types, regardless of whether the line contains positive or negative quantity; **Positive Quantity Lines Only** - you can limit the discount to apply to positive quantity lines only; **Negative Quantity Lines Only** - you can limit the discount to apply to negative quantity lines only; **All Non-Zero Quantity Lines** - applies to all non-zero quantity lines, both positive and negative; **Ask** - the type is selected by a salesperson. |


### Discount Types

Refer to this table for additional information on what each available discount type does:

| Field Name      | Description |
| ----------- | ----------- |
| **TotalAmount** | The amount that you set on the popup is affecting the total amount, so you set which total amount you want the customer to pay. |
| **TotalDiscountAmount** | You can set by which amount you wish to reduce or discount the total amount payable. |
| **DiscountPercentABS** | You can set discount percentage that will be omitted from the absolute amount on the total amount payable. For example, if you choose to give 10%, you press it once, and it calculates 10% on the original total. However, if you press it again, another 10% discount is added to the original amount. |
| **DiscountPercentREL** | You can set discount percentage as a relative value on the total amount payable. For example, if you choose to give 10%, you press it once, and it calculates 10% on the original total. However, if you press it again, another 10% discount is added to the new amount (after the first discount). It acts as a compounded discount each time you use it on the same transaction. |
| **LineAmount** | The amount set on the popup affects the line amount. Hence, you set what line amount you wish to make the customer pay. |
| **LineDiscountAmount** | You can state how much you wish to reduce the original line amount payable. |
| **LineDiscountPercentABS** | You can set a discount percentage in an absolute value on the line amount payable. For example, if you choose to give 10%, you press it once, and it calculates 10% on the original total. However, if you press it again, another 10% discount is added to the original amount. |
| **LineDiscountPercentREL** | You can set a discount percentage to a relative value of the line amount payable. For example, if you choose to give 10%, you press it once, and it calculates 10% on the original total. However, if you press it again, another 10% discount is added to the new amount (after the first discount). It acts as a compounded discount each time you use it on the same transaction. |
| **LineUnitPrice** | Although not a discount, it allows you to modify the unit price directly on the POS sales line. |
| **ClearLineDiscount** | You can use it to remove the discount that has already been applied to the line. |
| **ClearTotalDiscount** | You can use it to remove the discount already applied to the total. |
| **DiscountPercentExtra** | You can add an extra discount percentage on a total that already has a discount applied to it. |
| **LineDiscountPercentExtra** | You can add an extra discount percentage on a line that already has a line discount applied to it. |


