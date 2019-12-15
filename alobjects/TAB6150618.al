table 6150618 "POS Posting Setup"
{
    // NPR5.29/AP/20170126 CASE 262628 Recreated ENU-captions
    // NPR5.36/BR/20170704 CASE 279551 Restructured recalculation functions
    // NPR5.38/BR/20180123 CASE 302777 "POS Payment Method Code" and "POS Store Code" mandatory if "POS Payment Bin Code" is filled

    Caption = 'POS Posting Setup';

    fields
    {
        field(1;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
        }
        field(2;"POS Payment Method Code";Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "POS Payment Method";
        }
        field(3;"POS Payment Bin Code";Code[10])
        {
            Caption = 'POS Payment Bin Code';
            TableRelation = "POS Payment Bin";
        }
        field(8;"Account Type";Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'G/L Account,Bank Account,Customer';
            OptionMembers = "G/L Account","Bank Account",Customer;

            trigger OnValidate()
            begin
                if "Account Type" <>  xRec."Account Type" then begin
                  "Account No." := '';

                end;
            end;
        }
        field(9;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type"=CONST("G/L Account")) "G/L Account"."No."
                            ELSE IF ("Account Type"=CONST("Bank Account")) "Bank Account"."No."
                            ELSE IF ("Account Type"=CONST(Customer)) Customer."No.";
        }
        field(10;"Difference Account Type";Option)
        {
            Caption = 'Difference Account Type';
            OptionCaption = 'G/L Account,Bank Account,Customer';
            OptionMembers = "G/L Account","Bank Account",Customer;

            trigger OnValidate()
            begin
                if "Difference Account Type" <>  xRec."Difference Account Type" then begin
                  "Difference Acc. No." := '';
                  "Difference Acc. No. (Neg)" := '';
                end;
            end;
        }
        field(11;"Close to POS Bin No.";Code[10])
        {
            Caption = 'Close to POS Bin No.';
            TableRelation = "POS Payment Bin";
        }
        field(12;"Difference Acc. No.";Code[20])
        {
            Caption = 'Difference Acc. No.';
            TableRelation = IF ("Difference Account Type"=CONST("G/L Account")) "G/L Account"."No."
                            ELSE IF ("Difference Account Type"=CONST("Bank Account")) "Bank Account"."No."
                            ELSE IF ("Difference Account Type"=CONST(Customer)) Customer."No.";
        }
        field(13;"Difference Acc. No. (Neg)";Code[20])
        {
            Caption = 'Difference Acc. No. (Neg)';
            TableRelation = IF ("Difference Account Type"=CONST("G/L Account")) "G/L Account"."No."
                            ELSE IF ("Difference Account Type"=CONST("Bank Account")) "Bank Account"."No."
                            ELSE IF ("Difference Account Type"=CONST(Customer)) Customer."No.";
        }
    }

    keys
    {
        key(Key1;"POS Store Code","POS Payment Method Code","POS Payment Bin Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //-NPR5.38 [302777]
        if "POS Payment Bin Code" <> '' then begin
          TestField("POS Payment Method Code");
          TestField("POS Store Code");
        end;
        //+NPR5.38 [302777]
    end;

    trigger OnRename()
    begin
        //-NPR5.38 [302777]
        if "POS Payment Bin Code" <> '' then begin
          TestField("POS Payment Method Code");
          TestField("POS Store Code");
        end;
        //+NPR5.38 [302777]
    end;
}

