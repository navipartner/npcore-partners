page 6014498 "Serial Numbers Lookup"
{
    Caption = 'Serial Numbers Lookup';
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
                field("Serial No."; "Serial No.")
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

