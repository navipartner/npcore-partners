codeunit 6150729 "POS Sales Print Mgt."
{
    // NPR5.39/MHA /20180202  CASE 302779 Object created - Implements POS Sales Workflow and overloads AuditRoll.PrintSalesReceipt()
    // NPR5.39/MMV /20180207  CASE 302687 Added support for POS Entry sales receipt.


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Print Sales Receipt';
        Text001: Label 'Sales ticket %1 is posted.\An error occured during the printing of sales ticket %1.\Try to re-print sales ticket %1 from retail-mainmenu under "Audit roll". If the re-printing is unsuccessfull a description of the occurred error will be shown.';
        Text002: Label 'Print Credit Voucher';

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'PrintReceiptOnSale':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 20;
                end;
            'PrintCreditVoucherOnSale':
                begin
                    Rec.Description := Text002;
                    Rec."Sequence No." := 30;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"POS Sales Print Mgt.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure PrintReceiptOnSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step"; SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
        Register: Record Register;
        NPRetailSetup: Record "NP Retail Setup";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'PrintReceiptOnSale' then
            exit;

        //-NPR5.39 [302687]
        if NPRetailSetup.Get then
            if NPRetailSetup."Advanced Posting Activated" then begin
                PrintPOSEntrySalesReceipt(SalePOS);
                exit;
            end;
        //+NPR5.39 [302687]
        //Legacy print:

        if not Register.Get(SalePOS."Register No.") then
            exit;

        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not AuditRoll.FindFirst then
            exit;

        if SalePOS."Send Receipt Email" and (Register."Sales Ticket Email Output" = Register."Sales Ticket Email Output"::"Prompt With Print Overrule") then
            exit;

        if not PrintSalesReceipt(AuditRoll, true, false) then
            Message(Text001, AuditRoll."Sales Ticket No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure PrintCreditVoucherOnSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step"; SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'PrintCreditVoucherOnSale' then
            exit;

        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not AuditRoll.FindFirst then
            exit;

        StdCodeunitCode.PrintCreditGiftVoucher(AuditRoll);
    end;

    procedure PrintSalesReceipt(var AuditRoll: Record "Audit Roll"; SilentError: Boolean; ViewDemand: Boolean): Boolean
    var
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        StdCodeunitCode.OnRunSetShowDemand(ViewDemand);

        if SilentError then
            exit(StdCodeunitCode.Run(AuditRoll));

        StdCodeunitCode.Run(AuditRoll);
    end;

    procedure PrintPOSEntrySalesReceipt(SalePOS: Record "Sale POS")
    var
        POSEntry: Record "POS Entry";
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        //-NPR5.39 [302687]
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if not POSEntry.FindFirst then
            exit;

        RecRef.GetTable(POSEntry);
        RetailReportSelectionMgt.SetRegisterNo(POSEntry."POS Unit No.");
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
        //+NPR5.39 [302687]
    end;
}

