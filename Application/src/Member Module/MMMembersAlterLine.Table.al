table 6059872 "NPR MM Members. Alter. Line"
{
    Access = Internal;

    Caption = 'MMembership Alteration Line';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR MM Members. Alter. Lines";

    fields
    {
        field(1; "Group Code"; Code[10])
        {
            Caption = 'Group';
            TableRelation = "NPR MM Members. Alter. Group".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Alteration Id"; Guid)
        {
            Caption = 'Alteration Id';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Group Code", "Alteration Id")
        {
            Clustered = true;
        }
    }
}
