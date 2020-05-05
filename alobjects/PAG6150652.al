page 6150652 "POS Entry List"
{
    // NPR5.36/BR  /20170808  CASE 277096 Object created
    // NPR5.37/BR  /20171011  CASE 293133 Compare with Audit Roll
    // NPR5.37/BR  /20171024  CASE 294294 Added Navigate Action
    // NPR5.37/BR  /20171024  CASE 294311 Changed sorting and always go to last transaction OnOpenPage
    // NPR5.37/BR  /20171024  CASE 294362 Added Entry Type option Debitsale, added fields Sales Document Type, Sales Document No.
    // NPR5.38/BR  /20171108  CASE 294747 Added Action ShowDimensions
    // NPR5.38/BR  /20171127  CASE 297087 Added Field System Entry
    // NPR5.38/BR  /20180105  CASE 285957 Added Confirmation to posting item and POS entries
    // NPR5.38/BR  /20180115  CASE 302311 Added warning if Posting is switched off
    // NPR5.38/BR  /20180118  CASE 302685 Added links to Credit Card and EFT Transactions
    // NPR5.38/BR  /20180119  CASE 302818 Added field Reason Code ( Visible = False);
    // NPR5.38/BR  /20180122  CASE 302690 Added Action Sales Document
    // NPR5.38/BR  /20180122  CASE 302809 POS Posting Log - OnAction()
    // NPR5.38/BR  /20180123  CASE 302809 Added Global Dimension 1 + 2, Non-visible
    // NPR5.38/BR  /20180123  CASE 302813 Added Tax fields, Non-visible
    // NPR5.38/BR  /20180123  CASE 302815 Added field Salesperson Code
    // NPR5.38/TSA /20180122  CASE 302690 Added Action Balancing Line
    // NPR5.38/BR  /20180124  CASE 302764 Added Voucher Actions to RelatedInformation
    // NPR5.39/BR  /20180129  CASE 302696 Added POS Entry Factbox, set filter System Entries = No
    // NPR5.39/MMV /20180207  CASE 304165 Added print actions
    // NPR5.39/BR  /20180208  CASE 304165 Added link to print log
    // NPR5.39/BR  /20180215  CASE 305016 Added Fiscal No., Enabled if Active
    // NPR5.40/MMV /20180306  CASE 284505 Filter before print
    // NPR5.40/TSA /20180308  CASE 307267 Printing of balancing
    // NPR5.40/THRO/20180314  CASE 304312 Added Action SendSMS
    // NPR5.40/JLK /20180315  CASE 307437 Added Action Entry Overview
    // NPR5.40/MMV /20180319  CASE 308457 Updated fiscal condition
    // NPR5.40/MMV /20180328  CASE 276562 Unified print actions. Removed deprecated credit card action.
    // NPR5.41/THRO/20180424  CASE 312185 Added action POS Info
    // NPR5.42/TS  /20180511  CASE 312186 Added Action POS Info Audit Roll
    // NPR5.42/ZESO/20180517  CASE 312186 Print Entry Large - OnAction()
    // NPR5.46/TS  /20180918  CASE 302770 Added Action Group PDF2NAV on POSEntry List
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring
    // NPR5.48/MMV /20181026 CASE 318028 French certification
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.50/MMV /20190328 CASE 300557 Refactored sales doc. handling
    // NPR5.50/TSA /20190424 CASE 352319 Added navigation to workshifts
    // NPR5.51/TSA /20190623 CASE 359403 Refactored Post Range action
    // NPR5.51/TSA /20190624 CASE 359508 Changed navigate to consider the period document no
    // NPR5.53/SARA/20191024 CASE 373672 Refactore POS Entry List
    // NPR5.53/SARA/20200124 CASE 387227 Move Navigate action to Navigate Ribbon
    // NPR5.53/SARA/20200129 CASE 387885 Apply 'Entry Type' is NOT "Cancelled" as default filter
    // NPR5.53/SARA/20200205 CASE 389242 Remove shortcut 'POS Info Audit Roll'
    // NPR5.54/SARA/20200218 CASE 391360 Remove Shortcut 'POS Audit Log'
    // NPR5.54/SARA/20200228 CASE 393492 Remove Delete button

    Caption = 'POS Entry List';
    CardPageID = "POS Entry Card";
    DeleteAllowed = false;
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,POS Entry Lists,Failed POS Lists,Posting Entries';
    SourceTable = "POS Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(AdvancedPostingWarning;TextAdvancedPostingOff)
            {
                Caption = 'Advanced Posting Warning';
                Editable = false;
                MultiLine = false;
                ShowCaption = false;
                Style = Unfavorable;
                StyleExpr = TRUE;
                Visible = AdvancedPostingOff;
            }
            field(ClicktoSeeAuditRoll;TextClicktoSeeAuditRoll)
            {
                Caption = 'Click to See Audit Roll';
                LookupPageID = "POS Entries";
                ShowCaption = false;
                Visible = AdvancedPostingOff;

                trigger OnAssistEdit()
                begin
                    //-NPR5.38 [301600]
                    PAGE.Run(PAGE::"Audit Roll");
                    CurrPage.Close;
                    //+NPR5.38 [301600]
                end;
            }
            repeater(Group)
            {
                FreezeColumn = "Ending Time";
                field("System Entry";"System Entry")
                {
                    Visible = false;
                }
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Entry Date";"Entry Date")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field("Fiscal No.";"Fiscal No.")
                {
                    Visible = false;
                }
                field("POS Store Code";"POS Store Code")
                {
                    Visible = false;
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("POS Period Register No.";"POS Period Register No.")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                    Visible = false;
                }
                field("Entry Type";"Entry Type")
                {
                }
                field(Description;Description)
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(LastOpenSalesDocumentNo;LastOpenSalesDocumentNo)
                {
                    Caption = 'Last Open Sales Doc.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
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
                field(LastPostedSalesDocumentNo;LastPostedSalesDocumentNo)
                {
                    Caption = 'Last Posted Sales Doc.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
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
                field("No. of Print Output Entries";"No. of Print Output Entries")
                {
                    Visible = false;
                }
                field("Post Item Entry Status";"Post Item Entry Status")
                {
                }
                field("Post Entry Status";"Post Entry Status")
                {
                }
                field("Amount Excl. Tax";"Amount Excl. Tax")
                {
                }
                field("Tax Amount";"Tax Amount")
                {
                }
                field("Amount Incl. Tax";"Amount Incl. Tax")
                {
                }
                field("Rounding Amount (LCY)";"Rounding Amount (LCY)")
                {
                }
                field("Amount Incl. Tax & Round";"Amount Incl. Tax & Round")
                {
                }
                field("Currency Code";"Currency Code")
                {
                    Visible = false;
                }
                field("Reason Code";"Reason Code")
                {
                    Visible = false;
                }
                field("Tax Area Code";"Tax Area Code")
                {
                    Visible = false;
                }
                field("POS Sale ID";"POS Sale ID")
                {
                }
                field("Transaction Type";"Transaction Type")
                {
                    Visible = false;
                }
                field("Transport Method";"Transport Method")
                {
                    Visible = false;
                }
                field("Exit Point";"Exit Point")
                {
                    Visible = false;
                }
                field("Area";Area)
                {
                    Visible = false;
                }
            }
            part(Sales;"POS Sale Line Subpage")
            {
                Caption = 'Sales';
                Editable = false;
                SubPageLink = "POS Entry No."=FIELD("Entry No.");
                Visible = false;
            }
            part(Payments;"POS Payment Line Subpage")
            {
                Caption = 'Payments';
                Editable = false;
                SubPageLink = "POS Entry No."=FIELD("Entry No.");
                Visible = false;
            }
            part(Taxes;"POS Tax Line Subpage")
            {
                Caption = 'Taxes';
                Editable = false;
                SubPageLink = "POS Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("POS Entry No.","Tax Area Code for Key","Tax Jurisdiction Code","VAT Identifier","Tax %","Tax Group Code","Expense/Capitalize","Tax Type","Use Tax",Positive)
                              ORDER(Ascending);
                Visible = false;
            }
        }
        area(factboxes)
        {
            part(Control6014466;"POS Entry Factbox")
            {
                SubPageLink = "Entry No."=FIELD("Entry No.");
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
                RunObject = Page "POS Posting Log";
                RunPageLink = "Entry No."=FIELD("POS Posting Log Entry No.");
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "POS Sales Line List";
                RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "POS Payment Line List";
                RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
            action("Tax Lines")
            {
                Caption = 'Tax Lines';
                Image = TaxDetail;
                RunObject = Page "POS Tax Line List";
                RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
            action("Balancing Lines")
            {
                Caption = 'Balancing Lines';
                Image = Balance;
                RunObject = Page "POS Balancing Line";
                RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
            action("Comment Lines")
            {
                Caption = 'Comment Lines';
                Image = Comment;
                RunObject = Page "POS Entry Comments";
                RunPageLink = "Table ID"=CONST(6150621),
                              "POS Entry No."=FIELD("Entry No.");
                RunPageView = SORTING("Table ID","POS Entry No.","POS Entry Line No.",Code,"Line No.")
                              ORDER(Ascending);
                Visible = false;
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
                    POSEntryManagement: Codeunit "POS Entry Management";
                begin
                    //-NPR5.38 [302690]
                    if not POSEntryManagement.ShowSalesDocument(Rec) then
                      Error(TextSalesDocNotFound,"Sales Document Type","Sales Document No.");
                    //+NPR5.38 [302690]
                end;
            }
            action("POS Info POS Entry")
            {
                Caption = 'POS Info POS Entry';
                Image = Info;
                RunObject = Page "POS Info POS Entry";
                RunPageLink = "POS Entry No."=FIELD("Entry No.");
                RunPageView = SORTING("POS Info Code","POS Entry No.","Entry No.");
            }
            action("POS Info Audit Roll")
            {
                Caption = 'POS Info Audit Roll';
                Image = "Action";
                RunObject = Page "POS Info Audit Roll";
                RunPageLink = "Sales Ticket No."=FIELD("Document No.");
                Visible = false;
            }
            action("POS Audit Log")
            {
                Caption = 'POS Audit Log';
                Image = InteractionLog;
                Visible = false;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
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
                    POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
                begin
                    //-NPR5.50 [300557]
                    POSEntrySalesDocLink.SetRange("POS Entry No.", "Entry No.");
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Line No.", 0);
                    PAGE.RunModal(PAGE::"POS Entry Related Sales Doc.", POSEntrySalesDocLink);
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
                    ShowWorkshift (Rec);
                    //+NPR5.50 [345376]
                end;
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
                        RunObject = Page "Gift Voucher List";
                        RunPageLink = "Issuing POS Entry No"=FIELD("Entry No.");
                    }
                    action(RedeemedGiftVouchers)
                    {
                        Caption = 'Redeemed';
                        Image = PostedReceivableVoucher;
                        RunObject = Page "Gift Voucher List";
                        RunPageLink = "Cashed POS Entry No."=FIELD("Entry No.");
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
                        RunObject = Page "Credit Voucher List";
                        RunPageLink = "Issuing POS Entry No"=FIELD("Entry No.");
                    }
                    action(RedeemdedCreditVouchers)
                    {
                        Caption = 'Redeemed';
                        Image = PostedReceivableVoucher;
                        RunObject = Page "Credit Voucher List";
                        RunPageLink = "Cashed POS Entry No."=FIELD("Entry No.");
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
                            TaxFree: Codeunit "Tax Free Handler Mgt.";
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
                        RunObject = Page "Tax Free Voucher";
                        RunPageLink = "Sales Receipt No."=FIELD("Document No.");
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
                    RunObject = Page "NpRv Vouchers";
                    RunPageLink = "Issue Document No."=FIELD("Document No.");

                    trigger OnAction()
                    var
                        TaxFree: Codeunit "Tax Free Handler Mgt.";
                    begin
                    end;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    Image = VoucherDescription;
                    RunObject = Page "NpRv Vouchers";

                    trigger OnAction()
                    var
                        TaxFree: Codeunit "Tax Free Handler Mgt.";
                    begin
                    end;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    Image = VoucherGroup;
                    RunObject = Page "NpRv Voucher Types";
                }
            }
            group(EFT)
            {
                Caption = '&EFT';
                action("EFT Transaction Requests")
                {
                    Caption = 'EFT Transaction Requests';
                    Image = CreditCardLog;
                    RunObject = Page "EFT Transaction Requests";
                    RunPageLink = "Sales Ticket No."=FIELD("Document No.");
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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "POS Sales Line List";
                }
                action("Payment Line List")
                {
                    Caption = 'Payment Line List';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "POS Payment Line List";
                }
                action("Tax Line List")
                {
                    Caption = 'Tax Line List';
                    Image = TaxDetail;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "POS Tax Line List";
                }
                action("Balancing Line List")
                {
                    Caption = 'Balancing Line List';
                    Image = Balance;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "POS Balancing Line";
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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Item Entry Status"=FILTER("Error while Posting"));
                }
                action("Failed G/L Posting List")
                {
                    Caption = 'Failed G/L Posting List';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Entry Status"=FILTER("Error while Posting"));
                }
                action("Unposted Item List")
                {
                    Caption = 'Unposted Item List';
                    Image = Pause;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Item Entry Status"=FILTER(Unposted));
                }
                action("Unposted G/L List")
                {
                    Caption = 'Unposted G/L List';
                    Image = Pause;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "POS Entries";
                    RunPageView = SORTING("Entry No.")
                                  WHERE("Post Entry Status"=FILTER(Unposted));
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
                    PromotedCategory = Category6;

                    trigger OnAction()
                    var
                        POSPeriodRegister: Record "POS Period Register";
                        Navigate: Page Navigate;
                    begin
                        //-NPR5.51 [359508]
                        // Navigate.SetDoc("Posting Date","Document No.");
                        // Navigate.RUN;

                        Navigate.SetDoc("Posting Date","Document No.");
                        if ("Entry Type" <> "Entry Type"::Balancing) then
                          if (POSPeriodRegister.Get ("POS Period Register No.")) then
                            if (POSPeriodRegister."Document No." <> '') then
                              Navigate.SetDoc ("Posting Date", POSPeriodRegister."Document No.");

                        Navigate.Run;
                        //+NPR5.51 [359508]
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "POS Post Entries";
                    POSEntryToPost: Record "POS Entry";
                begin
                    POSEntryToPost.SetRange("Entry No.","Entry No.");
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
                    POSEntryToPost: Record "POS Entry";
                    POSPostEntries: Codeunit "POS Post Entries";
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

                    ItemPosting := Confirm (TextPostItemEntries);
                    POSPosting := Confirm (TextPostPosEntries);

                    POSPostEntries.SetPostCompressed(Confirm(TextPostCompressed));
                    POSPostEntries.SetStopOnError(true);

                    if (ItemPosting) then begin
                      POSEntryToPost.Reset;
                      POSEntryToPost.CopyFilters(Rec);
                      POSEntryToPost.SetFilter("Post Item Entry Status",'<2');
                      POSPostEntries.SetPostItemEntries (true);
                      POSPostEntries.SetPostPOSEntries (false);
                      repeat

                        if (POSEntryToPost.FindLast ()) then
                          POSEntryToPost.SetFilter ("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                        POSPostEntries.Run (POSEntryToPost);
                        Commit;

                        ErrorDuringPosting := not POSEntryToPost.IsEmpty ();
                        POSEntryToPost.SetFilter ("POS Period Register No.", GetFilter ("POS Period Register No."));

                      until (ErrorDuringPosting or POSEntryToPost.IsEmpty());
                    end;

                    if (POSPosting) then begin
                      POSEntryToPost.Reset;
                      POSEntryToPost.CopyFilters(Rec);
                      POSEntryToPost.SetFilter("Post Entry Status",'<2');
                      POSPostEntries.SetPostItemEntries (false);
                      POSPostEntries.SetPostPOSEntries (true);
                      repeat

                        if (POSEntryToPost.FindLast ()) then
                          POSEntryToPost.SetFilter ("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                        POSPostEntries.Run (POSEntryToPost);
                        Commit;

                        ErrorDuringPosting := not POSEntryToPost.IsEmpty ();
                        POSEntryToPost.SetFilter ("POS Period Register No.", GetFilter ("POS Period Register No."));

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
                Visible = false;

                trigger OnAction()
                var
                    POSEntryToPost: Record "POS Entry";
                    POSPostEntries: Codeunit "POS Post Entries";
                begin
                    POSEntryToPost.SetRange("Entry No.","Entry No.");
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
                Visible = false;

                trigger OnAction()
                var
                    POSEntryToPost: Record "POS Entry";
                    POSPostEntries: Codeunit "POS Post Entries";
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
                    POSEntryToPost: Record "POS Entry";
                    POSPostEntries: Codeunit "POS Post Entries";
                begin
                    //-NPR5.37 [293133]
                    POSEntryToPost.SetRange("Entry No.","Entry No.");
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
            action(Action6014435)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                var
                    POSPeriodRegister: Record "POS Period Register";
                    Navigate: Page Navigate;
                begin
                    //-NPR5.51 [359508]
                    // Navigate.SetDoc("Posting Date","Document No.");
                    // Navigate.RUN;

                    Navigate.SetDoc("Posting Date","Document No.");
                    if ("Entry Type" <> "Entry Type"::Balancing) then
                      if (POSPeriodRegister.Get ("POS Period Register No.")) then
                        if (POSPeriodRegister."Document No." <> '') then
                          Navigate.SetDoc ("Posting Date", POSPeriodRegister."Document No.");

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
                        POSEntryManagement: Codeunit "POS Entry Management";
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
                        POSEntryManagement: Codeunit "POS Entry Management";
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
                        EFTTransactionRequest: Record "EFT Transaction Request";
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
                    RunObject = Page "POS Entry Output Log";
                    RunPageLink = "POS Entry No."=FIELD("Entry No.");
                }
                action("Entry Overview")
                {
                    Caption = 'Entry Overview';
                    Image = PrintCheck;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        POSEntry: Record "POS Entry";
                    begin
                        //-NPR5.40
                        Clear(POSEntry);
                        POSEntry.SetRange("POS Store Code",Rec."POS Store Code");
                        REPORT.Run(REPORT::"Posting Overview POS",true,true,POSEntry);
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
        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
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
    end;

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NP Retail Setup";
    begin
        NPRetailSetup.Get;
        TestMode :=  (NPRetailSetup."Environment Type" in [NPRetailSetup."Environment Type"::DEV,NPRetailSetup."Environment Type"::TEST]);
        AdvancedPostingOff := (not NPRetailSetup."Advanced Posting Activated");
        //-NPR5.48 [318028]
        //FiscalNoSet := (NPRetailSetup."Sale Fiscal No. Series" <> '') OR (NPRetailSetup."Balancing Fiscal No. Series" <> '');
        //+NPR5.48 [318028]

        SetRange("System Entry",false);
        //-NPR5.53 [387885]
        if GetFilter("Entry Type") = '' then
          SetFilter("Entry Type",'<>%1',"Entry Type"::"Cancelled Sale");
        //+NPR5.53 [387885]
        if FindFirst then;
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
        LastOpenSalesDocumentNo: Code[20];
        LastPostedSalesDocumentNo: Code[20];

    local procedure TryGetLastOpenSalesDoc(var POSEntrySalesDocLinkOut: Record "POS Entry Sales Doc. Link"): Boolean
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

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "POS Entry Sales Doc. Link"): Boolean
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

    local procedure ShowWorkshift(POSEntry: Record "POS Entry")
    var
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
    begin

        //-NPR5.50 [352319]
        if (POSEntry."Entry No." <> 0) then begin
          POSWorkshiftCheckpoint.SetFilter ("POS Entry No.", '=%1', POSEntry."Entry No.");
          if (POSWorkshiftCheckpoint.FindLast ()) then begin
            PAGE.Run (PAGE::"POS Workshift Checkpoint Card", POSWorkshiftCheckpoint);
          end else begin
            POSWorkshiftCheckpoint.Reset ();
            POSWorkshiftCheckpoint.SetFilter ("POS Unit No.", '=%1', POSEntry."POS Unit No.");
            POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
            POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);
            if (POSWorkshiftCheckpoint.FindSet ()) then
              PAGE.Run (PAGE::"POS Workshift Checkpoints", POSWorkshiftCheckpoint);
          end;
        end else begin
          POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);
          POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
          PAGE.Run (PAGE::"POS Workshift Checkpoints", POSWorkshiftCheckpoint);
        end;
        //+NPR5.50 [352319]
    end;
}

