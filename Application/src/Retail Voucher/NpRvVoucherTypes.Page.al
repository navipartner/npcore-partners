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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Valid Period"; "Valid Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Period field';
                }
                field("Voucher Qty. (Open)"; "Voucher Qty. (Open)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Qty. (Open) field';
                }
                field("Arch. Voucher Qty."; "Arch. Voucher Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived Voucher Qty. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Vouchers action';
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Partner Relations action';
            }
        }
    }
}

