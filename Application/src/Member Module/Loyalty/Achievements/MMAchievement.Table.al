table 6150767 "NPR MM Achievement"
{
    Access = Internal;

    Caption = 'Membership Achievement';
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;

        }
        field(10; MembershipEntryNo; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(40; GoalCode; Code[20])
        {
            Caption = 'Goal Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchGoal";
        }
        field(50; RewardCode; Code[20])
        {
            Caption = 'Reward Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchReward";
        }
        field(52; RewardId; Code[20])
        {
            Caption = 'Reward Id';
            DataClassification = CustomerContent;
        }
        field(55; RewardCollectedAt; DateTime)
        {
            Caption = 'Reward Collected At';
            DataClassification = CustomerContent;
        }
        field(60; AchievedAt; DateTime)
        {
            Caption = 'Achieved At';
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
        }
    }

}