# SQL statements for Lookup POS action

When menu buttons are added for the **LOOKUP** POS action, you can set filters on the item table using an SQL statement. 

![pos_action_sql_filter](../images/pos_action_sql_filter.png)

If you use the example from the provided screenshot - *SORTING(Description) ORDER(Ascending) WHERE(Inventory Posting Group=FILTER(SHOP))* - which means that the list will have items whose *Inventory Posting Group = SHOP*, and it is sorted in alphabetical order according to the item names. 

Some examples of statements that can be set with the **LOOKUP** POS action:

- Item Lookup by Specific Item Category:       

  SORTING(Description) ORDER(Ascending) WHERE(Item Category Code=FILTER(10..103))

- Item Lookup by Unit Price of a Certain Value:       

  SORTING(Description) ORDER(Ascending) WHERE(Unit Price=FILTER(>0&<25))

- Item Lookup by Specific Inventory Posting Group            
SORTING(Description) ORDER(Ascending) WHERE(Inventory Posting Group=FILTER(SHOP))

- Item Lookup by Specific Description      
SORTING(Description) ORDER(Ascending) WHERE(Description=FILTER(@Bag))

- Item Lookup by Specific Vendor and Item Category        
SORTING(Description) ORDER(Ascending) WHERE(Vendor No.=FILTER(CR000001), Item Category Code =FILTER(DESK))

## Example of SQL syntax used in Business Central

| Symbol      | Meaning |  Sample Expression  | Records Displayed  | 
| ----------- | ----------- | ----------- | ----------- |
| = | Equal to | 777 | Number 777 |
|     |     |   RED  | Those with the RED code, for example, the RED warehouse code |
|     |     |  12    | A datetime: from 12-current month-current year 0:00:00 to 12-current month-current year 22:59:59 |
|    |     |  12 10  | An exact datetime: 12-07-17 10:00:00 |
| ..  |  Interval   |  100..200  | A range of numbers 100 through 200 | 
|     |    |   ..500 | Up to, and including 500 | 
|     |    |  ..310117   | Dates up to, and including 31/01/17 | 
|     |    | P2.. | Information for accounting period 2 and subsequent periods | 
| /  | Vertical bar  |   7/8 |   The vertical bar signifies either/or, so the value is either 7 or 8. |
| @ | Ignore case (either uppercase or lowercase allowed) | @green | Text like GREEN, green or Green |
| ** | Wildcard | \*Bag*| Any item containing the word "Bag" in any part of the name, filtered with an asterisk (wildcard) before and after the word | 
| > | Greater | >100 | A value greater than 100 | 
| <> | Not equal to | <>100 | A value not equal to 100. It can be higher or lower |
| <= | Lower than or equal to | <=100 | A value lower than or equal to 100 |
| >= | Greater than or equal to | >=100 | A value greater than or equal to 100 |
| @ ** | Wildcard, Case Insensitive | @\*bag* | To find any item containing the word "Bag", "bag", "bAg", etc. (case-insensitive) in any part of the name, use the @ expression: @bag |
| @ ?** |   | @ba? | Text containing "ba", "BA", "Ba", and "bA", such as bag, Bags and green bag. The "ba", "BA", "Ba", "bA" must be present, followed by at least one character. There can be an indefinite number of characters before and after these, and case is unimportant. | 
| " |  Blank |   | Value is blank. That is the field contains no value. | 
| <>'' | All not blank   | The field contains a value. |
| **Combination of Syntax** |    |    |    |
|     |     | 4444\|5100..5490 | Include any records with the number 4444 or a number from the interval 5100 through 5490 |
|     |     | ..1000\|1200.. | Include records with a number lower than or equal to 1000 or a number equal to 1200 or greater (all numbers except 10001 through 1199) |
|     |     | >30&<100  | Include records with numbers that are greater than 30 and lower than 100 (numbers 31 through 99) | 
|     |     | 7*..8* | Includes all records in which the field has values from (starting with the digit 7) to (starting with digit 8), e.g. 7, 77, 717, 8, 81, 8123456 and so on. |
|     |     | 7?..?11 | The result contains all records in which the field has values from (two-digit numbers starting with digit 7) to (three-digit numbers ending with digit 11), e.g. 70, 71, 79, 111, 211, 911, and so on. | 
|    |     | >B* | The result contains all records in which the field has text values that are greater than B*, where B* is any string that starts with "B". e.g Bag, Bags, Buggy, Boat etc. |
|    |     | >10?B* | The result contains all records in which the field has text values that are greater than 10?B*, where 10?B* is any string that starts with "10" followed by any random symbol, then "B", and finally at least one random symbol. |
|   |     | A&B | The text which contains both A and B |
|     |     |  SE\|SO\|LE..WE | Values SE, SO, LE, PE, WE | 
| **Date Formula** |    |     |      | 
|     |     |   20D  | 20 days |
|     |      | 6W   | 6 weeks |
|     |      |  CM+2D | The current month plus two days | 
|     |      | CM+1M | The current month plus one month |
|     |      | CQ+1M+20D | The current quarter plus one month plus 20 days |
|    |    |  CW+1W | The current week plus one week |
|    |     | D15 | On the 15th of each month |
|    |     | -CY+10M | November 1st | 
|    |     |  CY | The current year |
|    |     |  CM | The current month |
|    |     | CQ | The current quarter | 

### Related links

- [POS menu](../explanation/POS_menu.md)
- [POS actions](pos_actions.md)
- [Create new buttons in the POS menu](../howto/add_button_to_pos_menu.md)
- [Create a new item button in the POS](../howto/Create_a_new_item_button_in_the_POS.md)