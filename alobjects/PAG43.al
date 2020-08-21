pageextension 6014442 pageextension6014442 extends "Sales Invoice"
{
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.23/TS/20160603 CASE 2430085 Added field Posting Description
    // NPR5.29/TJ  /20170113 CASE 262797 Restored standard values in property ToolTipML in some actions
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.49/BHR /20190227 CASE 346899 Add Action Import Scanner
    // NPR5.55/BHR /20200525 CASE 405953 Added Fields"Bill-to E-mail","Document Processing"
    // NPR5.55/MHA /20200427 CASE 402013 Added Retail Vouchers action group
    // NPR5.55/MHA /20200601 CASE 402014 Added Page action "Issue Voucher"
    layout
    {
        addafter("Posting Date")
        {
            field(NPPostingDescription1; "Posting Description")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
        addafter(Control174)
        {
            field("Bill-to E-mail"; "Bill-to E-mail")
            {
                ApplicationArea = All;
            }
            field("Document Processing"; "Document Processing")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Co&mments")
        {
            action("POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;
            }
        }
        addafter("&Invoice")
        {
            group(Retail)
            {
                Caption = 'Retail';
                action("Retail Vouchers")
                {
                    Caption = 'Retail Vouchers';
                    Image = Certificate;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NpRv Sales Doc. Mgt.";
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
            action(ImportFromScanner)
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;

                trigger OnAction()
                begin
                    //-NPR5.49 [346899]
                    //-NPR5.49 [346899]
                end;
            }
        }
        addafter("F&unctions")
        {
            group("Retail Voucher")
            {
                action("Issue Voucher")
                {
                    Caption = 'Issue Voucher';
                    Image = PostedPayableVoucher;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NpRv Sales Doc. Mgt.";
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
            action(PostAndSendPdf2Nav)
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
            }
        }
    }

    var
        HasRetailVouchers: Boolean;


    //Unsupported feature: Code Modification on "OnAfterGetCurrRecord".

    //trigger OnAfterGetCurrRecord()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);
    CurrPage.ApprovalFactBox.PAGE.UpdateApprovalEntriesFromSourceRecord(RecordId);
    ShowWorkflowStatus := CurrPage.WorkflowStatus.PAGE.SetFilterOnWorkflowRecord(RecordId);

    UpdatePaymentService;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..5

    //-NPR5.55 [402013]
    SetHasRetailVouchers();
    //+NPR5.55 [402013]
    */
    //end;

    local procedure SetHasRetailVouchers()
    var
        NpRvSaleLinePOSVoucher: Record "NpRv Sales Line";
    begin
        //-NPR5.55 [402013]
        if "No." = '' then
            exit;

        NpRvSaleLinePOSVoucher.SetRange("Document Type", "Document Type");
        NpRvSaleLinePOSVoucher.SetRange("Document No.", "No.");
        HasRetailVouchers := NpRvSaleLinePOSVoucher.FindFirst;
        //+NPR5.55 [402013]
    end;
}

