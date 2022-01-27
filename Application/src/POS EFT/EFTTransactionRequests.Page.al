page 6184498 "NPR EFT Transaction Requests"
{
    Extensible = False;
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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                InstructionalText = 'Blue: Recovered & in sync\Yellow: Recovered but on different receipt number\Red: Unfinished, no external result or unposted amount';
                field("Entry No."; Rec."Entry No.")
                {

                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Type"; Rec."Integration Type")
                {

                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Integration Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Processing Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Auxiliary Operation Desc."; Rec."Auxiliary Operation Desc.")
                {

                    ToolTip = 'Specifies the value of the Auxiliary Operation Desc. field';
                    ApplicationArea = NPRRetail;
                }
                field(Started; Rec.Started)
                {

                    ToolTip = 'Specifies the value of the Started field';
                    ApplicationArea = NPRRetail;
                }
                field(Finished; Rec.Finished)
                {

                    ToolTip = 'Specifies the value of the Finished field';
                    ApplicationArea = NPRRetail;
                }
                field(TransDuration; TransDuration)
                {

                    Caption = 'Duration';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Result Amount"; Rec."Result Amount")
                {

                    ToolTip = 'Specifies the value of the Result Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Successful; Rec.Successful)
                {

                    ToolTip = 'Specifies the value of the Successful field';
                    ApplicationArea = NPRRetail;
                }
                field("External Result Known"; Rec."External Result Known")
                {

                    ToolTip = 'Specifies the value of the External Result Known field';
                    ApplicationArea = NPRRetail;
                }
                field("Result Processed"; Rec."Result Processed")
                {

                    ToolTip = 'Specifies the value of the Result Processed field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Closed"; Rec."Force Closed")
                {

                    ToolTip = 'Specifies the value of the Force Closed field';
                    ApplicationArea = NPRRetail;
                }
                field(Reversed; Rec.Reversed)
                {

                    ToolTip = 'Specifies the value of the Reversed field';
                    ApplicationArea = NPRRetail;
                }
                field(Recovered; Rec.Recovered)
                {

                    ToolTip = 'Specifies the value of the Recovered field';
                    ApplicationArea = NPRRetail;
                }
                field("Result Display Text"; Rec."Result Display Text")
                {

                    ToolTip = 'Specifies the value of the Result Display Text field';
                    ApplicationArea = NPRRetail;
                }
                field("NST Error"; Rec."NST Error")
                {

                    ToolTip = 'Specifies the value of the NST Error field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Error"; Rec."Client Error")
                {

                    ToolTip = 'Specifies the value of the Client Error field';
                    ApplicationArea = NPRRetail;
                }
                field("Result Code"; Rec."Result Code")
                {

                    ToolTip = 'Specifies the value of the Result Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Result Description"; Rec."Result Description")
                {

                    ToolTip = 'Specifies the value of the Result Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Type"; Rec."Card Type")
                {

                    ToolTip = 'Specifies the value of the Card Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Name"; Rec."Card Name")
                {

                    ToolTip = 'Specifies the value of the Card Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number"; Rec."Card Number")
                {

                    ToolTip = 'Specifies the value of the Card Number field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Expiry Date"; Rec."Card Expiry Date")
                {

                    ToolTip = 'Specifies the value of the Card Expiry Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference Number Input"; Rec."Reference Number Input")
                {

                    ToolTip = 'Specifies the value of the Reference Number Input field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference Number Output"; Rec."Reference Number Output")
                {

                    ToolTip = 'Specifies the value of the Reference Number Output field';
                    ApplicationArea = NPRRetail;
                }
                field("Authorisation Number"; Rec."Authorisation Number")
                {

                    ToolTip = 'Specifies the value of the Authorisation Number field';
                    ApplicationArea = NPRRetail;
                }
                field("Auxiliary Operation ID"; Rec."Auxiliary Operation ID")
                {

                    ToolTip = 'Specifies the value of the Auxiliary Operation ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the value of the Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Offline mode"; Rec."Offline mode")
                {

                    ToolTip = 'Specifies the value of the Offline mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Version Code"; Rec."Integration Version Code")
                {

                    ToolTip = 'Specifies the value of the Integration Version Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Assembly Version"; Rec."Client Assembly Version")
                {

                    ToolTip = 'Specifies the value of the Client Assembly Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper Terminal Code"; Rec."Pepper Terminal Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Terminal Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper Transaction Type Code"; Rec."Pepper Transaction Type Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Transaction Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper Trans. Subtype Code"; Rec."Pepper Trans. Subtype Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Pepper Transaction Subtype Code field';
                    ApplicationArea = NPRRetail;
                }
                field("External Transaction ID"; Rec."External Transaction ID")
                {

                    ToolTip = 'Specifies the value of the External Transaction ID field';
                    ApplicationArea = NPRRetail;
                }
                field("External Customer ID"; Rec."External Customer ID")
                {

                    ToolTip = 'Specifies the value of the External Customer ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Hardware ID"; Rec."Hardware ID")
                {

                    ToolTip = 'Specifies the value of the Hardware ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {

                    ToolTip = 'Specifies the value of the Transaction Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Time"; Rec."Transaction Time")
                {

                    ToolTip = 'Specifies the value of the Transaction Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Authentication Method"; Rec."Authentication Method")
                {

                    ToolTip = 'Specifies the value of the Authentication Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Bookkeeping Period"; Rec."Bookkeeping Period")
                {

                    ToolTip = 'Specifies the value of the Bookkeeping Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Input"; Rec."Amount Input")
                {

                    ToolTip = 'Specifies the value of the Amount Input field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Output"; Rec."Amount Output")
                {

                    ToolTip = 'Specifies the value of the Amount Output field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Cashback Amount"; Rec."Cashback Amount")
                {

                    ToolTip = 'Specifies the value of the Cashback Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Fee Amount"; Rec."Fee Amount")
                {

                    ToolTip = 'Specifies the value of the Fee Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Financial Impact"; Rec."Financial Impact")
                {

                    ToolTip = 'Specifies the value of the Financial Impact field';
                    ApplicationArea = NPRRetail;
                }
                field("Processed Entry No."; Rec."Processed Entry No.")
                {

                    ToolTip = 'Specifies the value of the Processed Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {

                    ToolTip = 'Specifies the value of the Reversed by Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Recovered by Entry No."; Rec."Recovered by Entry No.")
                {

                    ToolTip = 'Specifies the value of the Recovered by Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Initiated from Entry No."; Rec."Initiated from Entry No.")
                {

                    ToolTip = 'Specifies the value of the Initiated from Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt 1"; Rec."Receipt 1".HasValue)
                {

                    Caption = 'Receipt 1';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receipt 1.HasValue() field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt 2"; Rec."Receipt 2".HasValue)
                {

                    Caption = 'Receipt 2';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receipt 2.HasValue() field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Reprints"; Rec."No. of Reprints")
                {

                    ToolTip = 'Specifies the value of the No. of Reprints field';
                    ApplicationArea = NPRRetail;
                }
                field(Token; Rec.Token)
                {

                    ToolTip = 'Specifies the value of the Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Number of Attempts"; Rec."Number of Attempts")
                {

                    ToolTip = 'Specifies the value of the Number of Attempts field';
                    ApplicationArea = NPRRetail;
                }
                field("FF Moved to POS Entry"; Rec."FF Moved to POS Entry")
                {

                    ToolTip = 'Specifies the value of the Moved to POS Entry field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

            }
            part(Control6014410; "NPR EFT Trx Log Factbox")
            {
                SubPageLink = "Transaction Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Show Receipt 1 action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Show Receipt 2 action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Reprint action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Download Logs action';
                ApplicationArea = NPRRetail;

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

