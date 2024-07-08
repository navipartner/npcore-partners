page 6151028 "NPR NpRv Partner Relations"
{
    Extensible = False;
    Caption = 'Retail Voucher Partner Relations';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Partner Relation";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Partner Code"; Rec."Partner Code")
                {

                    ToolTip = 'Specifies the value of the Partner Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Partner Name"; Rec."Partner Name")
                {

                    ToolTip = 'Specifies the value of the Partner Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {

                    ToolTip = 'Specifies the value of the Voucher Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

