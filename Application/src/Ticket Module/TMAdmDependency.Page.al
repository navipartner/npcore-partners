page 6014471 "NPR TM Adm. Dependency"
{
    PageType = List;
    ApplicationArea = NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM Adm. Dependency";
    Caption = 'Admission Dependency Rule';
    Editable = false;
    CardPageId = "NPR TM Adm. Dependency Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Dependency Code"; "Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }

                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
}