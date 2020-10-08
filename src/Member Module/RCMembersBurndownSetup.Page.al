page 6060147 "NPR RC Members. Burndown Setup"
{

    Caption = 'Membership Burndown Setup';
    SourceTable = "NPR RC Members. Burndown Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Use Work Date as Base"; "Use Work Date as Base")
                {
                    ApplicationArea = All;
                }
                field("StartDate Offset"; "StartDate Offset")
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

