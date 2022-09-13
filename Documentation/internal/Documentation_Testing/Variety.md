## Variety (Variants)

In Business Central, it is possible to create different variants of each item, by selecting their different characteristics during configuration. Each variant represents a different quality of an item, such as its color or size. When configuring an item they wish to buy, users can select one of the suggested qualities before ordering.

Due to the widespread use of multiple variants to personalize items, NP Retail has developed a tool **Variety Setup** that represents variants in a more structured way.


### Item Journal Blocking

If variety is enabled and variants are created in the system, customers can select the level of variant checking or all items that have custom variants selected

### Variety tables

A variety can have unlimited variety tables, and each variety table can have almost an unlimited number of values (however, it's not recommended to have more than 100 values per table, as the need for customization can arise as a result).

There are two scenarios for variety table that is linked to the item:

- The same values are used for a table
  - Size
  - Waist
  - Length 

- Only distinct values are used for a table
  - Colors (it's impossible to determine which colors are used for a specific item group in advance)

## Create a new variety

Varieties are created from the **Item Card** of items that have attributes which should be selected. It's possible to create as many variety entries as possible, but a single item is limited to four varieties. 

1. Navigate to the **Item Card** by searching for **Items** and selecting the item you wish to configure and click **Create a new entry** (the plus icon at the top of the window).
2. Select a template you wish to use for the new item and click **Okay**.
3. Populate all the necessary fields, such as the item description, unit of measure, item category, and any other fields that may be necessary for your desired configuration. 
   The **No.** field is automatically generated.
4. Click **Actions**, and then **Item** and **Variants**.
5. Add codes and descriptions for as many variants as you need. 
   If a variant isn't available at this moment, tick the **Blocked** checkbox.
   The settings you've added are automatically saved.

Next steps:

1. To put variants to use, search for the **Sales Orders** and click **New**.
2. Add the **Customer Name**, and then add an item to the **Lines** panel. 
3. Click **Line** and then find the **Variety** option in the **Related Information** dropdown. Click it.



## Variety matrix on a sales order









## Block a variety

If some of the product variants are currently not available in the catalog, it is possible to block them, so as to prevent users from selecting them. 

To block a variety:

1. Navigate to the **Item Card** by searching for **Items** and selecting the item you wish to configure.
2. Select the **Variants** option from the **Actions** at the top of the **Item Card**. 
3. From the **History** option, click either the **Variety Maintenance** or **Variety Matrix** to reach the **Variety Matrix** screen.
4. In the **Variety Matrix** window, click **Create Variety** next to **Show Field**.
   The **Variety Fields Lookup** popup window is displayed.
5. Click on a row that has the **Blocked** label.
6. Select **Hide Inactive Values** to make sure they no longer appear when user selects item variants.