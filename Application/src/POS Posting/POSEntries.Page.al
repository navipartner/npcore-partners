page 6150650 "NPR POS Entries"
{
    Caption = 'POS Entries';
    Editable = false;
    PageType = List;
    UsageCategory = None;
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
                ToolTip = 'Specifies the value of the Advanced Posting Warning field';
            }
            field(ClicktoSeeAuditRoll; TextClicktoSeeAuditRoll)
            {
                ApplicationArea = All;
                Caption = 'Click to See Audit Roll';
                LookupPageID = "NPR POS Entries";
                ShowCaption = false;
                Visible = AdvancedPostingOff;
                ToolTip = 'Specifies the value of the Click to See Audit Roll field';

                trigger OnAssistEdit()
                begin
                    PAGE.Run(PAGE::"NPR Audit Roll");
                    CurrPage.Close;
                end;
            }
            repeater(Group)
            {
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
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                field("Post Item Entry Status"; "Post Item Entry Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Item Entry Status field';
                }
                field("Post Entry Status"; "Post Entry Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Entry Status field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Sales Document Type"; "Sales Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Document Type field';
                }
                field("Sales Document No."; "Sales Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Document No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Item Sales (LCY)"; "Item Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Sales (LCY) field';
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field("Sales Quantity"; "Sales Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Quantity field';
                }
                field("Return Sales Quantity"; "Return Sales Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Sales Quantity field';
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
                ToolTip = 'Executes the Sales Lines action';
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Payment Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Payment Lines action';
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
        }
        area(processing)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

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
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("Sales Receipt")
                {
                    Caption = 'Sales Receipt';
                    Image = PrintCheck;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Receipt action';

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        case "Entry Type" of
                            "Entry Type"::"Direct Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
                            "Entry Type"::"Credit Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
                        end;
                    end;
                }
                action("Large Sales Receipt")
                {
                    Caption = 'Large Sales Receipt';
                    Image = PrintCover;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Large Sales Receipt action';

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        if "Entry Type" = "Entry Type"::"Direct Sale" then
                            RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)");
                    end;
                }
                action("Balancing ")
                {
                    Caption = 'Balancing';
                    Image = PrintReport;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Balancing action';

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        TestField("Entry Type", "Entry Type"::Balancing);

                        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', "Entry No.");
                        POSWorkshiftCheckpoint.FindFirst();
                        RecRef.GetTable(POSWorkshiftCheckpoint);

                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
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
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    Promoted = true;
				    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if NPRetailSetup.Get then
            AdvancedPostingOff := (not NPRetailSetup."Advanced Posting Activated");
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

