page 6151223 "NPR NpCs Store Stock Items"
{
    Caption = 'Collect Store Stock Items';
    PageType = List;
    SourceTable = "NPR NpCs Store Stock Item";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {

                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Stock Qty."; Rec."Stock Qty.")
                {

                    ToolTip = 'Specifies the value of the Stock Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Updated at"; Rec."Last Updated at")
                {

                    ToolTip = 'Specifies the value of the Last Updated at field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}