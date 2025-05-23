page 6150768 "NPR SI POS Audit Log Aux. Info"
{
    ApplicationArea = NPRSIFiscal;
    Caption = 'SI POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Receipt Print,Download,Related';
    SourceTable = "NPR SI POS Audit Log Aux. Info";
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
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Audit Entry No.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the date of the entry creation.';
                }
                field("Log Timestamp"; Rec."Log Timestamp")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the time of the entry creation.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS Store Code related to this record.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS Unit No. related to this record.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Salesperson Code field.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Sales Book Invoice No."; Rec."Sales Book Invoice No.")
                {
                    Caption = 'Sales Book Receipt No.';
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the of the Sales Book Invoice Number of the related record. Sales Book Invoice is used when POS is out of order.';
                }
                field("Sales Book Serial No."; Rec."Sales Book Serial No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Sales Book Serial Number of the related document.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Total Amount of the related transaction.';
                }
                field("ZOI Code"; Rec."ZOI Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the ZOI Code - protective mark of the issuer, assigned by the POS system.';
                }
                field("EOR Code"; Rec."EOR Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the EOR Code -  unique receipt identifier, provided in the response message from TA.';
                }
                field("Validation Code"; Rec."Validation Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Validation Code.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-11-17';
                    ObsoleteReason = 'Not necessary on page.';
                }
                field("Receipt Fiscalized"; Rec."Receipt Fiscalized")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Receipt Fiscalized field.';
                }
                field("Fiscal Bill E-Mails"; Rec."Fiscal Bill E-Mails")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies if the Fiscal Bill was E-mailed to the recipient.';
                    trigger OnDrillDown()
                    var
                        SIFiscalEMailLog: Record "NPR SI Fiscal E-Mail Log";
                        SIFiscalEMailLogs: Page "NPR SI Fiscal E-Mail Logs";
                    begin
                        SIFiscalEMailLogs.Editable(false);
                        SIFiscalEMailLog.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                        SIFiscalEMailLog.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                        if SIFiscalEMailLog.IsEmpty() then
                            exit;
                        SIFiscalEMailLogs.SetTableView(SIFiscalEMailLog);
                        SIFiscalEMailLogs.RunModal();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendToTA)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Subsequently Fiscalize Bill';
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Executing this action, if not already, the bill will be sent to Tax Authorities.';
                trigger OnAction()
                var
                    SITaxCommunicationMgt: Codeunit "NPR SI Tax Communication Mgt.";
                    BillAlreadyFiscalizedErr: Label 'This receipt has already been fiscalized! (EOR Code Received from Tax Authorities)';
                begin
                    if Rec."EOR Code" <> '' then
                        Error(BillAlreadyFiscalizedErr);

                    SITaxCommunicationMgt.CreateNormalSale(Rec, true);
                    Rec."Subsequent Submit" := true;
                    Rec.Modify();
                end;
            }
            action(Print)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Print Receipt';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executing this action the receipt will be printed.';
                trigger OnAction()
                var
                    SIFiscalThermalPrint: Codeunit "NPR SI Fiscal Thermal Print";
                begin
                    SIFiscalThermalPrint.PrintReceipt(Rec);
                end;
            }
            action(PrintA4Report)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Print A4 Fiscal';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executing this action will print either the original or a copy of the receipt in A4 format.';
                trigger OnAction()
                var
                    SIFiscalBillA4: Report "NPR SI Fiscal Bill A4";
                begin
                    SIFiscalBillA4.SetFilters(Rec."Audit Entry Type", Rec."Audit Entry No.", Rec."Source Document No.");
                    SIFiscalBillA4.RunModal();
                end;
            }
            action("Send To Document E-mail")
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Send To Document E-mail';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executes the Send With Document E-mail action.';

                trigger OnAction()
                var
                    FiscalEMailMgt: Codeunit "NPR SI Fiscal E-Mail Mgt.";
                begin
                    FiscalEMailMgt.Run(Rec);
                end;
            }
            action("Send To Custom E-mail")
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Send To Custom E-mail';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executes the Send To Custom E-mail action.';

                trigger OnAction()
                var
                    MailManagement: Codeunit "Mail Management";
                    FiscalEMailMgt: Codeunit "NPR SI Fiscal E-Mail Mgt.";
                    EmailUserSpecifiedAddress: Page "Email User-Specified Address";
                    EmailRecipient: Text;
                    EmailAddressNotValidErrLbl: Label 'E-Mail address is not in the valid format.';
                begin
                    if EmailUserSpecifiedAddress.RunModal() <> Action::OK then
                        exit;

                    EmailRecipient := EmailUserSpecifiedAddress.GetEmailAddress();

                    if not MailManagement.CheckValidEmailAddress(EmailRecipient) then
                        Error(EmailAddressNotValidErrLbl);

                    FiscalEMailMgt.SendFiscalBillViaEmail(Rec, EmailRecipient);
                end;
            }
            action(DownloadRequest)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Download Request Message';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                ToolTip = 'The message sent to TA will be downloaded in the XML form.';
                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    FileNameLbl: Label '%1-request.xml', Locked = true;
                    OStream: OutStream;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Receipt Content".HasValue then begin
                        Rec."Receipt Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."Source Document No."), true);
                    end;
                end;
            }
            action(DownloadResponse)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Download Response Message';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                ToolTip = 'The message recived from TA will be downloaded in the XML form.';
                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    FileNameLbl: Label '%1-response.xml', Locked = true;
                    OStream: OutStream;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Response Content".HasValue then begin
                        Rec."Response Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."Source Document No."), true);
                    end;
                end;
            }

            action(OpenRelatedDocument)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Open Related Document';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                ToolTip = 'Opens the document related to the selected transaction record.';
                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    case Rec."Audit Entry Type" of
                        "NPR SI Audit Entry Type"::"POS Entry":
                            begin
                                POSEntry.Get(Rec."POS Entry No.");
                                Page.RunModal(Page::"NPR POS Entry Card", POSEntry);
                            end;
                        "NPR SI Audit Entry Type"::"Sales Invoice Header":
                            begin
                                SalesInvoiceHeader.Get(Rec."Source Document No.");
                                Page.RunModal(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                            end;
                        "NPR SI Audit Entry Type"::"Sales Cr. Memo Header":
                            begin
                                SalesCrMemoHeader.Get(Rec."Source Document No.");
                                Page.RunModal(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                            end;
                    end;
                end;
            }
            action(OpenRelatedSalesBook)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Open Related Salesbook Receipt';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                ToolTip = 'Opens the salesbook receipt related to the selected transaction record.';
                trigger OnAction()
                var
                    SISalesbookReceipt: Record "NPR SI Salesbook Receipt";
                begin
                    if Rec."Salesbook Entry No." = 0 then
                        exit;
                    SISalesbookReceipt.Get(Rec."Salesbook Entry No.");
                    Page.RunModal(Page::"NPR SI Salesbook Receipt", SISalesbookReceipt);
                end;
            }
        }
    }
}
