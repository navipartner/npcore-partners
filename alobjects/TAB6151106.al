table 6151106 "NpRi Provision Setup"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.46/MHA /20181002  CASE 323942 Corrected GLAccount.GET in Bal. Account No. - OnValidate()

    Caption = 'Provision Reimbursement Setup';

    fields
    {
        field(1;"Template Code";Code[20])
        {
            Caption = 'Template Code';
            NotBlank = true;
            TableRelation = "NpRi Reimbursement Template";
        }
        field(5;"Provision %";Decimal)
        {
            Caption = 'Provision %';
            DecimalPlaces = 0:5;
        }
        field(100;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account" WHERE ("Direct Posting"=CONST(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "Account No." = '' then
                  exit;

                GLAccount.Get("Account No.");
                Validate("Gen. Prod. Posting Group",GLAccount."Gen. Prod. Posting Group");
                Validate("VAT Prod. Posting Group",GLAccount."VAT Prod. Posting Group");
            end;
        }
        field(105;"Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(110;"VAT Prod. Posting Group";Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(200;"Bal. Account No.";Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = "G/L Account" WHERE ("Direct Posting"=CONST(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "Bal. Account No." = '' then
                  exit;

                //-NPR5.46 [323942]
                //GLAccount.GET("Account No.");
                GLAccount.Get("Bal. Account No.");
                //+NPR5.46 [323942]
                Validate("Bal. Gen. Prod. Posting Group",GLAccount."Gen. Prod. Posting Group");
                Validate("Bal. VAT Prod. Posting Group",GLAccount."VAT Prod. Posting Group");
            end;
        }
        field(205;"Bal. Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Bal. Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(210;"Bal. VAT Prod. Posting Group";Code[10])
        {
            Caption = 'Bal. VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(300;"Source Code";Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
    }

    keys
    {
        key(Key1;"Template Code")
        {
        }
    }

    fieldgroups
    {
    }
}

