page 6014498 "NPR Serial Numbers Lookup"
{
    Extensible = False;
    Caption = 'Serial Numbers Lookup';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Item Ledger Entry";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Serial No."; Rec."Serial No.")
                {

                    ToolTip = 'Specifies the value of the Serial No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

