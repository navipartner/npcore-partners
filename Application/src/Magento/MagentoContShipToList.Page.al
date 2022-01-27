page 6151459 "NPR Magento Cont. ShipTo List"
{
    Extensible = False;
    Caption = 'Magento Contact Ship-to List';
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Contact ShipToAdr.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Created By Contact No."; Rec."Created By Contact No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Created By Contact No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {

                    ToolTip = 'Specifies the value of the Ship-to Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRRetail;
                }
                field(Visibility; Rec.Visibility)
                {

                    ToolTip = 'Specifies the value of the Visibility field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
