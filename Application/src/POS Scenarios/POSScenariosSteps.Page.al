page 6150730 "NPR POS Scenarios Steps"
{
    Extensible = False;

    Caption = 'POS Scenarios Steps';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Sales Workflow Step";
    SourceTableView = SORTING("Sequence No.")
                      ORDER(Ascending);
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Scenarios have been moved to hardcoded codeunit calls for internal steps, and event subscribers for PTE steps';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Set Code"; Rec."Set Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Set Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Code"; Rec."Workflow Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Function"; Rec."Subscriber Function")
                {

                    ToolTip = 'Specifies the value of the Subscriber Function field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Sequence No."; Rec."Sequence No.")
                {

                    ToolTip = 'Specifies the value of the Sequence No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        HideInternalSteps(Rec);
    end;

    local procedure HideInternalSteps(var POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
        WorkflowStepSubscriberCodeunitsFilter: Text;
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('posLifeCycleEventsWorkflowsEnabled_v2') then
            exit;

        if not POSSalesWorkflow.Get(POSSalesWorkflowStep."Workflow Code") then
            exit;

        WorkflowStepSubscriberCodeunitsFilter := POSSalesWorkflow.GetWorkflowStepSubscriberCodeunitsFilter(false);
        if WorkflowStepSubscriberCodeunitsFilter = '' then
            exit;

        POSSalesWorkflowStep.SetFilter("Subscriber Codeunit ID", WorkflowStepSubscriberCodeunitsFilter);
    end;
}

