page 6014603 "Touch Screen - Meta F. Lookup"
{
    Caption = 'Touch Screen - Meta Func. Lookup';
    PageType = List;
    SourceTable = "Touch Screen - Meta Functions";

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

