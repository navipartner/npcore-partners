table 6014444 "Touch Screen - Meta F. Trans"
{
    Caption = 'Touch Screen - Meta F. Trans';
    DataCaptionFields = "Language Code", Description;
    ObsoleteState = Removed;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "On function call"; Code[50])
        {
            Caption = 'On function call';
            TableRelation = "NPR Touch Screen: Meta Func.".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            NotBlank = true;
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "On function call", "Language Code")
        {
        }
    }

    fieldgroups
    {
    }
}

