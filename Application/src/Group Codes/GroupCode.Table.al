table 6059803 "NPR Group Code"
{
    Access = Internal;
    Caption = 'Group Code';
    LookupPageId = "NPR Group Codes";
    DrillDownPageID = "NPR Group Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}