page 6150734 "NPR POS Scenarios Set Entries"
{

    Caption = 'POS Scenarios set entries';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Sales WF Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Workflow Description"; "Workflow Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Description field';
                }
                field(Control6014406; "Workflow Steps")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Workflow Steps field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("POS Scenarios Steps")
            {
                Caption = 'POS Scenarios Steps';
                Image = List;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Scenarios Steps";
                RunPageLink = "Set Code" = FIELD("Set Code"),
                              "Workflow Code" = FIELD("Workflow Code");
                ApplicationArea = All;
                ToolTip = 'Executes the Workflow Steps action';
            }
        }
    }
}

