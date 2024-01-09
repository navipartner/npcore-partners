table 6150764 "NPR MM AchActivityEntry"
{
    Access = Internal;

    Caption = 'Membership Achievement Activity Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(10; MembershipEntryNo; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(30; ActivityCode; Code[20])
        {
            Caption = 'Activity Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchActivity";
        }
        field(35; ActivityDescription; Code[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; GoalCode; Code[20])
        {
            Caption = 'Goal Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchGoal";
        }
        field(60; ActivityDateTime; DateTime)
        {
            Caption = 'Activity Datetime';
            DataClassification = CustomerContent;
        }

        field(70; ActivityWeight; Integer)
        {
            Caption = 'Activity Weight';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(key2; MembershipEntryNo, GoalCode)
        {
            SumIndexFields = ActivityWeight;
        }
    }
}