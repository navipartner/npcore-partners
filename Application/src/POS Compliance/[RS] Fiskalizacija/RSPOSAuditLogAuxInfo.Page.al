page 6059907 "NPR RS POS Audit Log Aux. Info"
{
    ApplicationArea = NPRRSFiscal;
    Caption = 'RS POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Receipt Print, Receipt Mailing';
    SourceTable = "NPR RS POS Audit Log Aux. Info";
    SourceTableView = sorting("Audit Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Entry No. of the POS Entry record related to this record.';
                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        if not (Rec."Audit Entry Type" in [Rec."Audit Entry Type"::"POS Entry"]) then
                            exit;
                        POSEntry.FilterGroup(2);
                        POSEntry.SetRange("Entry No.", Rec."POS Entry No.");
                        POSEntry.FilterGroup(0);
                        POSEntryList.SetTableView(POSEntry);
                        POSEntryList.Run();
                    end;
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the POS store code.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the POS unit number.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Entry Date.';
                }
                field("RS Invoice Type"; Rec."RS Invoice Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Invoice Type.';
                }
                field("RS Transaction Type"; Rec."RS Transaction Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Transaction Type.';
                }
                field(SentFiscalToTax; SentFiscalToTax)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Fiscal sent to Tax';
                    ToolTip = 'Specifies if Fiscal has been sent to Tax Authority.';
                }
                field("Fiscal Bill Copies"; Rec."Fiscal Bill Copies")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies if the Fiscal Bill Copies were created.';
                    trigger OnDrillDown()
                    var
                        RSPOSAuditLogCopy: Record "NPR RS POS Audit Log Aux. Copy";
                        RSPOSAuditLogCopyPage: Page "NPR RS POS Audit Log Aux. Copy";
                    begin
                        RSPOSAuditLogCopyPage.Editable(false);
                        RSPOSAuditLogCopy.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                        RSPOSAuditLogCopy.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                        if not RSPOSAuditLogCopy.FindSet() then
                            exit;
                        RSPOSAuditLogCopyPage.SetTableView(RSPOSAuditLogCopy);
                        RSPOSAuditLogCopyPage.RunModal();
                    end;
                }
                field("Fiscal Bill E-Mails"; Rec."Fiscal Bill E-Mails")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies if the Fiscal Bill was E-mailed to the recipient.';
                    trigger OnDrillDown()
                    var
                        RSFiscalEMailLog: Record "NPR RS Fiscal E-Mail Log";
                        RSFiscalEMailLogs: Page "NPR RS Fiscal E-Mail Logs";
                    begin
                        RSFiscalEMailLogs.Editable(false);
                        RSFiscalEMailLog.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                        RSFiscalEMailLog.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                        if RSFiscalEMailLog.IsEmpty() then
                            exit;
                        RSFiscalEMailLogs.SetTableView(RSFiscalEMailLog);
                        RSFiscalEMailLogs.RunModal();
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part(FiscalPreview; "NPR RS Fiscal A.Info Privew FB")
            {
                ApplicationArea = NPRRSFiscal;
                SubPageLink = "Audit Entry Type" = field("Audit Entry Type"), "Audit Entry No." = field("Audit Entry No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SendFiscalToTax)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Send To Tax Auth.';
                Image = ReceivableBill;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action will try to send the fiscal bill to Tax Authority for evidenting it.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                    AlreadySentMsg: Label 'Fiscal Bill has already been sent to Tax Auth.';
                begin
                    if Rec.Signature <> '' then begin
                        Message(AlreadySentMsg);
                        exit;
                    end;
                    case Rec."RS Invoice Type" of
                        Rec."RS Invoice Type"::NORMAL,
                        Rec."RS Invoice Type"::TRAINING:
                            begin
                                if Rec."RS Transaction Type" in [Rec."RS Transaction Type"::SALE] then
                                    RSTaxCommunicationMgt.CreateNormalSale(Rec);
                                if Rec."RS Transaction Type" in [Rec."RS Transaction Type"::REFUND] then
                                    RSTaxCommunicationMgt.CreateNormalRefund(Rec);
                            end;
                        Rec."RS Invoice Type"::ADVANCE:
                            begin
                                if Rec."RS Transaction Type" in [Rec."RS Transaction Type"::SALE] then
                                    RSTaxCommunicationMgt.CreatePrepaymentSale(Rec);
                            end;
                    end;
                end;
            }
            action(CreateFiscalCopy)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Create Copy of Fiscal Bill';
                Enabled = Rec."RS Invoice Type" <> Rec."RS Invoice Type"::TRAINING;
                Image = ReceivableBill;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action will try create a copy non-fiscal receipt and send to Tax Authority for evidenting it.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                begin
                    if Rec.Signature = '' then begin
                        Message(FiscalNotSentMsg);
                        exit;
                    end;
                    case Rec."RS Invoice Type" of
                        Rec."RS Invoice Type"::NORMAL:
                            if (Rec."RS Transaction Type" in [Rec."RS Transaction Type"::SALE, Rec."RS Transaction Type"::REFUND]) then
                                RSTaxCommunicationMgt.CreateCopyFiscalReceipt(Rec);
                    end;
                end;
            }
            action(InputReturnInfo)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Input Return Reference Info';
                Image = InsertFromCheckJournal;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action will give you an option to insert return invoice reference information.';
                trigger OnAction()
                var
                    RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
                begin
                    RSAuditMgt.InputReturnReferenceInformation(Rec);
                end;
            }
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action(PrintReceipt)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Print Original Receipt';
                    Image = PrintVoucher;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Executing this action the original receipt will be printed without a copy non-fiscal receipt.';
                    trigger OnAction()
                    var
                        RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
                    begin
                        if Rec.Signature = '' then begin
                            Message(FiscalNotSentMsg);
                            exit;
                        end;
                        RSPTFPITryPrint.PrintReceipt(Rec);
                    end;
                }
                action(PrintCopyReceipt)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Print Last Copy Receipt';
                    Enabled = Rec."RS Invoice Type" <> Rec."RS Invoice Type"::TRAINING;
                    Image = PrintAttachment;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Executing this action the last copy of non-fiscal receipt will be printed without the original fiscal receipt.';
                    trigger OnAction()
                    var
                        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
                        RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
                    begin
                        Rec.CalcFields("Fiscal Bill Copies");
                        if not Rec."Fiscal Bill Copies" then
                            exit;
                        RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                        RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                        RSPOSAuditLogAuxCopy.FindLast();
                        if RSPOSAuditLogAuxCopy.Signature = '' then begin
                            Message(FiscalNotSentMsg);
                            exit;
                        end;
                        RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxCopy);
                    end;
                }
                action(PrintBothReceipts)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Print Original with Copy Receipt';
                    Image = PrepaymentPostPrint;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Executing this action the original receipt will be printed with a copy non-fiscal receipt.';
                    trigger OnAction()
                    var
                        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
                        RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
                    begin
                        if Rec.Signature = '' then begin
                            Message(FiscalNotSentMsg);
                            exit;
                        end;
                        RSPTFPITryPrint.PrintReceipt(Rec);
                        Rec.CalcFields("Fiscal Bill Copies");
                        if not Rec."Fiscal Bill Copies" then
                            exit;
                        RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                        RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                        RSPOSAuditLogAuxCopy.FindLast();
                        if RSPOSAuditLogAuxCopy.Signature = '' then begin
                            Message(FiscalNotSentMsg);
                            exit;
                        end;
                        RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxCopy);
                    end;
                }
                action(PrintA4v1Report)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Print A4 Fiscal v1';
                    Image = PrintVoucher;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Executing this action the original receipt will be printed in A4 format without a copy non-fiscal receipt.';
                    trigger OnAction()
                    var
                        RSFiscalBillA4v1: Report "NPR RS Fiscal Bill A4 v1";
                    begin
                        if Rec.Signature = '' then begin
                            Message(FiscalNotSentMsg);
                            exit;
                        end;
                        RSFiscalBillA4v1.SetFilters(Rec."Audit Entry Type", Rec."POS Entry No.", Rec."Source Document No.", Rec."Source Document Type");
                        RSFiscalBillA4v1.RunModal();
                    end;
                }
                action(PrintA4v2Report)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Print A4 Fiscal v2';
                    Image = PrintVoucher;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Executing this action the original receipt will be printed in A4 format without a copy non-fiscal receipt.';
                    trigger OnAction()
                    var
                        RSFiscalBillA4v2: Report "NPR RS Fiscal Bill A4 V2";
                    begin
                        if Rec.Signature = '' then begin
                            Message(FiscalNotSentMsg);
                            exit;
                        end;
                        RSFiscalBillA4v2.SetFilters(Rec."Audit Entry Type", Rec."POS Entry No.", Rec."Source Document No.", Rec."Source Document Type");
                        RSFiscalBillA4v2.RunModal();
                    end;
                }
                action("Send To Document E-mail")
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Send To Document E-mail';
                    Image = SendElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Send With Document E-mail action.';

                    trigger OnAction()
                    var
                        FiscalEMailMgt: Codeunit "NPR RS Fiscal E-Mail Mgt.";
                    begin
                        FiscalEMailMgt.Run(Rec);
                    end;
                }
                action("Send To Custom E-mail")
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Send To Custom E-mail';
                    Image = SendElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Send To Custom E-mail action.';

                    trigger OnAction()
                    var
                        MailManagement: Codeunit "Mail Management";
                        FiscalEMailMgt: Codeunit "NPR RS Fiscal E-Mail Mgt.";
                        EmailUserSpecifiedAddress: Page "Email User-Specified Address";
                        EmailRecipient: Text;
                    begin
                        if EmailUserSpecifiedAddress.RunModal() = Action::OK then
                            EmailRecipient := EmailUserSpecifiedAddress.GetEmailAddress()
                        else
                            exit;

                        if not MailManagement.CheckValidEmailAddress(EmailRecipient) then
                            Error(_EmailAddressNotValidErrLbl);

                        FiscalEMailMgt.SendFiscalBillViaEmail(Rec, EmailRecipient);
                    end;
                }
                action("Open Related Document")
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Open Related Document';
                    Image = Open;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Scope = Repeater;
                    ToolTip = 'Executes the Open Related Document action.';

                    trigger OnAction()
                    var
                        POSEntry: Record "NPR POS Entry";
                        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                        SalesHeader: Record "Sales Header";
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                    begin
                        case Rec."Audit Entry Type" of
                            Rec."Audit Entry Type"::"POS Entry":
                                begin
                                    POSEntry.Get(Rec."POS Entry No.");
                                    Page.RunModal(Page::"NPR POS Entry Card", POSEntry);
                                end;
                            Rec."Audit Entry Type"::"Sales Header":
                                begin
                                    SalesHeader.SetRange("Document Type", Rec."Source Document Type");
                                    SalesHeader.SetRange("No.", Rec."Source Document No.");
                                    if not SalesHeader.FindFirst() then
                                        exit;
                                    case Rec."Source Document Type" of
                                        Rec."Source Document Type"::Invoice:
                                            Page.RunModal(Page::"Sales Invoice", SalesHeader);
                                        Rec."Source Document Type"::Order:
                                            Page.RunModal(Page::"Sales Order", SalesHeader);
                                        Rec."Source Document Type"::Quote:
                                            Page.RunModal(Page::"Sales Quote", SalesHeader);
                                        Rec."Source Document Type"::"Credit Memo":
                                            Page.RunModal(Page::"Sales Credit Memo", SalesHeader);
                                    end;
                                end;
                            Rec."Audit Entry Type"::"Sales Invoice Header":
                                begin
                                    SalesInvoiceHeader.Get(Rec."Source Document No.");
                                    Page.RunModal(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                                end;
                            Rec."Audit Entry Type"::"Sales Cr.Memo Header":
                                begin
                                    SalesCrMemoHeader.Get(Rec."Source Document No.");
                                    Page.RunModal(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                                end;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then;
    end;

    trigger OnAfterGetRecord()
    begin
        SentFiscalToTax := Rec.Signature <> '';
    end;

    var
        SentFiscalToTax: Boolean;
        _EmailAddressNotValidErrLbl: Label 'E-Mail address is not in the valid format.';
        FiscalNotSentMsg: Label 'Fiscal Bill has not been sent to Tax Auth.';
}
