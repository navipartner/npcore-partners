table 6151231 "NPR MM Renewal Sched Hdr"
{
    DataClassification = CustomerContent;
    Caption = 'Renewal Schedule Header';
    Access = Internal;
    LookupPageId = "NPR MM Renewal Sched List";
    DrillDownPageId = "NPR MM Renewal Sched List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(2; Description; Text[100])
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
    trigger OnDelete()
    begin
        DeleteLines();
    end;

    local procedure DeleteLines()
    var
        RenewalSchedLine: Record "NPR MM Renewal Sched Line";
    begin
        RenewalSchedLine.Reset();
        RenewalSchedLine.SetRange("Schedule Code", Rec.Code);
        if not RenewalSchedLine.IsEmpty then
            RenewalSchedLine.DeleteAll(true);
    end;
}