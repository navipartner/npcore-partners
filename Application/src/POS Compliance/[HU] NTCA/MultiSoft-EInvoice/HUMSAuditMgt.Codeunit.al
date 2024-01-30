codeunit 6184708 "NPR HU MS Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeFinishSale', '', false, false)]
    local procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale");
    var
        HUMSPaymentMethodMap: Record "NPR HU MS Payment Method Map.";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;
        if not IsHUAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not GetPOSEntryFromSalesTicketNo(SalePOS."Sales Ticket No.", POSEntry, POSEntry."Entry Type"::"Direct Sale") then
            exit;
        if not GetPaymentMethodMapping(POSEntry, HUMSPaymentMethodMap) then
            exit;
        if not HUMSPaymentMethodMap.FindFirst() then
            exit;
        if not GetLinkedSalesDocument(POSEntry, POSEntrySalesDocLink) then
            exit;

        ModifySalesHaderPaymentMethod(HUMSPaymentMethodMap, POSEntrySalesDocLink);
    end;

    local procedure GetPOSEntryFromSalesTicketNo(SalesTicketNo: Code[20]; var POSEntry: Record "NPR POS Entry"; EntryType: Integer): Boolean
    begin
        POSEntry.SetFilter("Document No.", '=%1', SalesTicketNo);
        POSEntry.SetRange("Entry Type", EntryType);
        if (POSEntry.IsEmpty()) then
            exit(false);
        exit(POSEntry.FindFirst());
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsHUAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddHUAuditHandler(tmpRetailList);
    end;

    local procedure AddHUAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    internal procedure IsHUFiscalActive(): Boolean
    var
        HUFiscalSetup: Record "NPR HU MS Fiscalization Setup";
    begin
        if HUFiscalSetup.Get() then
            exit(HUFiscalSetup."Enable HU Fiscal");
    end;

    internal procedure IsHUAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);
        exit(true);
    end;

    local procedure HandlerCode(): Text[20]
    var
        HandlerCodeTxt: Label 'HU_MULTISOFTEINVOICE', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        HUFiscalisationSetup: Page "NPR MS HU Fiscalization Setup";
    begin
        HUFiscalisationSetup.RunModal();
    end;

    local procedure GetLinkedSalesDocument(var POSEntry: Record "NPR POS Entry"; var POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::ORDER);
        POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::Unposted);
        if not POSEntrySalesDocLink.FindFirst() then
            exit(false);
        exit(true);
    end;

    local procedure ModifySalesHaderPaymentMethod(var HUMSPaymentMethodMap: Record "NPR HU MS Payment Method Map."; var POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No");
        SalesHeader."Payment Method Code" := HUMSPaymentMethodMap."Payment Method";
        SalesHeader.Modify(false);
    end;

    local procedure GetPaymentMethodMapping(var POSEntry: Record "NPR POS Entry"; var HUMSPaymentMethodMap: Record "NPR HU MS Payment Method Map."): Boolean
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetFilter(Amount, '>%1', 0);
        if POSEntryPaymentLine.IsEmpty() then
            exit(false);

        POSEntryPaymentLine.FindSet();
        repeat
            POSPaymentMethod.Get(POSEntryPaymentLine."POS Payment Method Code");
            case POSPaymentMethod."Processing Type" of
                POSPaymentMethod."Processing Type"::CASH:
                    HUMSPaymentMethodMap.SetRange(Cash, true);
                POSPaymentMethod."Processing Type"::EFT:
                    HUMSPaymentMethodMap.SetRange(Card, true);
                POSPaymentMethod."Processing Type"::VOUCHER:
                    HUMSPaymentMethodMap.SetRange(Voucher, true);
            end;
        until POSEntryPaymentLine.Next() = 0;
        exit(true);
    end;
}