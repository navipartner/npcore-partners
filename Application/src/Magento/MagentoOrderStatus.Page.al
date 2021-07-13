page 6151452 "NPR Magento Order Status"
{
    Caption = 'Order Status';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Order Status";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order No."; Rec."Order No.")
                {

                    ToolTip = 'Specifies the value of the Order No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Order No."; Rec."External Order No.")
                {

                    ToolTip = 'Specifies the value of the External Order No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {

                    ToolTip = 'Specifies the value of the Last Modified Date field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}