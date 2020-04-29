table 6150699 "Data Model Upgrade Log Entry"
{
    Caption = 'Data Model Upgrade Log Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Data Model Build";Integer)
        {
            Caption = 'Data Model Build';
        }
        field(10;Text;Text[100])
        {
            Caption = 'Text';
        }
        field(11;"User ID";Text[50])
        {
            Caption = 'User ID';
        }
        field(12;"Date and Time";DateTime)
        {
            Caption = 'Date and Time';
        }
        field(13;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Message,Warning,Error';
            OptionMembers = Message,Warning,Error;
        }
        field(14;Indent;Integer)
        {
            Caption = 'Indent';
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

