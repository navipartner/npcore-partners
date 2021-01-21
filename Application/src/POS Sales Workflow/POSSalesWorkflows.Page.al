page 6150729 "NPR POS Sales Workflows"
{
    // NPR5.39/MHA /20180202  CASE 302779 Object created - POS Workflow
    // NPR5.45/MHA /20180820  CASE 321266 Update Link on Action "Workflow Steps" to consider new Primary Key

    Caption = 'POS Sales Workflows';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Sales Workflow";
    UsageCategory = Administration;
    ApplicationArea = All;

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
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Publisher Codeunit ID"; "Publisher Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Publisher Codeunit ID field';
                }
                field("Publisher Codeunit Name"; "Publisher Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Publisher Codeunit Name field';
                }
                field("Publisher Function"; "Publisher Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Publisher Function field';
                }
                field(Control6014410; "Workflow Steps")
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
        area(navigation)
        {
            action("Workflow Steps")
            {
                Caption = 'Workflow Steps';
                Image = List;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Sales WF Steps";
                RunPageLink = "Set Code" = CONST(''),
                              "Workflow Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Workflow Steps action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Initiate Workflow Steps action';

                trigger OnAction()
                var
                    StepsInitiated: Integer;
                begin
                    CurrPage.SetSelectionFilter(POSSalesWorkflow);
                    if POSSalesWorkflow.FindSet then
                        repeat
                            StepsInitiated += POSSalesWorkflow.InitPOSSalesWorkflowSteps();
                        until POSSalesWorkflow.Next = 0;

                    Message(Text000, StepsInitiated);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        OnDiscoverPOSSalesWorkflows();
    end;

    var
        Text000: Label '%1 Workflow Steps initiated';
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
}

