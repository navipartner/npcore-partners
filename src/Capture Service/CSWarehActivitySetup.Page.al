page 6151364 "NPR CS Wareh. Activity Setup"
{
    // NPR5.55/ALPO/20200729 CASE 404663 Possibility to use vendor item number & description for CS warehouse activity lines

    Caption = 'CS Warehouse Activity Setup';
    DelayedInsert = true;
    PageType = ListPlus;
    SourceTable = "NPR CS Wareh. Activ. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = All;
                }
                field("Activity Type"; "Activity Type")
                {
                    ApplicationArea = All;
                }
                field("Show as Item No."; "Show as Item No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

