# Stock-Take Templates (reference guide)

The following fields and options are available in the **Stock-Take Templates** administrative section of Business Central:

## Adjustment methods

Adjustment methods control the fundamentals of the inventory adjustment. The following options are available:

| Option Name      | Description |
| ----------- | ----------- | 
| **Stock Take** | the counted items are recorded in a designated **Physical Inventory Ledger**, and the counted quantity is the stock level. A regular stock take should always use this option. |
| **Adjustment** | for reasons beyond the scope of this document, the physical inventory transaction can't be the first transaction for the item - items need to either be **Positive Adjusted** or **Purchased** to enter the inventory. With this option, it is possible to use the stock-take worksheet to load the inventory with items using the adjustment method. The counted quantity is the stock level. |
| **Purchase (Adjmt.)** | for reasons beyond the scope of this document, the physical inventory transaction can't be the first transaction for an item. Items need either to be **Positive Adjusted** or **Purchased** to enter the inventory. With this option, it's possible to use the stock-take worksheet to load the inventory with items using the purchase method. The counted quantity is relative to the current stock level. |

## Stock-take methods

The stock-take method you select governs the main method of the stock-take. The following options are available: 

| Option Name      | Description |
| ----------- | ----------- | 
| **By Area** | when the counting is performed by area, the same product may be reported in different worksheets for the same stock-take. The total quantity counted among all worksheets within the stock-take will be as the physical inventory count. |
| **By Product** | when this method is used, the responsibility is arranged to count a specific product, regardless of its location within the shop location code. |
| **By Dimension** | this option is like **By Product** except it extends it with the standard dimension codes. The counting is arranged according to dimension codes and worksheets. |
## Counting method

The selected counting method determines the scope of the count. The following options are available: 

| Option Name      | Description |
| ----------- | ----------- | 
| **Complete (Non-Zero)** | the physical inventory will include all items whose stock level is not zero. Deviations for not counting specific items are controlled in the **Transfer** section. |
| **Complete** | the physical inventory should include every non-blocked item that has had inventory at some point in time. Deviations for not counting specific items are controlled in the **Transfer** section. |
| **Partial** | this method supports ad-hoc counting. |

## Suggested unit cost source 

This option controls the suggested unit cost for items. The options may be used when the item costing method is FIFO, LIFO, Average or Specific. It applies to those items that are recorded in the inventory during the stock-take. The available options are **Unit Cost**, **Last Direct Cost**, and **Standard Cost**.

## Transfer action

This option dictates actions when transferring counts from the stock-take worksheet to the item inventory journal. The options are:

| Option Name      | Description |
| ----------- | ----------- | 
| **Transfer** | the user is required to navigate to the item journal, and perform posting manually. |
| **Transfer and Post** | the option is the same as **Transfer**, except that the journal is also automatically posted. |
| **Transfer, Post, and Print** | this option is the same as the **Transfer** option, except that the journal is also automatically posted and printed. |

## Aggregation level 

With this option it is possible to control how data imported to the worksheet will be compressed. The available options are: **Scanned Number**, **Session Name**, **Native**, and **Consecutive**.

## Session Based Loading

This option dictates how the user can work with worksheets. Different worksheets can be used to divide work among different people/areas or products. The available options are **Append**, **Append Until Transferred**, and **Append is Not Allowed**.

## Session Based Transfer

With this option, it is possible to control the amount required to be transferred to the item journal. The following options are available:

| Option Name      | Description |
| ----------- | ----------- | 
| **All Worksheets** | when the transfer begins, all worksheets need to have the **Ready to Transfer** status, and all worksheet lines need to have the status **Ready**. After the transfer is completed, all lines will have the status **Transferred**. | 
| **Single Worksheet** | the functionality is the same as the one above, but applies to the current worksheet only. |
| **Selected Lines** | With this option, the greater manual control can be exercised on the worksheet lines. When transferring, only the current worksheet is affected. Individual lines may be ignored or have the **Transferred** status, and be skipped. |

## Data Release 

With this option, the user can control when the stock take lines are removed from the worksheet. The options are:

| Option Name      | Description |
| ----------- | ----------- |
| **Manual** | the worksheet needs to be cleared manually. There's no requirement to clear the worksheet after it has ben transferred to the **Inventory Journal**. |
| **Per Transfer** | the lines that were successfully transferred to the **Item Inventory Journal** have been deleted. All future work needs to be conducted from the **Inventory Journal**. This option should only be used in conjunction with **Transfer Action** which involves posting. |
| **Final Transfer** | this option is the same as the one above, except that it requires all lines which have the **Transferred** status after transferring is completed. |
## Default Profile

When creating a new stock-take configuration, it inherits all default settings from the first profile marked as the default profile. 

## Allow User Modification 

This setting controls what the user may change in the transfer dialog when creating the inventory journal. 

