page 6151395 "NPR CS Counting Supervisor"
{
    // NPR5.53/CLVA  /20191203  CASE 375919 Object created - NP Capture Service

    Caption = 'CS Counting Supervisor';
    PageType = List;
    SourceTable = "NPR CS Counting Supervisor";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Full Name"; "Full Name")
                {
                    ApplicationArea = All;
                }
                field(Pin; Pin)
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

