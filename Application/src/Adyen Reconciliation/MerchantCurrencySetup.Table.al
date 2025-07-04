table 6151208 "NPR Merchant Currency Setup"
{
    Access = Internal;
    Caption = 'NP Pay Merchant Account Currency Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Merchant Account Name"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Account Name';
            TableRelation = "NPR Adyen Merchant Account".Name;
            NotBlank = true;
        }
        field(10; "Reconciliation Account Type"; Enum "NPR Merchant Account")
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Account Type';
            NotBlank = true;

            trigger OnValidate()
            begin
                if (xRec."Reconciliation Account Type" <> Rec."Reconciliation Account Type") and ("Account Type" <> "Account Type"::"G/L Account") then begin
                    "Account Type" := "Account Type"::"G/L Account";
                    "Account No." := '';
                end;
            end;
        }
        field(20; "NP Pay Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'NP Pay Currency Code';
            TableRelation = Currency.Code;
            ValidateTableRelation = false;
            NotBlank = true;
        }
        field(30; "Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Account Type';
            ValuesAllowed = "G/L Account", "Bank Account";

            trigger OnValidate()
            var
                AccountTypeNotAllowedErr: Label 'Bank Account type is not allowed for expenses.\ G/L Account type is required for Reconciliation Account Types:\\- Fee\- Deposit\- Markup\- Other commissions\- Invoice Deduction';
            begin
                if ("Reconciliation Account Type" in
                    ["Reconciliation Account Type"::Fee,
                    "Reconciliation Account Type"::"Invoice Deduction",
                    "Reconciliation Account Type"::Deposit,
                    "Reconciliation Account Type"::Markup,
                    "Reconciliation Account Type"::"Other commissions",
                    "Reconciliation Account Type"::"Chargeback Fees",
                    "Reconciliation Account Type"::"Advancement External Commission",
                    "Reconciliation Account Type"::"Refunded External Commission",
                    "Reconciliation Account Type"::"Settled External Commission"]) and
                    ("Account Type" = "Account Type"::"Bank Account") then
                    Error(AccountTypeNotAllowedErr);
            end;
        }
        field(40; "Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const("Bank Account")) "Bank Account";
        }
    }
    keys
    {
        key(PK; "Merchant Account Name", "Reconciliation Account Type", "NP Pay Currency Code")
        {
            Clustered = true;
        }
    }
}
