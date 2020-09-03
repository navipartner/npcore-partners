page 6151459 "NPR Magento Cont. ShipTo List"
{
    // MAG2.18/TSA /20181219 CASE 320424 Initial Version

    Caption = 'Magento Contact Ship-to List';
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = List;
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
                }
                field("Created By Contact No."; "Created By Contact No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                }
                field(Visibility; Visibility)
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

