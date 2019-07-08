table 6151107 "NpRi Purch. Doc. Disc. Setup"
{
    // NPR5.46/MHA /20181002  CASE 323942 Object Created - NaviPartner Reimbursement - Purchase Document Discount

    Caption = 'Purchase Document Discount Reimbursement Setup';

    fields
    {
        field(1;"Template Code";Code[20])
        {
            Caption = 'Template Code';
            NotBlank = true;
            TableRelation = "NpRi Reimbursement Template";
        }
        field(5;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:5;
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

                GLAccount.Get("Bal. Account No.");
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

