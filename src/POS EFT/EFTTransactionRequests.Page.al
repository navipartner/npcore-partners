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
                }
                field("Integration Type"; "Integration Type")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                }
                field("Auxiliary Operation Desc."; "Auxiliary Operation Desc.")
                {
                    ApplicationArea = All;
                }
                field(Started; Started)
                {
                    ApplicationArea = All;
                }
                field(Finished; Finished)
                {
                    ApplicationArea = All;
                }
                field(TransDuration; TransDuration)
                {
                    ApplicationArea = All;
                    Caption = 'Duration';
                    Editable = false;
                }
                field("Result Amount"; "Result Amount")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field(Successful; Successful)
                {
                    ApplicationArea = All;
                }
                field("External Result Known"; "External Result Known")
                {
                    ApplicationArea = All;
                }
                field("Result Processed"; "Result Processed")
                {
                    ApplicationArea = All;
                }
                field("Force Closed"; "Force Closed")
                {
                    ApplicationArea = All;
                }
                field(Reversed; Reversed)
                {
                    ApplicationArea = All;
                }
                field(Recovered; Recovered)
                {
                    ApplicationArea = All;
                }
                field("Result Display Text"; "Result Display Text")
                {
                    ApplicationArea = All;
                }
                field("NST Error"; "NST Error")
                {
                    ApplicationArea = All;
                }
                field("Client Error"; "Client Error")
                {
                    ApplicationArea = All;
                }
                field("Result Code"; "Result Code")
                {
                    ApplicationArea = All;
                }
                field("Result Description"; "Result Description")
                {
                    ApplicationArea = All;
                }
                field("Card Type"; "Card Type")
                {
                    ApplicationArea = All;
                }
                field("Card Name"; "Card Name")
                {
                    ApplicationArea = All;
                }
                field("Card Number"; "Card Number")
                {
                    ApplicationArea = All;
                }
                field("Card Expiry Date"; "Card Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("Reference Number Input"; "Reference Number Input")
                {
                    ApplicationArea = All;
                }
                field("Reference Number Output"; "Reference Number Output")
                {
                    ApplicationArea = All;
                }
                field("Authorisation Number"; "Authorisation Number")
                {
                    ApplicationArea = All;
                }
                field("Auxiliary Operation ID"; "Auxiliary Operation ID")
                {
                    ApplicationArea = All;
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                }
                field("Offline mode"; "Offline mode")
                {
                    ApplicationArea = All;
                }
                field("Integration Version Code"; "Integration Version Code")
                {
                    ApplicationArea = All;
                }
                field("Client Assembly Version"; "Client Assembly Version")
                {
                    ApplicationArea = All;
                }
                field("Pepper Terminal Code"; "Pepper Terminal Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pepper Transaction Type Code"; "Pepper Transaction Type Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pepper Trans. Subtype Code"; "Pepper Trans. Subtype Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Transaction ID"; "External Transaction ID")
                {
                    ApplicationArea = All;
                }
                field("External Customer ID"; "External Customer ID")
                {
                    ApplicationArea = All;
                }
                field("Hardware ID"; "Hardware ID")
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = All;
                }
                field("Transaction Time"; "Transaction Time")
                {
                    ApplicationArea = All;
                }
                field("Authentication Method"; "Authentication Method")
                {
                    ApplicationArea = All;
                }
                field("Bookkeeping Period"; "Bookkeeping Period")
                {
                    ApplicationArea = All;
                }
                field("Amount Input"; "Amount Input")
                {
                    ApplicationArea = All;
                }
                field("Amount Output"; "Amount Output")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Cashback Amount"; "Cashback Amount")
                {
                    ApplicationArea = All;
                }
                field("Fee Amount"; "Fee Amount")
                {
                    ApplicationArea = All;
                }
                field("Financial Impact"; "Financial Impact")
                {
                    ApplicationArea = All;
                }
                field("Processed Entry No."; "Processed Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Reversed by Entry No."; "Reversed by Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Recovered by Entry No."; "Recovered by Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Initiated from Entry No."; "Initiated from Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Receipt 1"; "Receipt 1".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Receipt 2"; "Receipt 2".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. of Reprints"; "No. of Reprints")
                {
                    ApplicationArea = All;
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                }
                field("Number of Attempts"; "Number of Attempts")
                {
                    ApplicationArea = All;
                }
                field("FF Moved to POS Entry"; "FF Moved to POS Entry")
                {
                    ApplicationArea = All;
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
            }
            part(Control6014410; "NPR EFT Trx Log Factbox")
            {
                SubPageLink = "Transaction Entry No." = FIELD("Entry No.");
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

