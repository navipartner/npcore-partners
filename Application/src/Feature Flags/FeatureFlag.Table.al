table 6060033 "NPR Feature Flag"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Feature Flag';
    DrillDownPageId = "NPR Feature Flags";
    LookupPageId = "NPR Feature Flags";
    DataPerCompany = false;
    fields
    {
        field(1; Name; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';

        }
        field(10; Value; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';

        }
        field(20; "Variation ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Variation ID';

        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }



}