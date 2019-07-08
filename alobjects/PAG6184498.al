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
                field("Entry No.";"Entry No.")
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
                }
                field("Integration Type";"Integration Type")
                {
                }
                field("Pepper Terminal Code";"Pepper Terminal Code")
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
                    Visible = false;
                }
                field(Mode;Mode)
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
                }
                field("Pepper Transaction Type Code";"Pepper Transaction Type Code")
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
                    Visible = false;
                }
                field("Pepper Trans. Subtype Code";"Pepper Trans. Subtype Code")
                {
                    Visible = false;
                }
                field("Processing Type";"Processing Type")
                {
                }
                field("Auxiliary Operation ID";"Auxiliary Operation ID")
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
                    Style = Attention;
                    StyleExpr = NOT Successful;
                }
                field("Register No.";"Register No.")
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
                }
                field("Offline mode";"Offline mode")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Integration Version Code";"Integration Version Code")
                {
                }
                field("Client Assembly Version";"Client Assembly Version")
                {
                }
                field("Auxiliary Operation Desc.";"Auxiliary Operation Desc.")
                {
                }
                field("Result Code";"Result Code")
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
                }
                field("Result Description";"Result Description")
                {
                    Style = Attention;
                    StyleExpr = NOT Successful;
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
                field(Successful;Successful)
                {
                }
                field("External Result Received";"External Result Received")
                {
                }
                field("Financial Impact";"Financial Impact")
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
                field("Force Closed";"Force Closed")
                {
                }
                field("Processed Entry No.";"Processed Entry No.")
                {
                }
                field(Reversed;Reversed)
                {
                }
                field("Reversed by Entry No.";"Reversed by Entry No.")
                {
                }
                field(Recovered;Recovered)
                {
                }
                field("Recovered by Entry No.";"Recovered by Entry No.")
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
                field("Initiated from Entry No.";"Initiated from Entry No.")
                {
                }
                field("Number of Attempts";"Number of Attempts")
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
    end;

    trigger OnOpenPage()
    begin
        if FindFirst then;
    end;

    var
        DisplayText: Text;
        TransDuration: Duration;

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
}

