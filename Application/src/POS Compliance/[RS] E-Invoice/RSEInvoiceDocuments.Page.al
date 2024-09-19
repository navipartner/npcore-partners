page 6184547 "NPR RS E-Invoice Documents"
{
    Caption = 'RS E-Invoice Documents';
    ApplicationArea = NPRRSEInvoice;
    UsageCategory = Documents;
    PageType = List;
    SourceTable = "NPR RS E-Invoice Document";
    DelayedInsert = true;
    Extensible = false;
    Editable = false;
    PromotedActionCategories = 'New,Process,Report,Purchase Documents,Sales Documents,Download';
    AdditionalSearchTerms = 'Serbia E-Invoice Documents,RS E Invoice Documents';
    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Sales Invoice ID"; Rec."Sales Invoice ID")
                {
                    ToolTip = 'Specifies the value of the Sales Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Purchase Invoice ID"; Rec."Purchase Invoice ID")
                {
                    ToolTip = 'Specifies the value of the Purchase Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Direction; Rec.Direction)
                {
                    ToolTip = 'Specifies the value of the Direction field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Invoice Document No."; Rec."Invoice Document No.")
                {
                    ToolTip = 'Specifies the value of the Invoice Document No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Document Status"; FormatDocumentStatus)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the value of the Staus field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ToolTip = 'Specifies the value of the Supplier No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ToolTip = 'Specifies the value of the Supplier Name field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Sending Date"; Rec."Sending Date")
                {
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Created; Rec."Created")
                {
                    ToolTip = 'Specifies the value of the Created field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Posted; Rec."Posted")
                {
                    ToolTip = 'Specifies the value of the Posted field.';
                    ApplicationArea = NPRRSEInvoice;
                }
            }
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    actions
    {
        area(Processing)
        {
            action("Open Related Document")
            {
                Caption = 'Open Related Document';
                ToolTip = 'Executes the Open Related Document action.';
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = NPRRSEInvoice;

                trigger OnAction()
                begin
                    if Rec."Posted" then
                        OpenPostedDocument()
                    else
                        OpenUnpostedDocument();
                end;
            }
            group("Purchase Documents")
            {
                Image = PurchaseInvoice;
                Caption = 'Purchase Documents';
                action("Import Purchase Documents")
                {
                    Caption = 'Import New Documents';
                    ToolTip = 'Executes the Import New Documents action.';
                    Image = ImportLog;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;

                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                        RSEIDateDialog: Page "NPR RS EI Date Dialog";
                        EndDate: Date;
                        StartDate: Date;
                    begin
                        RSEIDateDialog.LookupMode(true);
                        if RSEIDateDialog.RunModal() <> Action::LookupOK then
                            exit;
                        StartDate := RSEIDateDialog.GetStartDate();
                        EndDate := RSEIDateDialog.GetEndDate();

                        RSEICommunicationMgt.ImportNewPurchaseInvoiceDocuments(StartDate, EndDate);
                    end;
                }
                action("Refresh Purchase Status")
                {
                    Caption = 'Refresh Documents Status';
                    ToolTip = 'Executes the Refresh Document Status action.';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                        DateDialog: Page "Date-Time Dialog";
                        RefreshStatusDate: Date;
                    begin
                        DateDialog.UseDateOnly();
                        DateDialog.SetDate(CalcDate('<-1D>', Today()));
                        if DateDialog.RunModal() <> Action::OK then
                            exit;

                        RefreshStatusDate := DateDialog.GetDate();
                        RSEICommunicationMgt.RefreshPurchaseDocumentsStatus(RefreshStatusDate);
                    end;
                }
                action("Accept Purchase Document")
                {
                    Caption = 'Accept Purchase Document';
                    ToolTip = 'Executes the Accept Purchase Document action.';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        RSEICommunicationMgt.GetPurchaseDocumentStatus(Rec);
                        CurrPage.Update(true);
                        if Rec."Invoice Status" in [Rec."Invoice Status"::APPROVED] then
                            exit;
                        RSEICommunicationMgt.AcceptIncomingPurchaseDocument(Rec);
                    end;
                }
                action("Reject Purchase Document")
                {
                    Caption = 'Reject Purchase Document';
                    ToolTip = 'Executes the Reject Purchase Document action.';
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        RSEICommunicationMgt.GetPurchaseDocumentStatus(Rec);
                        CurrPage.Update(true);
                        if Rec."Invoice Status" in [Rec."Invoice Status"::REJECTED] then
                            exit;
                        RSEICommunicationMgt.RejectIncomingPurchaseDocument(Rec);
                    end;
                }
                action("Get Purchase Document Status")
                {
                    Caption = 'Get Purchase Document Status';
                    ToolTip = 'Executes the Get Purchase Document Status action.';
                    Image = Status;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        RSEICommunicationMgt.GetPurchaseDocumentStatus(Rec);
                        CurrPage.Update(true);
                    end;
                }
            }

            group("Sales Documents")
            {
                Caption = 'Sales Documents';
                Image = SalesInvoice;

                action("Refresh Sales Status")
                {
                    Caption = 'Refresh Document Status';
                    ToolTip = 'Executes the Refresh Document Status action.';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                        DateDialog: Page "Date-Time Dialog";
                        RefreshStatusDate: Date;
                    begin
                        DateDialog.UseDateOnly();
                        DateDialog.SetDate(CalcDate('<-1D>', Today()));
                        if DateDialog.RunModal() <> Action::OK then
                            exit;

                        RefreshStatusDate := DateDialog.GetDate();
                        RSEICommunicationMgt.RefreshSalesDocumentStatus(RefreshStatusDate);
                    end;
                }
                action("Get Sales Document Status")
                {
                    Caption = 'Get Sales Document Status';
                    ToolTip = 'Executes the Get Sales Document Status action.';
                    Image = Status;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        RSEICommunicationMgt.GetSalesDocumentStatus(Rec);
                        CurrPage.Update(true);
                    end;
                }
                action("Resend Sales Document")
                {
                    Caption = 'Resend Sales Document';
                    ToolTip = 'Executes the Resend Sales Document action.';
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        RSEICommunicationMgt.ResendSalesDocument(Rec);
                        CurrPage.Update(true);
                    end;
                }
                action("Cancel Sales Document")
                {
                    Caption = 'Cancel Sales Document';
                    ToolTip = 'Executes the Cancel Sales Document action.';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        RSEICommunicationMgt.CancelSalesInvoiceDocument(Rec);
                        CurrPage.Update(true);
                    end;
                }
            }

            group(Download)
            {
                Caption = 'Download';
                Image = Download;

                action(DownloadRequest)
                {
                    Caption = 'Download Request Message';
                    ToolTip = 'The message sent to E-Invoice API will be downloaded in the XML form.';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;

                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                        TempBlob: Codeunit "Temp Blob";
                        OStream: OutStream;
                        BaseDocumentValue: Text;
                        FileNameLbl: Label '%1.xml', Locked = true;
                    begin
                        if Rec.Direction in [Rec.Direction::Outgoing] then
                            if not Rec.GetDocumentPdfBase64(BaseDocumentValue) then
                                RSEICommunicationMgt.GetSalesInvoice(Rec);

                        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                        if Rec."Request Content".HasValue() then begin
                            Rec."Request Content".ExportStream(OStream);
                            case Rec.Direction of
                                Rec.Direction::Outgoing:
                                    FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."Sales Invoice Id"), true);
                                Rec.Direction::Incoming:
                                    FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."Purchase Invoice Id"), true);
                            end;
                        end;
                    end;
                }
                action(DownloadReceived)
                {
                    Caption = 'Download Response Message';
                    ToolTip = 'The message received from E-Invoice API will be downloaded in the XML form.';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        TempBlob: Codeunit "Temp Blob";
                        OStream: OutStream;
                        FileNameJsonLbl: Label '%1.json', Locked = true;
                        FileNameXmlLbl: Label '%1.xml', Locked = true;
                    begin
                        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                        if Rec."Response Content".HasValue() then begin
                            Rec."Response Content".ExportStream(OStream);
                            case Rec.Direction of
                                Rec.Direction::Outgoing:
                                    FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameJsonLbl, Rec."Sales Invoice Id"), true);
                                Rec.Direction::Incoming:
                                    FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameXmlLbl, Rec."Purchase Invoice Id"), true);
                            end;
                        end;
                    end;
                }
                action(DownloadDocumentPDF)
                {
                    Caption = 'Download Document PDF';
                    ToolTip = 'The document PDF from E-Invoice API will be downloaded.';
                    Image = SendAsPDF;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
                    begin
                        RSEInvoiceMgt.DownloadDocument(Rec);
                    end;
                }
                action(DownloadAttachmentPDF)
                {
                    Caption = 'Download Document Attachment';
                    ToolTip = 'The document attachment from E-Invoice API will be downloaded in the PDF form.';
                    Image = SendAsPDF;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnAction()
                    var
                        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
                    begin
                        RSEInvoiceMgt.DownloadAttachment(Rec);
                    end;
                }
            }
        }
    }
