table 6150768 "NPR MM AchActivityCondition"
{
    Access = Internal;

    Caption = 'Membership Achievement Activity Conditions';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ActivityCode; Code[20])
        {
            Caption = 'ActivityCode';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchActivity";
        }

        field(5; ConditionName; Text[30])
        {
            Caption = 'Condition Name';
            DataClassification = CustomerContent;
        }

        field(10; ConditionValue; Text[30])
        {
            Caption = 'Condition Value';
            DataClassification = CustomerContent;
        }

        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ActivityCode, ConditionName)
        {
            Clustered = true;
        }
    }

}