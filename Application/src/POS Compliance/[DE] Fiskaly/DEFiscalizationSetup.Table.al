table 6150916 "NPR DE Fiscalization Setup"
{
    Access = Internal;
    Caption = 'DE Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DE Fiscalization Setup";
    LookupPageId = "NPR DE Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable DE Fiscal"; Boolean)
        {
            Caption = 'Enable DE Fiscalization';
            DataClassification = CustomerContent;
        }
    }
}