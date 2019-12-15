table 6150908 "HC Generic Web Request"
{
    // NPR5.38/BR  /20171205  CASE 297946 Created object

    Caption = 'Generic Web Request';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"External Entry No.";Integer)
        {
            Caption = 'External Entry No.';
        }
        field(10;"Request Date";DateTime)
        {
            Caption = 'Request Date';
        }
        field(11;"Request User ID";Code[50])
        {
            Caption = 'Request User ID';
        }
        field(15;"Response Date";DateTime)
        {
            Caption = 'Response Date';
        }
        field(16;"Response User ID";Code[50])
        {
            Caption = 'Response User ID';
        }
        field(100;"Request Code";Code[20])
        {
            Caption = 'Request Code';
        }
        field(110;"Parameter 1";Text[250])
        {
            Caption = 'Parameter 1';
        }
        field(111;"Parameter 2";Text[250])
        {
            Caption = 'Parameter 2';
        }
        field(112;"Parameter 3";Text[250])
        {
            Caption = 'Parameter 3';
        }
        field(113;"Parameter 4";Text[250])
        {
            Caption = 'Parameter 4';
        }
        field(114;"Parameter 5";Text[250])
        {
            Caption = 'Parameter 5';
        }
        field(115;"Parameter 6";Text[250])
        {
            Caption = 'Parameter 6';
        }
        field(150;"Response 1";Text[250])
        {
            Caption = 'Response 1';
        }
        field(151;"Response 2";Text[250])
        {
            Caption = 'Response 2';
        }
        field(152;"Response 3";Text[250])
        {
            Caption = 'Response 3';
        }
        field(153;"Response 4";Text[250])
        {
            Caption = 'Response 4';
        }
        field(200;"Has Error";Boolean)
        {
            Caption = 'Has Error';
        }
        field(201;"Error Code";Code[20])
        {
            Caption = 'Error Code';
        }
        field(202;"Error Text";Text[250])
        {
            Caption = 'Error Text';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

