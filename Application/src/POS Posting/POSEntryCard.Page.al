page 6150675 "NPR POS Entry Card"
{
    Caption = 'POS Entry Card';
    DeleteAllowed = false;
    Editable = false;
    PageType = Document;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                field("System Entry"; "System Entry")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the System Entry field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Fiscal No."; "Fiscal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fiscal No. field';
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("POS Period Register No."; "POS Period Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(LastOpenSalesDocumentNo; LastOpenSalesDocumentNo)
                {
                    ApplicationArea = All;
                    Caption = 'Last Open Sales Doc.';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Open Sales Doc. field';

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
                    ApplicationArea = All;
                    Caption = 'Last Posted Sales Doc.';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Posted Sales Doc. field';

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
                field("No. of Print Output Entries"; "No. of Print Output Entries")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. of Print Output Entries field';
                }
                field("Post Item Entry Status"; "Post Item Entry Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Post Item Entry Status field';
                }
                field("Post Entry Status"; "Post Entry Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Post Entry Status field';
                }
                field("Amount Excl. Tax"; "Amount Excl. Tax")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Excl. Tax field';
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tax Amount field';
                }
                field("Amount Incl. Tax"; "Amount Incl. Tax")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Incl. Tax field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Rounding Amount (LCY)"; "Rounding Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rounding Amount (LCY) field';
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Prices Including VAT field';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Sale ID field';
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Transaction Type field';
                }
                field("Transport Method"; "Transport Method")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Transport Method field';
                }
                field("Exit Point"; "Exit Point")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Exit Point field';
                }
                field("Area"; Area)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Area field';
                }
            }
            part(Sales; "NPR POS Sale Line Subpage")
            {
                Caption = 'Sales';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = HasSaleLines;
                ApplicationArea = All;
            }
            part(Payments; "NPR POS Paym. Line Subpage")
            {
                Caption = 'Payments';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = HasPaymentLines;
                ApplicationArea = All;
            }
            part(Taxes; "NPR POS Tax Line Subpage")
            {
                Caption = 'Taxes';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive)
                              ORDER(Ascending);
                Visible = HasTaxLines;
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(Control6014466; "NPR POS Entry Factbox")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
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
                RunObject = Page "NPR POS Posting Log";
                RunPageLink = "Entry No." = FIELD("POS Posting Log Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the POS Posting Log action';
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Sales Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Lines action';
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Payment Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Payment Lines action';
            }
            action("Balancing Lines")
            {
                Caption = 'Balancing Lines';
                Image = Balance;
                RunObject = Page "NPR POS Balancing Line";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Balancing Lines action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Comment Lines action';
            }
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';

                trigger OnAction()
                begin
                    ShowDimensions;
                end;
            }
            action("Sales Document")
            {
                Caption = 'Sales Document';
                Image = CoupledOrder;
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Document action';

                trigger OnAction()
                var
                    POSEntryManagement: Codeunit "NPR POS Entry Management";
                begin
                    if not POSEntryManagement.ShowSalesDocument(Rec) then
                        Error(TextSalesDocNotFound, "Sales Document Type", "Sales Document No.");
                end;
            }
            action("POS Info POS Entry")
            {
                Caption = 'POS Info POS Entry';
                Image = Info;
                RunObject = Page "NPR POS Info POS Entry";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("POS Info Code", "POS Entry No.", "Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the POS Info POS Entry action';
            }
            action("POS Info Audit Roll")
            {
                Caption = 'POS Info Audit Roll';
                Image = "Action";
                RunObject = Page "NPR POS Info Audit Roll";
                RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Info Audit Roll action';
            }
            action("POS Audit Log")
            {
                Caption = 'POS Audit Log';
                Image = InteractionLog;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Audit Log action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Related Sales Documents action';

                trigger OnAction()
                var
                    POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                begin
                    POSEntrySalesDocLink.SetRange("POS Entry No.", "Entry No.");
                    PAGE.RunModal(PAGE::"NPR POS Entry Rel. Sales Doc.", POSEntrySalesDocLink);
                end;
            }
            action(Workshift)
            {
                Caption = 'Workshift Statistics';
                Image = Sales;
                ApplicationArea = All;
                ToolTip = 'Executes the Workshift Statistics action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Period Register action';
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
                        ApplicationArea = All;
                        ToolTip = 'Executes the New action';

                        trigger OnAction()
                        var
                            TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                        begin
                            if "Entry Type" = "Entry Type"::"Direct Sale" then
                                TaxFree.VoucherIssueFromPOSSale("Document No.");
                        end;
                    }
                    action(IssuedTaxFreeVouchers)
                    {
                        Caption = 'Issued';
                        Image = PostedPayableVoucher;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Issued action';
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
                Caption = 'NpRv Vouchers';
                action("Voucher Lines")
                {
                    Caption = 'Voucher Lines';
                    Image = RefreshVoucher;
                    RunObject = Page "NPR NpRv Vouchers";
                    RunPageLink = "Issue Document No." = FIELD("Document No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Voucher Lines action';

                    trigger OnAction()
                    var
                        TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                    begin
                    end;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    Image = VoucherDescription;
                    RunObject = Page "NPR NpRv Vouchers";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Voucher List action';

                    trigger OnAction()
                    var
                        TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                    begin
                    end;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    Image = VoucherGroup;
                    RunObject = Page "NPR NpRv Voucher Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Voucher Types action';
                }
            }
            group(EFT)
            {
                Caption = '&EFT';
                action("EFT Transaction Requests")
                {
                    Caption = 'EFT Transaction Requests';
                    Image = CreditCardLog;
                    RunObject = Page "NPR EFT Transaction Requests";
                    RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT Transaction Requests action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Post Entry action';

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    POSEntryToPost: Record "NPR POS Entry";
                begin
                    POSEntryToPost.SetRange("Entry No.", "Entry No.");
                    if Rec."Post Item Entry Status" < "Post Item Entry Status"::Posted then
                        POSPostEntries.SetPostItemEntries(true);
                    if Rec."Post Entry Status" < "Post Entry Status"::Posted then
                        POSPostEntries.SetPostPOSEntries(true);
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
                ApplicationArea = All;
                ToolTip = 'Executes the Post Range action';

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    ErrorDuringPosting: Boolean;
                    ItemPosting: Boolean;
                    POSPosting: Boolean;
                begin
                    ItemPosting := Confirm(TextPostItemEntries);
                    POSPosting := Confirm(TextPostPosEntries);

                    POSPostEntries.SetPostCompressed(Confirm(TextPostCompressed));
                    POSPostEntries.SetStopOnError(true);

                    if (ItemPosting) then begin
                        POSEntryToPost.Reset;
                        POSEntryToPost.CopyFilters(Rec);
                        POSEntryToPost.SetFilter("Post Item Entry Status", '<2');
                        POSPostEntries.SetPostItemEntries(true);
                        POSPostEntries.SetPostPOSEntries(false);
                        repeat

                            if (POSEntryToPost.FindLast()) then
                                POSEntryToPost.SetFilter("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                            POSPostEntries.Run(POSEntryToPost);
                            Commit;

                            ErrorDuringPosting := not POSEntryToPost.IsEmpty();
                            POSEntryToPost.SetFilter("POS Period Register No.", GetFilter("POS Period Register No."));

                        until (ErrorDuringPosting or POSEntryToPost.IsEmpty());
                    end;

                    if (POSPosting) then begin
                        POSEntryToPost.Reset;
                        POSEntryToPost.CopyFilters(Rec);
                        POSEntryToPost.SetFilter("Post Entry Status", '<2');
                        POSPostEntries.SetPostItemEntries(false);
                        POSPostEntries.SetPostPOSEntries(true);
                        repeat

                            if (POSEntryToPost.FindLast()) then
                                POSEntryToPost.SetFilter("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                            POSPostEntries.Run(POSEntryToPost);
                            Commit;

                            ErrorDuringPosting := not POSEntryToPost.IsEmpty();
                            POSEntryToPost.SetFilter("POS Period Register No.", GetFilter("POS Period Register No."));

                        until (ErrorDuringPosting or POSEntryToPost.IsEmpty());
                    end;
                    CurrPage.Update(false);
                end;
            }
            action("Preview Post Entry")
            {
                Caption = 'Preview Post Entry';
                Image = ViewPostedOrder;
                ApplicationArea = All;
                ToolTip = 'Executes the Preview Post Entry action';

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSEntryToPost.SetRange("Entry No.", "Entry No.");
                    if Rec."Post Item Entry Status" < "Post Item Entry Status"::Posted then
                        POSPostEntries.SetPostItemEntries(true);
                    if Rec."Post Entry Status" < "Post Entry Status"::Posted then
                        POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.Preview(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("Preview Post Range")
            {
                Caption = 'Preview Post Range';
                Image = ViewWorksheet;
                ApplicationArea = All;
                ToolTip = 'Executes the Preview Post Range action';

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSEntryToPost.CopyFilters(Rec);
                    POSPostEntries.SetPostItemEntries(Confirm(TextPostItemEntries));
                    POSPostEntries.SetPostPOSEntries(Confirm(TextPostPosEntries));
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(Confirm(TextPostCompressed));
                    POSPostEntries.Preview(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("Compare Preview Post Entry to Audit Roll Posting")
            {
                Caption = 'Compare Preview Post Entry to Audit Roll Posting';
                Image = CompareCOA;
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Compare Preview Post Entry to Audit Roll Posting action';

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSEntryToPost.SetRange("Entry No.", "Entry No.");
                    if Rec."Post Item Entry Status" < "Post Item Entry Status"::Posted then
                        POSPostEntries.SetPostItemEntries(true);
                    if Rec."Post Entry Status" < "Post Entry Status"::Posted then
                        POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.CompareToAuditRoll(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

                trigger OnAction()
                var
                    POSPeriodRegister: Record "NPR POS Period Register";
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    if ("Entry Type" <> "Entry Type"::Balancing) then
                        if (POSPeriodRegister.Get("POS Period Register No.")) then
                            if (POSPeriodRegister."Document No." <> '') then
                                Navigate.SetDoc("Posting Date", POSPeriodRegister."Document No.");

                    Navigate.Run;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Entry action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Entry Large action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT Receipt action';

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        EFTTransactionRequest.SetRange("Sales Ticket No.", "Document No.");
                        EFTTransactionRequest.SetRange("Register No.", "POS Unit No.");
                        if EFTTransactionRequest.FindSet then
                            repeat
                                EFTTransactionRequest.PrintReceipts(true);
                            until EFTTransactionRequest.Next = 0;
                    end;
                }
                action("Print Log")
                {
                    Caption = 'Print Log';
                    Image = Log;
                    RunObject = Page "NPR POS Entry Output Log";
                    RunPageLink = "POS Entry No." = FIELD("Entry No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Log action';
                }
                action("Entry Overview")
                {
                    Caption = 'Entry Overview';
                    Image = PrintCheck;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Entry Overview action';

                    trigger OnAction()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        Clear(POSEntry);
                        POSEntry.SetRange("POS Store Code", Rec."POS Store Code");
                        REPORT.Run(REPORT::"NPR Posting Overview POS", true, true, POSEntry);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send SMS action';
                }
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    Promoted = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
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
        POSEntrySalesDocLink.Reset;

        LastPostedSalesDocumentNo := '';
        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then
            LastPostedSalesDocumentNo := POSEntrySalesDocLink."Sales Document No";
        CalcFields("Sale Lines", "Payment Lines", "Tax Lines");
        HasSaleLines := "Sale Lines" > 0;
        HasPaymentLines := "Payment Lines" > 0;
        HasTaxLines := "Tax Lines" > 0;
    end;

    trigger OnOpenPage()
    begin

    end;

    var
        TextPostCompressed: Label 'Post Compressed?';
        TextPostItemEntries: Label 'Post Item Entries?';
        TextPostPosEntries: Label 'Post all other Entries?';
        TextSalesDocNotFound: Label 'Sales Document %1 %2 not found.';
        HasSaleLines: Boolean;
        HasPaymentLines: Boolean;
        HasTaxLines: Boolean;
        LastOpenSalesDocumentNo: Code[20];
        LastPostedSalesDocumentNo: Code[20];

    local procedure TryGetLastOpenSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", "Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", 0);
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2|%3|%4',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::ORDER,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::CREDIT_MEMO,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::RETURN_ORDER);
        exit(POSEntrySalesDocLinkOut.FindLast);
    end;

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", "Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", 0);
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_CREDIT_MEMO);
        exit(POSEntrySalesDocLinkOut.FindLast);
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

