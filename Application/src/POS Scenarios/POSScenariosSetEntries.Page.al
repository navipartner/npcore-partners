page 6150734 "NPR POS Scenarios Set Entries"
{
    Extensible = False;
    Caption = 'POS Scenarios Set Entries';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Sales WF Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Workflow Code"; Rec."Workflow Code")
                {

                    ToolTip = 'Specifies the value of the Workflow Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Description"; Rec."Workflow Description")
                {

                    ToolTip = 'Specifies the value of the Workflow Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Control6014406; Rec."Workflow Steps")
                {

                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Workflow Steps field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Workflow Steps action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

