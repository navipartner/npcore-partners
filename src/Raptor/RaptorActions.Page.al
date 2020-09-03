page 6151493 "NPR Raptor Actions"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.54/ALPO/20200302 CASE 355871 Possibility to specify user identifier parameter name

    Caption = 'Raptor Actions';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Raptor Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Raptor Module Code"; "Raptor Module Code")
                {
                    ApplicationArea = All;
                }
                field("Raptor Module API Req. String"; "Raptor Module API Req. String")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Data Type Description"; "Data Type Description")
                {
                    ApplicationArea = All;
                }
                field("Number of Entries to Return"; "Number of Entries to Return")
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("User Identifier Param. Name"; "User Identifier Param. Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Show Date-Time Created"; "Show Date-Time Created")
                {
                    ApplicationArea = All;
                }
                field("Show Priority"; "Show Priority")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(AddDefaultActions)
            {
                Caption = 'Add Default Actions';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RaptorManagement: Codeunit "NPR Raptor Management";
                begin
                    RaptorManagement.InitializeDefaultActions(true, false);
                end;
            }
        }
    }
}

