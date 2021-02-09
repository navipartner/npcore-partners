page 6151452 "NPR Magento Order Status"
{
    Caption = 'Order Status';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Order Status";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No. field';
                }
                field("External Order No."; Rec."External Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Order No. field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Modified Date field';
                }
            }
        }
    }
}