page 6150652 "NPR POS Entry List"
{
    Caption = 'POS Entry List';
    ContextSensitiveHelpPage = 'docs/retail/posting_setup/explanation/accounting_entries/';
    AdditionalSearchTerms = 'POS Entries';
    CardPageID = "NPR POS Entry Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,POS Entry Lists,Failed POS Lists,Posting Entries';
    SourceTable = "NPR POS Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Ending Time";
                field("System Entry"; Rec."System Entry")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value assigned by the system to the specific entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the entry number.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ToolTip = 'Specifies the entry date.';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number for each entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ToolTip = 'Specifies the starting time.';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ToolTip = 'Specifies the ending time.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiscal No."; Rec."Fiscal No.")
                {
                    ToolTip = 'Specifies the fiscal number.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ToolTip = 'Specifies POS Store from which the POS entry has been created.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies POS unit number that has been used for processing this transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies POS period register number for the entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Visible = not _IsSimpleView;
                    ToolTip = 'Specifies the code for a global dimension that is linked to the record or entry for analysis purposes';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Visible = not _IsSimpleView;
                    ToolTip = 'Specifies the code for a global dimension that is linked to the record or entry for analysis purposes. ';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the entry type.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description for the entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'It is not used anymore';
                    ToolTip = 'Specifies the person that has been working on this transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer account number that the entry is linked to.';
                    ApplicationArea = NPRRetail;
                    Visible = not _IsSimpleView;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the contact account number that the entry is linked to.';
                    ApplicationArea = NPRRetail;
                    Visible = not _IsSimpleView;
                }
                field(LastOpenSalesDocumentNo; LastOpenSalesDocumentNo)
                {
                    Caption = 'Last Open Sales Doc.';
                    Visible = false;
                    ToolTip = 'Specifies the last open sales document.';
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
                    ToolTip = 'Specifies the last posted sales document.';
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
                    ToolTip = 'Specifies the number of print output entries.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Item Entry Status"; Rec."Post Item Entry Status")
                {
                    ToolTip = 'Specifies the post item entry status.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Entry Status"; Rec."Post Entry Status")
                {
                    ToolTip = 'Specifies the post entry status.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Sales Document Status"; Rec."Post Sales Document Status")
                {
                    ApplicationArea = NPRRetail;
                    Visible = AsyncEnabled;
                    ToolTip = 'Specifies the post Sale Documents status.';
                }
                field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
                {
                    ToolTip = 'Specifies the amount excluding tax.';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ToolTip = 'Specifies the tax amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ToolTip = 'Specifies the amount including tax.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Amount (LCY)"; Rec."Rounding Amount (LCY)")
                {
                    ToolTip = 'Specifies the rounding amount in local currency.';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax & Round"; Rec."Amount Incl. Tax & Round")
                {
                    ToolTip = 'Specifies the amount including tax and rounding.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the currency code.';
                    ApplicationArea = NPRRetail;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the reason code.';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the tax area code.';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the transaction type.';
                    ApplicationArea = NPRRetail;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    Visible = false;
                    ToolTip = 'Specifies the transaction type.';
                    ApplicationArea = NPRRetail;
                }
                field("Exit Point"; Rec."Exit Point")
                {
                    Visible = false;
                    ToolTip = 'Specifies the exit point.';
                    ApplicationArea = NPRRetail;
                }
                field("Area"; Rec.Area)
                {
                    Visible = false;
                    ToolTip = 'Specifies the area.';
                    ApplicationArea = NPRRetail;
                }
                field("Is Pay-in Pay-out"; Rec."Is Pay-in Pay-out")
                {
                    Visible = false;
                    ToolTip = 'Specifies if transaction is created as pay-in/pay-out action. Sales transaction created on retail payment G/L accounts is treated as a pay-in/pay-out transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Prioritized Posting"; Rec."Prioritized Posting")
                {
                    Visible = false;
                    ToolTip = 'Specifies if transaction is for Prioritized Posting';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Sales; "NPR POS Sale Line Subpage")
            {
                Caption = 'Sales';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            part(Payments; "NPR POS Paym. Line Subpage")
            {
                Caption = 'Payments';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            part(Taxes; "NPR POS Tax Line Subpage")
            {
                Caption = 'Taxes';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive)
                              ORDER(Ascending);
                Visible = false;
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
                ToolTip = 'Displays the POS posting log entries.';
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
                ToolTip = 'Displays the sales lines.';
                ApplicationArea = NPRRetail;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Entry Pmt. Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Displays the payment lines.';
                ApplicationArea = NPRRetail;
            }
            action("Sales & Payment Lines")
            {
                Caption = 'Sales & Payment Lines';
                Image = AllLines;
                RunObject = Page "NPR POS Entry Sales & Payments";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Displays sales and payment lines.';
                ApplicationArea = NPRRetail;
            }
            action("Tax Lines")
            {
                Caption = 'Tax Lines';
                Image = TaxDetail;
                RunObject = Page "NPR POS Entry Tax Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Displays the tax lines.';
                ApplicationArea = NPRRetail;
            }
            action("Balancing Lines")
            {
                Caption = 'Balancing Lines';
                Image = Balance;
                RunObject = Page "NPR POS Balancing Line";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Displays the balancing lines.';
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
                Visible = false;
                ToolTip = 'Displays the comment lines.';
                ApplicationArea = NPRRetail;
            }
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                ToolTip = 'Displays the dimensions for the selected record.';
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
                ToolTip = 'Displays the sales document.';
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
                ToolTip = 'Displays information about POS entry.';
                ApplicationArea = NPRRetail;
            }
            action("POS Info Audit Roll")
            {
                Caption = 'POS Info Audit Roll';
                Image = "Action";
                Visible = false;
                ToolTip = 'Displays the information about POS audit roll.';
                ApplicationArea = NPRRetail;
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Not used';
            }
            action("POS Audit Log")
            {
                Caption = 'POS Audit Log';
                Image = InteractionLog;
                ToolTip = 'Displays the POS audit log.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                begin
                    POSAuditLogMgt.ShowAuditLogForPOSEntry(Rec);
                end;
            }
            action("POS Receipt Profile")
            {
                Caption = 'POS Receipt Profile';
                Image = Receipt;
                RunObject = Page "NPR POS Receipt Profiles";
                ToolTip = 'Displays the list of POS Receipt Profiles.';
                ApplicationArea = NPRRetail;
            }
            action("Related Sales Documents")
            {
                Caption = 'Related Sales Documents';
                Image = CoupledOrder;
                ToolTip = 'Displays the related sales documents.';
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
                ToolTip = 'Displays the workshift statistics.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    ShowWorkshift(Rec);
                end;
            }
            action("EFT Transaction Requests")
            {
                Caption = 'EFT Transaction Requests';
                Image = CreditCardLog;
                RunObject = Page "NPR EFT Transaction Requests";
                RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                ToolTip = 'Displays the EFT transactions requests.';
                ApplicationArea = NPRRetail;
            }
            action("POS Period Register")
            {
                Image = PeriodEntries;
                RunObject = Page "NPR POS Period Register List";
                RunPageLink = "No." = FIELD("POS Period Register No.");
                ToolTip = 'Displays the POS period register.';
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
                    ToolTip = 'Tax Free Vouchers.';
                    action(IssueNewTaxFreeVoucher)
                    {
                        Caption = 'Issue New Tax Free Voucher';
                        Image = PostedPayableVoucher;
                        ToolTip = 'Issue new tax free voucher for the selected POS entry.';
                        ApplicationArea = NPRRetail;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;

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
                        Caption = 'Show Tax Free Vouchers';
                        Image = Voucher;
                        ToolTip = 'Show existing tax free vouchers for the selected POS entry.';
                        ApplicationArea = NPRRetail;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;

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
                Image = Voucher;
                action("Voucher Lines")
                {
                    Caption = 'Voucher Lines';
                    Image = RefreshVoucher;
                    RunObject = Page "NPR NpRv Vouchers";
                    RunPageLink = "Issue Document No." = FIELD("Document No.");
                    ToolTip = 'Displays the voucher lines.';
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
                    ToolTip = 'Displays the voucher list.';
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
                    ToolTip = 'Displays the voucher types.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("POS Entry Lists")
            {
                Caption = 'POS Entry Lists';
                action("Sales Line List")
                {
                    Caption = 'Sales Line List';
                    Image = Sales;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry Sales Line List";
                    ToolTip = 'Displays the sales line list';
                    ApplicationArea = NPRRetail;
                }
                action("Payment Line List")
                {
                    Caption = 'Payment Line List';
                    Image = Payment;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry Pmt. Line List";
                    ToolTip = 'Displays the payment line list.';
                    ApplicationArea = NPRRetail;
                }
                action("Sales & Payment Line List")
                {
                    Caption = 'Sales & Payment Line List';
                    Image = AllLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry Sales & Payments";
                    ToolTip = 'Displays the sales & payment line List.';
                    ApplicationArea = NPRRetail;
                }
                action("Tax Line List")
                {
                    Caption = 'Tax Line List';
                    Image = TaxDetail;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry Tax Line List";
                    ToolTip = 'Displays the tax line list';
                    ApplicationArea = NPRRetail;
                }
                action("Balancing Line List")
                {
                    Caption = 'Balancing Line List';
                    Image = Balance;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Balancing Line";
                    ToolTip = 'Displays the balancing line list.';
                    ApplicationArea = NPRRetail;
                }
                action("POS Period Register List")
                {
                    Caption = 'POS Period Register List';
                    Image = PeriodEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Period Register List";
                    ToolTip = 'Displays the POS period register list.';
                    ApplicationArea = NPRRetail;
                }
                action("POS Info POS Entry List")
                {
                    Caption = 'POS Info POS Entry List';
                    Image = Info;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR POS Info POS Entry";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Displays the POS entry list.';
                }
            }
            group("Failed POS Lists")
            {
                Caption = 'Failed POS Lists';
                action("Failed Item Posting List")
                {
                    Caption = 'Failed Item Posting List';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Item Entry Status" = FILTER("Error while Posting"));
                    ToolTip = 'Displays the failed item posting list.';
                    ApplicationArea = NPRRetail;
                }
                action("Failed G/L Posting List")
                {
                    Caption = 'Failed G/L Posting List';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Entry Status" = FILTER("Error while Posting"));
                    ToolTip = 'Displays the failed G/L posting list.';
                    ApplicationArea = NPRRetail;
                }
                action("Failed Sales Doc. Posting List")
                {
                    Caption = 'Failed Sales Documents Posting List';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Sales Document Status" = FILTER("Error while Posting"));
                    ToolTip = 'Displays the failed Sales Documents posting list.';
                    ApplicationArea = NPRRetail;
                }
                action("Unposted Item List")
                {
                    Caption = 'Unposted Item List';
                    Image = Pause;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Item Entry Status" = FILTER(Unposted));
                    ToolTip = 'Displays the unposted item list.';
                    ApplicationArea = NPRRetail;
                }
                action("Unposted G/L List")
                {
                    Caption = 'Unposted G/L List';
                    Image = Pause;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Entry Status" = FILTER(Unposted));
                    ToolTip = 'Displays the unposted G/L list.';
                    ApplicationArea = NPRRetail;
                }
                action("Unposted Sales Doc. Posting List")
                {
                    Caption = 'Unposted Sales Documents Posting List';
                    Image = Pause;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Sales Document Status" = FILTER(Unposted));
                    ToolTip = 'Displays the unposted Sales Documents posting list.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Posting Entries")
            {
                Caption = 'Posting Entries';
                action("&Navigate")
                {
                    Caption = 'Find entries...';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;

                    ToolTip = 'Posts the selected entry.';
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
                action(ClassicView)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show More Columns';
                    Image = SetupColumns;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'View all available fields. Fields not frequently used are currently hidden.';
                    Visible = _IsSimpleView;

                    trigger OnAction()
                    begin
                        CurrPage.Close();
                        SetIsSimpleView(false);
                        Page.Run(PAGE::"NPR POS Entry List");
                    end;
                }
                action(SimpleView)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Fewer Columns';
                    Image = SetupList;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Hide fields that are not frequently used.';
                    Visible = NOT _IsSimpleView;

                    trigger OnAction()
                    begin
                        CurrPage.Close();
                        SetIsSimpleView(true);
                        Page.Run(PAGE::"NPR POS Entry List");
                    end;
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
                ToolTip = 'Posts the selected entry.';
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
                    if (Rec."Post Sales Document Status" = Rec."Post Sales Document Status"::unPosted) or (Rec."Post Sales Document Status" = Rec."Post Sales Document Status"::"Error while Posting") then
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
                ToolTip = 'Gives the opportunity to post for a specific range of transactions.';
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
            action(Action6014435)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ToolTip = 'Navigates to the selected entry.';
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
                    ToolTip = 'Prints the selected entry.';
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
                    ToolTip = 'Prints a large format for the selected entry.';
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
                    ToolTip = 'Creates an EFT Receipt for the selected entry.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.");
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

                    ToolTip = 'Prints the log for the selected entry.';
                    ApplicationArea = NPRRetail;
                }
                action("Entry Overview")
                {
                    Caption = 'Entry Overview';
                    Image = PrintCheck;
                    ToolTip = 'Displays an overview for the selected entry.';
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
                Image = SendTo;
                action(SendSMS)
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                    ToolTip = 'Send an SMS for the selected entry.';
                    ApplicationArea = NPRRetail;
                    trigger OnAction()
                    var
                        SMSMgt: Codeunit "NPR SMS Management";
                    begin
                        SMSMgt.EditAndSendSMS(Rec);
                    end;
                }
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                Image = SendEmailPDF;
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    Promoted = false;
                    ToolTip = 'Executes the e-mail Log for the selected entry';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
                    begin
                        EmailDocMgt.RunEmailLog(Rec);
                    end;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ToolTip = 'Sends the entry as PDF.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
                    begin
                        EmailDocMgt.SendReport(Rec, false);
                    end;
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
    end;

    trigger OnOpenPage()
    var
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        Rec.SetRange("System Entry", false);
        if Rec.GetFilter("Entry Type") = '' then
            Rec.SetFilter("Entry Type", '<>%1', Rec."Entry Type"::"Cancelled Sale");
        if Rec.FindFirst() then;
        CheckIsSimpleView();
        AsyncEnabled := POSAsyncPostingMgt.SetVisibility();

    end;

    var
        TextSalesDocNotFound: Label 'Sales Document %1 %2 not found.';
        LastOpenSalesDocumentNo: Code[20];
        LastPostedSalesDocumentNo: Code[20];
        _IsSimpleView, AsyncEnabled : Boolean;

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

    local procedure CheckIsSimpleView()
    var
        JournalUserPreferences: Record "Journal User Preferences";
    begin
        _IsSimpleView := true;

        JournalUserPreferences.SetFilter("User ID", '%1', UserSecurityId());
        JournalUserPreferences.SetRange("Page ID", PAGE::"NPR POS Entry List");
        if not JournalUserPreferences.FindFirst() then
            exit;

        _IsSimpleView := JournalUserPreferences."Is Simple View";
    end;

    local procedure SetIsSimpleView(IsSimpleView: Boolean)
    var
        JournalUserPreferences: Record "Journal User Preferences";
    begin
        JournalUserPreferences.SetFilter("User ID", '%1', UserSecurityId());
        JournalUserPreferences.SetRange("Page ID", PAGE::"NPR POS Entry List");
        if not JournalUserPreferences.FindFirst() then begin
            Clear(JournalUserPreferences);
            JournalUserPreferences."Page ID" := PAGE::"NPR POS Entry List";
            JournalUserPreferences."User ID" := UserSecurityId();
            JournalUserPreferences.Insert();
        end;

        if JournalUserPreferences."Is Simple View" <> IsSimpleView then begin
            JournalUserPreferences."Is Simple View" := IsSimpleView;
            JournalUserPreferences.Modify();
        end;
    end;
}

