page 6151493 "NPR Raptor Actions"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.54/ALPO/20200302 CASE 355871 Possibility to specify user identifier parameter name

    Caption = 'Raptor Actions';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Raptor Action";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Raptor Module Code"; Rec."Raptor Module Code")
                {

                    ToolTip = 'Specifies the value of the Raptor Module Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Raptor Module API Req. String"; Rec."Raptor Module API Req. String")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Raptor Module API Req. String field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type Description"; Rec."Data Type Description")
                {

                    ToolTip = 'Specifies the value of the Data Type Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Number of Entries to Return"; Rec."Number of Entries to Return")
                {

                    ToolTip = 'Specifies the value of the Number of Entries to Return field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("User Identifier Param. Name"; Rec."User Identifier Param. Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the User Identifier Param. Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Date-Time Created"; Rec."Show Date-Time Created")
                {

                    ToolTip = 'Specifies the value of the Show Date-Time Created field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Priority"; Rec."Show Priority")
                {

                    ToolTip = 'Specifies the value of the Show Priority field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Add Default Actions action';
                ApplicationArea = NPRRetail;

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

