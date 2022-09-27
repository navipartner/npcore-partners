# Adding variety values to the worksheet

Inserting a value that is not currently in the table for a variety will add that Variety Value for that worksheet line. For example: if Variety table for the variety SIZE contains two values: SMALL and MEDIUM and the action **Suggest all Varieties** is run, the system will propose two lines per combination of other variety lines.
If for example the only other Variety is COLOR, and there are two values, BLACK and WHITE for this variety, there will be four lines.

If the user overwrites SMALL with LARGE, this new value will be added to the **Variety Value** for this worksheet line. If **Suggest all Varieties** is clicked again, there will be three lines per color, and six lines in total. 

When the **Item Worksheet** line is registered in this case, the system will check whether a **Variety Table** is set to **Locked**. If this is the case, a copy of the table will be created for this item, and the new value will be added to the table. If the **Varity Table** is not locked then, by default, no copy will be created and the value will be added to the **Variety Table**. The field **Status Comment** is filled with a text describing how the update will be handled. In the case of an unlocked **Variety Table**, the field **Create Copy of Variety Table** can be switched on in the **Item Worksheet** line to create a copy of the table anyway. 

## Validating the lines

Lines can have one of the following statuses:

- **Unvalidated** - the initial value for newly inserted or imported lines
- **Error** - the line has errors and can't be registered
- **Warning** - conflicting values are found in the worksheet line
- **Validated** - the line has been checked, and is ready to be registered.
- **Processed** - the line has been registered; if the item worksheet template has been set up to **Delete Registered Lines**, this status will not occur as the lines will be deleted immediately after being registered. 

Lines are validated via the **Check Lines** action, or by registering the lines. In both cases, all lines are validated, even the ones that already have the status **Validated**. After validation, the lines will either have the **Validated** or **Error** status. 

The following checks are performed during validation:

- Check consistency between the **Worksheet Line** and **Worksheet Variety Lines**.
- Check if values exist (such as **Item Category Code** etc.).
- Check if the **Variety Value** tables are unlocked (if values are to be added).
- Check if the item numbers in the worksheet already exist as items (if the **Create** action is used).
- Check whether a combination of varieties already exists as a variety (if the **Create** action is used).
- Check on item numbering for new items.
- Check on currency codes for sales prices and cost prices.
- Check the **Vendor No.** validity.
- Check whether the description is provided.
- Check if there are multiple lines with the same combination of varieties, or the the same barcode.
- Check if all variety codes have values; for example: if SIZE is set up with a variety table on the worksheet line, all varieties must have a SIZE value.
- Check if the **Existing item**/**Existing Variant** is filled and if it exists exists (if the **Update** action is used).

### Related links

- [Item worksheet line creation](adding_variety_values.md)
- [Worksheet line registration](worksheet_line_registration.md)