#endif

    trigger OnAfterGetRecord()
    var
        RSEIDocumentStatus: Enum "NPR RS E-Invoice Status";
    begin
        FormatDocumentStatus := RSEIDocumentStatus.Names().Get(RSEIDocumentStatus.Ordinals.IndexOf(Rec."Invoice Status".AsInteger()));
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)

    local procedure OpenUnpostedDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case Rec."Document Type" of
            "NPR RS EI Document Type"::"Purchase Order":
                begin
                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Document No.");
                    Page.RunModal(Page::"Purchase Order", PurchaseHeader)
                end;
            "NPR RS EI Document Type"::"Purchase Invoice":
                begin
                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, Rec."Document No.");
                    Page.RunModal(Page::"Purchase Invoice", PurchaseHeader)
                end;
            "NPR RS EI Document Type"::"Purchase Cr. Memo":
                begin
                    PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", Rec."Document No.");
                    Page.RunModal(Page::"Purchase Credit Memo", PurchaseHeader)
                end;
            "NPR RS EI Document Type"::"Sales Invoice":
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, Rec."Document No.");
                    Page.RunModal(Page::"Sales Invoice", SalesHeader)
                end;
            "NPR RS EI Document Type"::"Sales Cr. Memo":
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", Rec."Document No.");
                    Page.RunModal(Page::"Sales Credit Memo", SalesHeader)
                end;
        end;
    end;

    local procedure OpenPostedDocument()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        case Rec."Document Type" of
            "NPR RS EI Document Type"::"Purchase Order", "NPR RS EI Document Type"::"Purchase Invoice":
                begin
                    PurchInvHeader.Get(Rec."Document No.");
                    Page.RunModal(Page::"Posted Purchase Invoice", PurchInvHeader);
                end;
            "NPR RS EI Document Type"::"Purchase Cr. Memo":
                begin
                    PurchCrMemoHdr.Get(Rec."Document No.");
                    Page.RunModal(Page::"Posted Purchase Credit Memo", PurchCrMemoHdr);
                end;
            "NPR RS EI Document Type"::"Sales Invoice":
                begin
                    SalesInvHeader.Get(Rec."Document No.");
                    Page.RunModal(Page::"Posted Sales Invoice", SalesInvHeader);
                end;
            "NPR RS EI Document Type"::"Sales Cr. Memo":
                begin
                    SalesCrMemoHeader.Get(Rec."Document No.");
                    Page.RunModal(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
        end;
    end;

#endif

    var
        FormatDocumentStatus: Text;
}