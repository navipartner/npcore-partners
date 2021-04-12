page 6184492 "NPR Pepper Instances"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Instances';
    PageType = List;
    SourceTable = "NPR Pepper Instance";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Configuration Code"; Rec."Configuration Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Configuration Code field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Terminals action';
            }
        }
    }
}

