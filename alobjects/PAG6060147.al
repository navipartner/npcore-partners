page 6060147 "RC Membership Burndown Setup"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016

    Caption = 'Membership Burndown Setup';
    SourceTable = "RC Membership Burndown Setup";

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

