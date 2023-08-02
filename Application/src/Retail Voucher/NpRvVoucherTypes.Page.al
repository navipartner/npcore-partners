page 6151013 "NPR NpRv Voucher Types"
{
    Extensible = False;
    Caption = 'Retail Voucher Types';
    ContextSensitiveHelpPage = 'docs/retail/vouchers/explanation/voucher_types/';
    CardPageID = "NPR NpRv Voucher Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code value associated with the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the code of the No. Series field for the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Period"; Rec."Valid Period")
                {

                    ToolTip = 'Specifies the valid period for the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Qty. (Open)"; Rec."Voucher Qty. (Open)")
                {

                    ToolTip = 'Specifies the quantity of open vouchers for the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field("Arch. Voucher Qty."; Rec."Arch. Voucher Qty.")
                {

                    ToolTip = 'Specifies the quantity of archived vouchers for the Voucher Type';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Opens the Vouchers page for the selected Voucher Type';
                ApplicationArea = NPRRetail;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);

                ToolTip = 'Opens the Partner Relations page for the selected Voucher Type';
                ApplicationArea = NPRRetail;
            }
        }
    }
}