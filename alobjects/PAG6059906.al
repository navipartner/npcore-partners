page 6059906 "Task Worker Group"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    Caption = 'Task Worker Group';
    PageType = List;
    SourceTable = "Task Worker Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Language ID"; "Language ID")
                {
                    ApplicationArea = All;
                }
                field("Abbreviated Name"; "Abbreviated Name")
                {
                    ApplicationArea = All;
                }
                field("Min Interval Between Check"; "Min Interval Between Check")
                {
                    ApplicationArea = All;
                }
                field("Max Interval Between Check"; "Max Interval Between Check")
                {
                    ApplicationArea = All;
                }
                field(Default; Default)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