## Allow Unit Cost Change

This setting controls whether the user can change the value of the item unit cost in the stock take worksheet. The proposed value (regardless of how it is calculated) will be transferred to the item inventory journal when the item costing method differs from standard. 

   > [!Note]
   > The **Scope** section defines the items that should be included in the stock-take. An annual stock take might not specify any other value other than the **Location Code** on the template and configuration level. On the worksheet level, it might be practical to divide the work in item categories or areas or in some other way to have an organized and efficient stock-take.  

## Location Code 

This is a required setting that is applied when there are multiple locations defined in Business Central. One inventory journal (with multiple worksheets) can only apply to one location code. 

## Item Category Filter

This filter narrows the scope a little further. Filter strings (such as "1*” and “2*" can be used to select the active item categories). For annual stock take, this option will likely remain blank or the filter will specify active items. The filter can also be specified on the worksheet level, in which case there will be an "AND" between the filters (items matching both filters will be included as in-scope). This is very useful when dividing work/worksheets between people and items.

## Vendor Code Filter

This filter can be used for selecting a vendor. For annual stock take, it will most likely remain blank or listing the active item vendors. This filter can also be specified on the worksheet level, in which case there will be an "AND" between the filters (items matching both filters will be included as in-scope). This is very useful when dividing work/worksheets between people and items.

## \<Global Dim 1>

This dimension filter requires items to have this specific dimension code and value to be defined as in-scope. This field is hidden. 

## \<Global Dim 2>

Using the dimension filter requires items to have this specific dimension code and value, to be defined as in-scope This field is hidden. 

> [!Note]
> The **Transfer** section contains settings for controlling transfer to the item journal. 

## Item Journal Batch Usage

This option controls how journal batches are used. Since a batch must be empty when initiating a transfer, there might be a queue situation when having multiple worksheets wanting to transfer at the same time. The available options are: 

| Option Name      | Description |
| ----------- | ----------- |
| **Use Directly** | the template/batch (as specified in the fields above) is used verbatim. When working with multiple worksheets and individual transfers, the results need to be posted before the next worksheet is transferred. |
|  **As Template** | with this option, a new item journal batch is created with the same name as the worksheet, and with the same parameters as the named item journal batch. This option allows multiple worksheets to post journal in parallel. |

## Items Out-of-Scope 

This option controls how items that are out-of-scope (items not supposed to be counted) should be handled. When work is split into multiple worksheets (and people), it is imperative that items are not counted multiple times. The available options are: 

| Option Name      | Description |
| ----------- | ----------- |
| **Error** | when selecting this options, items not within the combined filters of the whole stock take, and the current worksheets' filters will generate an error during transfer to the item journal. |
| **Ignore** | when selecting this option, items not within the combined filters of the whole stock take, and the current worksheet's filters will be marked as ignored during transfer to the item journal, and will be skipped. |
| **Accept Count** | with this option, the counted items are accepted as if they would be in scope. The default dimension values from the stock take configuration will be applied to this physical inventory line. |

## Items in Scope Not Counted

This option controls the behavior of items that aren't counted, but should have been (according to the scope filter). The following options are available:

| Option Name      | Description |
| ----------- | ----------- |
| **Error** | unless all items matching the scope, a fatal error will occur during transfer. |
| **Ignore** | nothing happens when items aren't counted; there is no record of these items in the posted journal.  |
| **Accept Current** | the current stock level will be accepted (and recorded) as a valid stock-take. |
| **Adjust of Negative** | physical inventory can't be negative; when items not counted, have a negative inventory level, they will be changed and set to zero automatically. |
| **Adjust Set Zero** | all items not counted that are in the scope will have the stock level set to zero when the stock level is not zero. |

## Suppress Not Counted

The automatic adjustments are recorded on the item description in the **Physical Inventory Ledger**. Enabling this option suppresses the prefix on the **Physical Inventory Ledger**. 

## Barcode Not Accepted

Lines in the worksheet that have invalid barcodes that don't translate to items can be automatically ignored, or an error can be generated and force manual intervention. The barcode value is translated via three different tables in the following order:

- **Item Number**
- **Item Cross Reference**
- **Alternative No.** 

The available options are: 

| Option Name      | Description |
| ----------- | ----------- |
| **Error** | with this option, the user needs to remove or correct lines with invalid barcodes that don't translate to items. | 
| **Ignore** | with this option, the line status is set to **Ignore** for lines that have an invalid barcode value. |

## Blocked Item

Lines in the worksheet that contain blocked items can't be handled in physical inventory. The following options are available: 

| Option Name      | Description |
| ----------- | ----------- |
| **Error** | with this option, the user needs to remove or correct lines with blocked items. | 
| **Ignore** | with this option, the line status is set to **Ignore** for lines that have an invalid barcode value. |

### Related links

- [Physical inventory](../intro.md)