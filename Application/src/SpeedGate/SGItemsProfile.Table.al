table 6151133 "NPR SG ItemsProfile"
{
    DataClassification = CustomerContent;
    Access = Internal;

    LookupPageId = "NPR SG ItemsProfiles";

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Main; Code, Description)
        {
            Caption = 'Additional items profile for Speedgate';
        }
    }

    trigger OnDelete()
    var
        ItemsProfileLine: Record "NPR SG ItemsProfileLine";
    begin
        ItemsProfileLine.SetFilter(Code, '=%1', Rec.Code);
        ItemsProfileLine.DeleteAll();
    end;

}