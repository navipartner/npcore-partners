page 6059798 "NPR E-mail Templ. Reports"
{
    Extensible = False;
    Caption = 'Additional E-mail Template Reports';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR E-mail Templ. Report";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report ID"; Rec."Report ID")
                {

                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Filename; Rec.Filename)
                {

                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRRetail;
                }
                field("Report Name"; Rec."Report Name")
                {

                    ToolTip = 'Specifies the value of the Report Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

