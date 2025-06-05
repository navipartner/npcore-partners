﻿page 6151452 "NPR Magento Order Status"
{
    Extensible = False;
    Caption = 'Order Status';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Order Status";
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order No."; Rec."Order No.")
                {

                    ToolTip = 'Specifies the value of the Order No. field';
                    ApplicationArea = NPRMagento;
                }
                field("External Order No."; Rec."External Order No.")
                {

                    ToolTip = 'Specifies the value of the External Order No. field';
                    ApplicationArea = NPRMagento;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRMagento;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {

                    ToolTip = 'Specifies the value of the Last Modified Date field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
