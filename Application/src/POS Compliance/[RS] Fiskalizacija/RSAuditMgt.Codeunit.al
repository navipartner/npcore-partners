codeunit 6059942 "NPR RS Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        Enabled: Boolean;
        Initialized: Boolean;
        RetailLocationExistsOnSalesLines: Boolean;

    #region Subscribers - POS Audit Logging
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddRSAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry");
    begin
        HandleCustIdentOnAuditLogAfterPOSEntryInsert(SalePOS, POSEntry);
    end;
    #endregion

    #region Subscribers - POS Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Issue POSAction Mgt.", 'OnIssueVoucherBeforeNpRvSalesLineModify', '', false, false)]
    local procedure OnIssueVoucherBeforeNpRvSalesLineModify(var POSSale: Codeunit "NPR POS Sale"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary; var VoucherType: Record "NPR NpRv Voucher Type"; var POSSaleLine: Codeunit "NPR POS Sale Line");
    begin
        FillVATPostingGroupsOnIssueVoucher(POSSale, TempVoucher, POSSaleLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure OnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(SaleHeader."Register No.");
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        VerifyPINCodeWithError(POSUnit."No.");
        VerifyGTINandTaxCategory(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale");
    var
        POSEntry: Record "NPR POS Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not GetPOSEntryFromSalesTicketNo(SalePOS."Sales Ticket No.", POSEntry) then
            exit;
        if not RSPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;

        Sender.GetContext(POSSaleLine, POSPaymentLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SalesInvoiceHeader.SetRange("No.", SaleLinePOS."Posted Sales Document No.");
        SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
        if SalesInvoiceHeader.FindFirst() then begin
            RSPOSAuditLogAuxInfo.Rename(RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header", RSPOSAuditLogAuxInfo."Audit Entry No.");
            RSPOSAuditLogAuxInfo."Source Document Type" := RSPOSAuditLogAuxInfo."Source Document Type"::Invoice;
            RSPOSAuditLogAuxInfo."Source Document No." := SaleLinePOS."Posted Sales Document No.";
            RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::ADVANCE;
            RSPOSAuditLogAuxInfo.Modify();
            exit;
        end;

        case POSEntry."Amount Incl. Tax" >= 0 of
            true:
                RSTaxCommunicationMgt.CreateNormalSale(RSPOSAuditLogAuxInfo);
            false:
                begin
                    RSTaxCommunicationMgt.CreateNormalRefund(RSPOSAuditLogAuxInfo);
                    if (POSCheckIfPaymentMethodCashAndDirectSale(POSEntry."Entry No.") or not (RSPOSAuditLogAuxInfo."Audit Entry Type" in [RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry"])) then
                        RSTaxCommunicationMgt.CreateCopyFiscalReceipt(RSPOSAuditLogAuxInfo);
                end;
        end;
        Commit();
        RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'OnAfterDebitSalePostEvent', '', false, false)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; Posted: Boolean);
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not GetPOSEntryFromSalesTicketNo(SalePOS."Sales Ticket No.", POSEntry) then
            exit;
        if not RSPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;

        case POSEntry."Amount Incl. Tax" >= 0 of
            true:
                RSTaxCommunicationMgt.CreateNormalSale(RSPOSAuditLogAuxInfo);
            false:
                begin
                    RSTaxCommunicationMgt.CreateNormalRefund(RSPOSAuditLogAuxInfo);
                    RSTaxCommunicationMgt.CreateCopyFiscalReceipt(RSPOSAuditLogAuxInfo);
                end;
        end;

        RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeLogin(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        //Error upon POS Login if any configuration is missing or clearly not set according to compliance
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        VerifyRSCompilanceSetupBeforeLogin(POSUnit);
        VerifyPINCodeWithError(POSUnit."No.");
        CheckAreDataSetAndAccordingToCompliance(FrontEnd);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure OnBeforeHendleReverse(Setup: Codeunit "NPR POS Setup"; var SalesTicketNo: Code[20]; Context: Codeunit "NPR POS JSON Helper");
    var
        POSUnit: Record "NPR POS Unit";
        NewSalesTicketNo: Code[20];
    begin
        Setup.GetPOSUnit(POSUnit);
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        NewSalesTicketNo := GetPOSEntryNoFromAuditLog(Context);

        if NewSalesTicketNo <> '' then
            SalesTicketNo := NewSalesTicketNo;
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsRSAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'CreateSalesHeaderOnBeforeSalesHeaderModify', '', false, false)]
    local procedure CreateSalesHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale");
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
    begin
        if not IsRSFiscalActive() then
            exit;

        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesHeader."NPR RS POS Unit" := SalePOS."Register No.";
        RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if not IsRSFiscalActive() then
            exit;

        if EanBoxEvent.Get(EventCodeItemGtin()) then
            exit;
        InsertEanBoxEvent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if not IsRSFiscalActive() then
            exit;

        case EanBoxEvent.Code of
            EventCodeItemGtin():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifierType', false, 'ItemGtin');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeGtin(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        if not IsRSFiscalActive() then
            exit;
        if EanBoxSetupEvent."Event Code" <> EventCodeItemGtin() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Item.GTIN) then
            exit;

        Item.SetRange(GTIN, EanBoxValue);
        if not Item.IsEmpty() then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertPOSSaleLineBeforeCommit', '', false, false)]
    local procedure OnAfterInsertPOSSaleLineBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        POSSaleLine2: Record "NPR POS Sale Line";
        SameSignErr: Label 'Cannot have sale and return in the same transaction';
    begin
        if not IsRSFiscalActive() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if SaleLinePOS."Line No." = 10000 then
            exit;
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"Issue Voucher"]) then
            exit;
        if not GetFirstSaleLinePOSOfTypeItemOrVoucher(POSSaleLine2, SaleLinePOS) then
            exit;
        if (POSSaleLine2.Quantity > 0) and (SaleLinePOS.Quantity > 0) then
            exit;
        if (POSSaleLine2.Quantity < 0) and (SaleLinePOS.Quantity < 0) then
            exit;
        if not ChangeQtyOnPOSSaleLine(SaleLinePOS) then
            Error(SameSignErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', false, false)]
    local procedure OnBeforeSetQuantity(var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        POSUnit: Record "NPR POS Unit";
        POSSaleLine2: Record "NPR POS Sale Line";
        SameSignErr: Label 'Cannot have sale and return in the same transaction';
    begin
        if not IsRSFiscalActive() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if SaleLinePOS.Quantity = NewQuantity then
            exit;
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"Issue Voucher"]) then
            exit;
        if not GetFirstSaleLinePOSOfTypeItemOrVoucher(POSSaleLine2, SaleLinePOS) then
            exit;
        if (POSSaleLine2.Quantity > 0) and (NewQuantity > 0) then
            exit;
        if (POSSaleLine2.Quantity < 0) and (NewQuantity < 0) then
            exit;
        if not ChangeQtyOnAllPOSSaleLines(SaleLinePOS) then
            Error(SameSignErr);
    end;
    #endregion

    #region Subscribers - Validations
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSStore(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSStoreIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSUnit(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSUnitIfAlreadyUsed(xRec);
    end;
    #endregion

    #region Subscribers - Standard Adjustment
    [EventSubscriber(ObjectType::Page, Page::"VAT Posting Setup", 'OnBeforeValidateEvent', 'VAT %', false, false)]
    local procedure VATPostingSetup_OnBeforeValidateEvent(var Rec: Record "VAT Posting Setup")
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        PreventChangeVATErr: Label 'VAT % can not be changed since it already has posted entries and due Tax Law preventing change if posted entries exist.';
    begin
        if RSAuditMgt.IsRSFiscalActive() and RSAuditMgt.CheckIfVATPostingSetupHasEntries(Rec) then
            Error(PreventChangeVATErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeManualReleaseSalesDoc', '', false, false)]
    local procedure OnBeforeManualReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean);
    begin
        VerifyIsDataSetOnSalesDocuments(SalesHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeManualReOpenSalesDoc', '', false, false)]
    local procedure OnBeforeManualReOpenSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean);
    begin
        VerifyIsDataSetOnSalesDocuments(SalesHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterManualReleaseSalesDoc', '', false, false)]
    local procedure OnAfterManualReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean);
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote,
            SalesHeader."Document Type"::Order,
            SalesHeader."Document Type"::Invoice:
                begin
                    RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
                    if RSAuxSalesHeader."NPR RS Audit Entry" in [RSAuxSalesHeader."NPR RS Audit Entry"::" ", RSAuxSalesHeader."NPR RS Audit Entry"::"Proforma Refund"] then
                        RSTaxCommunicationMgt.CreateProformaSale(SalesHeader);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterManualReOpenSalesDoc', '', false, false)]
    local procedure OnAfterManualReOpenSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean);
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote,
            SalesHeader."Document Type"::Order,
            SalesHeader."Document Type"::Invoice:
                begin
                    RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
                    if RSAuxSalesHeader."NPR RS Audit Entry" in [RSAuxSalesHeader."NPR RS Audit Entry"::"Proforma Sales"] then
                        RSTaxCommunicationMgt.CreateProformaRefund(SalesHeader, true);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SalesHeader_OnBeforeDeleteEvent(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
        if RSAuxSalesHeader."NPR RS Audit Entry" in [RSAuxSalesHeader."NPR RS Audit Entry"::"Proforma Sales"] then
            RSTaxCommunicationMgt.CreateProformaRefund(Rec, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header");
    begin
        VerifyIsDataSetOnSalesDocuments(SalesHeader, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean);
    var
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if not RetailLocationExistsOnSalesLines then
            exit;

        if SalesInvHdrNo <> '' then
            RSTaxCommunicationMgt.CreateNormalSale(SalesInvHdrNo);

        if SalesCrMemoHdrNo <> '' then
            RSTaxCommunicationMgt.CreateNormalRefund(SalesCrMemoHdrNo);
    end;

#if not BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCopyDocument', '', false, false)]
    local procedure OnAfterCreateCopyDocument(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(SalesInvoiceHeader);
        RSAuxSalesHeader.TransferFields(RSAuxSalesInvHeader, false);
        RSAuxSalesHeader."NPR RS Refund Reference" := SalesInvoiceHeader."No.";
        RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure SalesHeader_OnAfterValidateEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
    begin
        if not IsRSFiscalActive() then
            exit;

        Customer.Get(Rec."Sell-to Customer No.");
        if Customer."VAT Registration No." <> '' then begin
            RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
            RSAuxSalesHeader."NPR RS Cust. Ident. Type" := RSAuxSalesHeader."NPR RS Cust. Ident. Type"::PIB;
            RSAuxSalesHeader."NPR RS Customer Ident." := Customer."VAT Registration No.";
            RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
        end;
    end;

    #region RS Fiscal - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        RSFiscalizationSetup.ChangeCompany(CompanyName);
        if not (RSFiscalizationSetup.Get() and RSFiscalizationSetup."Enable RS Fiscal") then
            exit;

        Clear(RSFiscalizationSetup."Sandbox URL");
        Clear(RSFiscalizationSetup."Configuration URL");
        Clear(RSFiscalizationSetup."TaxPayer Admin Portal URL");
        Clear(RSFiscalizationSetup."TaxCore API URL");
        Clear(RSFiscalizationSetup."VSDC URL");
        Clear(RSFiscalizationSetup."Root URL");
        Clear(RSFiscalizationSetup."NPT Server URL");
        RSFiscalizationSetup.Modify();

        RSPOSUnitMapping.ChangeCompany(CompanyName);
        RSPOSUnitMapping.ModifyAll("RS Sandbox PIN", 0);
        RSPOSUnitMapping.ModifyAll("RS Sandbox JID", '');
        RSPOSUnitMapping.ModifyAll("RS Sandbox Token", '00000000-0000-0000-0000-000000000000');
    end;
#endif

    #endregion

    #region RS Fiscal - Aux and Mapping Tables Cleanup 
    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesInvoiceHeader_OnAfterDeleteEvent(var Rec: Record "Sales Invoice Header"; RunTrigger: Boolean)
    var
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
    begin
        if not RunTrigger then
            exit;
        if not IsRSFiscalActive() then
            exit;

        if RSAuxSalesInvHeader.Get(Rec."No.") then
            RSAuxSalesInvHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesCrMemoHeader_OnAfterDeleteEvent(var Rec: Record "Sales Cr.Memo Header"; RunTrigger: Boolean)
    var
        RSAuxSalesCrMemoHeader: Record "NPR RS Aux Sales CrMemo Header";
    begin
        if not RunTrigger then
            exit;
        if not IsRSFiscalActive() then
            exit;

        if RSAuxSalesCrMemoHeader.Get(Rec."No.") then
            RSAuxSalesCrMemoHeader.Delete(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Method", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PaymentMethod_OnAfterDeleteEvent(var Rec: Record "NPR POS Payment Method"; RunTrigger: Boolean)
    var
        RSPaymentMethodMapping: Record "NPR RS POS Paym. Meth. Mapping";
    begin
        if not RunTrigger then
            exit;
        if not IsRSFiscalActive() then
            exit;

        if RSPaymentMethodMapping.Get(Rec.Code) then
            RSPaymentMethodMapping.Delete(true);
    end;
    #endregion

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header");
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(SalesInvHeader);
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesInvHeader.TransferFields(RSAuxSalesHeader, false);
        RSAuxSalesInvHeader.SaveRSAuxSalesInvHeaderFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnAfterSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header");
    var
        RSAuxSalesCrMemoHeader: Record "NPR RS Aux Sales CrMemo Header";
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        RSAuxSalesCrMemoHeader.ReadRSAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesCrMemoHeader.TransferFields(RSAuxSalesHeader, false);
        RSAuxSalesCrMemoHeader.SaveRSAuxSalesCrMemoHeaderFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterDeleteAfterPosting', '', false, false)]
    local procedure OnAfterDeleteAfterPosting(SalesHeader: Record "Sales Header"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; CommitIsSuppressed: Boolean);
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RetailLocationExistsOnSalesLines then
            exit;

        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterPostPrepaymentsOnBeforeThrowPreviewModeError', '', false, false)]
    local procedure OnAfterPostPrepaymentsOnBeforeThrowPreviewModeError(var SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean);
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        CheckSalesLinesRetailLocation(SalesHeader);
        if not RetailLocationExistsOnSalesLines then
            exit;

        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(SalesInvHeader);
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesInvHeader.TransferFields(RSAuxSalesHeader, false);
        RSAuxSalesInvHeader.SaveRSAuxSalesInvHeaderFields();

        RSPOSAuditLogAuxInfo.SetRange("Source Document Type", RSPOSAuditLogAuxInfo."Source Document Type"::Invoice);
        RSPOSAuditLogAuxInfo.SetRange("Source Document No.", SalesInvHeader."No.");
        if not RSPOSAuditLogAuxInfo.FindFirst() then
            InsertRSPOSAuditLogAuxInfoFromSalesInvHeader(RSPOSAuditLogAuxInfo, SalesInvHeader);

        RSTaxCommunicationMgt.CreatePrepaymentSale(RSPOSAuditLogAuxInfo);
    end;
    #endregion

    #region Job Queue
    procedure AddRSAuditBackgroundJobQueue(Enable: Boolean; Silent: Boolean) Success: Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        OpenJobQueueQst: Label 'A job queue entry to automate fiscalization tasks has been created.\\Do you want to open the Job Queue Entry Setup page now?';
    begin
        Success := InitRSAuditBackgroundJobQueue(JobQueueEntry, Enable);
        if Success and not Silent then begin
            Commit();
            if Confirm(OpenJobQueueQst, true) then
                Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
        end;
    end;

    local procedure InitRSAuditBackgroundJobQueue(var JobQueueEntry: Record "Job Queue Entry"; Enable: Boolean): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
        JobQueueDescrLbl: Label 'RS Fiscal background processor', MaxLength = 250;
    begin
        if Enable then begin
            Evaluate(NextRunDateFormula, '<1D>');
            JobQueueMgt.SetJobTimeout(4, 0);  //4 hours
            JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 2700, '');
            if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR RS Fiscal BG Comm. Batch",
                '',
                JobQueueDescrLbl,
                JobQueueMgt.NowWithDelayInSeconds(300),
                0T,
                0T,
                NextRunDateFormula,
                DefaultRSAuditCategoryCode(),
                JobQueueEntry)
            then begin
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
                exit(true);
            end;
        end;

        JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR RS Fiscal BG Comm. Batch");
        exit(false);
    end;

    local procedure DefaultRSAuditCategoryCode(): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        ImportListJQCategoryCode: Label 'FISCAL', MaxLength = 10, Locked = true;
        ImportListJQCategoryDescrLbl: Label 'POS Audit Fiscal Processing', MaxLength = 30;
    begin
        JobQueueCategory.InsertRec(ImportListJQCategoryCode, ImportListJQCategoryDescrLbl);
        exit(JobQueueCategory.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        AddRSAuditBackgroundJobQueue(IsRSFiscalActive(), true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = Codeunit::"NPR RS Fiscal BG Comm. Batch")
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;
    #endregion

    #region Procedures - Helper functions
    local procedure OnActionShowSetup()
    var
        RSFiscalizationSetup: Page "NPR RS Fiscalisation Setup";
    begin
        RSFiscalizationSetup.RunModal();
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'RS_FISKALIZACIJA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure EventCodeItemGtin(): Code[20]
    begin
        exit('ITEMGTIN');
    end;

    internal procedure FillCertificationData(Certification: Dictionary of [Text, Text])
    var
        CertificationApp: Label 'NP Retail', Locked = true;
        CertificationDate: Label '24.10.2023.', Locked = true;
        CertificationIBNo: Label '1230', Locked = true;
        CertificationVendor: Label 'Navi Partner Copenhagen ApS', Locked = true;
        CertificationVersion: Label '1.0', Locked = true;
    begin
        Certification.Set('Vendor', CertificationVendor);
        Certification.Set('RSFiscalName', CertificationApp);
        Certification.Set('RSFiscalIBNo', CertificationIBNo);
        Certification.Set('RSFiscalVersion', CertificationVersion);
        Certification.Set('CertificationDate', CertificationDate);
        Certification.Set('ESIRNo', CertificationIBNo + '/' + CertificationVersion);
    end;

    local procedure IsRSAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);
        if Initialized then
            exit(Enabled);

        Initialized := true;
        Enabled := true;
        exit(true);
    end;

    internal procedure IsRSFiscalActive(): Boolean
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
    begin
        if not RSFiscalizationSetup.Get() then begin
            RSFiscalizationSetup.Init();
            RSFiscalizationSetup.Insert();
        end;
        exit(RSFiscalizationSetup."Enable RS Fiscal");
    end;

    internal procedure CheckIfVATPostingSetupHasEntries(VATPostingSetup: Record "VAT Posting Setup"): Boolean
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        exit(not VATEntry.IsEmpty());
    end;

    internal procedure POSCheckIfPaymentMethodCashAndDirectSale(POSEntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        ShouldCreateRefundFiscalBillCopy: Boolean;
    begin
        if not POSEntry.Get(POSEntryNo) then
            exit(false);
        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale"]) then
            exit(false);

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryPaymentLine.FindSet() then
            repeat
                RSPOSPaymMethMapping.Get(POSEntryPaymentLine."POS Payment Method Code");
                if not ShouldCreateRefundFiscalBillCopy then
                    ShouldCreateRefundFiscalBillCopy := RSPOSPaymMethMapping."RS Payment Method" in [RSPOSPaymMethMapping."RS Payment Method"::Cash];
            until (POSEntryPaymentLine.Next() = 0) or ShouldCreateRefundFiscalBillCopy;

        exit(ShouldCreateRefundFiscalBillCopy);
    end;

    procedure DocumentCheckIfPaymentMethodCash(PaymentMethodCode: Code[20]): Boolean
    var
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
    begin
        if not RSPaymentMethodMapping.Get(PaymentMethodCode) then
            exit(false);
        if not (RSPaymentMethodMapping."RS Payment Method" in [RSPaymentMethodMapping."RS Payment Method"::Cash]) then
            exit(false);

        exit(true);
    end;

    local procedure GetPOSEntryFromSalesTicketNo(SalesTicketNo: Code[20]; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetFilter("Document No.", '=%1', SalesTicketNo);
        if (POSEntry.IsEmpty()) then
            exit(false);

        exit(POSEntry.FindFirst());
    end;

    internal procedure InputReturnReferenceInformation(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        InputDialog: Page "NPR Input Dialog";
        ReferenceNo: Text;
        ReferenceDate: Date;
        ReferenceTime: Time;
        ReferenceNoLbl: Label 'Reference No.';
        ReferenceNoDefaultLbl: Label 'XXXXXXXX-XXXXXXXX-000000', Locked = true;
        ReferenceNoInvalidErr: Label 'Reference No. you inserted is not valid. Please try again';
        ReferenceDateLbl: Label 'Reference Date';
        ReferenceTimeLbl: Label 'Reference Time';
        DateTimeFormatLbl: Label '%1T%2', Locked = true, Comment = '%1 = Date, %2 = Time';
    begin
        if RSPOSAuditLogAuxInfo.Signature <> '' then
            exit;
        if (not (RSPOSAuditLogAuxInfo."Audit Entry Type" in [RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry"]) and
            (not (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND]))) then
            exit;

        Clear(InputDialog);

        ReferenceNo := ReferenceNoDefaultLbl;
        ReferenceDate := Today();
        ReferenceTime := Time();

        InputDialog.SetInput(1, ReferenceNo, ReferenceNoLbl);
        InputDialog.SetInput(2, ReferenceDate, ReferenceDateLbl);
        InputDialog.SetInput(3, ReferenceTime, ReferenceTimeLbl);

        if InputDialog.RunModal() <> Action::OK then
            exit;

        InputDialog.InputText(1, ReferenceNo);
        InputDialog.InputDate(2, ReferenceDate);
        InputDialog.InputTime(3, ReferenceTime);

        if ReferenceNo = ReferenceNoDefaultLbl then
            Error(ReferenceNoInvalidErr);

        RSPOSAuditLogAuxInfo."Return Reference No." := CopyStr(ReferenceNo, 1, MaxStrLen(RSPOSAuditLogAuxInfo."Return Reference No."));
        RSPOSAuditLogAuxInfo."Return Reference Date/Time" := CopyStr(StrSubstNo(DateTimeFormatLbl, Format(ReferenceDate, 10, '<Year4>-<Month,2>-<Day,2>').ToUpper(), Format(ReferenceTime, 8, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>')), 1, MaxStrLen(RSPOSAuditLogAuxInfo."Return Reference Date/Time"));
        RSPOSAuditLogAuxInfo.Modify();
    end;
    #endregion

    #region Procedures - Validations
    local procedure VerifyPINCodeWithError(POSStoreNo: Code[10])
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
        TaxPINSuccessCode: Label '0100 - SUCCESS', Locked = true;
        VerifyPinResultTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        if RSFiscalizationSetup."Allow Offline Use" then
            exit;

        VerifyPinResultTxt := RSTaxCommunicationMgt.VerifyPIN(POSStoreNo);
        if VerifyPinResultTxt <> TaxPINSuccessCode then
            Error(VerifyPinResultTxt);
    end;

    local procedure CheckAreDataSetAndAccordingToCompliance(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSUnit.GetProfile(POSAuditProfile);
        POSAuditProfile.TestField("Do Not Print Receipt on Sale", false);

        VerifyPINCodeWithError(POSUnit."No.");
    end;

    local procedure VerifyRSCompilanceSetupBeforeLogin(var POSUnit: Record "NPR POS Unit")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSStore: Record "NPR POS Store";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
    begin
        RSFiscalizationSetup.Get();
        RSFiscalizationSetup.TestField("Sandbox URL");
        RSPOSUnitMapping.Get(POSUnit."No.");
        if not RSFiscalizationSetup."Exclude Token from URL" then
            RSPOSUnitMapping.TestField("RS Sandbox Token");
        RSPOSUnitMapping.TestField("RS Sandbox JID");
        RSPOSUnitMapping.TestField("RS Sandbox PIN");

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sale Fiscal No. Series");
        POSAuditProfile.TestField("Credit Sale Fiscal No. Series");
        POSAuditProfile.TestField("Balancing Fiscal No. Series");
        POSAuditProfile.TestField("Fill Sale Fiscal No. On", POSAuditProfile."Fill Sale Fiscal No. On"::Successful);
        POSAuditProfile.TestField("Print Receipt On Sale Cancel", false);
        POSAuditProfile.TestField("Do Not Print Receipt on Sale", false);

        POSStore.Get(POSUnit."POS Store Code");
        POSStore.TestField("Country/Region Code");
    end;

    local procedure VerifyIsDataSetOnSalesDocuments(SalesHeader: Record "Sales Header"; Proforma: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        NotRSAuditProfileErr: Label 'RS Audit Profile is not selected on POS Unit No.: %1', Comment = '%1 - POS Unit No.';
    begin
        if not IsRSFiscalActive() then
            exit;
        if not CheckSalesLinesRetailLocation(SalesHeader) then
            exit;

        RSFiscalizationSetup.Get();
        if Proforma then begin
            if not RSFiscalizationSetup."Fiscal Proforma on Sales Doc." then
                exit;
        end;

        SalesHeader.TestField("Salesperson Code");
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);

        RSAuxSalesHeader.TestField("NPR RS POS Unit");
        POSUnit.Get(RSAuxSalesHeader."NPR RS POS Unit");
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            Error(NotRSAuditProfileErr, POSUnit."No.");

        RSPOSUnitMapping.Get(POSUnit."No.");
        RSPOSUnitMapping.TestField("RS Sandbox JID");
        RSPOSUnitMapping.TestField("RS Sandbox PIN");
        if not RSFiscalizationSetup."Exclude Token from URL" then
            RSPOSUnitMapping.TestField("RS Sandbox Token");
    end;

    internal procedure IsDataSetOnSalesInvoiceDoc(RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not IsRSFiscalActive() then
            exit(false);
        if RSAuxSalesInvHeader."NPR RS POS Unit" = '' then
            exit(false);

        POSUnit.Get(RSAuxSalesInvHeader."NPR RS POS Unit");
        RSPOSUnitMapping.Get(POSUnit."No.");
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit(false);
        if RSPOSUnitMapping."RS Sandbox JID" = '' then
            exit(false);
        if RSPOSUnitMapping."RS Sandbox PIN" = 0 then
            exit(false);
        RSFiscalizationSetup.Get();
        if not RSFiscalizationSetup."Exclude Token from URL" then
            if RSPOSUnitMapping."RS Sandbox Token" = '' then
                exit(false);
        SalesInvoiceHeader.Get(RSAuxSalesInvHeader."Sales Invoice Header No.");
        if SalesInvoiceHeader."Salesperson Code" = '' then
            exit(false);
        exit(true);
    end;

    local procedure VerifyGTINandTaxCategory(var SaleHeader: Record "NPR POS Sale")
    var
        Item: Record Item;
        POSSaleLine: Record "NPR POS Sale Line";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalGTINErr: Label 'GTIN number of item can not be less than 8 or grater than 14 characters.';
        RSTaxCatNameErr: Label 'RS Tax Category Name must be filled for VAT Posting Setup = %1, %2', Comment = '%1 - VAT Bus. Posting Group, %2 - VAT Prod. Posting Group';
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        if POSSaleLine.FindSet() then
            repeat
                if POSSaleLine."Line Type" = POSSaleLine."Line Type"::Item then begin
                    RSVATPostSetupMapping.Get(POSSaleLine."VAT Bus. Posting Group", POSSaleLine."VAT Prod. Posting Group");
                    if RSVATPostSetupMapping."RS Tax Category Name" = '' then
                        Error(RSTaxCatNameErr, POSSaleLine."VAT Bus. Posting Group", POSSaleLine."VAT Prod. Posting Group");
                    Item.Get(POSSaleLine."No.");
                    if (((StrLen(Item.GTIN) < 8) or (StrLen(Item.GTIN) > 14))) and (StrLen(Item.GTIN) > 0) then
                        Error(RSFiscalGTINErr);
                end
            until POSSaleLine.Next() = 0;
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - RS POS Audit Log Aux. Info table caption';
    begin
        if not IsRSFiscalActive() then
            exit;

        RSPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not RSPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, RSPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - RS POS Audit Log Aux. Info table caption';
    begin
        if not IsRSAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        RSPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not RSPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", RSPOSAuditLogAuxInfo.TableCaption());
    end;
    #endregion

    #region Procedures - Misc
    local procedure AddRSAuditHandler(var TempRetailList: Record "NPR Retail List")
    begin
        TempRetailList.Number += 1;
        TempRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(TempRetailList.Choice));
        TempRetailList.Insert();
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;
        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertRSPOSAuditLogAuxInfoFromPOSEntry(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertRSPOSAuditLogAuxInfoFromPOSEntry(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        Customer: Record Customer;
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        CustomerVATRegNoRSLabel: Label '10:', Locked = true;
    begin
        RSPOSAuditLogAuxInfo.Init();
        RSPOSAuditLogAuxInfo."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        RSPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        RSPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        RSPOSAuditLogAuxInfo."Discount Amount" := POSEntry."Discount Amount Incl. VAT";
        RSPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        RSPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        RSPOSAuditLogAuxInfo."Source Document Type" := POSEntry."Sales Document Type";
        RSPOSAuditLogAuxInfo."POS Entry Type" := POSEntry."Entry Type";
        RSPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        RSFiscalizationSetup.Get();

        case RSFiscalizationSetup.Training of
            true:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING;
            false:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL;
        end;

        case POSEntry."Amount Incl. Tax" >= 0 of
            true:
                RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE;
            false:
                RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND;
        end;

        if POSEntry."Customer No." <> '' then begin
            Customer.Get(POSEntry."Customer No.");
            if Customer."VAT Registration No." <> '' then
                RSPOSAuditLogAuxInfo."Customer Identification" := CustomerVATRegNoRSLabel + Customer."VAT Registration No.";
            RSPOSAuditLogAuxInfo."Email-To" := Customer."E-Mail";
        end;

        RSPOSAuditLogAuxInfo.Insert();
    end;

    local procedure InsertRSPOSAuditLogAuxInfoFromSalesInvHeader(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
        POSUnit: Record "NPR POS Unit";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        CustomerVATRegNoRSLabel: Label '10:', Locked = true;
    begin
        RSPOSAuditLogAuxInfo.Init();
        RSPOSAuditLogAuxInfo."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header";
        RSPOSAuditLogAuxInfo."Source Document No." := SalesInvoiceHeader."No.";
        RSPOSAuditLogAuxInfo."Source Document Type" := RSPOSAuditLogAuxInfo."Source Document Type"::Invoice;
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(SalesInvoiceHeader);
        RSPOSAuditLogAuxInfo."POS Unit No." := RSAuxSalesInvHeader."NPR RS POS Unit";
        if POSUnit.Get(RSAuxSalesInvHeader."NPR RS POS Unit") then
            RSPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        SalesInvoiceHeader.CalcFields("Amount Including VAT", "Invoice Discount Amount");
        RSPOSAuditLogAuxInfo."Discount Amount" := SalesInvoiceHeader."Invoice Discount Amount";
        RSPOSAuditLogAuxInfo."Entry Date" := SalesInvoiceHeader."Posting Date";
        RSPOSAuditLogAuxInfo."POS Entry Type" := RSPOSAuditLogAuxInfo."POS Entry Type"::"Direct Sale";
        RSPOSAuditLogAuxInfo."Prepayment Order No." := SalesInvoiceHeader."Prepayment Order No.";
        RSFiscalizationSetup.Get();

        case RSFiscalizationSetup.Training of
            true:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING;
            false:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::ADVANCE;
        end;

        case SalesInvoiceHeader."Amount Including VAT" > 0 of
            true:
                RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE;
            false:
                RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND;
        end;

        if SalesInvoiceHeader."Sell-to Customer No." <> '' then begin
            Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
            if Customer."VAT Registration No." <> '' then
                RSPOSAuditLogAuxInfo."Customer Identification" := CustomerVATRegNoRSLabel + Customer."VAT Registration No.";
            RSPOSAuditLogAuxInfo."Email-To" := Customer."E-Mail";
        end;

        RSPOSAuditLogAuxInfo.Insert();
    end;

    local procedure HandleCustIdentOnAuditLogAfterPOSEntryInsert(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSSale: Record "NPR RS POS Sale";
    begin
        if not IsRSFiscalActive() then
            exit;
        if not RSPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;
        if not RSPOSSale.Get(SalePOS.SystemId) then
            exit;

        if RSPOSSale."RS Customer Identification" <> '' then
            RSPOSAuditLogAuxInfo."Customer Identification" := RSPOSSale."RS Customer Identification";

        if RSPOSSale."RS Add. Customer Field" <> '' then
            RSPOSAuditLogAuxInfo."Additional Customer Field" := RSPOSSale."RS Add. Customer Field";

        if (RSPOSSale."Return Reference No." <> '') and (RSPOSSale."Return Reference Date/Time" <> '') then begin
            RSPOSAuditLogAuxInfo."Return Reference No." := RSPOSSale."Return Reference No.";
            RSPOSAuditLogAuxInfo."Return Reference Date/Time" := RSPOSSale."Return Reference Date/Time";
        end;

        RSPOSAuditLogAuxInfo.Modify();
    end;

    local procedure GetPOSEntryNoFromAuditLog(Context: Codeunit "NPR POS JSON Helper"): Code[20]
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesTicketPartsList: List of [Text];
        SalesTicketPart: Text;
        SalesTicketNo: Text[30];
        TextBuilder: TextBuilder;
    begin
        SalesTicketNo := CopyStr(UpperCase(Context.GetString('receipt')), 1, MaxStrLen(SalesTicketNo));
        SalesTicketPartsList := SalesTicketNo.Split('-');

        if SalesTicketPartsList.Count() = 2 then begin
            SalesTicketPartsList.Insert(1, SalesTicketPartsList.Get(1));
            foreach SalesTicketPart in SalesTicketPartsList do
                TextBuilder.Append(SalesTicketPart + '-');
            SalesTicketNo := CopyStr(TextBuilder.ToText().TrimEnd('-'), 1, MaxStrLen(SalesTicketNo));
        end;

        RSPOSAuditLogAuxInfo.SetRange("Invoice Number", SalesTicketNo);
        if RSPOSAuditLogAuxInfo.FindFirst() then
            exit(RSPOSAuditLogAuxInfo."Source Document No.");
    end;

    local procedure FillVATPostingGroupsOnIssueVoucher(var POSSale: Codeunit "NPR POS Sale"; var TempVoucher: Record "NPR NpRv Voucher" temporary; var POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        GLAccount: Record "G/L Account";
        POSSaleRecord: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        VoucherAccountNoNotSetErr: Label 'Account No. is not set on Voucher.';
    begin
        POSSale.GetCurrentSale(POSSaleRecord);
        POSUnit.Get(POSSaleRecord."Register No.");
        if not IsRSAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not GLAccount.Get(TempVoucher."Account No.") then
            Error(VoucherAccountNoNotSetErr);

        GLAccount.TestField("VAT Prod. Posting Group");
        GLAccount.TestField("VAT Bus. Posting Group");

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        SaleLinePOS.Modify(false);
    end;

    procedure TermalPrintSalesHeader(SalesHeader: Record "Sales Header")
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
        AuditLogNotExistingMsg: Label 'RS Audit Log is not existing for this document.';
        FiscalNotSentMsg: Label 'Fiscal Bill has not been sent to Tax Auth.';
    begin
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Header");
        RSPOSAuditLogAuxInfo.SetRange("Source Document Type", SalesHeader."Document Type");
        RSPOSAuditLogAuxInfo.SetRange("Source Document No.", SalesHeader."No.");
        if not RSPOSAuditLogAuxInfo.FindLast() then begin
            Message(AuditLogNotExistingMsg);
            exit;
        end;

        if RSPOSAuditLogAuxInfo.Signature = '' then begin
            Message(FiscalNotSentMsg);
            exit;
        end;

        RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
    end;

    local procedure CheckSalesLinesRetailLocation(SalesHeader: Record "Sales Header"): Boolean
    var
        Location: Record Location;
        SalesLines: Record "Sales Line";
    begin
        RetailLocationExistsOnSalesLines := false;
        SalesLines.SetCurrentKey("Document Type", "Document No.", "Location Code");
        SalesLines.SetLoadFields("Location Code");
        SalesLines.SetFilter(Type, '%1|%2', SalesLines.Type::Item, SalesLines.Type::"Charge (Item)");
        SalesLines.SetRange("Document No.", SalesHeader."No.");
        if not SalesLines.FindSet() then
            exit(RetailLocationExistsOnSalesLines);

        repeat
            if Location.Get(SalesLines."Location Code") then
                if Location."NPR Retail Location" then begin
                    RetailLocationExistsOnSalesLines := true;
                    exit(RetailLocationExistsOnSalesLines);
                end;
        until SalesLines.Next() = 0;
        exit(RetailLocationExistsOnSalesLines);
    end;

    local procedure InsertEanBoxEvent()
    var
        EanBoxEvent: Record "NPR Ean Box Event";
        Item: Record Item;
    begin
        EanBoxEvent.Code := EventCodeItemGtin();
        EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
        EanBoxEvent.Description := CopyStr(Item.FieldCaption(GTIN), 1, MaxStrLen(EanBoxEvent.Description));
        EanBoxEvent."Action Code" := CopyStr(Format(Enum::"NPR POS Workflow"::ITEM), 1, MaxStrLen(EanBoxEvent."Action Code"));
        EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
        EanBoxEvent."Event Codeunit" := Codeunit::"NPR POS Action: Insert Item";
        EanBoxEvent.Insert(true);
    end;

    local procedure GetFirstSaleLinePOSOfTypeItemOrVoucher(var POSSaleLine2: Record "NPR POS Sale Line"; POSSaleLine: Record "NPR POS Sale Line"): Boolean
    begin
        POSSaleLine2.SetFilter("Line Type", '%1|%2', POSSaleLine2."Line Type"::Item, POSSaleLine2."Line Type"::"Issue Voucher");
        POSSaleLine2.SetRange("Sales Ticket No.", POSSaleLine."Sales Ticket No.");
        POSSaleLine2.SetFilter("Line No.", '<>%1', POSSaleLine."Line No.");
        exit(POSSaleLine2.FindFirst());
    end;

    local procedure ChangeQtyOnAllPOSSaleLines(var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        POSSaleLine: Record "NPR POS Sale Line";
        ConfirmManagement: Codeunit "Confirm Management";
        ChangeQuantityQst: Label 'Sales and Return are not allowed in the same transaction. Do you want to set negative Quantity for all existing Sales Lines?';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(ChangeQuantityQst, false)) then
            exit(false);
        POSSaleLine.SetFilter("Line Type", '%1|%2', POSSaleLine."Line Type"::Item, POSSaleLine."Line Type"::"Issue Voucher");
        POSSaleLine.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSSaleLine.SetFilter("Line No.", '<>%1', SaleLinePOS."Line No.");
        if POSSaleLine.FindSet(true) then
            repeat
                POSSaleLine.Validate(Quantity, -POSSaleLine.Quantity);
                POSSaleLine.Modify(true);
            until POSSaleLine.Next() = 0;
        exit(true);
    end;

    local procedure ChangeQtyOnPOSSaleLine(var POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ChangeQuantityQst: Label 'Sales and Return are not allowed in the same transaction. Do you want to change the Quantity of the line you''re about to add?';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(ChangeQuantityQst, false)) then
            exit(false);

        POSSaleLine.Validate(Quantity, -POSSaleLine.Quantity);
        exit(POSSaleLine.Modify(true));
    end;
    #endregion
}