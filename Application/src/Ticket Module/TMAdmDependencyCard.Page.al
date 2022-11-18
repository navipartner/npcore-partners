﻿page 6014484 "NPR TM Adm. Dependency Card"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR TM Adm. Dependency";
    Caption = 'Admission Dependency Card';
    ContextSensitiveHelpPage = 'entertainment/ticket/explanation/AdmissionDependencyCode.html';

    layout
    {
        area(Content)
        {
            Group(GroupName)
            {
                Caption = 'Admission Dependency Rule';

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
