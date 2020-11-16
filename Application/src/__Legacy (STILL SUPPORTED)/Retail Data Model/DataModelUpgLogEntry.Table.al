table 6150699 "NPR Data Model Upg. Log Entry"
{
    Caption = 'Data Model Upgrade Log Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Data Model Build"; Integer)
        {
            Caption = 'Data Model Build';
            DataClassification = CustomerContent;
        }
        field(10; "Text"; Text[100])
        {
            Caption = 'Text';
            DataClassification = CustomerContent;
        }
        field(11; "User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(12; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
            DataClassification = CustomerContent;
        }
        field(13; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Message,Warning,Error';
            OptionMembers = Message,Warning,Error;
        }
        field(14; Indent; Integer)
        {
            Caption = 'Indent';
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

