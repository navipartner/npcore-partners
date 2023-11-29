page 6150768 "NPR SI POS Audit Log Aux. Info"
{
    ApplicationArea = NPRSIFiscal;
    Caption = 'SI POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Receipt Print,Related';
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
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry No. field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the entry date value.';
                }
                field("Log Timestamp"; Rec."Log Timestamp")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Log Timestamp field.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Sales Book Invoice No."; Rec."Sales Book Invoice No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Sales Book Invoice Number field.';
                }
                field("Sales Book Serial No."; Rec."Sales Book Serial No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Sales Book Serial Number field.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
                field("ZOI Code"; Rec."ZOI Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the ZOI Code field.';
                }
                field("EOR Code"; Rec."EOR Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the EOR Code field.';
                }
                field("Validation Code"; Rec."Validation Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Validation Code field.';
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

                    if Rec."Return Receipt No." = '' then begin
                        SITaxCommunicationMgt.CreateNormalSale(Rec, false, true);
                        Rec."Subsequent Submit" := true;
                        Rec.Modify();
                    end
                    else
                        SITaxCommunicationMgt.CreateNormalSale(Rec, true, true);
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

            action(DownloadRequest)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Download Request Message';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Category5;
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
                    if Rec."Receipt Content".HasValue then begin
                        Rec."Receipt Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."ZOI Code"), true);
                    end;
                end;
            }
            action(DownloadResponse)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Download Response Message';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Executes the Download Response Message action.';
                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    FileNameLbl: Label '%1.xml', Locked = true;
                    OStream: OutStream;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Response Content".HasValue then begin
                        Rec."Response Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."EOR Code"), true);
                    end;
                end;
            }

            action(ShowSalesLines)
            {
                ApplicationArea = NPRSIFiscal;
                Caption = 'Show Related POS Sale Lines';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                ToolTip = 'Executes the Show Related POS Sale Lines action.';
                trigger OnAction()
                var
                    POSEntrySalesLine: Record "NPR POS Entry Sales Line";
                begin
                    POSEntrySalesLine.FilterGroup(10);
                    POSEntrySalesLine.SetRange("POS Entry No.", Rec."POS Entry No.");
                    POSEntrySalesLine.FilterGroup(0);

                    Page.RunModal(Page::"NPR POS Entry Sales Line List", POSEntrySalesLine);
                end;
            }
        }
    }
}
