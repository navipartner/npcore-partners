query 6151370 "CS Rfid Item Totals"
{
    // NPR5.47/CLVA/20181012 CASE 318296 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'CS Rfid Item Totals';
    OrderBy = Ascending(Item_No);

    elements
    {
        dataitem(CS_Rfid_Item_Handling;"CS Rfid Item Handling")
        {
            filter(Id;Id)
            {
            }
            filter(Handled;Handled)
            {
            }
            filter(Transferred_to_Item_Cross_Ref;"Transferred to Item Cross Ref.")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Item_Description;"Item Description")
            {
            }
            column(Variant_Code;"Variant Code")
            {
            }
            column(Variant_Description;"Variant Description")
            {
            }
            column(Duplicate_Tag_Id;"Duplicate Tag Id")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

