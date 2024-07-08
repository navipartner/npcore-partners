table 6151209 "NPR NpCs Open. Hour Set"
{
    Access = Internal;
    Caption = 'Collect Store Opening Hour Set';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpCs Open. Hour Sets";
    LookupPageID = "NPR NpCs Open. Hour Sets";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
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

