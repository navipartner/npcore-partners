page 6151028 "NPR NpRv Partner Relations"
{
    Caption = 'Retail Voucher Partner Relations';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpRv Partner Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Partner Code"; "Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Code field';
                }
                field("Partner Name"; "Partner Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Name field';
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
            }
        }
    }
}

