table 6184519 "NPR EFT NETSCloud Unit Setup"
{
    Access = Internal;

    Caption = 'EFT NETS Cloud POS Unit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(10; "Terminal ID"; Text[50])
        {
            Caption = 'Terminal ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
        }
    }

    fieldgroups
    {
    }
}

