pageextension 6014442 "NPR Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Posting Date")
        {
            field("NPR NPPostingDescription1"; Rec."Posting Description")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the Posting Description field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Control174)
        {
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {

                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the POS Entry action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromSalesDocument(Rec);
                end;
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

                    ToolTip = 'Executes the Retail Vouchers action';
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Import from scanner action';
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Issue Voucher action';
                    ApplicationArea = NPRRetail;

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
}