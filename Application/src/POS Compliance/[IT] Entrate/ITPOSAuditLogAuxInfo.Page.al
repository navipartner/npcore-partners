page 6151313 "NPR IT POS Audit Log Aux Info"
{
    ApplicationArea = NPRITFiscal;
    Caption = 'IT POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR IT POS Audit Log Aux Info";
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Related';
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
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry No. field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the entry date value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
                field("Z Report No."; Rec."Z Report No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Z Report No. field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Payment Method field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Transaction Type field.';
                }
                field("Receipt Fiscalized"; Rec."Receipt Fiscalized")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Receipt Fiscalized field.';
                }
                field("Fiscal Printer Serial No."; Rec."Fiscal Printer Serial No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Fiscal Printer Serial No. field.';
                }
                field("Customer Lottery Code"; Rec."Customer Lottery Code")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Customer Lottery Code field.';
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
                ApplicationArea = NPRITFiscal;
                Caption = 'Open Related Document';
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Openes the Document related to the selected transaction.';

                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                begin
                    POSEntry.Get(Rec."POS Entry No.");
                    Page.RunModal(Page::"NPR POS Entry Card", POSEntry);
                end;
            }
            group(Download)
            {
                Caption = 'Download';
                Image = Download;

                action(DownloadRequest)
                {
                    ApplicationArea = NPRITFiscal;
                    Caption = 'Download Request Message';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'The message sent to Fiscal Printer will be downloaded in the XML form.';
                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        TempBlob: Codeunit "Temp Blob";
                        FileNameLbl: Label '%1-%2-%3-req.xml', Locked = true;
                        OStream: OutStream;
                    begin
                        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                        if Rec."Request Content".HasValue() then begin
                            Rec."Request Content".ExportStream(OStream);
                            FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."Z Report No.", Rec."Receipt No.", Rec."Fiscal Printer Serial No."), true);
                        end;
                    end;
                }
                action(DownloadResponse)
                {
                    ApplicationArea = NPRITFiscal;
                    Caption = 'Download Response Message';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'The message received from Fiscal Printer will be downloaded in the XML form.';
                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        TempBlob: Codeunit "Temp Blob";
                        FileNameLbl: Label '%1-%2-%3-resp.xml', Locked = true;
                        OStream: OutStream;
                    begin
                        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                        if Rec."Response Content".HasValue()  then begin
                            Rec."Response Content".ExportStream(OStream);
                            FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."Z Report No.", Rec."Receipt No.", Rec."Fiscal Printer Serial No."), true);
                        end;
                    end;
                }
            }
        }
    }
}
