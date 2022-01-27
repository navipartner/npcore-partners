page 6151013 "NPR NpRv Voucher Types"
{
    Extensible = False;
    Caption = 'Retail Voucher Types';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Period"; Rec."Valid Period")
                {

                    ToolTip = 'Specifies the value of the Valid Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Qty. (Open)"; Rec."Voucher Qty. (Open)")
                {

                    ToolTip = 'Specifies the value of the Voucher Qty. (Open) field';
                    ApplicationArea = NPRRetail;
                }
                field("Arch. Voucher Qty."; Rec."Arch. Voucher Qty.")
                {

                    ToolTip = 'Specifies the value of the Archived Voucher Qty. field';
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

                ToolTip = 'Executes the Vouchers action';
                ApplicationArea = NPRRetail;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);

                ToolTip = 'Executes the Partner Relations action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

