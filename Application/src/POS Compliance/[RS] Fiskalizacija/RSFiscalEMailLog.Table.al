table 6059815 "NPR RS Fiscal E-Mail Log"
{
    Access = Internal;
    Caption = 'RS Fiscal E-Mail Log';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS Fiscal E-Mail Logs";
    LookupPageId = "NPR RS Fiscal E-Mail Logs";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Audit Entry No."; Integer)
        {
            Caption = 'Audit Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Audit Entry Type"; Enum "NPR RS Audit Entry Type")
        {
            Caption = 'Audit Entry Type';
            DataClassification = CustomerContent;
        }
        field(4; "Recipient E-mail"; Text[250])
        {
            Caption = 'Recipient E-mail';
            DataClassification = CustomerContent;
        }
        field(5; "From E-mail"; Text[250])
        {
            Caption = 'From E-mail';
            DataClassification = CustomerContent;
        }
        field(6; "E-mail subject"; Text[200])
        {
            Caption = 'E-mail subject';
            DataClassification = CustomerContent;
        }
        field(7; Filename; Text[200])
        {
            Caption = 'Filename(s)';
            DataClassification = CustomerContent;
        }
        field(8; "Sent Time"; Time)
        {
            Caption = 'Sent time';
            DataClassification = CustomerContent;
        }
        field(9; "Sent Date"; Date)
        {
            Caption = 'Sent Date';
            DataClassification = CustomerContent;
        }
        field(10; "Sent Username"; Text[250])
        {
            Caption = 'Sent by Username';
            DataClassification = CustomerContent;
        }
        field(11; Successful; Boolean)
        {
            Caption = 'Successful';
            DataClassification = CustomerContent;
        }
        field(12; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
