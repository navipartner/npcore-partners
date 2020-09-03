page 6150675 "NPR POS Entry Card"
{
    // NPR5.53/SARA/20191024 CASE 373672 Object create(Copy of POS Entry List)
    // NPR5.54/SARA/20200218 CASE 391359 Hide field 'Last Open Sales Doc' and 'Last Posted Sales Doc'
    // NPR5.54/SARA/20200218 CASE 391360 Remove Shortcut 'POS Audit Log' and 'POS Info Audit Roll'
    // NPR5.54/SARA/20200228 CASE 393492 Remove Delete button
    // NPR5.54/SARA/20200323 CASE 397581 Added Section NpRV Voucher under Navigate Ribbon
    // NPR5.55/SARA/20200511 CASE 401547 Add shortcut 'POS Period Register List'
    // NPR5.55/YAHA/20200218 CASE 391361 Remove groupaction EFT.
    // NPR5.55/MMV /20200623 CASE 391360 Re-actived action 'POS Audit Log'.
    // NPR5.55/SARA/20200706 CASE 412905 Related Sales Document Button: Filter only by Entry No.

    Caption = 'POS Entry Card';
    DeleteAllowed = false;
    Editable = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "NPR POS Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            field(AdvancedPostingWarning; TextAdvancedPostingOff)
            {
                ApplicationArea = All;
                Caption = 'Advanced Posting Warning';
                Editable = false;
                MultiLine = false;
                ShowCaption = false;
                Style = Unfavorable;
                StyleExpr = TRUE;
                Visible = AdvancedPostingOff;
            }
            field(ClicktoSeeAuditRoll; TextClicktoSeeAuditRoll)
            {
                ApplicationArea = All;
                Caption = 'Click to See Audit Roll';
                LookupPageID = "NPR POS Entries";
                ShowCaption = false;
                Visible = AdvancedPostingOff;

                trigger OnAssistEdit()
                begin
                    //-NPR5.38 [301600]
                    PAGE.Run(PAGE::"NPR Audit Roll");
                    CurrPage.Close;
                    //+NPR5.38 [301600]
                end;
            }
            group(Group)
            {
                field("System Entry"; "System Entry")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Fiscal No."; "Fiscal No.")
                {
                    ApplicationArea = All;
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("POS Period Register No."; "POS Period Register No.")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(LastOpenSalesDocumentNo; LastOpenSalesDocumentNo)
                {
                    ApplicationArea = All;
                    Caption = 'Last Open Sales Doc.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                        RecordVariant: Variant;
                    begin
                        //-NPR5.50 [300557]
                        if TryGetLastOpenSalesDoc(POSEntrySalesDocLink) then begin
                            POSEntrySalesDocLink.GetDocumentRecord(RecordVariant);
                            PAGE.RunModal(POSEntrySalesDocLink.GetCardpageID(), RecordVariant);
                        end;
                        //+NPR5.50 [300557]
                    end;
                }
                field(LastPostedSalesDocumentNo; LastPostedSalesDocumentNo)
                {
                    ApplicationArea = All;
                    Caption = 'Last Posted Sales Doc.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                        RecordVariant: Variant;
                    begin
                        //-NPR5.50 [300557]
                        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then begin
                            POSEntrySalesDocLink.GetDocumentRecord(RecordVariant);
                            PAGE.RunModal(POSEntrySalesDocLink.GetCardpageID(), RecordVariant);
                        end;
                        //+NPR5.50 [300557]
                    end;
                }
                field("No. of Print Output Entries"; "No. of Print Output Entries")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Post Item Entry Status"; "Post Item Entry Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Post Entry Status"; "Post Entry Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount Excl. Tax"; "Amount Excl. Tax")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount Incl. Tax"; "Amount Incl. Tax")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rounding Amount (LCY)"; "Rounding Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Transport Method"; "Transport Method")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Exit Point"; "Exit Point")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Area"; Area)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
            part(Sales; "NPR POS Sale Line Subpage")
            {
                Caption = 'Sales';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = HasSaleLines;
            }
            part(Payments; "NPR POS Paym. Line Subpage")
            {
                Caption = 'Payments';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = HasPaymentLines;
            }
            part(Taxes; "NPR POS Tax Line Subpage")
            {
                Caption = 'Taxes';
                Editable = false;
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive)
                              ORDER(Ascending);
                Visible = HasTaxLines;
            }
        }
        area(factboxes)
        {
            part(Control6014466; "NPR POS Entry Factbox")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Posting Log";
                RunPageLink = "Entry No." = FIELD("POS Posting Log Entry No.");
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Sales Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Payment Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                Visible = false;
            }
            action("Balancing Lines")
            {
                Caption = 'Balancing Lines';
                Image = Balance;
                RunObject = Page "NPR POS Balancing Line";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
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
            }
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;

                trigger OnAction()
                begin
                    //-NPR5.38 [294717]
                    ShowDimensions;
                    //+NPR5.38 [294717]
                end;
            }
            action("Sales Document")
            {
                Caption = 'Sales Document';
                Image = CoupledOrder;
                Visible = false;

                trigger OnAction()
                var
                    POSEntryManagement: Codeunit "NPR POS Entry Management";
                begin
                    //-NPR5.38 [302690]
                    if not POSEntryManagement.ShowSalesDocument(Rec) then
                        Error(TextSalesDocNotFound, "Sales Document Type", "Sales Document No.");
                    //+NPR5.38 [302690]
                end;
            }
            action("POS Info POS Entry")
            {
                Caption = 'POS Info POS Entry';
                Image = Info;
                RunObject = Page "NPR POS Info POS Entry";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("POS Info Code", "POS Entry No.", "Entry No.");
            }
            action("POS Info Audit Roll")
            {
                Caption = 'POS Info Audit Roll';
                Image = "Action";
                RunObject = Page "NPR POS Info Audit Roll";
                RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                Visible = false;
            }
            action("POS Audit Log")
            {
                Caption = 'POS Audit Log';
                Image = InteractionLog;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                begin
                    //-NPR5.48 [318028]
                    POSAuditLogMgt.ShowAuditLogForPOSEntry(Rec);
                    //+NPR5.48 [318028]
                end;
            }
            action("Related Sales Documents")
            {
                Caption = 'Related Sales Documents';
                Image = CoupledOrder;

                trigger OnAction()
                var
                    POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                begin
                    //-NPR5.50 [300557]
                    POSEntrySalesDocLink.SetRange("POS Entry No.", "Entry No.");
                    //-NPR5.55 [412905]
                    //POSEntrySalesDocLink.SETRANGE("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
                    //POSEntrySalesDocLink.SETRANGE("POS Entry Reference Line No.", 0);
                    //+NPR5.55 [412905]
                    PAGE.RunModal(PAGE::"NPR POS Entry Rel. Sales Doc.", POSEntrySalesDocLink);
                    //+NPR5.50 [300557]
                end;
            }
            action(Workshift)
            {
                Caption = 'Workshift Statistics';
                Image = Sales;

                trigger OnAction()
                begin

                    //-NPR5.50 [345376]
                    ShowWorkshift(Rec);
                    //+NPR5.50 [345376]
                end;
            }
            action("POS Period Register")
            {
                Image = PeriodEntries;
                RunObject = Page "NPR POS Period Register List";
                RunPageLink = "No." = FIELD("POS Period Register No.");
            }
            group(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                group("Gift Vouchers")
                {
                    Caption = 'Gift Vouchers';
                    Image = Voucher;
                    action(IssuedGiftVouchers)
                    {
                        Caption = 'Issued';
                        Image = PostedPayableVoucher;
                        RunObject = Page "NPR Gift Voucher List";
                        RunPageLink = "Issuing POS Entry No" = FIELD("Entry No.");
                    }
                    action(RedeemedGiftVouchers)
                    {
                        Caption = 'Redeemed';
                        Image = PostedReceivableVoucher;
                        RunObject = Page "NPR Gift Voucher List";
                        RunPageLink = "Cashed POS Entry No." = FIELD("Entry No.");
                    }
                }
                group("Credit Vouchers")
                {
                    Caption = 'Credit Vouchers';
                    Image = Voucher;
                    action(IssuedCreditVouchers)
                    {
                        Caption = 'Issued';
                        Image = PostedPayableVoucher;
                        RunObject = Page "NPR Credit Voucher List";
                        RunPageLink = "Issuing POS Entry No" = FIELD("Entry No.");
                    }
                    action(RedeemdedCreditVouchers)
                    {
                        Caption = 'Redeemed';
                        Image = PostedReceivableVoucher;
                        RunObject = Page "NPR Credit Voucher List";
                        RunPageLink = "Cashed POS Entry No." = FIELD("Entry No.");
                    }
                }
                group("Tax Free Vouchers")
                {
                    Caption = 'Tax Free Vouchers';
                    Image = Voucher;
                    ToolTip = 'Tax Free Vouchers';
                    action(IssueNewTaxFreeVoucher)
                    {
                        Caption = 'New';
                        Image = RefreshVoucher;

                        trigger OnAction()
                        var
                            TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                        begin
                            //-NPR5.39 [304165]
                            if "Entry Type" = "Entry Type"::"Direct Sale" then
                                TaxFree.VoucherIssueFromPOSSale("Document No.");
                            //+NPR5.39 [304165]
                        end;
                    }
                    action(IssuedTaxFreeVouchers)
                    {
                        Caption = 'Issued';
                        Image = PostedPayableVoucher;
                        RunObject = Page "NPR Tax Free Voucher";
                        RunPageLink = "Sales Receipt No." = FIELD("Document No.");
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
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    ErrorDuringPosting: Boolean;
                    ItemPosting: Boolean;
                    POSPosting: Boolean;
                begin

                    //-NPR5.51 [359403]
                    // POSEntryToPost.COPYFILTERS(Rec);
                    // //-NPR5.38 [285957]
                    // //POSPostEntries.SetPostItemEntries(TRUE);
                    // //POSPostEntries.SetPostPOSEntries(TRUE);
                    // POSPostEntries.SetPostItemEntries(CONFIRM(TextPostItemEntries));
                    // POSPostEntries.SetPostPOSEntries(CONFIRM(TextPostPosEntries));
                    // //+NPR5.38 [285957]
                    // POSPostEntries.SetStopOnError(TRUE);
                    // POSPostEntries.SetPostCompressed(CONFIRM(TextPostCompressed));
                    // POSPostEntries.RUN(POSEntryToPost);

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
                    //+NPR5.51 [359403]

                    CurrPage.Update(false);
                end;
            }
            action("Preview Post Entry")
            {
                Caption = 'Preview Post Entry';
                Image = ViewPostedOrder;

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

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSEntryToPost.CopyFilters(Rec);
                    //-NPR5.38 [285957]
                    //POSPostEntries.SetPostItemEntries(TRUE);
                    //POSPostEntries.SetPostPOSEntries(TRUE);
                    POSPostEntries.SetPostItemEntries(Confirm(TextPostItemEntries));
                    POSPostEntries.SetPostPOSEntries(Confirm(TextPostPosEntries));
                    //+NPR5.38 [285957]
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

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    //-NPR5.37 [293133]
                    POSEntryToPost.SetRange("Entry No.", "Entry No.");
                    if Rec."Post Item Entry Status" < "Post Item Entry Status"::Posted then
                        POSPostEntries.SetPostItemEntries(true);
                    if Rec."Post Entry Status" < "Post Entry Status"::Posted then
                        POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.CompareToAuditRoll(POSEntryToPost);
                    CurrPage.Update(false);
                    //+NPR5.37 [293133]
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    POSPeriodRegister: Record "NPR POS Period Register";
                    Navigate: Page Navigate;
                begin
                    //-NPR5.51 [359508]
                    // Navigate.SetDoc("Posting Date","Document No.");
                    // Navigate.RUN;

                    Navigate.SetDoc("Posting Date", "Document No.");
                    if ("Entry Type" <> "Entry Type"::Balancing) then
                        if (POSPeriodRegister.Get("POS Period Register No.")) then
                            if (POSPeriodRegister."Document No." <> '') then
                                Navigate.SetDoc("Posting Date", POSPeriodRegister."Document No.");

                    Navigate.Run;
                    //+NPR5.51 [359508]
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
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        POSEntryManagement: Codeunit "NPR POS Entry Management";
                    begin
                        //-NPR5.48 [318028]
                        // POSEntry := Rec;
                        // POSEntry.SETRECFILTER;
                        //
                        // RecRef.GETTABLE(POSEntry);
                        // RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        // CASE "Entry Type" OF
                        //  "Entry Type"::"Direct Sale" : RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
                        //  "Entry Type"::"Credit Sale" : RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
                        //  "Entry Type"::Balancing :
                        //    BEGIN
                        //      POSWorkshiftCheckpoint.SETFILTER ("POS Entry No.", '=%1', "Entry No.");
                        //      POSWorkshiftCheckpoint.FINDFIRST ();
                        //      RecRef.GETTABLE(POSWorkshiftCheckpoint);
                        //      RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
                        //    END;
                        // END;
                        POSEntryManagement.PrintEntry(Rec, false);
                        //+NPR5.48 [318028]
                    end;
                }
                action("Print Entry Large")
                {
                    Caption = 'Print Entry Large';
                    Image = PrintCover;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        POSEntryManagement: Codeunit "NPR POS Entry Management";
                    begin
                        //-NPR5.48 [318028]
                        // POSEntry := Rec;
                        // POSEntry.SETRECFILTER;
                        //
                        // RecRef.GETTABLE(POSEntry);
                        // RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        //
                        // CASE "Entry Type" OF
                        //  "Entry Type"::"Direct Sale" :RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)");
                        //
                        //  "Entry Type"::Balancing :
                        //  BEGIN
                        //    POSWorkshiftCheckpoint.SETFILTER ("POS Entry No.", '=%1', "Entry No.");
                        //    POSWorkshiftCheckpoint.FINDFIRST ();
                        //    RecRef.GETTABLE(POSWorkshiftCheckpoint);
                        //    RetailReportSelectionMgt.SetRequestWindow(TRUE);
                        //    RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Balancing (POS Entry)");
                        //  END;
                        // END;
                        POSEntryManagement.PrintEntry(Rec, true);
                        //+NPR5.48 [318028]
                    end;
                }
                action("EFT Receipt")
                {
                    Caption = 'EFT Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        //-NPR5.46 [290734]
                        //-NPR5.38 [294717]
                        // CreditCardTransaction.RESET;
                        // CreditCardTransaction.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
                        // CreditCardTransaction.FILTERGROUP := 2;
                        // CreditCardTransaction.SETRANGE("Register No.","POS Unit No.");
                        // CreditCardTransaction.SETRANGE("Sales Ticket No.","Document No.");
                        // CreditCardTransaction.SETRANGE(Type,0);
                        //
                        // CreditCardTransaction.FILTERGROUP := 0;
                        // IF CreditCardTransaction.FIND('-') THEN
                        //  CreditCardTransaction.PrintTerminalReceipt(FALSE)
                        // ELSE
                        //  MESSAGE(Text10600006,"Document No.","POS Unit No.");
                        //+NPR5.38 [294717]

                        EFTTransactionRequest.SetRange("Sales Ticket No.", "Document No.");
                        EFTTransactionRequest.SetRange("Register No.", "POS Unit No.");
                        if EFTTransactionRequest.FindSet then
                            repeat
                                EFTTransactionRequest.PrintReceipts(true);
                            until EFTTransactionRequest.Next = 0;
                        //+NPR5.46 [290734]
                    end;
                }
                action("Print Log")
                {
                    Caption = 'Print Log';
                    Image = Log;
                    RunObject = Page "NPR POS Entry Output Log";
                    RunPageLink = "POS Entry No." = FIELD("Entry No.");
                }
                action("Entry Overview")
                {
                    Caption = 'Entry Overview';
                    Image = PrintCheck;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        //-NPR5.40
                        Clear(POSEntry);
                        POSEntry.SetRange("POS Store Code", Rec."POS Store Code");
                        REPORT.Run(REPORT::"NPR Posting Overview POS", true, true, POSEntry);
                        //+NPR5.40
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
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        //-NPR5.50 [300557]
        LastOpenSalesDocumentNo := '';
        if TryGetLastOpenSalesDoc(POSEntrySalesDocLink) then
            LastOpenSalesDocumentNo := POSEntrySalesDocLink."Sales Document No";
        POSEntrySalesDocLink.Reset;

        LastPostedSalesDocumentNo := '';
        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then
            LastPostedSalesDocumentNo := POSEntrySalesDocLink."Sales Document No";
        //+NPR5.50 [300557]
        CalcFields("Sale Lines", "Payment Lines", "Tax Lines");
        HasSaleLines := "Sale Lines" > 0;
        HasPaymentLines := "Payment Lines" > 0;
        HasTaxLines := "Tax Lines" > 0;
    end;

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        NPRetailSetup.Get;
        TestMode := (NPRetailSetup."Environment Type" in [NPRetailSetup."Environment Type"::DEV, NPRetailSetup."Environment Type"::TEST]);
        AdvancedPostingOff := (not NPRetailSetup."Advanced Posting Activated");
    end;

    var
        TestMode: Boolean;
        TextAdvancedPostingOff: Label 'WARNING: Advanced Posting is OFF. Audit Roll used for posting.';
        TextClicktoSeeAuditRoll: Label 'Click here to see Audit Roll';
        TextPostCompressed: Label 'Post Compressed?';
        TextPostItemEntries: Label 'Post Item Entries?';
        TextPostPosEntries: Label 'Post all other Entries?';
        AdvancedPostingOff: Boolean;
        Text10600006: Label 'There are no credit card transactions attached to sales ticket no. %1/Register %2';
        TextSalesDocNotFound: Label 'Sales Document %1 %2 not found.';
        HasSaleLines: Boolean;
        HasPaymentLines: Boolean;
        HasTaxLines: Boolean;
        LastOpenSalesDocumentNo: Code[20];
        LastPostedSalesDocumentNo: Code[20];

    local procedure TryGetLastOpenSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        //-NPR5.50 [300557]
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", "Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", 0);
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2|%3|%4',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::ORDER,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::CREDIT_MEMO,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::RETURN_ORDER);
        exit(POSEntrySalesDocLinkOut.FindLast);
        //+NPR5.50 [300557]
    end;

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        //-NPR5.50 [300557]
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", "Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", 0);
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_CREDIT_MEMO);
        exit(POSEntrySalesDocLinkOut.FindLast);
        //+NPR5.50 [300557]
    end;

    local procedure ShowWorkshift(POSEntry: Record "NPR POS Entry")
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        //-NPR5.50 [352319]
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
        //+NPR5.50 [352319]
    end;
}

