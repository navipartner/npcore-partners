page 6014599 "Connection Profiles"
{
    Caption = 'Connection Profiles';
    PageType = List;
    SourceTable = "Connection Profile";

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
                field("Hosting type"; "Hosting type")
                {
                    ApplicationArea = All;
                }
                field("Credit Card Extension"; "Credit Card Extension")
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

