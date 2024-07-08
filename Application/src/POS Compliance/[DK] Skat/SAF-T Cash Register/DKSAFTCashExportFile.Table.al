table 6150747 "NPR DK SAF-T Cash Export File"
{
    Access = Internal;
    Caption = 'SAF-T Cash Export File';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Export ID"; Integer)
        {
            Caption = 'Export ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "File No."; Integer)
        {
            Caption = 'File No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "File Name"; Text[512])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "SAF-T File"; Blob)
        {
            Caption = 'SAF-T File';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Export ID", "File No.")
        {
            Clustered = true;
        }
    }
}
