codeunit 6184500 "NPR CleanCash Wrapper"
{
    Access = Internal;

    var
        Text000: Label 'Create Sales in CleanCash';

    // Append to Print Receipt
    local procedure PrintCleanCash(var LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; var PosEntry: Record "NPR POS Entry")
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
    begin

        CleanCashTransaction.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
        CleanCashTransaction.SetFilter("Request Send Status", '=%1', CleanCashTransaction."Request Send Status"::COMPLETE);

        CleanCashTransaction.SetFilter("Request Type", '=%1', CleanCashTransaction."Request Type"::RegisterSalesReceipt);
        if (CleanCashTransaction.FindLast()) then
            PrintCleanCashTransaction(LinePrintMgt, CleanCashTransaction."Entry No.");

        CleanCashTransaction.SetFilter("Request Type", '=%1', CleanCashTransaction."Request Type"::RegisterReturnReceipt);
        if (CleanCashTransaction.FindLast()) then
            PrintCleanCashTransaction(LinePrintMgt, CleanCashTransaction."Entry No.");
    end;

    // Append to Print Receipt
    local procedure PrintCleanCashTransaction(var LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; TransactionEntryNo: Integer)
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        CleanCash: Interface "NPR CleanCash XCCSP Interface";
    begin
        if (not CleanCashTransaction.Get(TransactionEntryNo)) then
            exit;

        CleanCash := CleanCashTransaction."Request Type";
        CleanCash.AddToPrintBuffer(LinePrintMgt, CleanCashTransaction);
    end;

    // Subscriber to Footer Event in printing
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Aux: Event Publishers", 'OnSalesReceiptFooter', '', true, false)]
    local procedure OnReceiptFooter(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text; LinePrintMgt: Codeunit "NPR RP Line Print Mgt.")
    var
        PosEntry: Record "NPR POS Entry";
    begin
        LinePrintMgt.SetFont(TemplateLine."Type Option");
        LinePrintMgt.SetBold(TemplateLine.Bold);
        LinePrintMgt.SetUnderLine(TemplateLine.Underline);

        // TODO: A potential problem here, if different number series that overlap are used on different POS Units
        PosEntry.SetFilter("Document No.", '=%1', ReceiptNo);

        if (PosEntry.FindLast()) then
            PrintCleanCash(LinePrintMgt, PosEntry);
    end;

    // Insert the workflow step in  POS Workflows
    [Obsolete('Remove after POS Scenario is removed', '2024-03-28')]
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'CreateCleanCashOnSale' then
            exit;

        Rec.Description := Text000;
        Rec."Sequence No." := 10;
    end;

    [Obsolete('Remove after POS Scenario is removed', '2024-03-28')]
    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR CleanCash Wrapper");
    end;


    // This method stores the receipt in CleanCash Black Box
    procedure HandleCleanCashXCCSPReceipt(var PosEntry: Record "NPR POS Entry")
    var
        CleanCashXCCSP: Codeunit "NPR CleanCash XCCSP Protocol";
    begin
        CleanCashXCCSP.StoreReceipt(PosEntry);
    end;

    procedure CreateCleanCashOnPOSSale(SalePOS: Record "NPR POS Sale")
    var
        PosEntry: Record "NPR POS Entry";
        ResponseText: Text;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        if (not IsCleanCashXCCSPComplianceEnabled(SalePOS."Register No.")) then
            exit;

        PosEntry.SetCurrentKey("Document No.");
        PosEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if not PosEntry.FindFirst() then
            exit;

        if PosEntry."Entry Type" in [PosEntry."Entry Type"::Other, PosEntry."Entry Type"::"Cancelled Sale"] then
            exit;

        if (not IsCleanCashSetupValid(PosEntry."POS Unit No.", ResponseText)) then
            Message(ResponseText);

        Sentry.StartSpan(Span, 'bc.pos.endsale.cleancash');
        HandleCleanCashXCCSPReceipt(PosEntry);
        Span.Finish();
    end;


    // Check that CleanCash Audit Handler has been activated
    local procedure IsCleanCashXCCSPComplianceEnabled(POSUnitNo: Code[10]): Boolean
    var
        PosUnit: Record "NPR POS Unit";
        PosAuditProfile: Record "NPR POS Audit Profile";
    begin
        if (not PosUnit.Get(PosUnitNo)) then
            exit(false);

        if (PosUnit."POS Audit Profile" = '') then
            exit(false);

        if (not PosAuditProfile.Get(PosUnit."POS Audit Profile")) then
            exit(false);

        exit(IsCleanCashXCCSPComplianceEnabled(PosAuditProfile));
    end;

    local procedure IsCleanCashXCCSPComplianceEnabled(PosAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        CleanCashXCCSP: Codeunit "NPR CleanCash XCCSP Protocol";
    begin
        exit(PosAuditProfile."Audit Handler" = UpperCase(CleanCashXCCSP.HandlerCode()));
    end;

    // Check that CleanCash Setup is valid when Audit Handler is actived
    local procedure IsCleanCashSetupValid(PosUnitNo: Code[10]; var ResponseMessage: Text): Boolean
    var
        CleanCashSetup: Record "NPR CleanCash Setup";
        PosUnit: Record "NPR POS Unit";
        CCSetupNotFound: Label 'The "%1" for "%2" "%3" has enabled CleanCash as audit handler, but the CleanCash setup for "%2" "%3" is not found.';
        FieldMustHaveValue: Label '"%1" must have a value for field "%2", for "%3" "%4".';
    begin
        PosUnit.Get(PosUnitNo);

        ResponseMessage := '';

        if (not CleanCashSetup.Get(PosUnitNo)) then
            ResponseMessage := StrSubstNo(CCSetupNotFound, PosUnit.FieldName("POS Audit Profile"), PosUnit.TableName(), PosUnitNo);

        if (CleanCashSetup."CleanCash No. Series" = '') then
            ResponseMessage := StrSubstNo(FieldMustHaveValue, CleanCashSetup.TableName, CleanCashSetup.FieldName("CleanCash No. Series"), PosUnit.TableName(), PosUnitNo);

        if (CleanCashSetup."CleanCash Register No." = '') then
            ResponseMessage := StrSubstNo(FieldMustHaveValue, CleanCashSetup.TableName, CleanCashSetup.FieldName("CleanCash Register No."), PosUnit.TableName(), PosUnitNo);

        if (CleanCashSetup."Connection String" = '') then
            ResponseMessage := StrSubstNo(FieldMustHaveValue, CleanCashSetup.TableName, CleanCashSetup.FieldName("Connection String"), PosUnit.TableName(), PosUnitNo);

        if (CleanCashSetup."Organization ID" = '') then
            ResponseMessage := StrSubstNo(FieldMustHaveValue, CleanCashSetup.TableName, CleanCashSetup.FieldName("Organization ID"), PosUnit.TableName(), PosUnitNo);

        exit(ResponseMessage = '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Setup Safety Check", 'OnAfterValidateSetup', '', false, false)]
    local procedure OnBeforeLogin()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        //Error upon POS login if any configuration is missing or clearly not set according to compliance
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not POSUnit.GetProfile(POSAuditProfile) then
            exit;
        if not IsCleanCashXCCSPComplianceEnabled(POSAuditProfile) then
            exit;

        POSAuditProfile.TestField("Do Not Print Receipt on Sale", false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    var
        CleanCashXCCSP: Codeunit "NPR CleanCash XCCSP Protocol";
    begin
        if PosAuditProfile."Audit Handler" <> UpperCase(CleanCashXCCSP.HandlerCode()) then
            exit;

        Page.Run(Page::"NPR CleanCash Setup List");
    end;

    #region SE Fiscal Clean Cash - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        SEFiscalizationSetup: Record "NPR SE Fiscalization Setup.";
        CleanCashSetup: Record "NPR CleanCash Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        SEFiscalizationSetup.ChangeCompany(CompanyName);
        if not (SEFiscalizationSetup.Get() and SEFiscalizationSetup."Enable SE Fiscal") then
            exit;
        SEFiscalizationSetup.Delete();

        CleanCashSetup.ChangeCompany(CompanyName);
        CleanCashSetup.ModifyAll("Organization ID", '');
        CleanCashSetup.ModifyAll("CleanCash Register No.", '');
        CleanCashSetup.ModifyAll("CleanCash No. Series", '');
        CleanCashSetup.ModifyAll("Connection String", '');
    end;
#endif

    #endregion
}

