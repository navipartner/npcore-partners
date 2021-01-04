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
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field("Card No. Series"; "Card No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card No. Series field';
                    }
                }
                group(Control6150624)
                {
                    ShowCaption = false;
                    field("EAN Prefix"; "EAN Prefix")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN Prefix field';
                    }
                    field("Expiration Calculation"; "Expiration Calculation")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Expiration Calculation field';
                    }
                    field("Point Account"; "Point Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Point Account field';
                    }
                    field("Post Point Earnings"; "Post Point Earnings")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Point Earnings field';
                    }
                    field("PaymentTypePOS.""No."""; PaymentTypePOS."No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Payment Type';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment Type field';
                    }
                    field(BalAccountType; BalAccountType)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the BalAccountType field';
                    }
                    field(BalAccount; BalAccount)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the BalAccount field';
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
                    ToolTip = 'Specifies the value of the Card Expiration Formula field';
                }
                field("Customer Template"; "Customer Template")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Price Group';
                    ToolTip = 'Specifies the value of the Customer Price Group field';
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
                ToolTip = 'Executes the Lookup action';
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

