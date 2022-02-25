pageextension 6014442 "NPR Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Posting Date")
        {
            field("NPR NPPostingDescription1"; Rec."Posting Description")
            {

                Visible = false;
                ToolTip = 'Specifies the date when the posting of the sales document will be recorded.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Control174)
        {
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {

                ToolTip = 'Specifies the e-mail address of the customer contact you are sending the invoice to.';
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

                ToolTip = 'View all the POS entries for this item.';
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

                    ToolTip = 'View all vouchers for the selected customer.';
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

                ToolTip = 'Start importing the file from the scanner.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ScannerImport: XmlPort "NPR Scanner Import";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    ScannerImport.ScannerImportFactory(Enum::"NPR Scanner Import"::SALES, RecRef);
                    ScannerImport.Run();
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

                    ToolTip = 'View all the Issued Vouchers for the customer selected.';
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