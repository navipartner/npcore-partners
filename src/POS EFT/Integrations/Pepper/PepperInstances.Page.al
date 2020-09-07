page 6184492 "NPR Pepper Instances"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Instances';
    PageType = List;
    SourceTable = "NPR Pepper Instance";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Configuration Code"; "Configuration Code")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;
            }
        }
    }
}

