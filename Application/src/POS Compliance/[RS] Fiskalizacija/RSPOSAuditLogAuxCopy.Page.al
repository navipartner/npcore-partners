page 6059908 "NPR RS POS Audit Log Aux. Copy"
{
    Caption = 'RS POS Audit Log Aux. Copy';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS POS Audit Log Aux. Copy";
    SourceTableView = sorting("Audit Entry No.", "Copy No.") order(descending);
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
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
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Entry Date field.';
                }
                field("RS Invoice Type"; Rec."RS Invoice Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Invoice Type field.';
                }
                field("RS Transaction Type"; Rec."RS Transaction Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Transaction Type field.';
                }
                field(SentFiscalToTax; SentFiscalToTax)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Fiscal sent to Tax';
                    ToolTip = 'Specifies if Fiscal has been sent to Tax Authority.';
                }
            }
        }
        area(FactBoxes)
        {
            part(FiscalPreview; "NPR RS Fiscal A.Copy Privew FB")
            {
                ApplicationArea = NPRRSFiscal;
                SubPageLink = "Audit Entry Type" = field("Audit Entry Type"), "Audit Entry No." = field("Audit Entry No."), "Copy No." = field("Copy No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PrintCopyReceipt)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Print Copy Receipt';
                Image = PrintAttachment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action a copy of the original receipt will be printed without the original fiscal receipt.';
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
            action(PrintReceipt)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Print Original Receipt';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action the original receipt will be printed without a copy non-fiscal receipt.';
                trigger OnAction()
                var
                    RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
                    RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
                begin
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                    RSPOSAuditLogAuxInfo.FindLast();
                    if RSPOSAuditLogAuxInfo.Signature = '' then begin
                        Message(FiscalNotSentMsg);
                        exit;
                    end;
                    RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
                end;
            }
            action(PrintBothReceipts)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Print Original with Copy Receipt';
                Image = PrepaymentPostPrint;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action the original receipt will be printed with a copy non-fiscal receipt.';
                trigger OnAction()
                var
                    RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
                    RSPTFPITryPrint: Codeunit "NPR RS Fiscal Thermal Print";
                begin
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", Rec."Audit Entry Type");
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", Rec."Audit Entry No.");
                    RSPOSAuditLogAuxInfo.FindLast();
                    if RSPOSAuditLogAuxInfo.Signature = '' then begin
                        Message(FiscalNotSentMsg);
                        exit;
                    end;
                    RSPTFPITryPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
                    if Rec.Signature = '' then begin
                        Message(FiscalNotSentMsg);
                        exit;
                    end;
                    RSPTFPITryPrint.PrintReceipt(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SentFiscalToTax := Rec.Signature <> '';
    end;

    var
        SentFiscalToTax: Boolean;
        FiscalNotSentMsg: Label 'Fiscal Bill has not been sent to Tax Auth.';
}
