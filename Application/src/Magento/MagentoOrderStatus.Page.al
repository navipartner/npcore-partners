page 6151452 "NPR Magento Order Status"
{
    // MAG1.02/HSK/20150202 CASE 201683 Object created - Contains NaviConnect Order Status
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

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
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No. field';
                }
                field("External Order No."; "External Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Order No. field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Modified Date field';
                }
            }
        }
    }

    actions
    {
    }
}

