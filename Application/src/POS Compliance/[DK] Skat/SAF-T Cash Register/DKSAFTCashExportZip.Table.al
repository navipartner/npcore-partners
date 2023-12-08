table 6150750 "NPR DK SAF-T Cash Export Zip"
{
    Access = Internal;
    Caption = 'SAF-T Cash Export Zip';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DK SAF-T Cash Export Zips";
    LookupPageId = "NPR DK SAF-T Cash Export Zips";

    fields
    {
        field(1; "Export ID"; Integer)
        {
            Caption = 'Export ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Zip No."; Integer)
        {
            Caption = 'ZIP No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "SAF-T File"; Blob)
        {
            Caption = 'SAF-T File';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Export ID", "Zip No.")
        {
            Clustered = true;
        }
    }
}
