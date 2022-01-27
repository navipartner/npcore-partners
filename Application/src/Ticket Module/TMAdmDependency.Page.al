page 6014471 "NPR TM Adm. Dependency"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM Adm. Dependency";
    Caption = 'Admission Dependency Rule';
    Editable = false;
    CardPageId = "NPR TM Adm. Dependency Card";
    ContextSensitiveHelpPage = 'display/ENT/Ticket+Admission+Dependencies';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Dependency Code"; Rec."Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Dependency Code field';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
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
