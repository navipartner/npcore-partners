page 6184492 "NPR Pepper Instances"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Instances';
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

                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Configuration Code"; Rec."Configuration Code")
                {

                    ToolTip = 'Specifies the value of the Configuration Code field';
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

                ToolTip = 'Executes the Terminals action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

