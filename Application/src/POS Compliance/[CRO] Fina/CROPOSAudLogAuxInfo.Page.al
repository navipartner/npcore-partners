page 6151213 "NPR CRO POS Aud. Log Aux. Info"
{
    ApplicationArea = NPRCROFiscal;
    Caption = 'CRO POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Receipt Print,Download,Related';
    SourceTable = "NPR CRO POS Aud. Log Aux. Info";
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
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Audit Entry No.';
                }
                field("Bill No."; Rec."Bill No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Fiscal Bill No.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the POS Entry No. related to this record.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the POS Store Code related to this record.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the POS Unit No. related to this record.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the entry date.';
                }
                field("Log Timestamp"; Rec."Log Timestamp")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the time of the record creation.';
                }
                field("Paragon Number"; Rec."Paragon Number")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Paragon Number related to this record.';
                }
                field("ZKI Code"; Rec."ZKI Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the ZKI - security code of the receipt issuer.';
                }
                field("JIR Code"; Rec."JIR Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the JIR - unique receipt identifier.';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Payment Method related to this transaction.';
                }
                field("Receipt Fiscalized"; Rec."Receipt Fiscalized")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies if the receipt is fiscalized or not.';
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
                ApplicationArea = NPRCROFiscal;
                Caption = 'Subsequently Fiscalize Bill';
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action, if not already, the bill will be sent to Tax Authorities.';
                trigger OnAction()
                var
                    CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
                    CROTaxCommunicationMgt: Codeunit "NPR CRO Tax Communication Mgt.";
                    BillAlreadyFiscalizedErr: Label 'You cannot fiscalize this receipt. It has already been fiscalized.';
                begin
                    if Rec."JIR Code" <> '' then
                        Error(BillAlreadyFiscalizedErr);
                    CROAuditMgt.CalculateZKI(Rec);
                    CROTaxCommunicationMgt.CreateNormalSale(Rec, true);
                end;
            }

            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action(PrintReceipt)
                {
                    ApplicationArea = NPRCROFiscal;
                    Caption = 'Print Receipt';
                    Image = PrintVoucher;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executing this action the receipt will be printed.';
                    trigger OnAction()
                    var
                        CROFiscalThermalPrint: Codeunit "NPR CRO Fiscal Thermal Print";
                    begin
                        CROFiscalThermalPrint.PrintReceipt(Rec);
                    end;
                }
            }

            action(DownloadRequest)
            {
                ApplicationArea = NPRCROFiscal;
                Caption = 'Download Request Message';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'The message sent to TA will be downloaded in the XML form.';
                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    FileNameLbl: Label '%1.xml', Locked = true;
                    OStream: OutStream;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Receipt Content".HasValue() then begin
                        Rec."Receipt Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."ZKI Code"), true);
                    end;
                end;
            }

            action("Open Related Document")
            {
                ApplicationArea = NPRCROFiscal;
                Caption = 'Open Related Document';
                Image = Open;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Opens the Document related to the selected transaction.';

                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    case Rec."Audit Entry Type" of
                        "NPR CRO Audit Entry Type"::"POS Entry":
                            begin
                                POSEntry.Get(Rec."POS Entry No.");
                                Page.RunModal(Page::"NPR POS Entry Card", POSEntry);
                            end;
                        Rec."Audit Entry Type"::"Sales Invoice":
                            begin
                                SalesInvoiceHeader.Get(Rec."Source Document No.");
                                Page.RunModal(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                            end;
                        Rec."Audit Entry Type"::"Sales Credit Memo":
                            begin
                                SalesCrMemoHeader.Get(Rec."Source Document No.");
                                Page.RunModal(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                            end;
                    end;
                end;
            }
            action(PrintA4Report)
            {
                ApplicationArea = NPRCROFiscal;
                Caption = 'Print A4 Fiscal';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executing this action the receipt will be printed in A4 format';
                trigger OnAction()
                var
                    CROFiscalBillA4: Report "NPR CRO Fiscal Bill A4";
                begin
                    CROFiscalBillA4.SetFilters(Rec."Audit Entry Type", Rec."Audit Entry No.", Rec."Source Document No.");
                    CROFiscalBillA4.RunModal();
                end;
            }
            action("Send To Document E-mail")
            {
                ApplicationArea = NPRCROFiscal;
                Caption = 'Send To Document E-mail';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executes the Send With Document E-mail action.';

                trigger OnAction()
                var
                    FiscalEMailMgt: Codeunit "NPR CRO Fiscal E-Mail Mgt.";
                begin
                    FiscalEMailMgt.Run(Rec);
                end;
            }
            action("Send To Custom E-mail")
            {
                ApplicationArea = NPRCROFiscal;
                Caption = 'Send To Custom E-mail';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executes the Send To Custom E-mail action.';

                trigger OnAction()
                var
                    MailManagement: Codeunit "Mail Management";
                    FiscalEMailMgt: Codeunit "NPR CRO Fiscal E-Mail Mgt.";
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
        }
    }
}