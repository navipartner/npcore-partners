page 6150652 "NPR POS Entry List"
{
    Extensible = False;
    Caption = 'POS Entry List';
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
                    ToolTip = 'Specifies the value of the System Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ToolTip = 'Specifies the value of the Entry Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field';
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
                field("Fiscal No."; Rec."Fiscal No.")
                {
                    ToolTip = 'Specifies the value of the Fiscal No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    Visible = not IsSimpleView;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                    Visible = not IsSimpleView;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                    Visible = not IsSimpleView;
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Visible = not IsSimpleView;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Visible = not IsSimpleView;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field';
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
                    Visible = not IsSimpleView;
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
                    ToolTip = 'Specifies the value of the Post Item Entry Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Entry Status"; Rec."Post Entry Status")
                {
                    ToolTip = 'Specifies the value of the Post Entry Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
                {
                    ToolTip = 'Specifies the value of the Amount Excl. Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ToolTip = 'Specifies the value of the Tax Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ToolTip = 'Specifies the value of the Amount Incl. Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Amount (LCY)"; Rec."Rounding Amount (LCY)")
                {
                    ToolTip = 'Specifies the value of the Rounding Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax & Round"; Rec."Amount Incl. Tax & Round")
                {
                    ToolTip = 'Specifies the value of the Amount Incl. Tax & Round field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
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
                RunObject = Page "NPR POS Posting Log";
                RunPageLink = "Entry No." = FIELD("POS Posting Log Entry No.");
                ToolTip = 'Executes the POS Posting Log action';
                ApplicationArea = NPRRetail;
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Entry Sales Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Executes the Sales Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Entry Pmt. Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Executes the Payment Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Tax Lines")
            {
                Caption = 'Tax Lines';
                Image = TaxDetail;
                RunObject = Page "NPR POS Entry Tax Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ToolTip = 'Executes the Tax Lines action';
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
                Visible = false;
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
            action("POS Info Audit Roll")
            {
                Caption = 'POS Info Audit Roll';
                Image = "Action";
                RunObject = Page "NPR POS Info Audit Roll";
                RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                Visible = false;
                ToolTip = 'Executes the POS Info Audit Roll action';
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
            action("EFT Transaction Requests")
            {
                Caption = 'EFT Transaction Requests';
                Image = CreditCardLog;
                RunObject = Page "NPR EFT Transaction Requests";
                RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                ToolTip = 'Executes the EFT Transaction Requests action';
                ApplicationArea = NPRRetail;
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
                        Caption = 'Issue New Tax Free Voucher';
                        Image = PostedPayableVoucher;
                        ToolTip = 'Issue new tax free voucher for the selected POS entry';
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
                        ToolTip = 'Show existing tax free vouchers for the selected POS entry';
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
                Caption = 'NpRv Vouchers';
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
                    ToolTip = 'Executes the Sales Line List action';
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
                    ToolTip = 'Executes the Payment Line List action';
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
                    ToolTip = 'Executes the Tax Line List action';
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
                    ToolTip = 'Executes the Balancing Line List action';
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
                    ToolTip = 'Executes the POS Period Register List action';
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
                    ToolTip = 'Executes the POS Info POS Entry List action';
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
                    ToolTip = 'Executes the Failed Item Posting List action';
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
                    ToolTip = 'Executes the Failed G/L Posting List action';
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
                    ToolTip = 'Executes the Unposted Item List action';
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
                    ToolTip = 'Executes the Unposted G/L List action';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Posting Entries")
            {
                Caption = 'Posting Entries';
                action("&Navigate")
                {
                    Caption = '&Navigate';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;

                    ToolTip = 'Executes the &Navigate action';
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
                    Visible = IsSimpleView;

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
                    Visible = NOT IsSimpleView;

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
                        POSEntryToPost.Reset();
                        POSEntryToPost.CopyFilters(Rec);
                        POSPostEntries.SetPostItemEntries(true);
                        POSPostEntries.SetPostPOSEntries(false);
                        repeat

                            if (POSEntryToPost.FindLast()) then
                                POSEntryToPost.SetFilter("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                            POSPostEntries.Run(POSEntryToPost);
                            Commit();

                            ErrorDuringPosting := not POSEntryToPost.IsEmpty();
                            POSEntryToPost.SetFilter("POS Period Register No.", Rec.GetFilter("POS Period Register No."));

                        until (ErrorDuringPosting or POSEntryToPost.IsEmpty());
                    end;

                    if (POSPosting) then begin
                        POSEntryToPost.Reset();
                        POSEntryToPost.CopyFilters(Rec);
                        POSPostEntries.SetPostItemEntries(false);
                        POSPostEntries.SetPostPOSEntries(true);
                        repeat

                            if (POSEntryToPost.FindLast()) then
                                POSEntryToPost.SetFilter("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                            POSPostEntries.Run(POSEntryToPost);
                            Commit();

                            ErrorDuringPosting := not POSEntryToPost.IsEmpty();
                            POSEntryToPost.SetFilter("POS Period Register No.", Rec.GetFilter("POS Period Register No."));

                        until (ErrorDuringPosting or POSEntryToPost.IsEmpty());
                    end;
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
                ToolTip = 'Executes the &Navigate action';
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
                    ToolTip = 'Executes the Send SMS action';
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
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    Promoted = false;
                    ToolTip = 'Executes the E-mail Log action';
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
                    ToolTip = 'Executes the Send as PDF action';
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
    begin
        Rec.SetRange("System Entry", false);
        if Rec.GetFilter("Entry Type") = '' then
            Rec.SetFilter("Entry Type", '<>%1', Rec."Entry Type"::"Cancelled Sale");
        if Rec.FindFirst() then;
        CheckIsSimpleView();
    end;

    var
        TextPostCompressed: Label 'Post Compressed?';
        TextPostItemEntries: Label 'Post Item Entries?';
        TextPostPosEntries: Label 'Post all other Entries?';
        TextSalesDocNotFound: Label 'Sales Document %1 %2 not found.';
        LastOpenSalesDocumentNo: Code[20];
        LastPostedSalesDocumentNo: Code[20];
        IsSimpleView: Boolean;

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
        IsSimpleView := true;

        JournalUserPreferences.SetFilter("User ID", '%1', UserSecurityId());
        JournalUserPreferences.SetRange("Page ID", PAGE::"NPR POS Entry List");
        if not JournalUserPreferences.FindFirst() then
            exit;

        IsSimpleView := JournalUserPreferences."Is Simple View";
    end;

    local procedure SetIsSimpleView(SetIsSimpleView: Boolean)
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

        if JournalUserPreferences."Is Simple View" <> SetIsSimpleView then begin
            JournalUserPreferences."Is Simple View" := SetIsSimpleView;
            JournalUserPreferences.Modify();
        end;
    end;
}

