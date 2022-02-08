# Varieties in NP Retail

Variety is a tool that assists users in creating and associating different characteristics with items. The most common characteristics, or variants, of items are **Color**, **Size**, **Waist**, and **Length**. There are also other variants that are specific to certain types of merchandise, for example **Label**, **Wash**, and **Fit** in regards to clothes. 

NP Retail has a tool that can be used for defining the variants associated with various items. The stock is maintained per a combination of variants, and is sold in these particular combinations. The tool doesn't affect price calculations. Rather, it simply represents the item characteristics in a more structured way. It also allows users to apply all item variants to the item at the same time.

## How varieties work

You can create as many varieties as you need, but a single item is limited to 4 varieties. Normally, 2 or 3 varieties are used for a single item. A variety can have an unlimited number of variety tables, and each variety table can have an (almost) unlimited number of values, but the recommended limit is 100 values per a table.

> [!Note]
> Adding more than 100 values per a table may require customization, so it's not recommended. 

There are two different types of variety tables according to the item characteristics they describe:

- Tables that always contain the same values     
  Example: 
    - Size (37, 39, 40 or S, L, XXXL)
    - Waist (38, 40, 46)
    - Length (38, 40, 46)

- Tables that always contain different values     
  Example:
    - Colors (it's almost impossible to determine what colors will each item be in advance)
