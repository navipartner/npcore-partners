page 6059772 "NPR Member Card Types Card"
{

    Caption = 'Point Card - Types Card';
    SourceTable = "NPR Member Card Types";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6150616)
                {
                    ShowCaption = false;
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                    field("Card No. Series"; "Card No. Series")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150624)
                {
                    ShowCaption = false;
                    field("EAN Prefix"; "EAN Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("Expiration Calculation"; "Expiration Calculation")
                    {
                        ApplicationArea = All;
                    }
                    field("Point Account"; "Point Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Post Point Earnings"; "Post Point Earnings")
                    {
                        ApplicationArea = All;
                    }
                    field("PaymentTypePOS.""No."""; PaymentTypePOS."No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Payment Type';
                        Editable = false;
                    }
                    field(BalAccountType; BalAccountType)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                    }
                    field(BalAccount; BalAccount)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                    }
                }
            }
            group("Card Setup")
            {
                Caption = 'Card Setup';
                field("Card Expiration Formula"; "Card Expiration Formula")
                {
                    ApplicationArea = All;
                    Caption = 'Card Expiration Formula';
                }
                field("Customer Template"; "Customer Template")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Price Group';
                }
            }
            part(Control6150629; "NPR Member Card Types Subform")
            {
                SubPageLink = "Card Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Lookup)
            {
                Caption = 'Lookup';
                Image = List;
                RunObject = Page "NPR Member Card Types";
                ShortCutKey = 'F5';
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PaymentTypePOS.Reset;
        PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Point Card");
        PaymentTypePOS.SetRange("Loyalty Card Type", Code);

        if PaymentTypePOS.FindFirst then;

        BalAccountType := PaymentTypePOS."Account Type";

        case BalAccountType of
            BalAccountType::"G/L Account":
                BalAccount := PaymentTypePOS."G/L Account No.";
            BalAccountType::Customer:
                BalAccount := PaymentTypePOS."Customer No.";
            BalAccountType::Bank:
                BalAccount := PaymentTypePOS."Bank Acc. No.";
        end;
    end;

    var
        PaymentTypePOS: Record "NPR Payment Type POS";
        BalAccountType: Option "G/L Account",Customer,Bank;
        BalAccount: Code[20];
}

