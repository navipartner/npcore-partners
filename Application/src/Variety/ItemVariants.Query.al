query 6014405 "NPR Item Variants"
{
    Caption = 'Item Variants';
    OrderBy = descending(Code);

    elements
    {
        dataitem(Item_Variant; "Item Variant")
        {
            DataItemTableFilter = "NPR Blocked" = const(false);
            filter(Item_No_; "Item No.")
            {
            }
            column(Code; Code)
            {
            }
            column(Description; Description)
            {
            }
            column(Description_2; "Description 2")
            {
            }
        }
    }
}