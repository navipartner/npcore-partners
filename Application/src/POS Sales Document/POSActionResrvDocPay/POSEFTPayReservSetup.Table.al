table 6150893 "NPR POS EFT Pay Reserv Setup"
{
    Caption = 'EFT Payment Reservation Setup';
    DataClassification = ToBeClassified;
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-09-16';
    ObsoleteReason = 'Table marked for removal. Reason: All the fields are transfered to to "NPR Adyen Setup" table.';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Payment Gateway Code"; Code[10])
        {
            Caption = 'Payment Gateway Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway".Code;
        }
        field(3; "Account Type"; Enum "Payment Balance Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Account Type" <> xRec."Account Type" then
                    Rec."Account No." := '';
            end;

        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }


}