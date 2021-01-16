page 6151459 "NPR Magento Cont. ShipTo List"
{
    // MAG2.18/TSA /20181219 CASE 320424 Initial Version

    Caption = 'Magento Contact Ship-to List';
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Contact ShipToAdr.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Created By Contact No."; "Created By Contact No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Created By Contact No. field';
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field';
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field(Visibility; Visibility)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Visibility field';
                }
            }
        }
    }

    actions
    {
    }
}

