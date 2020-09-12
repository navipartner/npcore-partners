page 6150734 "NPR POS Sales WF Set Entries"
{
    // NPR5.45/MHA /20180820  CASE 321266 Object created

    Caption = 'POS Sales Workflows';
    PageType = ListPart;
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
                }
                field("Workflow Description"; "Workflow Description")
                {
                    ApplicationArea = All;
                }
                field(Control6014406; "Workflow Steps")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Workflow Steps")
            {
                Caption = 'Workflow Steps';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Sales WF Steps";
                RunPageLink = "Set Code" = FIELD("Set Code"),
                              "Workflow Code" = FIELD("Workflow Code");
                ApplicationArea = All;
            }
        }
    }
}

