page 6151013 "NPR NpRv Voucher Types"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.49/MHA /20190228  CASE 342811 Added Action Partner Relations used with Cross Company Vouchers

    Caption = 'Retail Voucher Types';
    CardPageID = "NPR NpRv Voucher Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Valid Period"; "Valid Period")
                {
                    ApplicationArea = All;
                }
                field("Voucher Qty. (Open)"; "Voucher Qty. (Open)")
                {
                    ApplicationArea = All;
                }
                field("Arch. Voucher Qty."; "Arch. Voucher Qty.")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR NpRv Vouchers";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea=All;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ApplicationArea=All;
            }
        }
    }
}

