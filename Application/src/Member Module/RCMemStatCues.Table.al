table 6059790 "NPR RC Mem. Stat. Cues"
{
    Access = Internal;
    Caption = 'RC Membership Statistics Cues';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Active Members"; Integer)
        {
            Caption = 'Active Members';
            DataClassification = CustomerContent;
        }
        field(20; "First Time Members"; Integer)
        {
            Caption = 'First Time Members';
            DataClassification = CustomerContent;
        }

        field(21; "First Time Members (%)"; Decimal)
        {
            Caption = 'First Time Members (%)';
            DataClassification = CustomerContent;
        }
        field(30; "Recurring Members"; Integer)
        {
            Caption = 'Recurring Members';
            DataClassification = CustomerContent;
        }
        field(31; "Recurring Members (%)"; Decimal)
        {
            Caption = 'Recurring Members (%)';
            DataClassification = CustomerContent;
        }
        field(40; "Future Timeslot"; Integer)
        {
            Caption = 'Future Timeslot';
            DataClassification = CustomerContent;
        }
        field(41; "Future Timeslot (%)"; Decimal)
        {
            Caption = 'Future Timeslot (%)';
            DataClassification = CustomerContent;
        }
        field(50; "No. of. Members compared LY"; Decimal)
        {
            Caption = 'No. of. Members compared LY (%)';
            DataClassification = CustomerContent;
        }
        field(60; "No. of. Members expire CM"; Integer)
        {
            Caption = 'No. of. Members expire CM';
            DataClassification = CustomerContent;
        }
        field(61; "No. of. Members expire CM (%)"; Decimal)
        {
            Caption = 'No. of. Members expire CM (%)';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }

    procedure CalculateCues()
    var
        MMMembershipStatistics: Record "NPR MM Membership Statistics";
        RefDate: Date;
    begin
        RefDate := WorkDate() - 1;
        if not MMMembershipStatistics.Get(RefDate) then
            exit;

        Rec."Active Members" := MMMembershipStatistics."First Time Members" + MMMembershipStatistics."Recurring Members";
        Rec."First Time Members" := MMMembershipStatistics."First Time Members";
        if Rec."Active Members" > 0 then
            Rec."First Time Members (%)" := Rec."First Time Members" / Rec."Active Members";
        Rec."Recurring Members" := MMMembershipStatistics."Recurring Members";
        if Rec."Recurring Members" > 0 then
            Rec."Recurring Members (%)" := Rec."Recurring Members" / Rec."Active Members";
        Rec."Future Timeslot" := MMMembershipStatistics."Future Members";
        if Rec."Active Members" > 0 then
            Rec."Future Timeslot (%)" := Rec."Future Timeslot" / Rec."Active Members";
        if (MMMembershipStatistics."First Time Members Last Year" + MMMembershipStatistics."Recurring Members Last Year") > 0 then
            Rec."No. of. Members compared LY" := (Rec."Active Members" / (MMMembershipStatistics."First Time Members Last Year" + MMMembershipStatistics."Recurring Members Last Year") - 1)
        Else
            Rec."No. of. Members compared LY" := 1;
        Rec."No. of. Members expire CM" := MMMembershipStatistics."No. of Members expire CM";
        if Rec."Active Members" > 0 then
            Rec."No. of. Members expire CM (%)" := Rec."No. of. Members expire CM" / Rec."Active Members";
    end;

    procedure ShowStatisticsRecord()
    var
        MMMembershipStatistics: Record "NPR MM Membership Statistics";
        RefDate: Date;
    begin
        RefDate := WorkDate() - 1;
        MMMembershipStatistics.SetRange("Reference Date", RefDate);
        Page.RunModal(0, MMMembershipStatistics);
    end;
}
