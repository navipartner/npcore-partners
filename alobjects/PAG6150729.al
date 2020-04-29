page 6150729 "POS Sales Workflows"
{
    // NPR5.39/MHA /20180202  CASE 302779 Object created - POS Workflow
    // NPR5.45/MHA /20180820  CASE 321266 Update Link on Action "Workflow Steps" to consider new Primary Key

    Caption = 'POS Sales Workflows';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "POS Sales Workflow";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Publisher Codeunit ID";"Publisher Codeunit ID")
                {
                }
                field("Publisher Codeunit Name";"Publisher Codeunit Name")
                {
                }
                field("Publisher Function";"Publisher Function")
                {
                }
                field(Control6014410;"Workflow Steps")
                {
                    ShowCaption = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Sales Workflow Steps";
                RunPageLink = "Set Code"=CONST(''),
                              "Workflow Code"=FIELD(Code);
            }
            action("Initiate Workflow Steps")
            {
                Caption = 'Initiate Workflow Steps';
                Ellipsis = true;
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    StepsInitiated: Integer;
                begin
                    CurrPage.SetSelectionFilter(POSSalesWorkflow);
                    if POSSalesWorkflow.FindSet then
                      repeat
                        StepsInitiated += POSSalesWorkflow.InitPOSSalesWorkflowSteps();
                      until POSSalesWorkflow.Next = 0;

                    Message(Text000,StepsInitiated);
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
        POSSalesWorkflow: Record "POS Sales Workflow";
}

