table 6150859 "NPR MM POS Loyalty Profile"
{
    Access = Internal;
    Caption = 'POS Loyalty Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM POS Loyalty Profiles";
    DrillDownPageId = "NPR MM POS Loyalty Profiles";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Assign Loyalty On Sale"; Boolean)
        {
            Caption = 'Assign Loyalty On Sale';
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