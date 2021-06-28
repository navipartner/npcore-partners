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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Integration Type field';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Auxiliary Operation Desc."; Rec."Auxiliary Operation Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auxiliary Operation Desc. field';
                }
                field(Started; Rec.Started)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Started field';
                }
                field(Finished; Rec.Finished)
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
                field("Result Amount"; Rec."Result Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Amount field';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(Successful; Rec.Successful)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Successful field';
                }
                field("External Result Known"; Rec."External Result Known")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Result Known field';
                }
                field("Result Processed"; Rec."Result Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Processed field';
                }
                field("Force Closed"; Rec."Force Closed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Closed field';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed field';
                }
                field(Recovered; Rec.Recovered)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recovered field';
                }
                field("Result Display Text"; Rec."Result Display Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Display Text field';
                }
                field("NST Error"; Rec."NST Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NST Error field';
                }
                field("Client Error"; Rec."Client Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Error field';
                }
                field("Result Code"; Rec."Result Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Code field';
                }
                field("Result Description"; Rec."Result Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Result Description field';
                }
                field("Card Type"; Rec."Card Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Type field';
                }
                field("Card Name"; Rec."Card Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Name field';
                }
                field("Card Number"; Rec."Card Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field("Card Expiry Date"; Rec."Card Expiry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Expiry Date field';
                }
                field("Reference Number Input"; Rec."Reference Number Input")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Number Input field';
                }
                field("Reference Number Output"; Rec."Reference Number Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Number Output field';
                }
                field("Authorisation Number"; Rec."Authorisation Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorisation Number field';
                }
                field("Auxiliary Operation ID"; Rec."Auxiliary Operation ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auxiliary Operation ID field';
                }
                field(Mode; Rec.Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field("Offline mode"; Rec."Offline mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Offline mode field';
                }
                field("Integration Version Code"; Rec."Integration Version Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Integration Version Code field';
                }
                field("Client Assembly Version"; Rec."Client Assembly Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Assembly Version field';
                }
                field("Pepper Terminal Code"; Rec."Pepper Terminal Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Terminal Code field';
                }
                field("Pepper Transaction Type Code"; Rec."Pepper Transaction Type Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Transaction Type Code field';
                }
                field("Pepper Trans. Subtype Code"; Rec."Pepper Trans. Subtype Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Transaction Subtype Code field';
                }
                field("External Transaction ID"; Rec."External Transaction ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Transaction ID field';
                }
                field("External Customer ID"; Rec."External Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Customer ID field';
                }
                field("Hardware ID"; Rec."Hardware ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hardware ID field';
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Time field';
                }
                field("Authentication Method"; Rec."Authentication Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authentication Method field';
                }
                field("Bookkeeping Period"; Rec."Bookkeeping Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bookkeeping Period field';
                }
                field("Amount Input"; Rec."Amount Input")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Input field';
                }
                field("Amount Output"; Rec."Amount Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Output field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Cashback Amount"; Rec."Cashback Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashback Amount field';
                }
                field("Fee Amount"; Rec."Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fee Amount field';
                }
                field("Financial Impact"; Rec."Financial Impact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Financial Impact field';
                }
                field("Processed Entry No."; Rec."Processed Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed Entry No. field';
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed by Entry No. field';
                }
                field("Recovered by Entry No."; Rec."Recovered by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recovered by Entry No. field';
                }
                field("Initiated from Entry No."; Rec."Initiated from Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initiated from Entry No. field';
                }
                field("Receipt 1"; Rec."Receipt 1".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Receipt 1';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receipt 1.HasValue() field';
                }
                field("Receipt 2"; Rec."Receipt 2".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Receipt 2';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receipt 2.HasValue() field';
                }
                field("No. of Reprints"; Rec."No. of Reprints")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Reprints field';
                }
                field(Token; Rec.Token)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Token field';
                }
                field("Number of Attempts"; Rec."Number of Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number of Attempts field';
                }
                field("FF Moved to POS Entry"; Rec."FF Moved to POS Entry")
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
        if (Rec.Finished <> 0DT) and (Rec.Started <> 0DT) then
            TransDuration := Rec.Finished - Rec.Started;
        //+NPR5.28 [259563]

        //-NPR5.53 [377533]
        Style := SetStyle();
        //+NPR5.53 [377533]
    end;

    trigger OnOpenPage()
    begin
        UsesPOSEntry := true;
        Rec.SetAutoCalcFields("FF Moved to POS Entry");

        if Rec.FindFirst() then;
    end;

    var
        TransDuration: Duration;
        Style: Text;
        UsesPOSEntry: Boolean;

    local procedure SetStyle(): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (Rec.Recovered) then begin
            if EFTTransactionRequest.Get(Rec."Recovered by Entry No.") then
                if EFTTransactionRequest."Result Amount" <> 0 then
                    if EFTTransactionRequest."Sales Ticket No." <> Rec."Sales Ticket No." then
                        exit('Ambiguous'); //Recovered with an amount but too late to post automatically in same sale.

            exit('StrongAccent'); //Recovered and in sync.
        end;

        //-NPR5.54 [377533]
        if ((Rec.Finished = 0DT) or (not Rec."External Result Known"))
          and (Rec."Amount Input" <> 0) then begin
            exit('Unfavorable'); //Lost trx result
        end;

        if Rec."Result Amount" <> 0 then begin
            if ((not Rec."FF Moved to POS Entry") and UsesPOSEntry) then
                exit('Unfavorable'); //EFT handled it correctly but sale never ended.
        end;

        exit('');
        //+NPR5.54 [377533]
    end;
}

