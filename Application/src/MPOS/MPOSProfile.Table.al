table 6150657 "NPR MPOS Profile"
{
    Access = Internal;
    Caption = 'MPOS Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR MPOS Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Ticket Admission Web Url"; Text[250])
        {
            Caption = 'Ticket Admission Web Url';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
