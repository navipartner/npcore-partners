page 6151452 "NPR Magento Order Status"
{
    // MAG1.02/HSK/20150202 CASE 201683 Object created - Contains NaviConnect Order Status
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Order Status';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("External Order No."; "External Order No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Last Modified Date"; "Last Modified Date")
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

