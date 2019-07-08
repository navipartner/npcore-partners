table 6150906 "HC Payment Type Posting Setup"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.48/JDH /20181109 CASE 334163 Added option Caption to field Transfer Account Type

    Caption = 'HC Payment Type Posting Setup';
    DrillDownPageID = "HC Payment Types Posting Setup";
    LookupPageID = "HC Payment Types Posting Setup";

    fields
    {
        field(10;"BC Payment Type POS No.";Code[10])
        {
            Caption = 'BC Payment Type POS No.';
            TableRelation = "HC Payment Type POS";
        }
        field(20;"BC Register No.";Code[10])
        {
            Caption = 'BC Register No.';
            TableRelation = "HC Register";
        }
        field(30;"G/L Account No.";Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(40;"Bank Account No.";Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account"."No.";
        }
        field(50;"Difference G/L Account";Code[20])
        {
            Caption = 'Difference G/L Account';
            TableRelation = "G/L Account";
        }
        field(60;"Transfer Account Type";Option)
        {
            Caption = 'Closing Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(70;"Transfer Account No.";Code[20])
        {
            Caption = 'Closing Account No.';
            TableRelation = IF ("Transfer Account Type"=CONST("G/L Account")) "G/L Account"
                            ELSE IF ("Transfer Account Type"=CONST("Bank Account")) "Bank Account";
        }
    }

    keys
    {
        key(Key1;"BC Payment Type POS No.","BC Register No.")
        {
        }
    }

    fieldgroups
    {
    }
}

