page 6151013 "NpRv Voucher Types"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.49/MHA /20190228  CASE 342811 Added Action Partner Relations used with Cross Company Vouchers

    Caption = 'Retail Voucher Types';
    CardPageID = "NpRv Voucher Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Voucher Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("No. Series";"No. Series")
                {
                }
                field("Valid Period";"Valid Period")
                {
                }
                field("Voucher Qty. (Open)";"Voucher Qty. (Open)")
                {
                }
                field("Arch. Voucher Qty.";"Arch. Voucher Qty.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                RunObject = Page "NpRv Vouchers";
                RunPageLink = "Voucher Type"=FIELD(Code);
                ShortCutKey = 'Ctrl+F7';
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NpRv Partner Relations";
                RunPageLink = "Voucher Type"=FIELD(Code);
            }
        }
    }
}

