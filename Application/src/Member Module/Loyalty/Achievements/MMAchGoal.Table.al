table 6150763 "NPR MM AchGoal"
{
    Access = Internal;

    Caption = 'Membership Achievement Goal';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(15; Activated; Boolean)
        {
            Caption = 'Activated';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if (Rec.Activated) then begin
                    Rec.TestField(RewardCode);
                    Rec.TestField(RewardThreshold);
                    Rec.TestField(CommunityCode);
                    Rec.TestField(MembershipCode);
                end

            end;
        }
        field(30; EnableFromDate; Date)
        {
            Caption = 'Enable From Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }

        field(32; EnableUntilDate; Date)
        {
            Caption = 'Enable Until Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }

        field(40; RewardCode; Code[20])
        {
            Caption = 'Reward Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchReward";
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }

        field(45; RewardThreshold; Integer)
        {
            Caption = 'Reward Threshold';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }

        field(47; RequiresAchievement; Code[20])
        {
            Caption = 'Requires Achievement';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM AchGoal";
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }
        field(50; GroupBy; Code[10])
        {
            Caption = 'Group By';
            DataClassification = CustomerContent;
        }
        field(60; CommunityCode; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }
        field(65; MembershipCode; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
            trigger OnValidate()
            begin
                ValidateNotActivated();
            end;
        }

        field(200; MembershipEntryNoFilter; Integer)
        {
            Caption = 'Membership Entry No. Flow Filter';
            FieldClass = FlowFilter;
        }
        field(210; ActivityCount; Integer)
        {
            Caption = 'Activity Count';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR MM AchActivityEntry".ActivityWeight Where(MembershipEntryNo = Field(MembershipEntryNoFilter), GoalCode = Field(Code)));
            Editable = false;
        }
        field(220; AchievementAcquired; Boolean)
        {
            Caption = 'Achievement Acquired';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR MM Achievement" Where(MembershipEntryNo = Field(MembershipEntryNoFilter), GoalCode = Field(Code)));
            Editable = false;
        }
        field(230; RewardCollectedAt; Datetime)
        {
            Caption = 'Reward Collected At';
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR MM Achievement".RewardCollectedAt Where(MembershipEntryNo = Field(MembershipEntryNoFilter), GoalCode = Field(Code)));
            Editable = false;
        }

    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; GroupBy, RewardThreshold)
        {
        }
    }

    trigger OnDelete()
    var
        ConfirmDelete: Label 'Deleting a goal can not be undone. All related information will be deleted and it may take a while to complete. Do you want to continue?';
        MemberActivity: Record "NPR MM AchActivityEntry";
        Activity: Record "NPR MM AchActivity";
        Achievement: Record "NPR MM Achievement";

    begin
        if (not Confirm(ConfirmDelete, true)) then
            exit;

        ValidateNotActivated();

        Achievement.SetFilter(GoalCode, '=%1', Rec.Code);
        Achievement.DeleteAll();

        MemberActivity.SetFilter(GoalCode, '=%1', Rec.Code);
        MemberActivity.DeleteAll();

        Activity.SetFilter(GoalCode, '=%1', Rec.Code);
        Activity.DeleteAll(true);
    end;

    local procedure ValidateNotActivated()
    var
        NotActive: Label 'De-active goal %1 before changing goal properties.';
    begin
        if (Rec.Activated) then
            Error(NotActive, Rec.Code);
    end;


}