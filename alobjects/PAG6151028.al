page 6151028 "NpRv Partner Relations"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company Vouchers

    Caption = 'Retail Voucher Partner Relations';
    PageType = List;
    SourceTable = "NpRv Partner Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Partner Code";"Partner Code")
                {
                }
                field("Partner Name";"Partner Name")
                {
                }
                field("Voucher Type";"Voucher Type")
                {
                }
            }
        }
    }

    actions
    {
    }
}

