table 6151009 "NPR CRO Fiscal E-Mail Log"
{
    Access = Internal;
    Caption = 'CRO Fiscal E-Mail Log';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR CRO Fiscal E-Mail Logs";
    LookupPageId = "NPR CRO Fiscal E-Mail Logs";

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
        field(3; "Audit Entry Type"; Enum "NPR CRO Audit Entry Type")
        {
            Caption = 'Audit Entry Type';
            DataClassification = CustomerContent;
        }
        field(4; "Recipient E-mail"; Text[250])
        {
            Caption = 'Recipient E-mail';
            DataClassification = CustomerContent;
        }
        field(5; "Sender E-mail"; Text[250])
        {
            Caption = 'Sender E-mail';
            DataClassification = CustomerContent;
        }
        field(6; "E-mail Subject"; Text[200])
        {
            Caption = 'E-mail Subject';
            DataClassification = CustomerContent;
        }
        field(7; Filename; Text[200])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(8; "Sending Time"; Time)
        {
            Caption = 'Sending time';
            DataClassification = CustomerContent;
        }
        field(9; "Sending Date"; Date)
        {
            Caption = 'Sending Date';
            DataClassification = CustomerContent;
        }
        field(10; "Sent by"; Code[50])
        {
            Caption = 'Sent by';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
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