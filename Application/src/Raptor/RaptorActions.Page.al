page 6151493 "NPR Raptor Actions"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.54/ALPO/20200302 CASE 355871 Possibility to specify user identifier parameter name

    Caption = 'Raptor Actions';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Raptor Module Code"; "Raptor Module Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Raptor Module Code field';
                }
                field("Raptor Module API Req. String"; "Raptor Module API Req. String")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Raptor Module API Req. String field';
                }
                field("Data Type Description"; "Data Type Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type Description field';
                }
                field("Number of Entries to Return"; "Number of Entries to Return")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number of Entries to Return field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field("User Identifier Param. Name"; "User Identifier Param. Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the User Identifier Param. Name field';
                }
                field("Show Date-Time Created"; "Show Date-Time Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Date-Time Created field';
                }
                field("Show Priority"; "Show Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Priority field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Add Default Actions action';

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

