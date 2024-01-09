table 6150766 "NPR MM AchActivity"
{
    Access = Internal;

    Caption = 'Membership Achievement Activities';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; GoalCode; Code[20])
        {
            Caption = 'Goal Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchGoal";
            NotBlank = true;
        }

        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(20; Activity; Enum "NPR MM AchActivity")
        {
            Caption = 'Activity';
            DataClassification = CustomerContent;
            InitValue = NOOP;
        }

        field(30; EnableFromDate; Date)
        {
            Caption = 'Enable From Date';
            DataClassification = CustomerContent;
        }

        field(32; EnableUntilDate; Date)
        {
            Caption = 'Enable Until Date';
            DataClassification = CustomerContent;
        }

        field(70; Weight; Integer)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
            InitValue = 1;
        }

    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        Condition: Record "NPR MM AchActivityCondition";
    begin
        Condition.SetFilter(ActivityCode, '=%1', Rec.Code);
        Condition.DeleteAll();
    end;
}