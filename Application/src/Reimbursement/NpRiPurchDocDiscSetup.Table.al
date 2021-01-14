table 6151107 "NPR NpRi Purch.Doc.Disc. Setup"
{

    Caption = 'Purchase Document Discount Reimbursement Setup';
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
        field(5; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
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
        field(210; "Bal. VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'Bal. VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
    }

    keys
    {
        key(Key1; "Template Code")
        {
        }
    }
}

