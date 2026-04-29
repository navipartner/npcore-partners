#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248548 "NPR EcomCreateTicketProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";
    trigger OnRun()
    var
        EcomCreateTicketTryProcess: Codeunit "NPR EcomCreateTicketTryProcess";
    begin
        ClearLastError();
        Commit();

        Clear(EcomCreateTicketTryProcess);
        _Success := EcomCreateTicketTryProcess.Run(Rec);

        HandleResponse(_Success, Rec, _UpdateRetryCount);
        Commit();

        if (not _Success) and _ShowError then
            Error(GetLastErrorText);
    end;


    local procedure HandleResponse(Success: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; UpdateRetryCount: Boolean)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";

        UpdateErrStatus: Boolean;
        TicketEventId: Label 'NPR_API_Ecommerce_VirtualTicketCreationFailed', Locked = true;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();
        EcomSalesHeader2.ReadIsolation := EcomSalesHeader2.ReadIsolation::UpdLock;
        EcomSalesHeader2.Get(EcomSalesHeader."Entry No.");

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetRange(Captured, true);
        if not EcomSalesLine.FindSet() then
            exit;

        if UpdateRetryCount then
            EcomSalesHeader2."Ticket Retry Count" += 1;

        UpdateErrStatus := EcomSalesHeader2."Ticket Retry Count" >= IncEcomSalesDocSetup."Max Virtual Item Retry Count";

        repeat
            EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
            EcomSalesLine.Get(EcomSalesLine.RecordId);

            if not Success then begin
                EcomSalesLine."Virtual Item Process ErrMsg" := CopyStr(GetLastErrorText(), 1, MaxStrLen(EcomSalesLine."Virtual Item Process ErrMsg"));
                if UpdateErrStatus then
                    EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Error;
            end else begin
                EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
                EcomSalesLine."Virtual Item Process ErrMsg" := '';
            end;
            EcomSalesLine.Modify()
        until EcomSalesLine.Next() = 0;

        if not Success then begin
            EcomVirtualItemMgt.EmitError(GetLastErrorText(), TicketEventId);
            if UpdateErrStatus then
                EcomSalesHeader2."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Error
        end else
            EcomSalesHeader2."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Processed;

        UpdateVirtualItemDocStatus(EcomSalesHeader2);
        EcomSalesHeader2.Modify(true);

    end;

    internal procedure UpdateVirtualItemDocStatus(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomVirtualItemDocStatus: Enum "NPR EcomVirtualItemDocStatus";
    begin
        EcomVirtualItemDocStatus := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);
        if EcomVirtualItemDocStatus <> EcomSalesHeader."Virtual Items Process Status" then
            EcomSalesHeader."Virtual Items Process Status" := EcomVirtualItemDocStatus;
    end;

    internal procedure ShowRelatedTicketsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        EcomCreateTicketImpl.ShowRelatedTicketsAction(EcomSalesHeader);
    end;

    internal procedure ShowRelatedTicketsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        EcomCreateTicketImpl.ShowRelatedTicketsAction(EcomSalesLine);
    end;

    internal procedure SetUpdateRetryCount(UpdateRetryCount: Boolean)
    begin
        _UpdateRetryCount := UpdateRetryCount;
    end;

    internal procedure SetShowError(ShowError: Boolean)
    begin
        _ShowError := ShowError;
    end;

    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        _UpdateRetryCount: Boolean;
        _Success: Boolean;
        _ShowError: Boolean;
}
#endif
