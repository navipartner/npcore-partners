table 6151106 "NPR NpRi Provision Setup"
{
    Caption = 'Provision Reimbursement Setup';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Reimbursement Templ.";
        }
        field(5; "Provision %"; Decimal)
        {
            Caption = 'Provision %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(100; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "Account No." = '' then
                    exit;

                GLAccount.Get("Account No.");
                Validate("Gen. Prod. Posting Group", GLAccount."Gen. Prod. Posting Group");
                Validate("VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
            end;
        }
        field(105; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(110; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(200; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "Bal. Account No." = '' then
                    exit;

                GLAccount.Get("Bal. Account No.");

                Validate("Bal. Gen. Prod. Posting Group", GLAccount."Gen. Prod. Posting Group");
                Validate("Bal. VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
            end;
        }
        field(205; "Bal. Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Bal. Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(210; "Bal. VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'Bal. VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(300; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }

    keys
    {
        key(Key1; "Template Code")
        {
        }
    }
}

