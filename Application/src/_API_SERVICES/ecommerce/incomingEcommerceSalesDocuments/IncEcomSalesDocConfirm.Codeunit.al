#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248466 "NPR Inc Ecom Sales Doc Confirm"
{
    Access = Internal;
    TableNo = "NPR Inc Ecom Sales Header";

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ProcessConfirmLbl: Label 'Are you sure you want to process %1 external no. %2?', Comment = '%1 - document type %2 - external no';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ProcessConfirmLbl, Rec."Document Type", Rec."External No."), true) then
            exit;
        Process(Rec, _UpdateRetryCount, _ShowError);
    end;

    local procedure Process(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; UpdateRetryCount: Boolean; ShowError: Boolean)
    var
        IncEcomSalesDocProcess: Codeunit "NPR IncEcomSalesDocProcess";
    begin
        Clear(IncEcomSalesDocProcess);
        IncEcomSalesDocProcess.SetShowError(ShowError);
        IncEcomSalesDocProcess.SetUpdateRetryCount(UpdateRetryCount);
        IncEcomSalesDocProcess.Run(IncEcomSalesHeader);
    end;

    internal procedure SetUpdateRetryCount(UpdateRetryCount: Boolean)
    begin
        _UpdateRetryCount := UpdateRetryCount;
    end;

    internal procedure GetUpdateRetryCount() UpdateRetryCount: Boolean
    begin
        UpdateRetryCount := _UpdateRetryCount;
    end;

    internal procedure SetShowError(ShowError: Boolean)
    begin
        _ShowError := ShowError;
    end;

    internal procedure GetShowError() ShowError: Boolean
    begin
        ShowError := _ShowError;
    end;

    var
        _UpdateRetryCount: Boolean;
        _ShowError: Boolean;
}
#endif