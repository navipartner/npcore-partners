#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248533 "NPR EcomCreateMMShipProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Line";

    trigger OnRun()
    var
        EcomCreateMMShipTryProcess: Codeunit "NPR EcomCreateMMShipTryProcess";
    begin
        ClearLastError();
        Commit();

        Clear(EcomCreateMMShipTryProcess);
        _Success := EcomCreateMMShipTryProcess.Run(Rec);

        HandleResponse(_Success, Rec, _UpdateRetryCount);
        Commit();

        if (not _Success) and _ShowError then
            Error(GetLastErrorText);
    end;

    internal procedure HandleResponse(Success: Boolean; var EcomSalesLine: Record "NPR Ecom Sales Line"; UpdateRetryCount: Boolean)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        UpdateErrStatus: Boolean;
        MembershipEventId: Label 'NPR_API_Ecommerce_VirtualMembershipCreationFailed', Locked = true;
        ErrorMessage: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        if UpdateRetryCount then
            EcomSalesLine."Virtual Item Proc Retry Count" += 1;

        if not Success then begin
            ErrorMessage := GetLastErrorText();
            UpdateErrStatus := EcomSalesLine."Virtual Item Proc Retry Count" >= IncEcomSalesDocSetup."Max Virtual Item Retry Count";
            SetSalesDocMembershipStatusError(EcomSalesLine, CopyStr(ErrorMessage, 1, MaxStrLen(EcomSalesLine."Virtual Item Process ErrMsg")), UpdateErrStatus);
            EmitError(ErrorMessage, MembershipEventId);
        end else
            SetSalesDocMembershipStatusCreated(EcomSalesLine);
    end;

    local procedure EmitError(ErrorTxt: Text; EventId: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ErrorText', ErrorTxt);
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());

        Session.LogMessage(EventId, ErrorTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure SetSalesDocMembershipStatusError(var EcomSalesLine: Record "NPR Ecom Sales Line"; ErrorMessage: Text[500]; UpdateStatus: Boolean)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        EcomVirtualItemDocStatus: Enum "NPR EcomVirtualItemDocStatus";
        Modi: Boolean;
    begin
        EcomSalesLine."Virtual Item Process ErrMsg" := ErrorMessage;
        if UpdateStatus then begin
            EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Error;
            EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
            if EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then begin
                if EcomSalesHeader."Membership Processing Status" <> EcomSalesHeader."Membership Processing Status"::Error then begin
                    EcomSalesHeader."Membership Processing Status" := EcomSalesHeader."Membership Processing Status"::Error;
                    Modi := true;
                end;

                EcomVirtualItemDocStatus := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);
                if EcomVirtualItemDocStatus <> EcomSalesHeader."Virtual Items Process Status" then begin
                    EcomSalesHeader."Virtual Items Process Status" := EcomVirtualItemDocStatus;
                    Modi := true;
                end;

                if Modi then
                    EcomSalesHeader.Modify(true);
            end;
        end;
        EcomSalesLine.Modify(true);
        EcomVirtualItemEvents.OnAfterSetSalesDocMembershipStatusError(EcomSalesLine, EcomSalesHeader, ErrorMessage, UpdateStatus);
    end;

    local procedure SetSalesDocMembershipStatusCreated(var CurrEcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
        EcomVirtualItemDocStatus: Enum "NPR EcomVirtualItemDocStatus";
        Modi: Boolean;
    begin
        CurrEcomSalesLine."Virtual Item Process Status" := CurrEcomSalesLine."Virtual Item Process Status"::Processed;
        CurrEcomSalesLine."Virtual Item Process ErrMsg" := '';
        CurrEcomSalesLine.Modify(true);

        // Check if any other membership lines for this document are still in error
        EcomSalesLine.Reset();
        EcomSalesLine.SetFilter(SystemId, '<>%1', CurrEcomSalesLine.SystemId);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetRange("Document Entry No.", CurrEcomSalesLine."Document Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::Error);
        if not EcomSalesLine.IsEmpty then
            exit;

        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
        if not EcomSalesHeader.Get(CurrEcomSalesLine."Document Entry No.") then
            exit;

        // Check if any membership lines are still pending
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
        if not EcomSalesLine.IsEmpty then begin
            Modi := EcomSalesHeader."Membership Processing Status" <> EcomSalesHeader."Membership Processing Status"::"Partially Processed";
            if Modi then
                EcomSalesHeader."Membership Processing Status" := EcomSalesHeader."Membership Processing Status"::"Partially Processed";
        end else begin
            Modi := EcomSalesHeader."Membership Processing Status" <> EcomSalesHeader."Membership Processing Status"::Processed;
            if Modi then
                EcomSalesHeader."Membership Processing Status" := EcomSalesHeader."Membership Processing Status"::Processed;
        end;

        EcomVirtualItemDocStatus := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);
        if EcomVirtualItemDocStatus <> EcomSalesHeader."Virtual Items Process Status" then begin
            EcomSalesHeader."Virtual Items Process Status" := EcomVirtualItemDocStatus;
            Modi := true;
        end;

        if Modi then
            EcomSalesHeader.Modify(true);

        EcomVirtualItemEvents.OnAfterSetSalesDocMembershipStatusCreated(CurrEcomSalesLine, EcomSalesHeader);
    end;

    internal procedure ShowRelatedMembershipsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        EcomCreateMMShipImpl.ShowRelatedMembershipsAction(EcomSalesHeader);
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
        _Success: Boolean;
        _ShowError: Boolean;
}
#endif
