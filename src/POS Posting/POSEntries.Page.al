page 6150650 "NPR POS Entries"
{
    // NPR5.36/NPKNAV/20171003  CASE 262628-04 Transport NPR5.36 - 3 October 2017
    // NPR5.37/NPKNAV/20171030  CASE 294294 Transport NPR5.37 - 27 October 2017
    // NPR5.38/BR  /20180115  CASE 302311 Added warning if Posting is switched off
    // NPR5.39/BR  /20180212  CASE 302687 Added 'Print' Group Promoted Actions for Major Tom use
    // NPR5.40/TSA /20180308  CASE 307267 Refactored print for balancing
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring
    // NPR5.53/SARA/20191024 CASE 373672 Add Post and Post Range actions

    Caption = 'POS Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Entry";

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
            repeater(Group)
            {
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
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
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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
                field("Post Item Entry Status"; "Post Item Entry Status")
                {
                    ApplicationArea = All;
                }
                field("Post Entry Status"; "Post Entry Status")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Document Type"; "Sales Document Type")
                {
                    ApplicationArea = All;
                }
                field("Sales Document No."; "Sales Document No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Item Sales (LCY)"; "Item Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Sales Quantity"; "Sales Quantity")
                {
                    ApplicationArea = All;
                }
                field("Return Sales Quantity"; "Return Sales Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Sales Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Payment Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
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
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
            action("Post Entry")
            {
                Caption = 'Post Entry';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    POSEntryToPost: Record "NPR POS Entry";
                begin
                    //-NPR5.53 [373672]
                    POSEntryToPost.SetRange("Entry No.", "Entry No.");
                    if Rec."Post Item Entry Status" < "Post Item Entry Status"::Posted then
                        POSPostEntries.SetPostItemEntries(true);
                    if Rec."Post Entry Status" < "Post Entry Status"::Posted then
                        POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.Run(POSEntryToPost);
                    CurrPage.Update(false);
                    //+NPR5.53 [373672]
                end;
            }
            action("Post Range")
            {
                Caption = 'Post Range';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    ErrorDuringPosting: Boolean;
                    ItemPosting: Boolean;
                    POSPosting: Boolean;
                begin
                    //-NPR5.53 [373672]
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
                    //+NPR5.53 [373672]
                end;
            }
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("Sales Receipt")
                {
                    Caption = 'Sales Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.39 [302687]
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        case "Entry Type" of
                            "Entry Type"::"Direct Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
                            "Entry Type"::"Credit Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
                        end;
                        //+NPR5.39 [302687]
                    end;
                }
                action("Large Sales Receipt")
                {
                    Caption = 'Large Sales Receipt';
                    Image = PrintCover;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.39 [302687]
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        if "Entry Type" = "Entry Type"::"Direct Sale" then
                            RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)");
                        //+NPR5.39 [302687]
                    end;
                }
                action("Balancing ")
                {
                    Caption = 'Balancing';
                    Image = PrintReport;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.46 [307267]
                        TestField("Entry Type", "Entry Type"::Balancing);

                        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', "Entry No.");
                        POSWorkshiftCheckpoint.FindFirst();
                        RecRef.GetTable(POSWorkshiftCheckpoint);

                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
                        //+NPR5.46 [307267]
                    end;
                }
                action("EFT Receipt")
                {
                    Caption = 'EFT Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "NPR EFT Transaction Request";
                    begin
                        //-NPR5.46 [290734]
                        //-NPR5.39 [302687]
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
                        //+NPR5.39[302687]

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
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        //-NPR5.38 [301600]
        if NPRetailSetup.Get then
            AdvancedPostingOff := (not NPRetailSetup."Advanced Posting Activated");
        //+NPR5.38 [301600]
    end;

    var
        TextAdvancedPostingOff: Label 'WARNING: Advanced Posting is OFF. Audit Roll used for posting.';
        TextClicktoSeeAuditRoll: Label 'Click here to see Audit Roll';
        AdvancedPostingOff: Boolean;
        Text10600006: Label 'There are no credit card transactions attached to sales ticket no. %1/Register %2';
        TextPostItemEntries: Label 'Post Item Entries?';
        TextPostPosEntries: Label 'Post all other Entries?';
        TextPostCompressed: Label 'Post Compressed?';
}

