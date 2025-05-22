table 6151183 "NPR SG Scanner Category"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'SpeedGate Category';
    LookupPageId = "NPR SG Scanner Categories";

    fields
    {
        field(1; CategoryCode; Code[10])
        {
            Caption = 'Categroy Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; CategoryDescription; Text[100])
        {
            Caption = 'Category Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; CategoryCode)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; CategoryCode, CategoryDescription)
        {
        }
    }
}