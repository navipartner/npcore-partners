page 6059798 "NPR E-mail Templ. Reports"
{
    Caption = 'Additional E-mail Template Reports';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR E-mail Templ. Report";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename field';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Name field';
                }
            }
        }
    }
}

