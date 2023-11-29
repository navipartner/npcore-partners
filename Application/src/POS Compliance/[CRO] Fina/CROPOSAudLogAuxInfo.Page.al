page 6151213 "NPR CRO POS Aud. Log Aux. Info"
{
    ApplicationArea = NPRCROFiscal;
    Caption = 'CRO POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Receipt Print,Related';
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
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry No. field.';
                }
                field("Bill No."; Rec."Bill No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Bill No. field.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the entry date value.';
                }
                field("Log Timestamp"; Rec."Log Timestamp")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Log Timestamp field.';
                }
                field("Paragon Number"; Rec."Paragon Number")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Paragon Number field.';
                }
                field("ZKI Code"; Rec."ZKI Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the ZKI field.';
                }
                field("JIR Code"; Rec."JIR Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the JIR field.';
                }
                field("CRO Payment Method"; Rec."CRO Payment Method")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Payment Method field.';
                }
                field("Receipt Fiscalized"; Rec."Receipt Fiscalized")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the Receipt Fiscalized field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Open Related Document")
            {
                ApplicationArea = NPRCROFiscal;
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
            group(Download)
            {
                Caption = 'Download';
                Image = Download;

                action(DownloadRequest)
                {
                    ApplicationArea = NPRCROFiscal;
                    Caption = 'Download Request Message';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Download Request Message action.';
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
            }

            group(Related)
            {
                Caption = 'Related';

                action(ShowSalesLines)
                {
                    ApplicationArea = NPRCROFiscal;
                    Caption = 'Show Related Sale Lines';
                    Image = ShowList;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Show Related Sale Lines action.';
                    trigger OnAction()
                    var
                        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
                        SalesCrMemoLine: Record "Sales Cr.Memo Line";
                        SalesInvoiceLine: Record "Sales Invoice Line";
                    begin
                        case Rec."Audit Entry Type" of
                            "NPR CRO Audit Entry Type"::"POS Entry":
                                begin
                                    POSEntrySalesLine.FilterGroup(10);
                                    POSEntrySalesLine.SetRange("POS Entry No.", Rec."POS Entry No.");
                                    POSEntrySalesLine.FilterGroup(0);
                                    Page.RunModal(Page::"NPR POS Entry Sales Line List", POSEntrySalesLine);
                                end;
                            "NPR CRO Audit Entry Type"::"Sales Invoice":
                                begin
                                    SalesInvoiceLine.FilterGroup(10);
                                    SalesInvoiceLine.SetRange("Document No.", Rec."Source Document No.");
                                    SalesInvoiceLine.FilterGroup(0);
                                    Page.RunModal(Page::"Posted Sales Invoice Lines", SalesInvoiceLine);
                                end;
                            "NPR CRO Audit Entry Type"::"Sales Credit Memo":
                                begin
                                    SalesCrMemoLine.FilterGroup(10);
                                    SalesCrMemoLine.SetRange("Document No.", Rec."Source Document No.");
                                    SalesCrMemoLine.FilterGroup(0);
                                    Page.RunModal(Page::"Posted Sales Credit Memo Lines", SalesCrMemoLine);
                                end;
                        end;
                    end;
                }
            }
        }
    }
}