pageextension 6014442 "NPR Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Posting Date")
        {
            field("NPR NPPostingDescription1"; Rec."Posting Description")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Posting Description field';
            }
        }
        addafter(Control174)
        {
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
            }
        }
    }
    actions
    {
        addafter("Co&mments")
        {
            action("NPR POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry action';
            }
        }
        addafter("&Invoice")
        {
            group("NPR Retail")
            {
                Caption = 'Retail';
                action("NPR Retail Vouchers")
                {
                    Caption = 'Retail Vouchers';
                    Image = Certificate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Vouchers action';

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.ShowRelatedVouchersAction(Rec);
                    end;
                }
            }
        }
        addafter("Move Negative Lines")
        {
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import from scanner action';

                trigger OnAction()
                var
                    ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
                begin
                    ImportfromScannerFileSO.SelectTable(Rec);
                    ImportfromScannerFileSO.SetTableView(Rec);
                    ImportfromScannerFileSO.Run();
                end;
            }
        }
        addafter("F&unctions")
        {
            group("NPR Retail Voucher")
            {
                action("NPR Issue Voucher")
                {
                    Caption = 'Issue Voucher';
                    Image = PostedPayableVoucher;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Issue Voucher action';

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.IssueVoucherAction(Rec);
                    end;
                }
            }
        }
    }

    var
        HasRetailVouchers: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        NPRSetHasRetailVouchers();
    end;

    local procedure NPRSetHasRetailVouchers()
    var
        NpRvSaleLinePOSVoucher: Record "NPR NpRv Sales Line";
    begin
        if Rec."No." = '' then
            exit;

        NpRvSaleLinePOSVoucher.SetRange("Document Type", Rec."Document Type");
        NpRvSaleLinePOSVoucher.SetRange("Document No.", Rec."No.");
        HasRetailVouchers := not NpRvSaleLinePOSVoucher.IsEmpty();
    end;
}