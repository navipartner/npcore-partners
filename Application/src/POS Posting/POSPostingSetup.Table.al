table 6150618 "NPR POS Posting Setup"
{
    Caption = 'POS Posting Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(2; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(3; "POS Payment Bin Code"; Code[10])
        {
            Caption = 'POS Payment Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
        field(8; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L Account,Bank Account,Customer';
            OptionMembers = "G/L Account","Bank Account",Customer;

            trigger OnValidate()
            begin
                if "Account Type" <> xRec."Account Type" then begin
                    "Account No." := '';

                end;
            end;
        }
        field(9; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"."No."
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer."No.";
        }
        field(10; "Difference Account Type"; Option)
        {
            Caption = 'Difference Account Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L Account,Bank Account,Customer';
            OptionMembers = "G/L Account","Bank Account",Customer;

            trigger OnValidate()
            begin
                if "Difference Account Type" <> xRec."Difference Account Type" then begin
                    "Difference Acc. No." := '';
                    "Difference Acc. No. (Neg)" := '';
                end;
            end;
        }
        field(11; "Close to POS Bin No."; Code[10])
        {
            Caption = 'Close to POS Bin No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
        field(12; "Difference Acc. No."; Code[20])
        {
            Caption = 'Difference Acc. No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Difference Account Type" = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF ("Difference Account Type" = CONST("Bank Account")) "Bank Account"."No."
            ELSE
            IF ("Difference Account Type" = CONST(Customer)) Customer."No.";
        }
        field(13; "Difference Acc. No. (Neg)"; Code[20])
        {
            Caption = 'Difference Acc. No. (Neg)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Difference Account Type" = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF ("Difference Account Type" = CONST("Bank Account")) "Bank Account"."No."
            ELSE
            IF ("Difference Account Type" = CONST(Customer)) Customer."No.";
        }
    }

    keys
    {
        key(Key1; "POS Store Code", "POS Payment Method Code", "POS Payment Bin Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "POS Payment Bin Code" <> '' then begin
            TestField("POS Payment Method Code");
            TestField("POS Store Code");
        end;
    end;

    trigger OnRename()
    begin
        if "POS Payment Bin Code" <> '' then begin
            TestField("POS Payment Method Code");
            TestField("POS Store Code");
        end;
    end;
}

