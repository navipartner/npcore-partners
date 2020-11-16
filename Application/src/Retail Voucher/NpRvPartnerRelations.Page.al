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
                }
                field("Partner Name"; "Partner Name")
                {
                    ApplicationArea = All;
                }
                field("Voucher Type"; "Voucher Type")
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

