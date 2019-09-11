page 6150650 "POS Entries"
{
    // NPR5.36/NPKNAV/20171003  CASE 262628-04 Transport NPR5.36 - 3 October 2017
    // NPR5.37/NPKNAV/20171030  CASE 294294 Transport NPR5.37 - 27 October 2017
    // NPR5.38/BR  /20180115  CASE 302311 Added warning if Posting is switched off
    // NPR5.39/BR  /20180212  CASE 302687 Added 'Print' Group Promoted Actions for Major Tom use
    // NPR5.40/TSA /20180308  CASE 307267 Refactored print for balancing
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring

    Caption = 'POS Entries';
    Editable = false;
    PageType = List;
    SourceTable = "POS Entry";

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
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("POS Period Register No.";"POS Period Register No.")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field(Description;Description)
                {
                }
                field("Entry Date";"Entry Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field("Post Item Entry Status";"Post Item Entry Status")
                {
                }
                field("Post Entry Status";"Post Entry Status")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Sales Document Type";"Sales Document Type")
                {
                }
                field("Sales Document No.";"Sales Document No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Item Sales (LCY)";"Item Sales (LCY)")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
                field("Sales Quantity";"Sales Quantity")
                {
                }
                field("Return Sales Quantity";"Return Sales Quantity")
                {
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
            action("Comment Lines")
            {
                Caption = 'Comment Lines';
                Image = Comment;
                RunObject = Page "POS Entry Comments";
                RunPageLink = "Table ID"=CONST(6150621),
                              "POS Entry No."=FIELD("Entry No.");
                RunPageView = SORTING("Table ID","POS Entry No.","POS Entry Line No.",Code,"Line No.")
                              ORDER(Ascending);
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

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date","Document No.");
                    Navigate.Run;
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

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
                        ReportSelectionRetail: Record "Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.39 [302687]
                        RecRef.GetTable(Rec);
                        RetailReportSelectionMgt.SetRegisterNo("POS Unit No.");
                        case "Entry Type" of
                          "Entry Type"::"Direct Sale" : RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
                          "Entry Type"::"Credit Sale" : RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
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

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
                        ReportSelectionRetail: Record "Report Selection Retail";
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

                    trigger OnAction()
                    var
                        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
                        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
                        ReportSelectionRetail: Record "Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.46 [307267]
                        TestField ("Entry Type", "Entry Type"::Balancing);

                        POSWorkshiftCheckpoint.SetFilter ("POS Entry No.", '=%1', "Entry No.");
                        POSWorkshiftCheckpoint.FindFirst ();
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

                    trigger OnAction()
                    var
                        EFTTransactionRequest: Record "EFT Transaction Request";
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
                    RunObject = Page "POS Entry Output Log";
                    RunPageLink = "POS Entry No."=FIELD("Entry No.");
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NPRetailSetup: Record "NP Retail Setup";
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
}

