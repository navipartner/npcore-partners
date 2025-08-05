codeunit 6184860 "NPR RS E-Invoice Mgt."
{
    Access = Internal;
    Permissions = TableData "Tenant Media" = rd;

    #region RS E-Invoice - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        RSEInvoiceSetup.ChangeCompany(CompanyName);
        if not (RSEInvoiceSetup.Get() and RSEInvoiceSetup."Enable RS E-Invoice") then
            exit;
        Clear(RSEInvoiceSetup."API Key");
        Clear(RSEInvoiceSetup."API URL");
        RSEInvoiceSetup.Modify();
    end;
#endif

    #endregion

    #region RS E-Invoice Mgt. Procedures

    procedure IsRSEInvoiceEnabled(): Boolean
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        if not RSEInvoiceSetup.Get() then
            exit(false);

        exit(RSEInvoiceSetup."Enable RS E-Invoice");
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure CheckJKBJSFormatValidity(JBKJSCode: Code[5])
    var
        FieldLengthErr: Label 'JBKJS Code must consist of 5 digits!';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;
        if (StrLen(JBKJSCode) < 5) and (not (StrLen(JBKJSCode) = 0)) then
            Error(FieldLengthErr);
    end;

    internal procedure CheckJMBGFormatValidity(JMBGCode: Code[13])
    var
        FieldLengthErr: Label 'JMBG must consist of 13 digits!';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;
        if (StrLen(JMBGCode) < 13) and (not (StrLen(JMBGCode) = 0)) then
            Error(FieldLengthErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure Customer_OnAfterDeleteEvent(var Rec: Record Customer; RunTrigger: Boolean)
    var
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsRSEInvoiceEnabled() then
            exit;
        if RSEIAuxCustomer.Get(Rec."No.") then
            RSEIAuxCustomer.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterDeleteEvent', '', false, false)]
    local procedure CompanyInformation_OnAfterDeleteEvent(var Rec: Record "Company Information"; RunTrigger: Boolean)
    var
        RSEIAuxCompanyInfo: Record "NPR RS EI Aux Company Info";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsRSEInvoiceEnabled() then
            exit;
        if RSEIAuxCompanyInfo.Get(Rec.SystemId) then
            RSEIAuxCompanyInfo.Delete();
    end;

#endif

    #endregion RS E-Invoice Mgt. Procedures

#if not (BC17 or BC18 or BC19 or BC20 or BC21)

    #region RS E-Invoice Purchase Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc(PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        IsHandled := ValidateIfPostingIsAllowed(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchInvHeaderInsert', '', false, false)]
    local procedure OnAfterPurchInvHeaderInsert(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; PreviewMode: Boolean)
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        RSEIAuxPurchInvHdr: Record "NPR RS EI Aux Purch. Inv. Hdr.";
    begin
        if PreviewMode then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxPurchInvHdr.ReadRSEIAuxPurchInvHdrFields(PurchInvHeader);
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(PurchHeader);
        RSEIAuxPurchInvHdr.TransferFields(RSEIAuxPurchHeader, false);
        RSEIAuxPurchInvHdr.SaveRSEIAuxPurchInvHdrFields();

        if RSEIAuxPurchHeader."NPR RS EI Prepayment" then begin
            PurchInvHeader."Prepayment Invoice" := true;
            PurchInvHeader.Modify();
        end;

        SetEInvoiceDocumentToPosted(PurchHeader."Vendor Invoice No.", PurchInvHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchCrMemoHeaderInsert', '', false, false)]
    local procedure OnAfterPurchCrMemoHeaderInsert(var PurchHeader: Record "Purchase Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PreviewMode: Boolean)
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        RSEIAuxPurchCrMemHdr: Record "NPR RS EI Aux Purch. CrMem Hdr";
    begin
        if PreviewMode then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxPurchCrMemHdr.ReadRSEIAuxPurchCrMemHdrFields(PurchCrMemoHdr);
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(PurchHeader);
        RSEIAuxPurchCrMemHdr.TransferFields(RSEIAuxPurchHeader, false);
        RSEIAuxPurchCrMemHdr.SaveRSEIAuxPurchCrMemoHdrFields();

        if RSEIAuxPurchHeader."NPR RS EI Prepayment" then begin
            PurchCrMemoHdr."Prepayment Credit Memo" := true;
            PurchCrMemoHdr.Modify();
        end;

        SetEInvoiceDocumentToPosted(PurchCrMemoHdr."Vendor Cr. Memo No.", PurchCrMemoHdr."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterDeleteAfterPosting', '', false, false)]
    local procedure PurchPost_OnAfterDeleteAfterPosting(PurchHeader: Record "Purchase Header")
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxPurchHeader.Get(PurchHeader.SystemId) then
            RSEIAuxPurchHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PurchaseHeader_OnAfterDeleteEvent(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxPurchHeader.Get(Rec.SystemId) then
            RSEIAuxPurchHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterRenameEvent', '', false, false)]
    local procedure PurchaseHeader_OnAfterRenameEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", xRec."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.ModifyAll("Document No.", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PurchaseInvoiceHeader_OnAfterDeleteEvent(var Rec: Record "Purch. Inv. Header"; RunTrigger: Boolean)
    var
        RSEIAuxPurchInvHdr: Record "NPR RS EI Aux Purch. Inv. Hdr.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxPurchInvHdr.Get(Rec.SystemId) then
            RSEIAuxPurchInvHdr.Delete();

        DeleteRelatedRSEInvoiceDocument(Rec."Order No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterRenameEvent', '', false, false)]
    local procedure PurchaseInvoiceHeader_OnAfterRenameEvent(var Rec: Record "Purch. Inv. Header"; var xRec: Record "Purch. Inv. Header"; RunTrigger: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", xRec."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.ModifyAll("Document No.", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Cr. Memo Hdr.", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PurchaseCrMemoHeader_OnAfterDeleteEvent(var Rec: Record "Purch. Cr. Memo Hdr."; RunTrigger: Boolean)
    var
        RSEIAuxPurchCrMemHdr: Record "NPR RS EI Aux Purch. CrMem Hdr";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxPurchCrMemHdr.Get(Rec.SystemId) then
            RSEIAuxPurchCrMemHdr.Delete();

        if not PurchInvHeader.Get(Rec."Applies-to Doc. No.") then
            exit;

        if Rec."Prepayment Credit Memo" then
            DeleteRelatedRSEInvoiceDocument(PurchInvHeader."Prepayment Order No.")
        else
            DeleteRelatedRSEInvoiceDocument(PurchInvHeader."Order No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Cr. Memo Hdr.", 'OnAfterRenameEvent', '', false, false)]
    local procedure PurchaseCrMemoHeader_OnAfterRenameEvent(var Rec: Record "Purch. Cr. Memo Hdr."; var xRec: Record "Purch. Cr. Memo Hdr."; RunTrigger: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", xRec."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.ModifyAll("Document No.", Rec."No.");
    end;

    #endregion RS E-Invoice Purchase Subscribers

    #region RS E-Invoice Sales Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header");
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEIAuxSalesInvHeader: Record "NPR RS EI Aux Sales Inv. Hdr.";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxSalesInvHeader.ReadRSEIAuxSalesInvHdrFields(SalesInvHeader);
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        RSEIAuxSalesInvHeader.TransferFields(RSEIAuxSalesHeader, false);
        RSEIAuxSalesInvHeader.SaveRSEIAuxSalesInvHdrFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnAfterSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header");
    var
        RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr";
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxSalesCrMemoHdr.ReadRSEIAuxSalesCrMemoHdrFields(SalesCrMemoHeader);
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        RSEIAuxSalesCrMemoHdr.TransferFields(RSEIAuxSalesHeader, false);
        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCopyDocument', '', false, false)]
    local procedure OnAfterCreateCopyDocument(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        RSEIAuxSalesInvHdr.ReadRSEIAuxSalesInvHdrFields(SalesInvoiceHeader);
        RSEIAuxSalesHeader.TransferFields(RSEIAuxSalesInvHdr, false);
        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterDeleteAfterPosting', '', false, false)]
    local procedure SalesPost_OnAfterDeleteAfterPosting(SalesHeader: Record "Sales Header")
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxSalesHeader.Get(SalesHeader.SystemId) then
            RSEIAuxSalesHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesHeader_OnAfterDeleteEvent(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxSalesHeader.Get(Rec.SystemId) then
            RSEIAuxSalesHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterRenameEvent', '', false, false)]
    local procedure SalesHeader_OnAfterRenameEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", xRec."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.ModifyAll("Document No.", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesInvoiceHeader_OnAfterDeleteEvent(var Rec: Record "Sales Invoice Header"; RunTrigger: Boolean)
    var
        RSEIAuxSalesInvHeader: Record "NPR RS EI Aux Sales Inv. Hdr.";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxSalesInvHeader.ReadRSEIAuxSalesInvHdrFields(Rec);
        RSEIAuxSalesInvHeader.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterRenameEvent', '', false, false)]
    local procedure SalesInvoiceHeader_OnAfterRenameEvent(var Rec: Record "Sales Invoice Header"; var xRec: Record "Sales Invoice Header"; RunTrigger: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", xRec."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.ModifyAll("Document No.", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesCrMemoHeader_OnAfterDeleteEvent(var Rec: Record "Sales Cr.Memo Header"; RunTrigger: Boolean)
    var
        RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        if RSEIAuxSalesCrMemoHdr.Get(Rec.SystemId) then
            RSEIAuxSalesCrMemoHdr.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterRenameEvent', '', false, false)]
    local procedure SalesCrMemoHeader_OnAfterRenameEvent(var Rec: Record "Sales Cr.Memo Header"; var xRec: Record "Sales Cr.Memo Header"; RunTrigger: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not RunTrigger then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", xRec."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.ModifyAll("Document No.", Rec."No.");
    end;

    internal procedure CheckIfDocumentShouldBeSentToSEFBasedOnLocationCodeOnSalesLines(xSalesLine: Record "Sales Line"; var SalesLine: Record "Sales Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
    begin
        if not IsRSEInvoiceEnabled() then
            exit(false);
        if not (SalesLine.Type = SalesLine.Type::Item) then
            exit(false);
        if IsRetailLocation(SalesLine."Location Code") = IsRetailLocation(xSalesLine."Location Code") then
            exit(false);

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        if not RSEIAuxSalesHeader."NPR RS EI Send To SEF" then
            exit(false);
        RSEIAuxSalesHeader."NPR RS EI Send To SEF" := false;
        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure SalesPost_OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        Customer: Record Customer;
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
        ConfirmManagement: Codeunit "Confirm Management";
        EInvoiceCustomerNotSendingToSEFQst: Label 'The Customer %1 is an E-Invoice customer. The document %2 is not selected for sending to SEF. Are you sure you want to proceed?', Comment = '%1 = Customer No., %2 = Document No.';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;
        if SalesHeader."Sell-to Customer No." = '' then
            exit;
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        Customer.Get(SalesHeader."Sell-to Customer No.");
        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Customer);

        if not RSEIAuxCustomer."NPR RS E-Invoice Customer" then
            exit;

        if RSEIAuxSalesHeader."NPR RS EI Send To SEF" then
            exit;

        if not (ConfirmManagement.GetResponseOrDefault(StrSubstNo(EInvoiceCustomerNotSendingToSEFQst, SalesHeader."Sell-to Customer Name", SalesHeader."No."), false)) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', false, false)]
    local procedure SalesPost_OnRunOnBeforeFinalizePosting(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        RSEIOutSalesInvMgt: Codeunit "NPR RS EI Out Sales Inv. Mgt.";
        RSEIOutSalesCrMemoMgt: Codeunit "NPR RSEI Out SalesCr.Memo Mgt.";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        if SalesInvoiceHeader."No." <> '' then
            RSEIOutSalesInvMgt.CreateRequestAndSendSalesInvoice(SalesInvoiceHeader);

        if SalesCrMemoHeader."No." <> '' then
            RSEIOutSalesCrMemoMgt.CreateRequestAndSendSalesCrMemo(SalesCrMemoHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterPostPrepaymentsOnBeforeThrowPreviewModeError', '', false, false)]
    local procedure OnAfterPostPrepaymentsOnBeforeThrowPreviewModeError(var SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean)
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEIAuxSalesInvHeader: Record "NPR RS EI Aux Sales Inv. Hdr.";
        RSEIOutSalesInvMgt: Codeunit "NPR RS EI Out Sales Inv. Mgt.";
    begin
        if PreviewMode then
            exit;

        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);

        if SalesInvHeader."No." <> '' then begin
            RSEIAuxSalesInvHeader.ReadRSEIAuxSalesInvHdrFields(SalesInvHeader);
            RSEIAuxSalesInvHeader.TransferFields(RSEIAuxSalesHeader, false);
            RSEIAuxSalesInvHeader."NPR RS EI Tax Liability Method" := RSEIAuxSalesInvHeader."NPR RS EI Tax Liability Method"::"432";
            RSEIAuxSalesInvHeader."NPR RS EI Reference Number" := SalesInvHeader."No.";
            RSEIAuxSalesInvHeader.SaveRSEIAuxSalesInvHdrFields();
            RSEIOutSalesInvMgt.CreateRequestAndSendSalesInvoice(SalesInvHeader);
        end;
    end;

    #endregion RS E-Invoice Sales Subscribers

    #region RS E-Invoice Tax Exemption Mgt.

    internal procedure ApplyTaxExemptionReason(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        RSEIDocTaxExemption: Record "NPR RS EI Doc. Tax Exemption";
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
        RSEIDocTaxExemptionPage: Page "NPR RS EI Doc. Tax Exemption";
        TaxCategoriesList: List of [Enum "NPR RS EI Allowed Tax Categ."];
        TaxCategory: Enum "NPR RS EI Allowed Tax Categ.";
        MustChooseTaxExemptionReasonErr: Label 'You must choose Tax Exemption Reason for all entries exempted from tax.';
        NoTaxExemptedLinesErr: Label 'There are no tax exempted lines in this document.';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        SalesLine.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("VAT %", '=0');
        if SalesLine.IsEmpty() then
            Error(NoTaxExemptedLinesErr);

        SalesLine.FindSet();
        repeat
            RSEIVATPostSetupMap.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
            if not TaxCategoriesList.Contains(RSEIVATPostSetupMap."NPR RS EI Tax Category") then
                TaxCategoriesList.Add(RSEIVATPostSetupMap."NPR RS EI Tax Category");
        until SalesLine.Next() = 0;

        if TaxCategoriesList.Count() = 0 then
            exit;

        foreach TaxCategory in TaxCategoriesList do begin
            if not RSEIDocTaxExemption.Get(SalesHeader."No.", TaxCategory) then
                RSEIDocTaxExemption.Init();
            RSEIDocTaxExemption."Document No." := SalesHeader."No.";
            RSEIDocTaxExemption."Tax Category" := TaxCategory;
            if not RSEIDocTaxExemption.Insert() then
                RSEIDocTaxExemption.Modify();
        end;

        RSEIDocTaxExemption.SetRange("Document No.", SalesHeader."No.");
        RSEIDocTaxExemption.FindSet();
        repeat
            foreach TaxCategory in TaxCategoriesList do begin
                if not (RSEIDocTaxExemption."Tax Category" in [TaxCategory]) then
                    RSEIDocTaxExemption.Delete();
            end;
        until RSEIDocTaxExemption.Next() = 0;
        Commit();

        RSEIDocTaxExemption.SetRange("Document No.", SalesHeader."No.");
        if RSEIDocTaxExemption.IsEmpty() then
            exit;

        RSEIDocTaxExemption.FindSet();
        RSEIDocTaxExemptionPage.SetRecord(RSEIDocTaxExemption);
        RSEIDocTaxExemptionPage.SetTableView(RSEIDocTaxExemption);
        RSEIDocTaxExemptionPage.Editable(true);
        if RSEIDocTaxExemptionPage.RunModal() = Action::OK then begin
            RSEIDocTaxExemptionPage.GetRecord(RSEIDocTaxExemption);
            RSEIDocTaxExemption.SetRange("Tax Exemption Reason Code", '');
            if not RSEIDocTaxExemption.IsEmpty() then
                Error(MustChooseTaxExemptionReasonErr);
        end
    end;

    local procedure CheckForTaxExemptionReason(DocumentNo: Code[20]; RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.")
    var
        RSEIDocTaxExemption: Record "NPR RS EI Doc. Tax Exemption";
    begin
        if not RSEIDocTaxExemption.Get(DocumentNo, RSEIVATPostSetupMap."NPR RS EI Tax Category") then
            Error(SalesDocumentMustContainTaxExemptReasonErr, RSEIVATPostSetupMap."NPR RS EI Tax Category".Names.Get(RSEIVATPostSetupMap."NPR RS EI Tax Category".Ordinals.IndexOf(RSEIVATPostSetupMap."NPR RS EI Tax Category".AsInteger())),
                        RSEIDocTaxExemption.FieldCaption("Tax Exemption Reason Code"), RSEIDocTaxExemption.TableCaption());
    end;

    #endregion RS E-Invoice Tax Exemption Mgt.

    #region RS E-Invoice Sales Mgt. Helper Procedures

    internal procedure CheckIsDataSetOnSalesInvHeader(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
        CompanyInfo: Record "Company Information";
        RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.";
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
        PaymMethMappingNotFoundErr: Label 'Payment Method Mapping for %1: %2 has not been found in %3.', Comment = '%1 = Payment Method Code Caption, %2 = Payment Method Code, %3 = Payment Mapping Table Caption';
        TaxLiabilityCodeMustBeChosenErr: Label 'Tax Liability Code must not be empty.';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        RSEIAuxSalesInvHdr.ReadRSEIAuxSalesInvHdrFields(SalesInvoiceHeader);
        if not (RSEIAuxSalesInvHdr."NPR RS EI Send To SEF") then
            exit;

        if not SalesInvoiceHeader."Prepayment Invoice" then
            if (RSEIAuxSalesInvHdr."NPR RS EI Tax Liability Method" in [RSEIAuxSalesInvHdr."NPR RS EI Tax Liability Method"::" "]) and GuiAllowed() then
                Error(TaxLiabilityCodeMustBeChosenErr);
        CompanyInfo.Get();
        Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");

        CompanyInfo.TestField("Registration No.");
        CompanyInfo.TestField("VAT Registration No.");
        CompanyInfo.TestField("Bank Account No.");
        CompanyInfo.TestField(Address);
        CompanyInfo.TestField(City);
        CompanyInfo.TestField("Post Code");
        CompanyInfo.TestField("Country/Region Code");

        Customer.TestField("Registration Number");
        Customer.TestField("VAT Registration No.");
        Customer.TestField(Address);
        Customer.TestField(City);
        Customer.TestField("Post Code");
        Customer.TestField("Country/Region Code");

        if (not RSEIPaymentMethodMapp.Get(SalesInvoiceHeader."Payment Method Code")) and GuiAllowed() then
            Error(PaymMethMappingNotFoundErr, SalesInvoiceHeader.FieldCaption("Payment Method Code"), SalesInvoiceHeader."Payment Method Code", RSEIPaymentMethodMapp.TableCaption());

        CheckIsDataSetOnSalesInvLines(SalesInvoiceHeader);
    end;

    local procedure CheckIsDataSetOnSalesInvLines(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
    begin
        SalesInvoiceLine.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter("VAT %", '=0');
        if SalesInvoiceLine.IsEmpty() then
            exit;

        SalesInvoiceLine.FindSet();
        repeat
            RSEIVATPostSetupMap.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
            RSEIVATPostSetupMap.TestField("NPR RS EI Tax Category");
            CheckForTaxExemptionReason(SalesInvoiceHeader."Order No.", RSEIVATPostSetupMap);
        until SalesInvoiceLine.Next() = 0;
    end;

    internal procedure CheckIsDataSetOnSalesCrMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        Customer: Record Customer;
        CompanyInfo: Record "Company Information";
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
        PaymMethMappingNotFoundErr: Label 'Payment Method Mapping for %1: %2 has not been found in %3.', Comment = '%1 = Payment Method Code Caption, %2 = Payment Method Code, %3 = Payment Mapping Table Caption';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        CompanyInfo.Get();
        Customer.Get(SalesCrMemoHeader."Sell-to Customer No.");

        CompanyInfo.TestField("Registration No.");
        CompanyInfo.TestField("VAT Registration No.");
        CompanyInfo.TestField("Bank Account No.");
        CompanyInfo.TestField(Address);
        CompanyInfo.TestField(City);
        CompanyInfo.TestField("Post Code");
        CompanyInfo.TestField("Country/Region Code");

        Customer.TestField("Registration Number");
        Customer.TestField("VAT Registration No.");
        Customer.TestField(Address);
        Customer.TestField(City);
        Customer.TestField("Post Code");
        Customer.TestField("Country/Region Code");

        if (not RSEIPaymentMethodMapp.Get(SalesCrMemoHeader."Payment Method Code")) and GuiAllowed() then
            Error(PaymMethMappingNotFoundErr, SalesCrMemoHeader.FieldCaption("Payment Method Code"), SalesCrMemoHeader."Payment Method Code", RSEIPaymentMethodMapp.TableCaption());

        CheckIsDataSetOnSalesCrMemoLines(SalesCrMemoHeader);
    end;

    local procedure CheckIsDataSetOnSalesCrMemoLines(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
    begin
        SalesCrMemoLine.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter("VAT %", '=0');
        if SalesCrMemoLine.IsEmpty() then
            exit;

        case SalesCrMemoHeader."Prepayment Credit Memo" of
            true:
                begin
                    SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesCrMemoHeader."Prepayment Order No.");
                    if not SalesInvoiceHeader.FindFirst() then
                        exit
                end;
            false:
                if not SalesInvoiceHeader.Get(SalesCrMemoHeader."Applies-to Doc. No.") then
                    exit;
        end;

        SalesCrMemoLine.FindSet();
        repeat
            RSEIVATPostSetupMap.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group");
            RSEIVATPostSetupMap.TestField("NPR RS EI Tax Category");
            CheckForTaxExemptionReason(SalesInvoiceHeader."Order No.", RSEIVATPostSetupMap);
        until SalesCrMemoLine.Next() = 0;
    end;

    internal procedure CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header"): Boolean
    begin
        if not IsRSEInvoiceEnabled() then
            exit(false);

        exit(RSEIAuxSalesHeader."NPR RS EI Send To SEF");
    end;

    internal procedure CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr."): Boolean
    begin
        if not IsRSEInvoiceEnabled() then
            exit(false);

        exit(RSEIAuxSalesInvHdr."NPR RS EI Send To SEF");
    end;

    internal procedure CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr"): Boolean
    begin
        if not IsRSEInvoiceEnabled() then
            exit(false);

        exit(RSEIAuxSalesCrMemoHdr."NPR RS EI Send To SEF");
    end;

    internal procedure SetSalesHeaderFieldsFromCustomer(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        Customer.Get(SalesHeader."Sell-to Customer No.");
        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Customer);
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        RSEIAuxSalesHeader."NPR RS EI Send To SEF" := RSEIAuxCustomer."NPR RS E-Invoice Customer";
        RSEIAuxSalesHeader."NPR RS EI Send To CIR" := RSEIAuxCustomer."NPR RS EI CIR Customer";
        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
    end;

    internal procedure CheckIsRSEInvoiceSent(DocumentNo: Code[20]): Boolean
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        if not IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceDocument.SetRange("Document No.", DocumentNo);
        exit(not RSEInvoiceDocument.IsEmpty());
    end;

    internal procedure SetSalesAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.";
        RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr";
    begin
        if RSEInvoiceDocument.Posted then
            case RSEInvoiceDocument."Document Type" of
                RSEInvoiceDocument."Document Type"::"Sales Invoice":
                    RSEIAuxSalesInvHdr.SetRSEIAuxSalesInvHdrInvoiceStatus(RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
                RSEInvoiceDocument."Document Type"::"Sales Cr. Memo":
                    RSEIAuxSalesCrMemoHdr.SetRSEIAuxSalesCrMemoHdrInvoiceStatus(RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
            end
        else
            RSEIAuxSalesHeader.SetRSEIAuxSalesHeaderInvoiceStatus(RSEInvoiceDocument."Document Type", RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
    end;

    internal procedure IsRSEInvoiceCustomer(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);

        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Customer);
        exit(RSEIAuxCustomer."NPR RS E-Invoice Customer");
    end;

    internal procedure CheckIfDocumentShouldBeSent(CustomerNo: Code[20]; DocumentNo: Code[20]; SendToSEFChecked: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        NotAnEInvoiceCustomerQst: Label 'Customer %1 is not an E-Invoice customer. Are you sure document %2 should be sent to SEF?', Comment = '%1 = Customer No., %2 = Document No.';
        ShouldSendDocumentToSEFQst: Label 'Are you sure document %1 should be sent to SEF?', Comment = '%1 = Document No.';
    begin
        if not SendToSEFChecked then
            exit(false);

        if IsRSEInvoiceCustomer(CustomerNo) then
            exit(ConfirmManagement.GetResponseOrDefault(StrSubstNo(ShouldSendDocumentToSEFQst, DocumentNo), true))
        else
            exit(ConfirmManagement.GetResponseOrDefault(StrSubstNo(NotAnEInvoiceCustomerQst, CustomerNo, DocumentNo), true));
    end;

    internal procedure CheckIfSalesOrderCanBeSentToSEF(SalesHeader: Record "Sales Header"; RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header")
    var
        SalesLine: Record "Sales Line";
        DocumentWithRetailLinesCannotBeSentToSEFErr: Label 'Document that contains Sales Lines with retail location cannot be sent to SEF.';
    begin
        if not RSEIAuxSalesHeader."NPR RS EI Send To SEF" then
            exit;
        SalesLine.SetLoadFields("Location Code");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if not SalesLine.FindFirst() then
            exit;
        if IsRetailLocation(SalesLine."Location Code") then
            Error(DocumentWithRetailLinesCannotBeSentToSEFErr);
    end;

    local procedure IsRetailLocation(LocationCode: Code[10]): Boolean
    var
        Location: Record Location;
    begin
        if not Location.Get(LocationCode) then
            exit(false);
        exit(Location."NPR Retail Location");
    end;

    internal procedure ClearTenantMedia(MediaId: Guid)
    var
        TenantMedia: Record "Tenant Media";
    begin
        if TenantMedia.Get(MediaId) then
            TenantMedia.Delete(true);
    end;
    #endregion RS E-Invoice Sales Mgt. Helper Procedures

    #region RS E-Invoice Purchase Mgt. Helper Procedures

    local procedure ValidateIfPostingIsAllowed(PurchaseHeader: Record "Purchase Header") Handled: Boolean
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        CannotPostPurchaseDocIfEInvStatusNotApprovedErr: Label 'You cannot post Purchase Document %1 if RS E-Invoice Status is not Approved.', Comment = '%1 = Purchase Header No.';
    begin
        if not IsRSEInvoiceEnabled() then
            exit;
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(PurchaseHeader);
        if not RSEIAuxPurchHeader."NPR RS E-Invoice" then
            exit;
        if not (CheckIfPurchaseDocumentIsApproved(PurchaseHeader)) then begin
            Message(CannotPostPurchaseDocIfEInvStatusNotApprovedErr, PurchaseHeader."No.");
            Handled := true;
        end;

        PurchaseHeader.CalcFields("Amount Including VAT", Amount);

        if RSEIAuxPurchHeader."NPR RS EI Prepayment" then begin
            HandlePrepaymentAmountDiffOnPurchaseHeader(Handled, RSEIAuxPurchHeader, PurchaseHeader)
        end else
            HandleTotalAmountDiffOnPurchaseHeader(Handled, RSEIAuxPurchHeader, PurchaseHeader);
    end;

    local procedure HandlePrepaymentAmountDiffOnPurchaseHeader(var Handled: Boolean; RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header"; PurchaseHeader: Record "Purchase Header")
    var
        TotalTaxAmountLbl: Label 'Total Tax Amount';
    begin
        if (RSEIAuxPurchHeader."NPR RS EI Total Amount" = PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount) then
            exit;

        Message(EInvoiceTotalAmountsMustBeEqualErr, TotalTaxAmountLbl, RSEIAuxPurchHeader.FieldCaption("NPR RS EI Total Amount"));
        Handled := true;
    end;

    local procedure HandleTotalAmountDiffOnPurchaseHeader(var Handled: Boolean; RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header"; PurchaseHeader: Record "Purchase Header")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        if (RSEIAuxPurchHeader."NPR RS EI Total Amount" = PurchaseHeader."Amount Including VAT") then
            exit;

        RSEInvoiceSetup.Get();
        if RSEInvoiceSetup."Allow Zero Amt. Purchase Doc." then
            HandleAllowedTotalAmountDiffOnPurchaseHeader(Handled, RSEIAuxPurchHeader, PurchaseHeader)
        else
            HandleForbiddenTotalAmountDiffOnPurchaseHeader(Handled, RSEIAuxPurchHeader, PurchaseHeader);
    end;

    local procedure HandleAllowedTotalAmountDiffOnPurchaseHeader(var Handled: Boolean; RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header"; PurchaseHeader: Record "Purchase Header")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        EInvoiceTotalAmountsMustBeEqualQst: Label '%1 is not equal to %2. Are you sure you want to proceed with posting?', Comment = '%1 = Purchase Header Amount Incl. VAT, %2 = RS EI Aux Total Amount';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(StrSubstNo(EInvoiceTotalAmountsMustBeEqualQst, PurchaseHeader.FieldCaption("Amount Including VAT"), RSEIAuxPurchHeader.FieldCaption("NPR RS EI Total Amount")), false)) then
            Handled := true;
    end;

    local procedure HandleForbiddenTotalAmountDiffOnPurchaseHeader(var Handled: Boolean; RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header"; PurchaseHeader: Record "Purchase Header")
    begin
        Message(EInvoiceTotalAmountsMustBeEqualErr, PurchaseHeader.FieldCaption("Amount Including VAT"), RSEIAuxPurchHeader.FieldCaption("NPR RS EI Total Amount"));
        Handled := true;
    end;

    local procedure DeleteRelatedRSEInvoiceDocument(DocumentNo: Code[20])
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        RSEInvoiceDocument.SetRange(Direction, RSEInvoiceDocument.Direction::Incoming);
        RSEInvoiceDocument.SetRange("Document No.", DocumentNo);
        if not RSEInvoiceDocument.IsEmpty() then
            RSEInvoiceDocument.DeleteAll();
    end;

    local procedure CheckIfPurchaseDocumentIsApproved(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        PurchaseDocumentCannotBePostedIfNotApprovedMsg: Label 'Purchase Document cannot be posted unless it has been Approved.';
    begin
        RSEInvoiceDocument.SetLoadFields("Invoice Status");
        RSEInvoiceDocument.SetRange("Document No.", PurchaseHeader."No.");
        if not RSEInvoiceDocument.FindFirst() then
            exit;
        RSEICommunicationMgt.GetPurchaseDocumentStatus(RSEInvoiceDocument);
        if RSEInvoiceDocument."Invoice Status" in [RSEInvoiceDocument."Invoice Status"::APPROVED] then
            exit(true);
        Message(PurchaseDocumentCannotBePostedIfNotApprovedMsg);
        exit(RSEICommunicationMgt.AcceptIncomingPurchaseDocument(RSEInvoiceDocument));
    end;

    local procedure SetEInvoiceDocumentToPosted(InvoiceDocumentNo: Code[35]; DocumentNo: Code[20])
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        RSEInvoiceDocument.SetRange("Invoice Document No.", InvoiceDocumentNo);
        RSEInvoiceDocument.SetRange(Direction, RSEInvoiceDocument.Direction::Incoming);
        if not RSEInvoiceDocument.FindFirst() then
            exit;
        RSEInvoiceDocument."Posted" := true;
        RSEInvoiceDocument."Document No." := DocumentNo;
        RSEInvoiceDocument.Modify();
    end;

    internal procedure ProcessSelectedPurchaseInvoicesForImporting(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary)
    var
        RSEIInPurchInvMgt: Codeunit "NPR RS EI In Purch. Inv. Mgt.";
    begin
        if TempRSEInvoiceDocument.IsEmpty() then
            exit;

        if not (Page.RunModal(Page::"NPR RS E-Invoice Selection", TempRSEInvoiceDocument) = Action::LookupOK) then
            exit;

        CheckIsDocTypeSetOnAllEntries(TempRSEInvoiceDocument);
        TempRSEInvoiceDocument.SetFilter("Document Type", '<>%1', TempRSEInvoiceDocument."Document Type"::" ");
        if TempRSEInvoiceDocument.FindSet() then
            repeat
                RSEIInPurchInvMgt.InsertPurchaseDocument(TempRSEInvoiceDocument)
            until TempRSEInvoiceDocument.Next() = 0;
    end;

    local procedure CheckIsDocTypeSetOnAllEntries(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary)
    var
        DocumentTypeNotSetOnEntryMsg: Label 'Document Type is not set on all entries. The entries without document type selected will not be imported.';
    begin
        TempRSEInvoiceDocument.FindSet();
        repeat
            if TempRSEInvoiceDocument."Document Type" in [TempRSEInvoiceDocument."Document Type"::" "] then begin
                Message(DocumentTypeNotSetOnEntryMsg);
                exit;
            end;
        until TempRSEInvoiceDocument.Next() = 0;
    end;

    internal procedure IsRSLocalizationEnabled(): Boolean
    var
        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";
    begin
        exit(RSLocalisationMgt.GetLocalisationSetupEnabled());
    end;

    internal procedure SetLocalizationPrepaymentPurchaseHeader(PurchaseHeader: Record "Purchase Header")
    var
        RSPurchaseHeader: Record "NPR RS Purchase Header";
    begin
        RSPurchaseHeader.Read(PurchaseHeader.SystemId);
        RSPurchaseHeader.Prepayment := true;
        RSPurchaseHeader.Save();
    end;

    internal procedure SetPurchaseAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        RSEIAuxPurchInvHdr: Record "NPR RS EI Aux Purch. Inv. Hdr.";
        RSEIAuxPurchCrMemHdr: Record "NPR RS EI Aux Purch. CrMem Hdr";
    begin
        if RSEInvoiceDocument.Posted then
            case RSEInvoiceDocument."Document Type" of
                RSEInvoiceDocument."Document Type"::"Purchase Order":
                    RSEIAuxPurchInvHdr.SetRSEIAuxPurchInvHdrInvoiceStatus(RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
                RSEInvoiceDocument."Document Type"::"Purchase Invoice":
                    RSEIAuxPurchInvHdr.SetRSEIAuxPurchInvHdrInvoiceStatus(RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
                RSEInvoiceDocument."Document Type"::"Purchase Cr. Memo":
                    RSEIAuxPurchCrMemHdr.SetRSEIAuxPurchCrMemoHdrInvoiceStatus(RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
            end
        else
            RSEIAuxPurchHeader.SetRSEIAuxPurchHeaderInvoiceStatus(RSEInvoiceDocument."Document Type", RSEInvoiceDocument."Document No.", RSEInvoiceDocument."Invoice Status");
    end;

    #endregion RS E-Invoice Purchase Mgt. Helper Procedures

    #region RS E-Invoice XML Helper Procedures

    internal procedure GetDecimalValue(var Value: Decimal; Element: XmlElement; XPath: Text; NamespaceManager: XmlNamespaceManager): Boolean
    var
        Node: XmlNode;
    begin
        if (not Element.SelectSingleNode(XPath, NamespaceManager, Node)) then
            exit(false);
        if Evaluate(Value, Node.AsXmlElement().InnerText, 9) then
            exit(true);
    end;

    internal procedure GetTextValue(var Value: Text; Element: XmlElement; XPath: Text; NamespaceManager: XmlNamespaceManager): Boolean
    var
        Node: XmlNode;
    begin
        if (not Element.SelectSingleNode(XPath, NamespaceManager, Node)) then
            exit(false);
        Value := Node.AsXmlElement().InnerText();

        if Value <> '' then
            exit(true);
    end;

    internal procedure GetCecNamespace(): Text
    var
        CecUrnNamespaceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2', Locked = true;
    begin
        exit(CecUrnNamespaceLbl);
    end;

    internal procedure GetCacNamespace(): Text
    var
        CacUrnNamespaceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
    begin
        exit(CacUrnNamespaceLbl);
    end;

    internal procedure GetCbcNamespace(): Text
    var
        CbcUrnNamespaceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;
    begin
        exit(CbcUrnNamespaceLbl);
    end;

    internal procedure CreateXmlElement(Name: Text; NamespaceUrl: Text; Content: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name, NamespaceUrl);
        Element.Add(XmlText.Create(Content));
    end;

    internal procedure CreateXmlElementWAttribute(Name: Text; NamespaceUrl: Text; Content: Text; AttrName: Text; AttrValue: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name, NamespaceUrl);
        Element.Add(XmlText.Create(Content));
        Element.Add(XmlAttribute.Create(AttrName, AttrValue));
    end;

    internal procedure FormatTwoDecimals(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'));
    end;

    internal procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,0:0><Sign><Integer>'));
    end;

    internal procedure FormatVATRegistrationNoWithoutPrefix(VATRegistrationNo: Text[20]) VATRegNoOut: Text
    begin
        VATRegNoOut := DelChr(VATRegistrationNo.ToUpper(), '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    end;

    internal procedure FormatVATRegistrationNoWithPrefix(VATRegistrationNo: Text[20]): Text
    var
        FullVATRegNoFormatLbl: Label 'RS%1', Locked = true, Comment = '%1 = VAT Registration No.';
    begin
        if VATRegistrationNo.Contains('RS') then
            exit(VATRegistrationNo)
        else
            exit(StrSubstNo(FullVATRegNoFormatLbl, VATRegistrationNo));
    end;

    internal procedure FormatPaymentReferenceNumber(Model: Text[3]; ReferenceNumber: Text[23]): Text
    var
        ReferenceNumberFormatLbl: Label '(mod%1) %2', Comment = '%1 = Reference Model, %2 = Reference Number', Locked = true;
    begin
        if Model <> '' then
            exit(StrSubstNo(ReferenceNumberFormatLbl, Model, ReferenceNumber))
        else
            exit(ReferenceNumber);
    end;

    internal procedure GetAllowedTaxCategoryName(EnumInteger: Integer): Text
    var
        RSEIAllowedTaxCateg: Enum "NPR RS EI Allowed Tax Categ.";
    begin
        exit(RSEIAllowedTaxCateg.Names.Get(RSEIAllowedTaxCateg.Ordinals.IndexOf(EnumInteger)));
    end;

    internal procedure GetInvoiceTypeCodeFromText(TextValue: Text): Enum "NPR RS EI Invoice Type Code"
    begin
        exit(Enum::"NPR RS EI Invoice Type Code".FromInteger(Enum::"NPR RS EI Invoice Type Code".Ordinals().Get(Enum::"NPR RS EI Invoice Type Code".Names().IndexOf(TextValue))));
    end;

    #endregion RS E-Invoice XML Helper Procedures

    #region RS E-Invoice Calculation Helper Procedures

    internal procedure CalculateTotalVATAmounts(var TotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; var TotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; var VATPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; DocumentNo: Code[20])
    var
        VATEntry: Record "VAT Entry";
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
        TaxAmount: Decimal;
        TaxableAmount: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocumentNo);
        if VATEntry.IsEmpty() then
            exit;

        VATEntry.FindSet();
        repeat
            TaxableAmount := VATEntry.Base;
            TaxAmount := VATEntry.Amount;
            RSEIVATPostSetupMap.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
            if not TotalTaxAmountDict.Add(RSEIVATPostSetupMap."NPR RS EI Tax Category", TaxAmount) then begin
                TaxAmount += TotalTaxAmountDict.Get(RSEIVATPostSetupMap."NPR RS EI Tax Category");
                TotalTaxAmountDict.Set(RSEIVATPostSetupMap."NPR RS EI Tax Category", TaxAmount);
            end;
            if not TotalTaxableAmountDict.Add(RSEIVATPostSetupMap."NPR RS EI Tax Category", TaxableAmount) then begin
                TaxableAmount += TotalTaxableAmountDict.Get(RSEIVATPostSetupMap."NPR RS EI Tax Category");
                TotalTaxableAmountDict.Set(RSEIVATPostSetupMap."NPR RS EI Tax Category", TaxableAmount);
            end;
            RSEIVATPostSetupMap.CalcFields("VAT %");
            if not VATPercentagesDict.Add(RSEIVATPostSetupMap."NPR RS EI Tax Category", RSEIVATPostSetupMap."VAT %") then
                VATPercentagesDict.Set(RSEIVATPostSetupMap."NPR RS EI Tax Category", RSEIVATPostSetupMap."VAT %");
        until VATEntry.Next() = 0;
    end;

    internal procedure CalculateVATCategoriesOfDiscountLines(var DiscAmtPerCategoryDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; var VatPercentagesPerCategoryDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; DocumentNo: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
        DiscAmount: Decimal;
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        if SalesInvoiceLine.IsEmpty() then
            exit;

        SalesInvoiceLine.FindSet();
        repeat
            DiscAmount := SalesInvoiceLine."Inv. Discount Amount";
            RSEIVATPostSetupMap.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
            RSEIVATPostSetupMap.CalcFields("VAT %");
            if not DiscAmtPerCategoryDict.Add(RSEIVATPostSetupMap."NPR RS EI Tax Category", DiscAmount) then begin
                DiscAmount += DiscAmtPerCategoryDict.Get(RSEIVATPostSetupMap."NPR RS EI Tax Category");
                DiscAmtPerCategoryDict.Set(RSEIVATPostSetupMap."NPR RS EI Tax Category", DiscAmount);
            end;
            if not VatPercentagesPerCategoryDict.Add(RSEIVATPostSetupMap."NPR RS EI Tax Category", RSEIVATPostSetupMap."VAT %") then
                VatPercentagesPerCategoryDict.Set(RSEIVATPostSetupMap."NPR RS EI Tax Category", RSEIVATPostSetupMap."VAT %");
        until SalesInvoiceLine.Next() = 0;
    end;

    internal procedure GetPayableAmount(TotalAmountWithVAT: Decimal; PrepaymentSum: Decimal; InvoiceDiscount: Decimal): Decimal
    begin
        exit(TotalAmountWithVAT - PrepaymentSum - InvoiceDiscount);
    end;

    #endregion RS E-Invoice Calculation Helper Procedures

    #region RS E-Invoice Documents Download Procedures

    internal procedure DownloadDocument(RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        BaseDocumentValue: Text;
        FileName: Text;
    begin
        if RSEInvoiceDocument.Direction in [RSEInvoiceDocument.Direction::Outgoing] then
            if not RSEInvoiceDocument.GetDocumentPdfBase64(BaseDocumentValue) then
                RSEICommunicationMgt.GetSalesInvoice(RSEInvoiceDocument);

        FormatFileName(FileName, RSEInvoiceDocument, false, 0);

        if BaseDocumentValue = '' then
            RSEInvoiceDocument.GetDocumentPdfBase64(BaseDocumentValue);

        DownloadDocumentAsPDF(BaseDocumentValue, FileName);
    end;

    internal procedure DownloadAttachment(RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        BaseDocumentValues: List of [Text];
        BaseDocValue: Text;
        DataCompression: Codeunit "Data Compression";
        FileName: Text;
        AttachmentDoesntExistErr: Label 'This document does not contain an attachment.';
        FileAttachZipFormatLbl: Label '%1_Attachments.zip';
    begin
        if not RSEInvoiceDocument.GetDocumentAttachmentsBase64(BaseDocumentValues) then
            Error(AttachmentDoesntExistErr);

        if BaseDocumentValues.Count() = 1 then begin
            FormatFileName(FileName, RSEInvoiceDocument, true, 1);
            DownloadDocumentAsPDF(BaseDocumentValues.Get(1), FileName);
            exit;
        end;

        DataCompression.CreateZipArchive();

        foreach BaseDocValue in BaseDocumentValues do begin
            FormatFileName(FileName, RSEInvoiceDocument, true, BaseDocumentValues.IndexOf(BaseDocValue));
            AddFileToDataCommpression(DataCompression, RSEInvoiceDocument, BaseDocValue, BaseDocumentValues.IndexOf(BaseDocValue), FileName);
        end;

        FileName := StrSubstNo(FileAttachZipFormatLbl, RSEInvoiceDocument."Document No.");
        DownloadCompressedFile(DataCompression, FileName);
    end;

    local procedure FormatFileName(var FileName: Text; RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; IsAttachment: Boolean; Index: Integer)
    var
        FilePDFFormatLbl: Label 'Document_%1.pdf', Locked = true, Comment = '%1 = Document No.';
        FileAttachPDFFormatLbl: Label 'Document_%1_Attach_%2.pdf', Comment = '%1 = Document No., %2 = Attachment Index';
    begin
        if IsAttachment then
            FileName := StrSubstNo(FileAttachPDFFormatLbl, RSEInvoiceDocument."Document No.", Index)
        else
            FileName := StrSubstNo(FilePDFFormatLbl, RSEInvoiceDocument."Document No.");
    end;

    local procedure DownloadDocumentAsPDF(DocumentContent: Text; FileName: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
    begin
        TempBlob.CreateOutStream(OStream);
        Base64Convert.FromBase64(DocumentContent, OStream);
        TempBlob.CreateInStream(IStream);
        FileMgt.BLOBExport(TempBlob, FileName, true);
    end;

    local procedure AddFileToDataCommpression(var DataCompression: Codeunit "Data Compression"; RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; Base64Value: Text; Index: Integer; Filename: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
        OStream: OutStream;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        Base64Convert.FromBase64(Base64Value, OStream);
        TempBlob.CreateInStream(IStream);
        FormatFileName(FileName, RSEInvoiceDocument, true, Index);
        DataCompression.AddEntry(IStream, FileName);
    end;

    local procedure DownloadCompressedFile(DataCompression: Codeunit "Data Compression"; FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
        ZipArchiveFilterTxt: Label 'Zip File (*.zip)|*.zip', Locked = true;
        ZipArchiveSaveDialogTxt: Label 'Export Document Attachments';
    begin
        TempBlob.CreateOutStream(OStream);
        DataCompression.SaveZipArchive(OStream);
        DataCompression.CloseZipArchive();
        TempBlob.CreateInStream(IStream);

        DownloadFromStream(IStream, ZipArchiveSaveDialogTxt, '', ZipArchiveFilterTxt, FileName);
    end;

    #endregion RS E-Invoice Documents Download Procedures

    var
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        SalesDocumentMustContainTaxExemptReasonErr: Label 'Sales Document with Tax Category %1 must have a %2 in %3.', Comment = '%1 - Line No., %2 - Field Caption, %3 - Table Caption';
        EInvoiceTotalAmountsMustBeEqualErr: Label '%1 must be equal to %2.', Comment = '%1 = Purchase Header Amount Incl. VAT, %2 = RS EI Aux Total Amount';
#endif
}