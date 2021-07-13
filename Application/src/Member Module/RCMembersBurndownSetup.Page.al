page 6060147 "NPR RC Members. Burndown Setup"
{
    UsageCategory = None;
    Caption = 'Membership Burndown Setup';
    SourceTable = "NPR RC Members. Burndown Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Use Work Date as Base"; Rec."Use Work Date as Base")
                {

                    ToolTip = 'Specifies the value of the Use Work Date as Base field';
                    ApplicationArea = NPRRetail;
                }
                field("StartDate Offset"; Rec."StartDate Offset")
                {

                    ToolTip = 'Specifies the value of the StartDate Offset field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

