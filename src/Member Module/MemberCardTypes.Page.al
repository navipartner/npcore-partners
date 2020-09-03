page 6059771 "NPR Member Card Types"
{
    Caption = 'Point Card - Types';
    CardPageID = "NPR Member Card Types Card";
    PageType = List;
    SourceTable = "NPR Member Card Types";

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
            }
        }
    }

    actions
    {
    }
}

