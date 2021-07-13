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
            repeater(Group)
            {
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
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Document Type"; Rec."Sales Document Type")
                {

                    ToolTip = 'Specifies the value of the Sales Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Document No."; Rec."Sales Document No.")
                {

                    ToolTip = 'Specifies the value of the Sales Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Sales (LCY)"; Rec."Item Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the Item Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {

                    ToolTip = 'Specifies the value of the Sales Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Sales Quantity"; Rec."Return Sales Quantity")
                {

                    ToolTip = 'Specifies the value of the Return Sales Quantity field';
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

                ToolTip = 'Executes the &Navigate action';
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

                    ToolTip = 'Executes the Sales Receipt action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo(Rec."POS Unit No.");
                        case Rec."Entry Type" of
                            Rec."Entry Type"::"Direct Sale":
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
                            Rec."Entry Type"::"Credit Sale":
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

                    ToolTip = 'Executes the Large Sales Receipt action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo(Rec."POS Unit No.");
                        if Rec."Entry Type" = Rec."Entry Type"::"Direct Sale" then
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

                    ToolTip = 'Executes the Balancing action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
                        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Balancing);

                        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', Rec."Entry No.");
                        POSWorkshiftCheckpoint.FindFirst();
                        RecRef.GetTable(POSWorkshiftCheckpoint);

                        RetailReportSelectionMgt.SetRegisterNo(Rec."POS Unit No.");
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
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;

                    ToolTip = 'Executes the E-mail Log action';
                    ApplicationArea = NPRRetail;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    Promoted = true;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Send as PDF action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


    var
        TextPostItemEntries: Label 'Post Item Entries?';
        TextPostPosEntries: Label 'Post all other Entries?';
        TextPostCompressed: Label 'Post Compressed?';
}

