table 6150965 "NPR MM Add. Info. Response"
{
    Caption = 'Additional Information Response Data';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Source Record"; RecordId)
        {
            Caption = 'Source Record';
            DataClassification = CustomerContent;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Birthdate"; Date)
        {
            Caption = 'Birthdate';
            DataClassification = CustomerContent;
        }
        field(4; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(5; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(6; "Address"; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(7; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(8; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(9; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(10; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(11; "Delegated Consent DateTime"; DateTime)
        {
            Caption = 'Delegated Consent DateTime';
            DataClassification = CustomerContent;
        }
        field(12; "Delegated Consent E-Mail"; Boolean)
        {
            Caption = 'Delegated Consent Email';
            DataClassification = CustomerContent;
        }
        field(13; "Consent Digital Marketing"; Boolean)
        {
            Caption = 'Delegated Consent Digital Marketing';
            DataClassification = CustomerContent;
        }
        field(14; "Consent Customized Offers"; Boolean)
        {
            Caption = 'Delegated Consent Customized Offers';
            DataClassification = CustomerContent;
        }
        field(15; "Delegated Consent SMS"; Boolean)
        {
            Caption = 'Delegated Consent SMS';
            DataClassification = CustomerContent;
        }
        field(16; "First Name"; Text[30])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(17; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(18; "Work Address"; Text[100])
        {
            Caption = 'Work Address';
            DataClassification = CustomerContent;
        }
        field(19; "Work Address 2"; Text[50])
        {
            Caption = 'Work Address 2';
            DataClassification = CustomerContent;
        }
        field(20; "Work Address City"; Text[30])
        {
            Caption = 'Work Addr. City';
            DataClassification = CustomerContent;
        }
        field(21; "Work Addr. Country/Region Code"; Code[10])
        {
            Caption = 'Work Addr. Country/Region Code';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(22; "Work Address Post Code"; Code[20])
        {
            Caption = 'Work Addr. Post Code';
            DataClassification = CustomerContent;
        }
        field(23; "Alt. Address"; Text[100])
        {
            Caption = 'Alt. Address';
            DataClassification = CustomerContent;
        }
        field(24; "Alt. Address 2"; Text[50])
        {
            Caption = 'Alt. Address 2';
            DataClassification = CustomerContent;
        }
        field(25; "Alt. Address City"; Text[30])
        {
            Caption = 'Alt. Addr. City';
            DataClassification = CustomerContent;
        }
        field(26; "Alt. Addr. Country/Region Code"; Code[10])
        {
            Caption = 'Alt. Addr. Country/Region Code';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(27; "Alt. Address Post Code"; Code[20])
        {
            Caption = 'Alt. Addr. Post Code';
            DataClassification = CustomerContent;
        }
        field(28; Started; Boolean)
        {
            Caption = 'Started';
            DataClassification = CustomerContent;
        }
        field(29; Completed; Boolean)
        {
            Caption = 'Completed';
            DataClassification = CustomerContent;
        }
        field(30; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }
        field(31; "Signature Data"; Blob)
        {
            Caption = 'Signature Data';
            DataClassification = CustomerContent;
        }
        field(32; "Confirmed Flag"; Boolean)
        {
            Caption = 'Confirmed Flage';
            DataClassification = CustomerContent;
        }
        field(33; "Response Result"; Text[50])
        {
            Caption = 'Response Result';
            DataClassification = CustomerContent;
        }
        field(34; "Error Condition"; Text[50])
        {
            Caption = 'Error Condition';
            DataClassification = CustomerContent;
        }
        field(35; "Screen Timeout"; Boolean)
        {
            Caption = 'Screen Timeout';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Source Record")
        {
        }
    }
}
