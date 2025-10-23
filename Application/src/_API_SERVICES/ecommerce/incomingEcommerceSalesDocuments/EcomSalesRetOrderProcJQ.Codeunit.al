#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248613 "NPR EcomSalesRetOrderProcJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessSalesOrders(Rec);
    end;

    local procedure ProcessSalesOrders(var JobQueueEntry: Record "Job Queue Entry")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
        SalesOrderNoTextFilter: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");

        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::"Return Order");
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetFilter("Process Retry Count", '<%1', IncEcomSalesDocSetup."Max Doc Process Retry Count");
        if JQParamStrMgt.ContainsParam(ParamSalesReturnOrderNo()) then begin
            SalesOrderNoTextFilter := JQParamStrMgt.GetParamValueAsText(ParamSalesReturnOrderNo());
            if SalesOrderNoTextFilter <> '' then
                EcomSalesHeader.SetFilter("External No.", SalesOrderNoTextFilter);
        end;

        if not EcomSalesHeader.FindSet() then
            exit;

        repeat
            Clear(EcomSalesDocProcess);
            EcomSalesDocProcess.SetUpdateRetryCount(true);
            EcomSalesDocProcess.Run(EcomSalesHeader);
        until EcomSalesHeader.Next() = 0;
    end;

    internal procedure ParamSalesReturnOrderNo(): Text
    begin
        exit('salesReturnOrderNo');
    end;
}
#endif