# Worksheet line registration

The Item Worksheet will not make any changes to the item master data and the related information until the Item Worksheet lines are registered. Worksheet lines can be registered from the **Item Worksheet** page. Only the lines that are within the filter on the page will be registered. Before registering, the lines will be validated, including the lines that already have the **validated’** status. 

If the field **Register Lines** on the **Item Worksheet Template** is checked, the system will create new entries in the **Registered Item Worksheet** table after registering the lines. 

If the field **Delete Processed Lines** on the **Item Worksheet Template** is checked, the system will delete any registered lines from the **Item Worksheet** table after registering the lines. This includes lines marked as **Skip**. 

> [!Note]
> To find the registered item worksheets, search for them via the Business Central's **Tell Me** feature. To clean up the database, the **Registered Item Worksheets** can be deleted using the task: **Delete Reg. Item Worksheets**. 

The information includes the date and time the registration took place, as well as the ID of the user that has registered the lines.

## Matching lines to existing items

The Item Worksheet attempts to match the input, both from the user and from a file import, to the existing items in the database, even if the **Existing Item No.** field isn't populated. The sequence in which the system checks whether an item is found is as follows:

1. Unblocked items
   1. With the **Vendor Item No.** field
      1. In the **Item Vendor** table
      2. In the SKU - **Vendor Item No.**
      3. In the Item - **Vendor Item No.**
   2. With the **Internal Barcode** field
      1. In the Cross References of the **Vendor** type
      2. In the Cross References of the **Barcode** type
      3. In **Alternative No.**
   3. With the **Vendor Barcode** field
      1. In the **Item Vendor** table
      2. In the SKU - **Vendor Item No.**
      3. In the Item - **Vendor Item No.**
      4. In Cross References of the **Vendor** type
      5. In the Cross References of the **Barcode** type
      6. In **Alternative No.**
2. All items (blocked and unblocked)
   1. With the **Vendor Item No.** field
      1. In the **Item Vendor** table
      2. In the SKU - **Vendor Item No.**
      3. In the Item - **Vendor Item No.**
   2. With the **Internal Barcode** field
      1. In the Cross References of the **Vendor** type
      2. In the Cross References of the **Barcode** type
      3. In **Alternative No.**
   3. With the **Vendor Item No.** field
      1. In Cross References of the **Vendor** type
      2. In the Cross References of the **Barcode** type
      3. In **Alternative No.**
   4. With the **Internal Barcode** field
      1. In the **Item Vendor** table
      2. In the SKU - **Vendor Item No.**
      3. In the Item - **Vendor Item No.**

### Related links

- [Adding variety values to the worksheet](adding_variety_values.md)
- [Item worksheet line creation](adding_variety_values.md)