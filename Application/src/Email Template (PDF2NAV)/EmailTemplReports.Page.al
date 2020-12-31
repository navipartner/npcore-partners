page 6059798 "NPR E-mail Templ. Reports"
{
    Caption = 'Additional E-mail Template Reports';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR E-mail Templ. Report";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                }
                field("Report Name"; "Report Name")
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

