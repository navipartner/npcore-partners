page 6014660 "NPR Item Variants FactBox"
{
    Caption = 'Item Variants FactBox';
    PageType = ListPart;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "Item";

    layout
    {
        area(Content)
        {
            repeater(Control)
            {
                field(Inventory; Rec.Inventory)
                {

                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field(NetChange; Rec."Net Change")
                {

                    Caption = 'Net Change';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Net Change field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}