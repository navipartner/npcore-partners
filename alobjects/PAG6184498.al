page 6184498 "EFT Transaction Requests"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160330  CASE 231481 Fixed misspelling Successful
    // NPR5.22\BR\20160407  CASE 231481 Added Result Display Text
    // NPR5.22\BR\20160412  CASE 231481 Added field offline mode
    // NPR5.28\BR\20161205  CASE 259563 Added field Duration
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Fields Token, Integration Type and Transaction Subtype
    // NPR5.35/BR  /20170815  CASE 284379 Added Field Cashback Amount
    // NPR5.38/MHA /20170109  CASE 295549 Added fields to be used with MobilPay Integration
    // NPR5.40/MMV /20180328  CASE 276562 Changed caption from Pepper to EFT.
    // NPR5.46/MMV /20180913  CASE 290734 Added new actions and changed fields around.
    // NPR5.48/MMV /20181221  CASE 340754 Removed page actions lookup, void, refund as the user flow has been replaced with action EFT_OPERATION approach.
    // NPR5.53/MMV /20191206 CASE 377533 Changed styling and added new flowfield for error overview.
    //                                   Added logging factbox.

    Caption = 'EFT Transaction Requests';
    Editable = false;
    PageType = List;
    SourceTable = "EFT Transaction Request";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                InstructionalText = 'Blue: Recovered & in sync\Yellow: Recovered but on different receipt number\Red: Unfinished, no external result or unposted amount';
                field("Entry No.";"Entry No.")
                {
                    StyleExpr = Style;
                }
                field("Integration Type";"Integration Type")
                {
                    StyleExpr = Style;
                }
                field("Processing Type";"Processing Type")
                {
                    StyleExpr = Style;
                }
                field("Auxiliary Operation Desc.";"Auxiliary Operation Desc.")
                {
                }
                field(Started;Started)
                {
                }
                field(Finished;Finished)
                {
                }
                field(TransDuration;TransDuration)
                {
                    Caption = 'Duration';
                    Editable = false;
                }
                field("Result Amount";"Result Amount")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("User ID";"User ID")
                {
                }
                field(Successful;Successful)
                {
                }
                field("External Result Received";"External Result Received")
                {
                }
                field("Force Closed";"Force Closed")
                {
                }
                field(Reversed;Reversed)
                {
                }
                field(Recovered;Recovered)
                {
                }
                field("Result Display Text";"Result Display Text")
                {
                }
                field("NST Error";"NST Error")
                {
                }
                field("Client Error";"Client Error")
                {
                }
                field("Result Code";"Result Code")
                {
                }
                field("Result Description";"Result Description")
                {
                }
                field("Card Type";"Card Type")
                {
                }
                field("Card Name";"Card Name")
                {
                }
                field("Card Number";"Card Number")
                {
                }
                field("Card Expiry Date";"Card Expiry Date")
                {
                }
                field("Reference Number Input";"Reference Number Input")
                {
                }
                field("Reference Number Output";"Reference Number Output")
                {
                }
                field("Authorisation Number";"Authorisation Number")
                {
                }
                field("Auxiliary Operation ID";"Auxiliary Operation ID")
                {
                }
                field(Mode;Mode)
                {
                }
                field("Offline mode";"Offline mode")
                {
                }
                field("Integration Version Code";"Integration Version Code")
                {
                }
                field("Client Assembly Version";"Client Assembly Version")
                {
                }
                field("Pepper Terminal Code";"Pepper Terminal Code")
                {
                    Visible = false;
                }
                field("Pepper Transaction Type Code";"Pepper Transaction Type Code")
                {
                    Visible = false;
                }
                field("Pepper Trans. Subtype Code";"Pepper Trans. Subtype Code")
                {
                    Visible = false;
                }
                field("External Transaction ID";"External Transaction ID")
                {
                }
                field("External Customer ID";"External Customer ID")
                {
                }
                field("Hardware ID";"Hardware ID")
                {
                }
                field("Transaction Date";"Transaction Date")
                {
                }
                field("Transaction Time";"Transaction Time")
                {
                }
                field("Authentication Method";"Authentication Method")
                {
                }
                field("Bookkeeping Period";"Bookkeeping Period")
                {
                }
                field("Amount Input";"Amount Input")
                {
                }
                field("Amount Output";"Amount Output")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Cashback Amount";"Cashback Amount")
                {
                }
                field("Fee Amount";"Fee Amount")
                {
                }
                field("Financial Impact";"Financial Impact")
                {
                }
                field("Processed Entry No.";"Processed Entry No.")
                {
                }
                field("Reversed by Entry No.";"Reversed by Entry No.")
                {
                }
                field("Recovered by Entry No.";"Recovered by Entry No.")
                {
                }
                field("Initiated from Entry No.";"Initiated from Entry No.")
                {
                }
                field("Receipt 1";"Receipt 1".HasValue)
                {
                    Editable = false;
                }
                field("Receipt 2";"Receipt 2".HasValue)
                {
                    Editable = false;
                }
                field("No. of Reprints";"No. of Reprints")
                {
                }
                field(Token;Token)
                {
                }
                field("Number of Attempts";"Number of Attempts")
                {
                }
                field("FF Moved to POS Entry";"FF Moved to POS Entry")
                {
                }
            }
        }
        area(factboxes)
        {
            part(Control6150639;"EFT Tr. Rq. Comment Subform")
            {
                SubPageLink = "Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("Entry No.")
                              ORDER(Ascending);
            }
            part(Control6014410;"EFT Transaction Log Factbox")
            {
                SubPageLink = "Transaction Entry No."=FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Receipt 1")
            {
                Caption = 'Show Receipt 1';
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
                begin
                    //-NPR5.46 [290734]
                    // DisplayText := PepperConfigManagement.GetReceiptText(Rec,1,TRUE);
                    // MESSAGE(DisplayText);
                    EFTFrameworkMgt.DisplayReceipt(Rec, 1);
                    //+NPR5.46 [290734]
                end;
            }
            action("Show Receipt 2")
            {
                Caption = 'Show Receipt 2';
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
                begin
                    //-NPR5.46 [290734]
                    // DisplayText := PepperConfigManagement.GetReceiptText(Rec,2,TRUE);
                    // MESSAGE(DisplayText);
                    EFTFrameworkMgt.DisplayReceipt(Rec, 2);
                    //+NPR5.46 [290734]
                end;
            }
            action(Reprint)
            {
                Caption = 'Reprint';
                Image = PrintCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-NPR5.46 [290734]
                    Rec.PrintReceipts(true);
                    //+NPR5.46 [290734]
                end;
            }
            action("Download Logs")
            {
                Caption = 'Download Logs';
                Image = CreateXMLFile;

                trigger OnAction()
                var
                    EFTFramework: Codeunit "EFT Framework Mgt.";
                begin
                    //-NPR5.46 [290734]
                    EFTFramework.DownloadTransactionLogs(Rec);
                    //+NPR5.46 [290734]
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.28 [259563]
        TransDuration := 0;
        if (Finished <> 0DT) and (Started <> 0DT) then
          TransDuration := Finished - Started;
        //+NPR5.28 [259563]

        //-NPR5.53 [377533]
        Style := SetStyle();
        //+NPR5.53 [377533]
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.53 [377533]
        SetAutoCalcFields("FF Moved to POS Entry");
        //+NPR5.53 [377533]

        if FindFirst then;
    end;

    var
        DisplayText: Text;
        TransDuration: Duration;
        Style: Text;

    local procedure ClosePageIfInsidePOS()
    var
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.46 [290734]
        if POSSession.IsActiveSession(POSFrontEnd) then
          CurrPage.Close();
        //+NPR5.46 [290734]
    end;

    local procedure SetStyle(): Text
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
    begin
        //-NPR5.53 [377533]
        if (Recovered) then begin
          if EFTTransactionRequest.Get("Recovered by Entry No.") then
            if EFTTransactionRequest."Result Amount" <> 0 then
              if EFTTransactionRequest."Sales Ticket No." <> "Sales Ticket No." then
                exit('Ambiguous'); //Recovered with an amount but too late to post automatically in same sale.

          exit('StrongAccent'); //Recovered and in sync.
        end;

        if (Finished = 0DT) and ("Amount Input" <> 0) then begin
          if (not EFTFrameworkMgt.IsFromMostRecentSaleOnPOSUnit(Rec)) then
            exit('Unfavorable'); //Lost trx result

          exit(''); //Currently ongoing trx
        end;

        if (not "External Result Received") and ("Amount Input" <> 0) then
          exit('Unfavorable'); //Lost trx result

        if "Result Amount" <> 0 then begin
          if (not "FF Moved to POS Entry") then
            if (not EFTFrameworkMgt.IsFromMostRecentSaleOnPOSUnit(Rec)) then
              exit('Unfavorable'); //Lost trx result
        end;

        exit('');
        //+NPR5.53 [377533]
    end;
}

