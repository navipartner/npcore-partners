codeunit 6014435 "NPR Credit Sale Post-Process"
{
    Access = Internal;
    TableNo = "NPR POS Sale";

    trigger OnRun()
    begin
        case FunctionToRun of
            FunctionToRun::"Invoke OnFinishCreditSale Subsribers":
                begin
                    OnFinishCreditSale(POSSalesWorkflowStepGlobal, Rec);
                end;
        end;
    end;

    procedure SetInvokeOnFinishCreditSaleSubsribers(POSSalesWorkflowStepIn: Record "NPR POS Sales Workflow Step")
    begin
        FunctionToRun := FunctionToRun::"Invoke OnFinishCreditSale Subsribers";
        POSSalesWorkflowStepGlobal := POSSalesWorkflowStepIn;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinishCreditSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
    end;

    var
        POSSalesWorkflowStepGlobal: Record "NPR POS Sales Workflow Step";
        FunctionToRun: Enum "NPR Sales Doc. FunctionToRun";
}
