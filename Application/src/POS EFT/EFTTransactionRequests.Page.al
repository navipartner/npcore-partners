page 6184498 "NPR EFT Transaction Requests"
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
    // NPR5.54/MMV /20200218 CASE 377533 Rolled back parts of styling due to perf.
    // NPR5.54/MMV /20200219 CASE 364340 Created field "Result Processed".
    // NPR5.54/JAKUBV/20200408  CASE 387990 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT Transaction Requests';
    Editable = false;
    PageType = List;
    SourceTable = "NPR EFT Transaction Request";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                InstructionalText = 'Blue: Recovered & in sync\Yellow: Recovered but on different receipt number\Red: Unfinished, no external result or unposted amount';
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Integration Type"; "Integration Type")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Integration Type field';
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Auxiliary Operation Desc."; "Auxiliary Operation Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auxiliary Operation Desc. field';
                }
                field(Started; Started)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Started field';
                }
                field(Finished; Finished)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Finished field';
                }
                field(TransDuration; TransDuration)
                {
                    ApplicationArea = All;
                    Caption = 'Duration';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Duration field';
                }
                field("Result Amount"; "Result Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Amount field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(Successful; Successful)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Successful field';
                }
                field("External Result Known"; "External Result Known")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Result Known field';
                }
                field("Result Processed"; "Result Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Processed field';
                }
                field("Force Closed"; "Force Closed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Closed field';
                }
                field(Reversed; Reversed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed field';
                }
                field(Recovered; Recovered)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recovered field';
                }
                field("Result Display Text"; "Result Display Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Display Text field';
                }
                field("NST Error"; "NST Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NST Error field';
                }
                field("Client Error"; "Client Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Error field';
                }
                field("Result Code"; "Result Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Code field';
                }
                field("Result Description"; "Result Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Description field';
                }
                field("Card Type"; "Card Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Type field';
                }
                field("Card Name"; "Card Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Name field';
                }
                field("Card Number"; "Card Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field("Card Expiry Date"; "Card Expiry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Expiry Date field';
                }
                field("Reference Number Input"; "Reference Number Input")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Number Input field';
                }
                field("Reference Number Output"; "Reference Number Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Number Output field';
                }
                field("Authorisation Number"; "Authorisation Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorisation Number field';
                }
                field("Auxiliary Operation ID"; "Auxiliary Operation ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auxiliary Operation ID field';
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field("Offline mode"; "Offline mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Offline mode field';
                }
                field("Integration Version Code"; "Integration Version Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Integration Version Code field';
                }
                field("Client Assembly Version"; "Client Assembly Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Assembly Version field';
                }
                field("Pepper Terminal Code"; "Pepper Terminal Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Terminal Code field';
                }
                field("Pepper Transaction Type Code"; "Pepper Transaction Type Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Transaction Type Code field';
                }
                field("Pepper Trans. Subtype Code"; "Pepper Trans. Subtype Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Transaction Subtype Code field';
                }
                field("External Transaction ID"; "External Transaction ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Transaction ID field';
                }
                field("External Customer ID"; "External Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Customer ID field';
                }
                field("Hardware ID"; "Hardware ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hardware ID field';
                }
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field("Transaction Time"; "Transaction Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Time field';
                }
                field("Authentication Method"; "Authentication Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authentication Method field';
                }
                field("Bookkeeping Period"; "Bookkeeping Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bookkeeping Period field';
                }
                field("Amount Input"; "Amount Input")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Input field';
                }
                field("Amount Output"; "Amount Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Output field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Cashback Amount"; "Cashback Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashback Amount field';
                }
                field("Fee Amount"; "Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fee Amount field';
                }
                field("Financial Impact"; "Financial Impact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Financial Impact field';
                }
                field("Processed Entry No."; "Processed Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed Entry No. field';
                }
                field("Reversed by Entry No."; "Reversed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed by Entry No. field';
                }
                field("Recovered by Entry No."; "Recovered by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recovered by Entry No. field';
                }
                field("Initiated from Entry No."; "Initiated from Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initiated from Entry No. field';
                }
                field("Receipt 1"; "Receipt 1".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receipt 1.HasValue field';
                }
                field("Receipt 2"; "Receipt 2".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receipt 2.HasValue field';
                }
                field("No. of Reprints"; "No. of Reprints")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Reprints field';
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Token field';
                }
                field("Number of Attempts"; "Number of Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number of Attempts field';
                }
                field("FF Moved to POS Entry"; "FF Moved to POS Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Moved to POS Entry field';
                }
            }
        }
        area(factboxes)
        {
            part(Control6150639; "NPR EFT Tr.Rq.Comment Subform")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Entry No.")
                              ORDER(Ascending);
                ApplicationArea = All;
            }
            part(Control6014410; "NPR EFT Trx Log Factbox")
            {
                SubPageLink = "Transaction Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Receipt 1 action';

                trigger OnAction()
                var
                    EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Receipt 2 action';

                trigger OnAction()
                var
                    EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
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
                ApplicationArea = All;
                ToolTip = 'Executes the Reprint action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Download Logs action';

                trigger OnAction()
                var
                    EFTFramework: Codeunit "NPR EFT Framework Mgt.";
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
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        //-NPR5.54 [377533]
        if NPRetailSetup.Get() then begin
            if NPRetailSetup."Advanced Posting Activated" then begin
                UsesPOSEntry := true;
                SetAutoCalcFields("FF Moved to POS Entry");
            end;
        end;
        //+NPR5.54 [377533]

        if FindFirst then;
    end;

    var
        DisplayText: Text;
        TransDuration: Duration;
        Style: Text;
        UsesPOSEntry: Boolean;

    local procedure ClosePageIfInsidePOS()
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.46 [290734]
        if POSSession.IsActiveSession(POSFrontEnd) then
            CurrPage.Close();
        //+NPR5.46 [290734]
    end;

    local procedure SetStyle(): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        if (Recovered) then begin
            if EFTTransactionRequest.Get("Recovered by Entry No.") then
                if EFTTransactionRequest."Result Amount" <> 0 then
                    if EFTTransactionRequest."Sales Ticket No." <> "Sales Ticket No." then
                        exit('Ambiguous'); //Recovered with an amount but too late to post automatically in same sale.

            exit('StrongAccent'); //Recovered and in sync.
        end;

        //-NPR5.54 [377533]
        if ((Finished = 0DT) or (not "External Result Known"))
          and ("Amount Input" <> 0) then begin
            exit('Unfavorable'); //Lost trx result
        end;

        if "Result Amount" <> 0 then begin
            if ((not "FF Moved to POS Entry") and UsesPOSEntry) then
                exit('Unfavorable'); //EFT handled it correctly but sale never ended.
        end;

        exit('');
        //+NPR5.54 [377533]
    end;
}

