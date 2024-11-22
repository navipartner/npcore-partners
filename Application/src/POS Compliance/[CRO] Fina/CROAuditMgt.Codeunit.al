codeunit 6151547 "NPR CRO Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        CROFiscalSetup: Record "NPR CRO Fiscalization Setup";
        CROFiscalThermalPrint: Codeunit "NPR CRO Fiscal Thermal Print";
        CROTaxCommunicationMgt: Codeunit "NPR CRO Tax Communication Mgt.";
        Enabled: Boolean;
        Initialized: Boolean;
        CAPTION_CERT_SUCCESS: Label 'Certificate with thumbprint %1 was uploaded successfully';
        CAPTION_OVERWRITE_CERT: Label 'Are you sure you want to overwrite the existing certificate?';
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';

    #region CRO Fiscal - Event Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsCROAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddCROAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        CheckAreDataSetAndAccordingToCompliance(FrontEnd);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure POSUnitOnBeforeInsert(var Rec: Record "NPR POS Unit")
    var
        i: Integer;
        POSUnitNoMustNotContainLettersErr: Label 'POS Unit No. must not contain any letters or special characters! It can only contain digits (0-9).';
    begin
        if not IsCROFiscalActive() then
            exit;
        for i := 1 to StrLen(Rec."No.") do
            case Rec."No."[i] of
                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
              'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
              'u', 'v', 'w', 'x', 'y', 'z', 'U', 'V', 'W', 'X', 'Y', 'Z', '-', '.':
                    Error(POSUnitNoMustNotContainLettersErr)
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale");
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        IsHandled: Boolean;
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        Sender.GetLastSalePOSEntry(POSEntry);

        if not CROPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;

        InsertParagonNumberToAuditLog(SalePOS, CROPOSAuditLogAuxInfo);

        CalculateZKI(CROPOSAuditLogAuxInfo);

        CROTaxCommunicationMgt.CreateNormalSale(CROPOSAuditLogAuxInfo, false);

        Commit();
        OnBeforePrintFiscalReceipt(IsHandled);
        if IsHandled then
            exit;
        CROFiscalThermalPrint.PrintReceipt(CROPOSAuditLogAuxInfo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure OnBeforeHendleReverse(var SalesTicketNo: Code[20])
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
    begin
        if not IsCROFiscalActive() then
            exit;

        CROPOSAuditLogAuxInfo.SetLoadFields("Bill No.", "POS Entry No.");
        CROPOSAuditLogAuxInfo.SetRange("Bill No.", SalesTicketNo);
        if not CROPOSAuditLogAuxInfo.FindFirst() then
            exit;
        POSEntry.SetRange("Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        if not POSEntry.FindFirst() then
            exit;
        SalesTicketNo := POSEntry."Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header");
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
    begin
        if not IsCROFiscalActive() then
            exit;

        CROAuxSalesInvHeader.ReadCROAuxSalesInvHeaderFields(SalesInvHeader);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesInvHeader.TransferFields(CROAuxSalesHeader, false);
        CROAuxSalesInvHeader.SaveCROAuxSalesInvHeaderFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnAfterSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header");
    var
        CROAuxSalesCrMemoHeader: Record "NPR CRO Aux Sales Cr. Memo Hdr";
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
    begin
        if not IsCROFiscalActive() then
            exit;

        CROAuxSalesCrMemoHeader.ReadCROAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesCrMemoHeader."NPR CRO POS Unit" := CROAuxSalesHeader."NPR CRO POS Unit";
        CROAuxSalesCrMemoHeader.SaveCROAuxSalesCrMemoHeaderFields();
    end;

#if not BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCopyDocument', '', false, false)]
    local procedure OnAfterCreateCopyDocument(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
    begin
        if not IsCROFiscalActive() then
            exit;

        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesInvHeader.ReadCROAuxSalesInvHeaderFields(SalesInvoiceHeader);
        CROAuxSalesHeader.TransferFields(CROAuxSalesInvHeader, false);
        CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header");
    begin
        VerifyIsDataSetOnSalesDocuments(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]);
    begin
        if not IsCROFiscalActive() then
            exit;

        if SalesInvHdrNo <> '' then
            FiscalizeSalesInvoice(SalesInvHdrNo);
        if SalesCrMemoHdrNo <> '' then
            FiscalizeSalesCrMemo(SalesCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'CreateSalesHeaderOnBeforeSalesHeaderModify', '', false, false)]
    local procedure CreateSalesHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale");
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
    begin
        if not IsCROFiscalActive() then
            exit;

        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesHeader."NPR CRO POS Unit" := SalePOS."Register No.";
        CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();
    end;

    #endregion

    #region CRO Fiscal - Aux and Mapping Tables Cleanup

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesInvoiceHeader_OnAfterDeleteEvent(var Rec: Record "Sales Invoice Header"; RunTrigger: Boolean)
    var
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsCROFiscalActive() then
            exit;

        if CROAuxSalesInvHeader.Get(Rec.SystemId) then
            CROAuxSalesInvHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesCrMemoHeader_OnAfterDeleteEvent(var Rec: Record "Sales Cr.Memo Header"; RunTrigger: Boolean)
    var
        CROAuxSalesCrMemoHdr: Record "NPR CRO Aux Sales Cr. Memo Hdr";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsCROFiscalActive() then
            exit;

        if CROAuxSalesCrMemoHdr.Get(Rec.SystemId) then
            CROAuxSalesCrMemoHdr.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterDeleteAfterPosting', '', false, false)]
    local procedure SalesPost_OnAfterDeleteAfterPosting(SalesHeader: Record "Sales Header");
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
    begin
        if not IsCROFiscalActive() then
            exit;

        if CROAuxSalesHeader.Get(SalesHeader.SystemId) then
            CROAuxSalesHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalespersonPurchaser_OnAfterDeleteEvent(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        CROAuxSalespPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsCROFiscalActive() then
            exit;

        if CROAuxSalespPurch.Get(Rec.SystemId) then
            CROAuxSalespPurch.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Method", 'OnAfterDeleteEvent', '', false, false)]
    local procedure POSPaymentMethod_OnAfterDeleteEvent(var Rec: Record "NPR POS Payment Method"; RunTrigger: Boolean)
    var
        CROPOSPaymentMethod: Record "NPR CRO POS Paym. Method Mapp.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsCROFiscalActive() then
            exit;

        if CROPOSPaymentMethod.Get(Rec."Code") then
            CROPOSPaymentMethod.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PaymentMethod_OnAfterDeleteEvent(var Rec: Record "Payment Method"; RunTrigger: Boolean)
    var
        CROPaymentMethod: Record "NPR CRO Payment Method Mapping";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsCROFiscalActive() then
            exit;

        if CROPaymentMethod.Get(Rec."Code") then
            CROPaymentMethod.Delete();
    end;

    #endregion

    #region CRO Fiscal - Audit Profile Mgt
    local procedure AddCROAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'CRO_FINA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        CROFiscalizationSetup: Page "NPR CRO Fiscalization Setup";
    begin
        CROFiscalizationSetup.RunModal();
    end;

    #endregion

    #region CRO Fiscal - CRO Audit Log Mgt.

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
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertCROPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertCROPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        CROAuxSalespPurch: Record "NPR CRO Aux Salesperson/Purch.";
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        CROPOSAuditLogAuxInfo.Init();
        CROPOSAuditLogAuxInfo."Audit Entry Type" := CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        CROPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        CROPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        CROPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        CROPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        CROPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        CROPOSAuditLogAuxInfo."Log Timestamp" := POSEntry."Ending Time";
        CROPOSAuditLogAuxInfo."Total Amount" := POSEntry."Amount Incl. Tax";

        SalespersonPurchaser.Get(POSEntry."Salesperson Code");
        CROAuxSalespPurch.ReadCROAuxSalespersonFields(SalespersonPurchaser);
        CROAuxSalespPurch.TestField("NPR CRO Salesperson OIB");
        CROPOSAuditLogAuxInfo."Cashier ID" := CROAuxSalespPurch."NPR CRO Salesperson OIB";

        CheckPaymentMethod(POSEntry, CROPOSAuditLogAuxInfo);

        CROPOSAuditLogAuxInfo.Insert(true);
    end;

    local procedure InsertCROPOSAuditLogAuxInfo(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
        CROAuxSalespPurch: Record "NPR CRO Aux Salesperson/Purch.";
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        CROAuxSalesInvHeader.ReadCROAuxSalesInvHeaderFields(SalesInvoiceHeader);
        if CROAuxSalesInvHeader."NPR CRO POS Unit" = '' then
            exit(false);

        POSUnit.Get(CROAuxSalesInvHeader."NPR CRO POS Unit");
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            exit(false);

        CROPOSAuditLogAuxInfo.Init();
        CROPOSAuditLogAuxInfo."POS Unit No." := CROAuxSalesInvHeader."NPR CRO POS Unit";
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        CROPOSAuditLogAuxInfo."Audit Entry Type" := CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice";
        CROPOSAuditLogAuxInfo."Entry Date" := SalesInvoiceHeader."Posting Date";
        CROPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        CROPOSAuditLogAuxInfo."Source Document No." := SalesInvoiceHeader."No.";
        Evaluate(CROPOSAuditLogAuxInfo."Log Timestamp", Format(Time, 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
        CROPOSAuditLogAuxInfo."Total Amount" := SalesInvoiceHeader."Amount Including VAT";

        SalespersonPurchaser.Get(SalesInvoiceHeader."Salesperson Code");
        CROAuxSalespPurch.ReadCROAuxSalespersonFields(SalespersonPurchaser);
        CROPOSAuditLogAuxInfo."Cashier ID" := CROAuxSalespPurch."NPR CRO Salesperson OIB";

        CROPaymentMethodMapping.Get(SalesInvoiceHeader."Payment Method Code");
        CROPOSAuditLogAuxInfo.Validate("Payment Method Code", CROPaymentMethodMapping."Payment Method Code");

        CROPOSAuditLogAuxInfo.Insert(true);

        CROAuxSalesInvHeader."NPR CRO Audit Entry No." := CROPOSAuditLogAuxInfo."Audit Entry No.";
        CROAuxSalesInvHeader.SaveCROAuxSalesInvHeaderFields();
        exit(true);
    end;

    local procedure InsertCROPOSAuditLogAuxInfo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Boolean
    var
        CROAuxSalesCrMemoHeader: Record "NPR CRO Aux Sales Cr. Memo Hdr";
        CROAuxSalespPurch: Record "NPR CRO Aux Salesperson/Purch.";
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        CROAuxSalesCrMemoHeader.ReadCROAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        if CROAuxSalesCrMemoHeader."NPR CRO POS Unit" = '' then
            exit(false);

        POSUnit.Get(CROAuxSalesCrMemoHeader."NPR CRO POS Unit");
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            exit(false);

        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        CROPOSAuditLogAuxInfo.Init();
        CROPOSAuditLogAuxInfo."Audit Entry Type" := CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Credit Memo";
        CROPOSAuditLogAuxInfo."Entry Date" := SalesCrMemoHeader."Posting Date";
        CROPOSAuditLogAuxInfo."POS Unit No." := CROAuxSalesCrMemoHeader."NPR CRO POS Unit";
        CROPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        CROPOSAuditLogAuxInfo."Source Document No." := SalesCrMemoHeader."No.";
        Evaluate(CROPOSAuditLogAuxInfo."Log Timestamp", Format(Time, 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
        CROPOSAuditLogAuxInfo."Total Amount" := SalesCrMemoHeader."Amount Including VAT";

        SalespersonPurchaser.Get(SalesCrMemoHeader."Salesperson Code");
        CROAuxSalespPurch.ReadCROAuxSalespersonFields(SalespersonPurchaser);
        CROPOSAuditLogAuxInfo."Cashier ID" := CROAuxSalespPurch."NPR CRO Salesperson OIB";

        CROPaymentMethodMapping.Get(SalesCrMemoHeader."Payment Method Code");
        CROPOSAuditLogAuxInfo.Validate("Payment Method Code", CROPaymentMethodMapping."Payment Method Code");

        CROPOSAuditLogAuxInfo.Insert(true);

        CROAuxSalesCrMemoHeader."NPR CRO Audit Entry No." := CROPOSAuditLogAuxInfo."Audit Entry No.";
        CROAuxSalesCrMemoHeader.SaveCROAuxSalesCrMemoHeaderFields();
        exit(true);
    end;

    local procedure CheckAreDataSetAndAccordingToCompliance(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        CROAuxSalespPurch: Record "NPR CRO Aux Salesperson/Purch.";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        MissingOIBErr: Label 'Salesperson OIB must have a value in Salesperson/Purchaser. It cannot be zero or empty.';
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        CROAuxSalespPurch.ReadCROAuxSalespersonFields(SalespersonPurchaser);
        if CROAuxSalespPurch."NPR CRO Salesperson OIB" = 0 then
            Error(MissingOIBErr);
    end;

    local procedure CheckPaymentMethod(POSEntry: Record "NPR POS Entry"; var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        CROPOSPaymMethMapping: Record "NPR CRO POS Paym. Method Mapp.";
        CROPOSPaymMethMapping2: Record "NPR CRO POS Paym. Method Mapp.";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryPaymentLine2: Record "NPR POS Entry Payment Line";
        PaymentMappingNonExistentErr: Label 'Selected POS Payment Method Mapping does not exist.';
    begin
        POSEntry.CalcFields("Payment Lines");
        POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
        POSEntryPaymentLine2.SetLoadFields("POS Payment Method Code", "Amount (LCY)");

        case POSEntry."Payment Lines" of
            1:
                begin
                    POSEntryPaymentLine.SetFilter("Amount (LCY)", '>0');
                    POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                    if POSEntryPaymentLine.FindFirst() then begin
                        CROPOSPaymMethMapping.Get(POSEntryPaymentLine."POS Payment Method Code");
                        CROPOSAuditLogAuxInfo.Validate("Payment Method Code", CROPOSPaymMethMapping."Payment Method Code");
                    end;
                end;
            else begin
                POSEntryPaymentLine.SetFilter("Amount (LCY)", '>0');
                POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSEntryPaymentLine2.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSEntryPaymentLine2.SetFilter("Amount (LCY)", '>0');
                if not POSEntryPaymentLine.FindFirst() then
                    exit;
                if not CROPOSPaymMethMapping.Get(POSEntryPaymentLine."POS Payment Method Code") then
                    Error(PaymentMappingNonExistentErr);
                POSEntryPaymentLine2.SetFilter("POS Payment Method Code", '<>%1', POSEntryPaymentLine."POS Payment Method Code");
                if not POSEntryPaymentLine2.FindSet() then begin
                    CROPOSPaymMethMapping.Get(POSEntryPaymentLine."POS Payment Method Code");
                    CROPOSAuditLogAuxInfo.Validate("Payment Method Code", CROPOSPaymMethMapping."Payment Method Code");
                    exit;
                end;
                repeat
                    if not CROPOSPaymMethMapping2.Get(POSEntryPaymentLine2."POS Payment Method Code") then
                        Error(PaymentMappingNonExistentErr);
                    if CROPOSPaymMethMapping."Payment Method" <> CROPOSPaymMethMapping2."Payment Method" then begin
                        CROPOSPaymMethMapping.SetRange("Payment Method", "NPR CRO Payment Method"::Other);
                        if CROPOSPaymMethMapping.FindFirst() then
                            CROPOSAuditLogAuxInfo.Validate("Payment Method Code", CROPOSPaymMethMapping."Payment Method Code")
                        else
                            CROPOSAuditLogAuxInfo.Validate("Payment Method Code");
                    end else begin
                        CROPOSPaymMethMapping.Get(POSEntryPaymentLine."POS Payment Method Code");
                        CROPOSAuditLogAuxInfo.Validate("Payment Method Code", CROPOSPaymMethMapping."Payment Method Code");
                    end;
                until POSEntryPaymentLine2.Next() = 0;
            end
        end;
    end;

    internal procedure CalculateZKI(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        BaseValuePatternLbl: Label '%1%2%3%4%5%6', Locked = true;
        ResponseText: Text;
        ZKIBaseValue: Text;
    begin
        CROFiscalSetup.Get();

        ZKIBaseValue := StrSubstNo(BaseValuePatternLbl, CROFiscalSetup."Certificate Subject OIB", Format(CROPOSAuditLogAuxInfo."Entry Date", 10, '<Day,2>.<Month,2>.<Year4>') + 'T' + Format(CROPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24,2>:<Minutes,2>:<Seconds,2>'), CROPOSAuditLogAuxInfo."Bill No.", CROPOSAuditLogAuxInfo."POS Store Code", CROPOSAuditLogAuxInfo."POS Unit No.", FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount"));
        if SignZKICode(CROPOSAuditLogAuxInfo, ZKIBaseValue, ResponseText) then begin
#pragma warning disable AA0139
            CROPOSAuditLogAuxInfo."ZKI Code" := ResponseText;
#pragma warning restore AA0139
            CROPOSAuditLogAuxInfo.Modify();
        end;
    end;

    local procedure InsertParagonNumberToAuditLog(SalePOS: Record "NPR POS Sale"; var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        CROPOSSale: Record "NPR CRO POS Sale";
    begin
        if not CROPOSSale.Get(SalePOS.SystemId) then
            exit;

        CROPOSAuditLogAuxInfo."Paragon Number" := CROPOSSale."CRO Paragon Number";
        CROPOSAuditLogAuxInfo.Modify();
    end;

    local procedure FiscalizeSalesInvoice(SalesInvHdrNo: Code[20])
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not SalesInvoiceHeader.Get(SalesInvHdrNo) then
            exit;
        if not InsertCROPOSAuditLogAuxInfo(SalesInvoiceHeader) then
            exit;
        if not CROPOSAuditLogAuxInfo.GetAuditFromSalesInvoice(SalesInvHdrNo) then
            exit;
        CalculateZKI(CROPOSAuditLogAuxInfo);
        CROTaxCommunicationMgt.CreateNormalSale(CROPOSAuditLogAuxInfo, true);
        Commit();

        CROFiscalizationSetup.Get();
        if CROFiscalizationSetup."Print Receipt On Sales Doc." then
            CROFiscalThermalPrint.PrintReceipt(CROPOSAuditLogAuxInfo);
    end;

    local procedure FiscalizeSalesCrMemo(SalesCrMemoHdrNo: Code[20])
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
            exit;
        if not InsertCROPOSAuditLogAuxInfo(SalesCrMemoHeader) then
            exit;
        if not CROPOSAuditLogAuxInfo.GetAuditFromSalesCrMemo(SalesCrMemoHdrNo) then
            exit;
        CalculateZKI(CROPOSAuditLogAuxInfo);
        CROTaxCommunicationMgt.CreateNormalSale(CROPOSAuditLogAuxInfo, true);
        Commit();

        CROFiscalizationSetup.Get();
        if CROFiscalizationSetup."Print Receipt On Sales Doc." then
            CROFiscalThermalPrint.PrintReceipt(CROPOSAuditLogAuxInfo);
    end;

    #endregion

    #region CRO Fiscal - Procedures/Helper Functions
    internal procedure IsCROFiscalActive(): Boolean
    begin
        if not CROFiscalSetup.Get() then begin
            CROFiscalSetup.Init();
            CROFiscalSetup.Insert();
        end;
        exit(CROFiscalSetup."Enable CRO Fiscal");
    end;

    internal procedure IsCROAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - CRO POS Audit Log Aux. Info table caption';
    begin
        if not IsCROFiscalActive() then
            exit;

        CROPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not CROPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, CROPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - CRO POS Audit Log Aux. Info table caption';
    begin
        if not IsCROAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        CROPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not CROPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", CROPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure VerifyIsDataSetOnSalesDocuments(SalesHeader: Record "Sales Header")
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        CROAuxSalespPurch: Record "NPR CRO Aux Salesperson/Purch.";
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        NotCROAuditProfileErr: Label 'CRO Audit Profile is not selected on POS Unit No.: %1', Comment = '%1 - POS Unit No.';
    begin
        if not IsCROFiscalActive() then
            exit;
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);

        if CROAuxSalesHeader."NPR CRO POS Unit" = '' then
            exit;

        POSUnit.Get(CROAuxSalesHeader."NPR CRO POS Unit");
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            Error(NotCROAuditProfileErr, POSUnit."No.");

        SalesHeader.TestField("Payment Method Code");
        SalesHeader.TestField("Salesperson Code");
        CROPaymentMethodMapping.Get(SalesHeader."Payment Method Code");
        SalespersonPurchaser.Get(SalesHeader."Salesperson Code");
        CROAuxSalespPurch.ReadCROAuxSalespersonFields(SalespersonPurchaser);
        CROAuxSalespPurch.TestField("NPR CRO Salesperson OIB");
    end;

    internal procedure FormatDecimal(DecimalValue: Decimal): Text
    begin
        exit(Format(DecimalValue, 0, '<Precision,2:2><Standard Format,2>'));
    end;

    #endregion

    #region CRO Fiscal - XML Signing
    internal procedure SignXML(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; SigningContent: Text; var ResponseText: Text): Boolean
    var
        KeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        IsHandled: Boolean;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        InStr: InStream;
        RequestMessageLbl: Label '{"certificateBase64": "%1","certificatePass": "%2","ZKIBaseValue": "%3", "contentToSign": "%4"}', Locked = true;
        CertBase64: Text;
        Url: Text;
        XMLDocText: Text;
    begin
        CROFiscalSetup.SetAutoCalcFields("Signing Certificate");
        CROFiscalSetup.Get();

        CROFiscalSetup.TestField("Signing Certificate");
        CROFiscalSetup.TestField("Signing Certificate Password");
        CROPOSAuditLogAuxInfo.TestField("ZKI Code");

        CROFiscalSetup."Signing Certificate".CreateInStream(InStr);
        InStr.ReadText(CertBase64);
        XMLDocText := StrSubstNo(RequestMessageLbl, CertBase64, CROFiscalSetup."Signing Certificate Password", CROPOSAuditLogAuxInfo."ZKI Code", SigningContent);
        Content.WriteFrom(XMLDocText);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');

        OnBeforeSendHttpRequestForXMLSigning(ResponseText, CROPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit(true);

        Url := 'https://crocompilance.azurewebsites.net/api/SignReceipt?code=' + KeyVaultMgt.GetAzureKeyVaultSecret('CompilanceCROSignReceipt');
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            exit(true)
    end;

    internal procedure SignZKICode(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; BaseValue: Text; var ResponseText: Text): Boolean
    var
        KeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        InStr: InStream;
        RequestMessageLbl: Label '{"certificateBase64": "%1","certificatePass": "%2","ZKIBaseValue": "%3"}', Locked = true;
        CertBase64: Text;
        Url: Text;
        XMLDocText: Text;
        IsHandled: Boolean;
    begin
        CROFiscalSetup.SetAutoCalcFields("Signing Certificate");
        CROFiscalSetup.Get();

        CROFiscalSetup.TestField("Signing Certificate");
        CROFiscalSetup.TestField("Signing Certificate Password");

        CROFiscalSetup."Signing Certificate".CreateInStream(InStr);
        InStr.ReadText(CertBase64);
        XMLDocText := StrSubstNo(RequestMessageLbl, CertBase64, CROFiscalSetup."Signing Certificate Password", BaseValue);
        Content.WriteFrom(XMLDocText);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');

        OnBeforeSendHttpRequestForSignZKICode(ResponseText, IsHandled);
        if IsHandled then
            exit(true);

        Url := 'https://crocompilance.azurewebsites.net/api/GenerateZKI?code=' + KeyVaultMgt.GetAzureKeyVaultSecret('CompilanceCROGenerateZKI');
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            exit(true)
    end;

    internal procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);

        Headers.Add(HeaderName, HeaderValue);
    end;

    internal procedure SendHttpRequest(var RequestMessage: HttpRequestMessage; var ResponseText: Text; SkipErrorMessage: Boolean): Boolean
    var
        IsResponseSuccess: Boolean;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ErrorText: Text;
    begin
        Clear(ResponseMessage);
        IsResponseSuccess := Client.Send(RequestMessage, ResponseMessage);
        if (not IsResponseSuccess) then
            if SkipErrorMessage then
                exit(IsResponseSuccess)
            else
                Error(GetLastErrorText);

        IsResponseSuccess := ResponseMessage.IsSuccessStatusCode();
        if (not IsResponseSuccess) and (not SkipErrorMessage) and GuiAllowed then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) then
                ErrorText += ':\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;
        ResponseMessage.Content.ReadAs(ResponseText);
        exit(IsResponseSuccess);
    end;

    #endregion

    #region CRO Fiscal - Certificate Handling

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)

    procedure ImportCertificate()
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        X509Certificate2: Codeunit X509Certificate2;
        IStream: InStream;
        StartPosition: Integer;
        DialCaption: Label 'Upload Certificate';
        ExtFilter: Label 'p12', Locked = true;
        FileFilter: Label 'Certificate File (*.P12)|*.P12', Locked = true;
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        CertificateSubject: Text;
        CertificateThumbprint: Text;
        FileName: Text;
    begin
        CROFiscalSetup.Get();
        if CROFiscalSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(CROFiscalSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream, TextEncoding::UTF16);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, CROFiscalSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, CROFiscalSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        CROFiscalSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        X509Certificate2.GetCertificateSubject(Base64Cert, CROFiscalSetup."Signing Certificate Password", CertificateSubject);
        StartPosition := StrPos(CertificateSubject, 'HR');
        CertificateSubject := CopyStr(CertificateSubject, StartPosition, 100);
        CertificateSubject := DelChr(CertificateSubject, '=', 'HR, C=');

        CROFiscalSetup."Certificate Subject OIB" := CopyStr(CertificateSubject, 1, MaxStrLen(CROFiscalSetup."Certificate Subject OIB"));
        CertificateThumbprint := CROFiscalSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, CROFiscalSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        CROFiscalSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        CROFiscalSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, CROFiscalSetup."Signing Certificate Thumbprint");
    end;
#else
    procedure ImportCertificate()
    var
        IStream: InStream;
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        X509Certificate2: Codeunit X509Certificate2;
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        DialCaption: Label 'Upload Certificate';
        FileFilter: Label 'Certificate File (*.P12)|*.P12', Locked = true;
        ExtFilter: Label 'p12', Locked = true;
        FileName: Text;
        CertificateThumbprint: Text;
    begin
        CROFiscalSetup.Get();
        if CROFiscalSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(CROFiscalSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, CROFiscalSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, CROFiscalSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        CROFiscalSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        CertificateThumbprint := CROFiscalSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, CROFiscalSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        CROFiscalSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        CROFiscalSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, CROFiscalSetup."Signing Certificate Thumbprint");
    end;
#endif
    #endregion

    #region CRO Audit Mgt - Test Procedures

    internal procedure TestGetSignatureFromResponse(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; ResponseText: Text): Boolean
    var
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true;
        Document: XmlDocument;
        ChildNode: XmlNode;
        Node: XmlNode;
    begin
        XmlDocument.ReadFrom(ResponseText, Document);
        Document.GetChildElements().Get(1, ChildNode);
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'SignatureValue'), Node);
        if Node.AsXmlElement().InnerText() <> '' then
            exit(true);
    end;

    #endregion

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForXMLSigning(var ResponseText: Text; var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePrintFiscalReceipt(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForSignZKICode(var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;
}