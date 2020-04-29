page 6014442 "Item - Series Number"
{
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

