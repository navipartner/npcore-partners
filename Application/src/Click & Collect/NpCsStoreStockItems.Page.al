page 6151223 "NPR NpCs Store Stock Items"
{
    Caption = 'Collect Store Stock Items';
    PageType = List;
    SourceTable = "NPR NpCs Store Stock Item";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Stock Qty."; Rec."Stock Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock Qty. field';
                }
                field("Last Updated at"; Rec."Last Updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Updated at field';
                }
            }
        }
    }
}