﻿page 6150675 "NPR POS Entry Card"
{
    Extensible = False;
    Caption = 'POS Entry Card';
    DeleteAllowed = false;
    Editable = false;
    PageType = Document;
    UsageCategory = None;

    RefreshOnActivate = true;
    SourceTable = "NPR POS Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            group(Group)
            {
                field("System Entry"; Rec."System Entry")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the System Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Fiscal No."; Rec."Fiscal No.")
                {
                    ToolTip = 'Specifies the value of the Fiscal No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    AccessByPermission = TableData "Responsibility Center" = R;
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the code of the responsibility center associated with the POS store the entry was created in.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {
                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ToolTip = 'Specifies the value of the Entry Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the value of the Contact No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Channel"; Rec."Sales Channel")
                {
                    ToolTip = 'Specifies the value of the Sales Channel field';
                    Visible = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(LastOpenSalesDocumentNo; LastOpenSalesDocumentNo)
                {
                    Caption = 'Last Open Sales Doc.';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Open Sales Doc. field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                        RecordVariant: Variant;
                    begin
                        if TryGetLastOpenSalesDoc(POSEntrySalesDocLink) then begin
                            POSEntrySalesDocLink.GetDocumentRecord(RecordVariant);
                            PAGE.RunModal(POSEntrySalesDocLink.GetCardpageID(), RecordVariant);
                        end;
                    end;
                }
                field(LastPostedSalesDocumentNo; LastPostedSalesDocumentNo)
                {
                    Caption = 'Last Posted Sales Doc.';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Posted Sales Doc. field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                        RecordVariant: Variant;
                    begin
                        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then begin
                            POSEntrySalesDocLink.GetDocumentRecord(RecordVariant);
                            PAGE.RunModal(POSEntrySalesDocLink.GetCardpageID(), RecordVariant);
                        end;
                    end;
                }
                field("No. of Print Output Entries"; Rec."No. of Print Output Entries")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. of Print Output Entries field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Item Entry Status"; Rec."Post Item Entry Status")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Post Item Entry Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Entry Status"; Rec."Post Entry Status")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Post Entry Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Excl. Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tax Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Incl. Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Amount (LCY)"; Rec."Rounding Amount (LCY)")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rounding Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Prices Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Transaction Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Transport Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Exit Point"; Rec."Exit Point")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Exit Point field';
                    ApplicationArea = NPRRetail;
                }
                field("Area"; Rec.Area)
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Area field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Sales; "NPR POS Sale Line Subpage")
            {
                Caption = 'Sales';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = HasSaleLines;
                ApplicationArea = NPRRetail;
            }
            part(Payments; "NPR POS Paym. Line Subpage")
            {
                Caption = 'Payments';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = HasPaymentLines;
                ApplicationArea = NPRRetail;
            }
            part(Taxes; "NPR POS Tax Line Subpage")
            {
                Caption = 'Taxes';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive)
                              ORDER(Ascending);
                Visible = HasTaxLines;
                ApplicationArea = NPRRetail;
            }
        }
        area(factboxes)
        {
            part(Control6014466; "NPR POS Entry Factbox")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Posting Log")
            {
                Caption = 'POS Posting Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the POS Posting Log action';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    POSPostingLog: Record "NPR POS Posting Log";
                begin
                    POSPostingLog.OpenPOSPostingLog(Rec, false);
                end;
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Entry Sales Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
                ToolTip = 'Executes the Sales Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Entry Pmt. Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
                ToolTip = 'Executes the Payment Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Balancing Lines")
            {
                Caption = 'Balancing Lines';
                Image = Balance;
                RunObject = Page "NPR POS Balancing Line";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Executes the Balancing Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Comment Lines")
            {
                Caption = 'Comment Lines';
                Image = Comment;
                RunObject = Page "NPR POS Entry Comments";
                RunPageLink = "Table ID" = CONST(6150621),
                              "POS Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Table ID", "POS Entry No.", "POS Entry Line No.", Code, "Line No.")
                              ORDER(Ascending);
                ToolTip = 'Executes the Comment Lines action';
                ApplicationArea = NPRRetail;
            }
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowDimensions();
                end;
            }
            action("Sales Document")
            {
                Caption = 'Sales Document';
                Image = CoupledOrder;
                Visible = false;
                ToolTip = 'Executes the Sales Document action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryManagement: Codeunit "NPR POS Entry Management";
                begin
                    if not POSEntryManagement.ShowSalesDocument(Rec) then
                        Error(TextSalesDocNotFound, Rec."Sales Document Type", Rec."Sales Document No.");
                end;
            }
            action("POS Info POS Entry")
            {
                Caption = 'POS Info POS Entry';
                Image = Info;
                RunObject = Page "NPR POS Info POS Entry";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("POS Info Code", "POS Entry No.", "Entry No.");
                ToolTip = 'Executes the POS Info POS Entry action';
                ApplicationArea = NPRRetail;
            }
            action("POS Audit Log")
            {
                Caption = 'POS Audit Log';
                Image = InteractionLog;
                ToolTip = 'Executes the POS Audit Log action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                begin
                    POSAuditLogMgt.ShowAuditLogForPOSEntry(Rec);
                end;
            }
            action("Related Sales Documents")
            {
                Caption = 'Related Sales Documents';
                Image = CoupledOrder;
                ToolTip = 'Executes the Related Sales Documents action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                begin
                    POSEntrySalesDocLink.SetRange("POS Entry No.", Rec."Entry No.");
                    PAGE.RunModal(PAGE::"NPR POS Entry Rel. Sales Doc.", POSEntrySalesDocLink);
                end;
            }
            action(Workshift)
            {
                Caption = 'Workshift Statistics';
                Image = Sales;
                ToolTip = 'Executes the Workshift Statistics action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    ShowWorkshift(Rec);
                end;
            }
            action("POS Period Register")
            {
                Image = PeriodEntries;
                RunObject = Page "NPR POS Period Register List";
                RunPageLink = "No." = FIELD("POS Period Register No.");
                ToolTip = 'Executes the POS Period Register action';
                ApplicationArea = NPRRetail;
            }
            group(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                group("Tax Free Vouchers")
                {
                    Caption = 'Tax Free Vouchers';
                    Image = Voucher;
                    ToolTip = 'Tax Free Vouchers';
                    action(IssueNewTaxFreeVoucher)
                    {
                        Caption = 'New';
                        Image = RefreshVoucher;
                        ToolTip = 'Executes the New action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                        begin
                            if Rec."Entry Type" = Rec."Entry Type"::"Direct Sale" then
                                TaxFree.VoucherIssueFromPOSSale(Rec."Document No.");
                        end;
                    }
                    action(IssuedTaxFreeVouchers)
                    {
                        Caption = 'Issued';
                        Image = PostedPayableVoucher;
                        ToolTip = 'Executes the Issued action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                            TaxFreeVoucher: Record "NPR Tax Free Voucher";
                        begin
                            if Rec."Entry Type" = Rec."Entry Type"::"Direct Sale" then
                                if TaxFree.TryGetActiveVoucherFromReceiptNo(Rec."Document No.", TaxFreeVoucher) then
                                    Page.Run(0, TaxFreeVoucher);
                        end;
                    }
                }
            }
            group("NpRv Vouchers")
            {
                Caption = 'Vouchers';
                Image = VoucherGroup;
                action("Voucher Lines")
                {
                    Caption = 'Voucher Lines';
                    Image = RefreshVoucher;
                    RunObject = Page "NPR NpRv Vouchers";
                    RunPageLink = "Issue Document No." = FIELD("Document No.");
                    ToolTip = 'Executes the Voucher Lines action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                    end;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    Image = VoucherDescription;
                    RunObject = Page "NPR NpRv Vouchers";
                    ToolTip = 'Executes the Voucher List action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                    end;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    Image = VoucherGroup;
                    RunObject = Page "NPR NpRv Voucher Types";
                    ToolTip = 'Executes the Voucher Types action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(EFT)
            {
                Caption = '&EFT';
                Image = CreditCard;
                action("EFT Transaction Requests")
                {
                    Caption = 'EFT Transaction Requests';
                    Image = CreditCardLog;
                    RunObject = Page "NPR EFT Transaction Requests";
                    RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                    ToolTip = 'Executes the EFT Transaction Requests action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(processing)
        {
            action("Post Entry")
            {
                Caption = 'Post Entry';
                Image = Post;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Post Entry action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    POSEntryToPost: Record "NPR POS Entry";
                begin
                    POSEntryToPost.SetRange("Entry No.", Rec."Entry No.");
                    if Rec."Post Item Entry Status" < Rec."Post Item Entry Status"::Posted then
                        POSPostEntries.SetPostItemEntries(true);
                    if Rec."Post Entry Status" < Rec."Post Entry Status"::Posted then
                        POSPostEntries.SetPostPOSEntries(true);
                    if (Rec."Post Sales Document Status" = Rec."Post Sales Document Status"::Unposted) or (Rec."Post Sales Document Status" = Rec."Post Sales Document Status"::"Error while Posting") then
                        POSPostEntries.SetPostSaleDocuments(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.Run(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("Post Range")
            {
                Caption = 'Post Range';
                Image = PostBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Post Range action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPostingAction: Report "NPR POS Posting Action";
                begin
                    POSPostingAction.SetPOSEntries(Rec);
                    POSPostingAction.SetGlobalValues(false, false, true, false, false, true);
                    POSPostingAction.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action("Navi&gate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Find entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPeriodRegister: Record "NPR POS Period Register";
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    if (Rec."Entry Type" <> Rec."Entry Type"::Balancing) then
                        if (POSPeriodRegister.Get(Rec."POS Period Register No.")) then
                            if (POSPeriodRegister."Document No." <> '') then
                                Navigate.SetDoc(Rec."Posting Date", POSPeriodRegister."Document No.");

                    Navigate.Run();
                end;
            }
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("Print Entry")
                {
                    Caption = 'Print Entry';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Print Entry action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        POSEntryManagement: Codeunit "NPR POS Entry Management";
                    begin
                        POSEntryManagement.PrintEntry(Rec, false);
                    end;
                }
                action("Print Entry Large")
                {
                    Caption = 'Print Entry Large';
                    Image = PrintCover;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Print Entry Large action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        POSEntryManagement: Codeunit "NPR POS Entry Management";
                    begin
                        POSEntryManagement.PrintEntry(Rec, true);
                    end;
                }
                action("EFT Receipt")
                {
                    Caption = 'EFT Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ToolTip = 'Executes the EFT Receipt action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        EFTTransactionRequest.SetRange("Sales Ticket No.", Rec."Document No.");
                        EFTTransactionRequest.SetRange("Register No.", Rec."POS Unit No.");
                        if EFTTransactionRequest.FindSet() then
                            repeat
                                EFTTransactionRequest.PrintReceipts(true);
                            until EFTTransactionRequest.Next() = 0;
                    end;
                }
                action("Print Log")
                {
                    Caption = 'Print Log';
                    Image = Log;
                    RunObject = Page "NPR POS Entry Output Log";
                    RunPageLink = "POS Entry No." = FIELD("Entry No.");
                    ToolTip = 'Executes the Print Log action';
                    ApplicationArea = NPRRetail;
                }
                action("Entry Overview")
                {
                    Caption = 'Entry Overview';
                    Image = PrintCheck;
                    ToolTip = 'Executes the Entry Overview action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        Clear(POSEntry);
                        POSEntry.SetRange("POS Store Code", Rec."POS Store Code");
                        REPORT.Run(REPORT::"NPR POS Entry Sales Details", true, true, POSEntry);
                    end;
                }
            }
            group(Send)
            {
                Caption = 'Send';
                action(SendSMS)
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                    ToolTip = 'Executes the Send SMS action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2BC';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    Promoted = false;
                    ToolTip = 'Executes the E-mail Log action';
                    ApplicationArea = NPRRetail;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ToolTip = 'Executes the Send as PDF action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        LastOpenSalesDocumentNo := '';
        if TryGetLastOpenSalesDoc(POSEntrySalesDocLink) then
            LastOpenSalesDocumentNo := POSEntrySalesDocLink."Sales Document No";
        POSEntrySalesDocLink.Reset();

        LastPostedSalesDocumentNo := '';
        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then
            LastPostedSalesDocumentNo := POSEntrySalesDocLink."Sales Document No";
        Rec.CalcFields("Sale Lines", "Payment Lines", "Tax Lines");
        HasSaleLines := Rec."Sale Lines" > 0;
        HasPaymentLines := Rec."Payment Lines" > 0;
        HasTaxLines := Rec."Tax Lines" > 0;
    end;

    var
        TextSalesDocNotFound: Label 'Sales Document %1 %2 not found.';
        HasSaleLines: Boolean;
        HasPaymentLines: Boolean;
        HasTaxLines: Boolean;
        LastOpenSalesDocumentNo: Code[20];
        LastPostedSalesDocumentNo: Code[20];

    local procedure TryGetLastOpenSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", Rec."Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", 0);
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2|%3|%4',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::ORDER,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::CREDIT_MEMO,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::RETURN_ORDER);
        exit(POSEntrySalesDocLinkOut.FindLast());
    end;

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", Rec."Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", 0);
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_CREDIT_MEMO);
        exit(POSEntrySalesDocLinkOut.FindLast());
    end;

    local procedure ShowWorkshift(POSEntry: Record "NPR POS Entry")
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        if (POSEntry."Entry No." <> 0) then begin
            POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
            if (POSWorkshiftCheckpoint.FindLast()) then begin
                PAGE.Run(PAGE::"NPR POS Workshift Checkp. Card", POSWorkshiftCheckpoint);
            end else begin
                POSWorkshiftCheckpoint.Reset();
                POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', POSEntry."POS Unit No.");
                POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
                POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
                if (POSWorkshiftCheckpoint.FindSet()) then
                    PAGE.Run(PAGE::"NPR POS Workshift Checkpoints", POSWorkshiftCheckpoint);
            end;
        end else begin
            POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
            POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
            PAGE.Run(PAGE::"NPR POS Workshift Checkpoints", POSWorkshiftCheckpoint);
        end;
    end;
}
