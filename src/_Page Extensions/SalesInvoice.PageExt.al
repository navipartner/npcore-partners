pageextension 6014442 "NPR Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Posting Date")
        {
            field("NPR NPPostingDescription1"; "Posting Description")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
        addafter(Control174)
        {
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
            {
                ApplicationArea = All;
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
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
                ApplicationArea=All;
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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        //-NPR5.55 [402013]
                        NpRvSalesDocMgt.ShowRelatedVouchersAction(Rec);
                        //+NPR5.55 [402013]
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
                ApplicationArea=All;

                trigger OnAction()
                begin
                    //-NPR5.49 [346899]
                    //-NPR5.49 [346899]
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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        //-NPR5.55 [402014]
                        NpRvSalesDocMgt.IssueVoucherAction(Rec);
                        //+NPR5.55 [402014]
                    end;
                }
            }
        }
        addafter("Remove From Job Queue")
        {
            action("NPR PostAndSendPdf2Nav")
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
                ApplicationArea=All;
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
        if "No." = '' then
            exit;

        NpRvSaleLinePOSVoucher.SetRange("Document Type", "Document Type");
        NpRvSaleLinePOSVoucher.SetRange("Document No.", "No.");
        HasRetailVouchers := NpRvSaleLinePOSVoucher.FindFirst;
    end;
}

