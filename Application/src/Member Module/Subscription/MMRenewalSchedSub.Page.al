page 6185098 "NPR MM Renewal Sched Sub"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR MM Renewal Sched Line";
    Extensible = false;
    Caption = 'Renewal Schedule Subform';
    DelayedInsert = true;
    SourceTableView = SORTING("Schedule Code", "Date Formula Duration (Days)") ORDER(Ascending);


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Date Formula"; Rec."Date Formula")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the date formula of the withdrawal schedule line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }
}