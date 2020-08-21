page 6151093 "Nc RapidConnect Endpoint Sub."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect

    Caption = 'Endpoints';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Nc RapidConnect Endpoint";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                }
                field("Endpoint Type"; "Endpoint Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Setup Summary"; "Setup Summary")
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

