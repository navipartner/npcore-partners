query 6151379 "NPR CS Item Journal Lines"
{
    // NPR5.51/JAKUBV/20190904  CASE 365659 Transport NPR5.51 - 3 September 2019
    // NPR5.52/CLVA  /20190926  CASE 370277 Added OrderBy

    Caption = 'CS Item Journal Lines';
    OrderBy = Descending(Changed_by_User);

    elements
    {
        dataitem(Item_Journal_Line; "Item Journal Line")
        {
            filter(Journal_Template_Name; "Journal Template Name")
            {
            }
            filter(Journal_Batch_Name; "Journal Batch Name")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {
            }
            column(Qty_Phys_Inventory; "Qty. (Phys. Inventory)")
            {
            }
            column(Changed_by_User; "Changed by User")
            {
            }
            column(Quantity; Quantity)
            {
            }
            column(Qty_Calculated; "Qty. (Calculated)")
            {
            }
        }
    }
}

