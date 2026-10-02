table 6150750 "NPR DK SAF-T Cash Export Zip"
{
    Access = Internal;
    Caption = 'SAF-T Cash Export Zip';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-09-29';
    ObsoleteReason = 'The SAF-T file is delivered as one XML file stored on the export line, not as a ZIP archive.';

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
