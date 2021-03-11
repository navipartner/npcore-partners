table 6014512 "NPR SMS Recipient Group"
{
    Caption = 'SMS Recipient Group';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SMS Recipient Groups";
    LookupPageId = "NPR SMS Recipient Groups";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}
