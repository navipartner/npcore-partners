page 6184492 "NPR Pepper Instances"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Instances';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/pepper_terminal/';
    PageType = List;
    SourceTable = "NPR Pepper Instance";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {

                    ToolTip = 'Specifies the unique identifier of the Pepper Instance';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Pepper Instance';
                    ApplicationArea = NPRRetail;
                }
                field("Configuration Code"; Rec."Configuration Code")
                {

                    ToolTip = 'Specifies the code for the configuration associated with the Pepper Instance';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Terminals)
            {
                Caption = 'Terminals';
                Image = MiniForm;
                RunObject = Page "NPR Pepper Terminal List";
                RunPageLink = "Instance ID" = FIELD(ID);
                RunPageView = SORTING(Code)
                              ORDER(Ascending);

                ToolTip = 'Opens the list of terminals associated with the Pepper Instance';
                ApplicationArea = NPRRetail;
            }
        }
    }
}