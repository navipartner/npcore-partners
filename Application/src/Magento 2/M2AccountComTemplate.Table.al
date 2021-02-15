table 6151152 "NPR M2 Account Com. Template"
{
    Caption = 'Account Com. Template';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Enum "NPR M2 Acc. Com. Template Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(10; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(11; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(12; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(15; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
        field(80; "Security Token"; Text[40])
        {
            Caption = 'Security Token';
            DataClassification = CustomerContent;
        }
        field(81; "B64 Email"; Text[120])
        {
            Caption = 'B64 Email';
            DataClassification = CustomerContent;
        }
        field(90; URL1; Text[250])
        {
            Caption = 'URL1';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}