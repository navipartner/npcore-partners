#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248475 "NPR IncEcomSalesRetOrderProcJQ"
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
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        IncEcomSalesDocProcess: Codeunit "NPR IncEcomSalesDocProcess";
        SalesOrderNoTextFilter: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");

        IncEcomSalesHeader.Reset();
        IncEcomSalesHeader.SetRange("Document Type", IncEcomSalesHeader."Document Type"::"Return Order");
        IncEcomSalesHeader.SetRange("Creation Status", IncEcomSalesHeader."Creation Status"::Pending);
        IncEcomSalesHeader.SetFilter("Process Retry Count", '<%1', IncEcomSalesDocSetup."Max Doc Process Retry Count");
        if JQParamStrMgt.ContainsParam(ParamSalesReturnOrderNo()) then begin
            SalesOrderNoTextFilter := JQParamStrMgt.GetParamValueAsText(ParamSalesReturnOrderNo());
            if SalesOrderNoTextFilter <> '' then
                IncEcomSalesHeader.SetFilter("External No.", SalesOrderNoTextFilter);
        end;

        if not IncEcomSalesHeader.FindSet() then
            exit;

        repeat
            Clear(IncEcomSalesDocProcess);
            IncEcomSalesDocProcess.SetUpdateRetryCount(true);
            IncEcomSalesDocProcess.Run(IncEcomSalesHeader);
        until IncEcomSalesHeader.Next() = 0;
    end;

    internal procedure ParamSalesReturnOrderNo(): Text
    begin
        exit('salesReturnOrderNo');
    end;
}
#endif