page 6151028 "NPR NpRv Partner Relations"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company Vouchers

    Caption = 'Retail Voucher Partner Relations';
    PageType = List;
    UsageCategory = Administration;
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

    actions
    {
    }
}

