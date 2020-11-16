page 6014442 "NPR Item - Series Number"
{
    // NPR5.55/ALPO/20200414 CASE 398263 Added "Variant Code" and "Expiration Date"

    Caption = 'Item Serial No.';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "Item Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

