codeunit 6014435 "NPR Credit Sale Post-Process"
{
    Access = Internal;
    TableNo = "NPR POS Sale";

    trigger OnRun()
    begin
        case FunctionToRun of
            FunctionToRun::"Invoke OnFinishCreditSale Subsribers":
                OnFinishCreditSale(POSSalesWorkflowStepGlobal, Rec);
            FunctionToRun::Default:
                begin
                    POSOnCreditSale(Rec);
                    OnAfterFinishCreditSale(Rec);
                end;
        end;
    end;

    local procedure POSOnCreditSale(Rec: Record "NPR POS Sale")
    var
        TempExecutionOrderOnSale: Record "NPR Execution Order On Sale" temporary;
    begin
        Commit();

        InitializeExecutionOrder(TempExecutionOrderOnSale);

        if TempExecutionOrderOnSale.FindSet(false) then
            repeat
                if not CODEUNIT.Run(TempExecutionOrderOnSale."Codeunit ID", Rec) then
                    Message(TempExecutionOrderOnSale."Error Msg", GetLastErrorText());
            until TempExecutionOrderOnSale.Next() = 0;
    end;

    local procedure InitializeExecutionOrder(var TempExecutionOrderOnSale: Record "NPR Execution Order On Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
        BinEjectError: Label 'The error occurred during the Bin Ejection: %1';
        IsHandled: Boolean;
    begin
        // Clear existing data in the temporary table
        if not TempExecutionOrderOnSale.IsEmpty() then
            TempExecutionOrderOnSale.DeleteAll();

        IsHandled := false;
        OnBeforeInsertExecutionOrderOnCreditSale(TempExecutionOrderOnSale, IsHandled);
        if IsHandled then
            exit;

        POSSale.InsertExecutionOrder(TempExecutionOrderOnSale, Codeunit::"NPR POS Bin Eject OnCreditSale", 10, BinEjectError);

        OnAfterInsertExecutionOrderOnCreditSale(TempExecutionOrderOnSale);
    end;

    [Obsolete('Use OnAfterFinishCreditSale in cdu 6014435 "NPR Credit Sale Post-Process"', 'NPR27.0')]
    procedure SetInvokeOnFinishCreditSaleSubsribers(POSSalesWorkflowStepIn: Record "NPR POS Sales Workflow Step")
    begin
        FunctionToRun := FunctionToRun::"Invoke OnFinishCreditSale Subsribers";
        POSSalesWorkflowStepGlobal := POSSalesWorkflowStepIn;
    end;

    [Obsolete('Use OnAfterFinishCreditSale in cdu 6014435 "NPR Credit Sale Post-Process"', 'NPR27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnFinishCreditSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinishCreditSale(SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertExecutionOrderOnCreditSale(var TempExecutionOrderOnSale: Record "NPR Execution Order On Sale"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertExecutionOrderOnCreditSale(var TempExecutionOrderOnSale: Record "NPR Execution Order On Sale")
    begin
    end;


    var
        POSSalesWorkflowStepGlobal: Record "NPR POS Sales Workflow Step";
        FunctionToRun: Enum "NPR Sales Doc. FunctionToRun";
}
