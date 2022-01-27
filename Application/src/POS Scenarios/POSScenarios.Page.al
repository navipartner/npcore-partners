page 6150729 "NPR POS Scenarios"
{
    Extensible = False;

    Caption = 'POS Scenarios';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Sales Workflow";
    UsageCategory = Administration;
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
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Publisher Codeunit ID"; Rec."Publisher Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Publisher Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Publisher Codeunit Name"; Rec."Publisher Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Publisher Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Publisher Function"; Rec."Publisher Function")
                {

                    ToolTip = 'Specifies the value of the Publisher Function field';
                    ApplicationArea = NPRRetail;
                }
                field(Control6014410; Rec."Workflow Steps")
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
        area(navigation)
        {
            action("POS Scenario Steps")
            {
                Caption = 'POS Scenario Steps';
                Image = List;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Scenarios Steps";
                RunPageLink = "Set Code" = CONST(''),
                              "Workflow Code" = FIELD(Code);

                ToolTip = 'Executes the Workflow Steps action';
                ApplicationArea = NPRRetail;
            }
            action("Initiate Workflow Steps")
            {
                Caption = 'Initiate Workflow Steps';
                Ellipsis = true;
                Image = AddAction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Initiate Workflow Steps action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    StepsInitiated: Integer;
                begin
                    CurrPage.SetSelectionFilter(POSSalesWorkflow);
                    if POSSalesWorkflow.FindSet() then
                        repeat
                            StepsInitiated += POSSalesWorkflow.InitPOSSalesWorkflowSteps();
                        until POSSalesWorkflow.Next() = 0;

                    Message(Text000, StepsInitiated);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnDiscoverPOSSalesWorkflows();
    end;

    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
        Text000: Label '%1 Workflow Steps initiated';
}

