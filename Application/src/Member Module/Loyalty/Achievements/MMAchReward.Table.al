table 6150769 "NPR MM AchReward"
{
    Access = Internal;

    Caption = 'Membership Achievement Rewards';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; RewardType; Option)
        {
            Caption = 'Reward Type';
            DataClassification = CustomerContent;
            OptionMembers = NO_REWARD,COUPON;
            OptionCaption = 'No Reward,Coupon';
        }
        field(20; CouponType; Code[10])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type" where("Issue Coupon Module" = FILTER('MEMBER-ACHIEVEMENT'));
        }
        field(30; CollectWithin; DateFormula)
        {
            Caption = 'Collect Within';
            DataClassification = CustomerContent;
        }
        field(40; NotificationCode; Code[10])
        {
            Caption = 'Notification Setup Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Notific. Setup" where(type = const(ACHIEVEMENT));
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