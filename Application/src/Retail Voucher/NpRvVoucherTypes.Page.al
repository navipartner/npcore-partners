page 6151013 "NPR NpRv Voucher Types"
{
    Caption = 'Retail Voucher Types';
    CardPageID = "NPR NpRv Voucher Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher Type";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Valid Period"; Rec."Valid Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Period field';
                }
                field("Voucher Qty. (Open)"; Rec."Voucher Qty. (Open)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Qty. (Open) field';
                }
                field("Arch. Voucher Qty."; Rec."Arch. Voucher Qty.")
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

