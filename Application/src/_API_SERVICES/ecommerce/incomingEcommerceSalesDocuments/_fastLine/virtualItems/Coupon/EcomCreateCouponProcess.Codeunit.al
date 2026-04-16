#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151122 "NPR EcomCreateCouponProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Line";

    var
        _UpdateRetryCount: Boolean;
        _Success: Boolean;
        _ShowError: Boolean;

    trigger OnRun()
    var
        EcomCreateCouponTryProcess: Codeunit "NPR EcomCreateCouponTryProcess";
    begin
        ClearLastError();
        Commit();

        Clear(EcomCreateCouponTryProcess);
        _Success := EcomCreateCouponTryProcess.Run(Rec);

        HandleResponse(_Success, Rec, _UpdateRetryCount);
        Commit();

        if (not _Success) and _ShowError then
            Error(GetLastErrorText);
    end;

    internal procedure HandleResponse(Success: Boolean; var EcomSalesLine: Record "NPR Ecom Sales Line"; UpdateRetryCount: Boolean)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        ErrorMessage: Text;
        UpdateErrStatus: Boolean;
        CouponEventId: Label 'NPR_API_Ecommerce_VirtualCouponCreationFailed', Locked = true;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();
        EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
        EcomSalesLine.Get(EcomSalesLine.RecordId());

        if UpdateRetryCount then
            EcomSalesLine."Virtual Item Proc Retry Count" += 1;

        if not Success then begin
            UpdateErrStatus := EcomSalesLine."Virtual Item Proc Retry Count" >= IncEcomSalesDocSetup."Max Virtual Item Retry Count";
            ErrorMessage := GetLastErrorText();
            SetSalesDocCouponStatusError(EcomSalesLine, ErrorMessage, UpdateErrStatus);
            EcomVirtualItemMgt.EmitError(ErrorMessage, CouponEventId);
        end else
            SetSalesDocCouponStatusCreated(EcomSalesLine);
    end;

    local procedure SetSalesDocCouponStatusError(var EcomSalesLine: Record "NPR Ecom Sales Line"; ErrorMessage: Text; UpdateStatus: Boolean)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        EcomVirtualItemDocStatus: Enum "NPR EcomVirtualItemDocStatus";
        Modi: Boolean;
    begin
        EcomSalesLine."Virtual Item Process ErrMsg" := CopyStr(ErrorMessage, 1, MaxStrLen(EcomSalesLine."Virtual Item Process ErrMsg"));
        if UpdateStatus then begin
            EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Error;
            EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
            if EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then begin
                if EcomSalesHeader."Coupon Processing Status" <> EcomSalesHeader."Coupon Processing Status"::Error then begin
                    EcomSalesHeader."Coupon Processing Status" := EcomSalesHeader."Coupon Processing Status"::Error;
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
    end;

    local procedure SetSalesDocCouponStatusCreated(var CurrEcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomVirtualItemDocStatus: Enum "NPR EcomVirtualItemDocStatus";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Modi: Boolean;
    begin
        CurrEcomSalesLine."Virtual Item Process Status" := CurrEcomSalesLine."Virtual Item Process Status"::Processed;
        CurrEcomSalesLine."Virtual Item Process ErrMsg" := '';
        CurrEcomSalesLine.Modify(true);

        EcomSalesLine.SetRange("Document Entry No.", CurrEcomSalesLine."Document Entry No.");
        EcomSalesLine.SetFilter(SystemId, '<>%1', CurrEcomSalesLine.SystemId);
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Coupon);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::Error);
        EcomSalesLine.SetFilter("Unit Price", '<>%1', 0);
        if not EcomSalesLine.IsEmpty() then
            exit;

        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
        if not EcomSalesHeader.Get(CurrEcomSalesLine."Document Entry No.") then
            exit;

        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
        if not EcomSalesLine.IsEmpty() then begin
            Modi := EcomSalesHeader."Coupon Processing Status" <> EcomSalesHeader."Coupon Processing Status"::"Partially Processed";
            if Modi then
                EcomSalesHeader."Coupon Processing Status" := EcomSalesHeader."Coupon Processing Status"::"Partially Processed"
        end else begin
            Modi := EcomSalesHeader."Coupon Processing Status" <> EcomSalesHeader."Coupon Processing Status"::Processed;
            if Modi then
                EcomSalesHeader."Coupon Processing Status" := EcomSalesHeader."Coupon Processing Status"::Processed;
        end;

        EcomVirtualItemDocStatus := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);
        if EcomVirtualItemDocStatus <> EcomSalesHeader."Virtual Items Process Status" then begin
            EcomSalesHeader."Virtual Items Process Status" := EcomVirtualItemDocStatus;
            Modi := true;
        end;

        if Modi then
            EcomSalesHeader.Modify(true);
    end;

    internal procedure ShowRelatedCouponsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        EcomCreateCouponImpl.ShowRelatedCouponsAction(EcomSalesHeader);
    end;

    internal procedure ShowRelatedCouponsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        EcomCreateCouponImpl.ShowRelatedCouponsAction(EcomSalesLine);
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
}
#endif
