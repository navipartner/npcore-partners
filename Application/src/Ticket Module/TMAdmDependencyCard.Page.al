page 6014484 "NPR TM Adm. Dependency Card"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR TM Adm. Dependency";
    Caption = 'Admission Dependency Card';

    layout
    {
        area(Content)
        {
            Group(GroupName)
            {
                Caption = 'Admission Dependency Rule';

                field("Dependency Code"; "Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }

                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
            part(Lines; "NPR TM Adm. Dependency List")
            {
                Caption = 'Rules';
                ApplicationArea = NPRTicketAdvanced;
                SubPageLink = "Dependency Code" = field("Dependency Code");
                SubPageView = sorting("Dependency Code", "Rule Sequence");
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

    var

}