page 6014442 "Item - Series Number"
{
    // NPR5.55/ALPO/20200414 CASE 398263 Added "Variant Code" and "Expiration Date"

    Caption = 'Item Serial No.';
    Editable = false;
    PageType = List;
    SourceTable = "Item Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Serial No.";"Serial No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Expiration Date";"Expiration Date")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

