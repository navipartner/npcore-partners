page 6150650 "NPR POS Entries"
{
    Caption = 'POS Entries';
    ContextSensitiveHelpPage = 'docs/retail/pos_academy/pos_entry/accounting_entries/';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies unique code assigned to POS store';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the identification number of the POS unit';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the document number associated with the transaction';
                    ApplicationArea = NPRRetail;
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {

                    ToolTip = 'Specifies the register number for the POS period';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the type of entry for the transaction';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a description about the entry';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Date"; Rec."Entry Date")
                {

                    ToolTip = 'Specifies the date on which transaction is performed';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the start time for the transaction';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the end time for the transaction';
                    ApplicationArea = NPRRetail;
                }
                field("Post Item Entry Status"; Rec."Post Item Entry Status")
                {

                    ToolTip = 'Indicates the status of the item entry after posting';
                    ApplicationArea = NPRRetail;
                }
                field("Post Entry Status"; Rec."Post Entry Status")
                {

                    ToolTip = 'Indicates the status of the entry after posting';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies customer''s identification number associated with the transaction';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Document Type"; Rec."Sales Document Type")
                {

                    ToolTip = 'Specifies the type of sales document';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Document No."; Rec."Sales Document No.")
                {

                    ToolTip = 'Specifies document number associated with the sales transaction';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies salesperson''s identification number associated with the transaction';
                    ApplicationArea = NPRRetail;
                }
                field("Item Sales (LCY)"; Rec."Item Sales (LCY)")
                {

                    ToolTip = 'Indicates the sales amount in the local currency';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the total amount of discount applied';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {

                    ToolTip = 'Specifies the quantity of items sold';
                    ApplicationArea = NPRRetail;
                }
                field("Return Sales Quantity"; Rec."Return Sales Quantity")
                {

                    ToolTip = 'Specifies the quantity of items returned';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ToolTip = 'Indicates the total amount including taxes for the transaction';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the date on which transaction is posted';
                    ApplicationArea = NPRRetail;
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
                RunObject = Page "NPR POS Entry Sales Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");

                ToolTip = 'View detailed information about the sales lines';
                ApplicationArea = NPRRetail;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Entry Pmt. Line List";
                RunPageLink = "POS Entry No." = FIELD("Entry No.");

                ToolTip = 'Access the payment details associated with this entry';
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

                ToolTip = 'Access the comments associated with this entry';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Quickly search for specific entries or documents';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
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

                ToolTip = 'Post this entry to finalize the transaction';
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

                ToolTip = 'Post a range of entries at once';
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
            action("Show Entry")
            {
                Caption = 'Show Entry';
                Image = Card;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open a card view to examine the entry details';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NPRPOSEntryCard: Page "NPR POS Entry Card";
                    NPRPOSEntry: Record "NPR POS Entry";
                begin
                    NPRPOSEntry.SetRange("Entry No.", Rec."Entry No.");
                    NPRPOSEntryCard.SetTableView(NPRPOSEntry);
                    NPRPOSEntryCard.RunModal();
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
                    PromotedOnly = false;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    ToolTip = 'Print a sales receipt for this entry';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo(Rec."POS Unit No.");
                        case Rec."Entry Type" of
                            Rec."Entry Type"::"Direct Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Sales Receipt (POS Entry)".AsInteger());
                            Rec."Entry Type"::"Credit Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Sales Doc. Confirmation (POS Entry)".AsInteger());
                        end;
                    end;
                }
                action("Large Sales Receipt")
                {
                    Caption = 'Large Sales Receipt';
                    Image = PrintCover;
                    Promoted = true;
                    PromotedOnly = false;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    ToolTip = 'Print a detailed sales receipt for this entry';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo(Rec."POS Unit No.");
                        if Rec."Entry Type" = Rec."Entry Type"::"Direct Sale" then
                            RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Large Sales Receipt (POS Entry)".AsInteger());
                    end;
                }
                action("Balancing ")
                {
                    Caption = 'Balancing';
                    Image = PrintReport;
                    Promoted = true;
                    PromotedOnly = false;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    ToolTip = 'Print the balance and reconcile information for this entry';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                        RecRef: RecordRef;
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Balancing);

                        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', Rec."Entry No.");
                        POSWorkshiftCheckpoint.FindFirst();
                        RecRef.GetTable(POSWorkshiftCheckpoint);

                        RetailReportSelectionMgt.SetRegisterNo(Rec."POS Unit No.");
                        RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Balancing (POS Entry)".AsInteger());
                    end;
                }
                action("EFT Receipt")
                {
                    Caption = 'EFT Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedOnly = false;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    ToolTip = 'Print electronic funds transfer receipt';
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

                    ToolTip = 'Review the printing history and details';
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

                    ToolTip = 'View the history of sent emails';
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
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Removed from promoted category.';
                    Visible = false;
                    Promoted = true;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Send as PDF action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
                    begin
                        EmailDocMgt.SendReport(Rec, false);
                    end;
                }

                action("Send As PDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;

                    ToolTip = 'Send this entry as a PDF attachment';
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
}

