table 6150908 "HC Generic Web Request"
{
    // NPR5.38/BR  /20171205  CASE 297946 Created object

    Caption = 'Generic Web Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "External Entry No."; Integer)
        {
            Caption = 'External Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Request Date"; DateTime)
        {
            Caption = 'Request Date';
            DataClassification = CustomerContent;
        }
        field(11; "Request User ID"; Code[50])
        {
            Caption = 'Request User ID';
            DataClassification = CustomerContent;
        }
        field(15; "Response Date"; DateTime)
        {
            Caption = 'Response Date';
            DataClassification = CustomerContent;
        }
        field(16; "Response User ID"; Code[50])
        {
            Caption = 'Response User ID';
            DataClassification = CustomerContent;
        }
        field(100; "Request Code"; Code[20])
        {
            Caption = 'Request Code';
            DataClassification = CustomerContent;
        }
        field(110; "Parameter 1"; Text[250])
        {
            Caption = 'Parameter 1';
            DataClassification = CustomerContent;
        }
        field(111; "Parameter 2"; Text[250])
        {
            Caption = 'Parameter 2';
            DataClassification = CustomerContent;
        }
        field(112; "Parameter 3"; Text[250])
        {
            Caption = 'Parameter 3';
            DataClassification = CustomerContent;
        }
        field(113; "Parameter 4"; Text[250])
        {
            Caption = 'Parameter 4';
            DataClassification = CustomerContent;
        }
        field(114; "Parameter 5"; Text[250])
        {
            Caption = 'Parameter 5';
            DataClassification = CustomerContent;
        }
        field(115; "Parameter 6"; Text[250])
        {
            Caption = 'Parameter 6';
            DataClassification = CustomerContent;
        }
        field(150; "Response 1"; Text[250])
        {
            Caption = 'Response 1';
            DataClassification = CustomerContent;
        }
        field(151; "Response 2"; Text[250])
        {
            Caption = 'Response 2';
            DataClassification = CustomerContent;
        }
        field(152; "Response 3"; Text[250])
        {
            Caption = 'Response 3';
            DataClassification = CustomerContent;
        }
        field(153; "Response 4"; Text[250])
        {
            Caption = 'Response 4';
            DataClassification = CustomerContent;
        }
        field(200; "Has Error"; Boolean)
        {
            Caption = 'Has Error';
            DataClassification = CustomerContent;
        }
        field(201; "Error Code"; Code[20])
        {
            Caption = 'Error Code';
            DataClassification = CustomerContent;
        }
        field(202; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

