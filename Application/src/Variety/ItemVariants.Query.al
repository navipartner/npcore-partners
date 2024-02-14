query 6014405 "NPR Item Variants"
{
    Access = Internal;
    Caption = 'Item Variants';

    elements
    {
        dataitem(Item_Variant; "Item Variant")
        {
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            DataItemTableFilter = "NPR Blocked" = const(false);
#ELSE
            DataItemTableFilter = Blocked = const(false);
#ENDIF
            filter(Item_No_; "Item No.")
            {
            }
            column("Code"; Code)
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
