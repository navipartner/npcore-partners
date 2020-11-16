codeunit 6014428 "NPR Std. Codeunit Code"
{
    // //-NPR3.1b
    // //  tager h¢jde for virtuelPDF printer
    // //-NPR3.2k
    //   Fallback tabel lavet til printer opslag
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    //  21. (C.NPR3.2o) (M.)
    //  "C80Capture(VAR "Sales Header" : Record "Sales Header")"
    //   Captures the transaction with number "Sales Header"."Transaction ID".
    //   "Webshop - Setup"."Payment Gateway" specifies where the payment should be captured.
    // NPR70.00.01.03/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // 
    // NPR4.10/VB/20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/MMV/20150618 CASE 215957 Added IncrementCount after sales ticket print like in latest6.2
    // NPR4.14/MMV/20150807 CASE 220160 Added function PrintRegisterReceipt()
    // NPR4.18/MMV/20160106 CASE 230218 Refactored PrintReceipt() & removed all comments without a case reference (very old ones)
    // NPR4.18/BR/20160111  CASE 231276 Changed behavior of FinComp1 function when description is too long
    // NPR4.18/MMV/20160122 CASE 229221 Commented out deprecated function C90OnRun
    // NPR4.18/MMV/20160203 CASE 233703 Added support for opening drawer when not printing regular receipt.
    // NPR5.20/JDH/20160321 CASE 237255 changed printout to not do anything when the setting is Development
    // NPR5.22/TJ/20160412 CASE 238601 Created new functions PostPrepmtInvoiceYN and PostPrepmtCrMemoYN as copies of same functions in codeunit 443 but altered
    //                                    to just use what we need when called from codeunit 6014414, function PosterDebitorIndbetaling
    // NPR5.22/MMV/20160427 CASE 237743 Updated references to Retail Report Selection Mgt.
    // NPR5.23/MMV /20160530 CASE 241549 Removed deprecated function FindPrinter()
    // NPR5.26/MMV /20160830 CASE 241549 Moved voucher print call from PrintReceipt to Post Processing codeunit (CU 6014478).
    //                                   Removed deprecated check on object no. in print function.
    //                                   Removed old comments.
    // NPR5.27/MMV /20161004 CASE 254376 Replaced COUNT with ISEMPTY.
    //                                   Removed increment of Printed No. on audit roll.
    // NPR5.29/JC/20161103  CASE 257499 Fixed Cross reference field used for serial no. not created
    // NPR5.29.01/JDH/20170203 CASE     Removed unused var
    // NPR5.30/TJ  /20170222 CASE 266874 Removed functions C11CheckGLLine and C12PostGLLine
    // NPR5.30/TJ  /20170224 CASE 266866 Commented code in functions IndsætOverf¢rselPost and OpsætVarePost
    // NPR5.31/MMV /20170321 CASE 269028 Re-added increment of printed no. on sales receipt.
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/TJ  /20170919 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.40/JDH /20180320 CASE 308647 Removed unused functions
    // NPR5.46/MMV /20180918 CASE 328879 Removed standard POS marshaller use.

    Permissions = TableData "Cust. Ledger Entry" = rm,
                  TableData "Sales Shipment Header" = rimd,
                  TableData "Sales Shipment Line" = rimd,
                  TableData "Sales Invoice Header" = rimd,
                  TableData "Sales Invoice Line" = rimd,
                  TableData "Sales Cr.Memo Header" = rimd,
                  TableData "Sales Cr.Memo Line" = rimd;
    TableNo = "NPR Audit Roll";

    trigger OnRun()
    begin
        PrintReceipt(Rec, false);
        //CODEUNIT.RUN(6014418,Rec);
    end;

    var
        ShowDemand: Boolean;
        Text1060000: Label 'Do you want sales ticket %1 on A4 print instead of normal receipt?';
        RetailSetupGlobal: Record "NPR Retail Setup";

    procedure OnRunSetShowDemand(VisAnf: Boolean)
    begin
        //OnRunSetVisAnfordring
        ShowDemand := VisAnf;
    end;

    procedure PrintReceipt(var Rec: Record "NPR Audit Roll"; Force: Boolean)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        AuditRoll: Record "NPR Audit Roll";
        Register: Record "NPR Register";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        ReceiptA4: Boolean;
        Txt001: Label 'Printing receipt';
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
    begin
        AuditRoll.Copy(Rec);
        AuditRoll.FindFirst;

        with AuditRoll do begin
            Register.Get(RetailFormCode.FetchRegisterNumber);

            RetailReportSelectionMgt.SetRegisterNo(Register."Register No.");
            RecRef.GetTable(AuditRoll);

            case Register."Sales Ticket Print Output" of
                Register."Sales Ticket Print Output"::"ASK LARGE":
                    begin
                        if not Force then begin
                            //-NPR5.46 [328879]
                            //          IF Register.Touchscreen THEN
                            //            ReceiptA4 := POSEventMarshaller.Confirm(Txt001,STRSUBSTNO(Text1060000,"Sales Ticket No."))
                            //          ELSE
                            //            ReceiptA4 := CONFIRM(Text1060000,"Customer No." <> '',"Sales Ticket No.");
                            //          IF ReceiptA4 THEN
                            if Confirm(Text1060000, "Customer No." <> '', "Sales Ticket No.") then
                                //+NPR5.46 [328879]
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt")
                            else
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt")
                        end else
                            RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt");
                    end;
                Register."Sales Ticket Print Output"::STANDARD:
                    RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt");
                Register."Sales Ticket Print Output"::NEVER:
                    if Force then
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt");
                //-NPR5.46 [328879]
                //      ELSE IF OpenDrawerOnSale(Register."Money drawer - open on special", AuditRoll) THEN
                //        RetailFormCode.OpenRegister();
                //+NPR5.46 [328879]
                Register."Sales Ticket Print Output"::DEVELOPMENT:
                    begin
                    end;
                Register."Sales Ticket Print Output"::CUSTOMER:
                    begin
                        if "Customer No." <> '' then begin
                            if Confirm(Text1060000, "Customer No." <> '') then
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt")
                            else
                                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt");
                        end else
                            RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt");
                    end;
            end;

            //-NPR5.31 [269028]
            if not ((not Force) and (Register."Sales Ticket Print Output" in [Register."Sales Ticket Print Output"::NEVER, Register."Sales Ticket Print Output"::DEVELOPMENT])) then begin //Only case where no print happens
                IncrementPrintedCount;
                Commit;
            end;
            //+NPR5.31 [269028]

        end;
    end;

    procedure PrintCreditGiftVoucher(var AuditRollIn: Record "NPR Audit Roll")
    var
        AuditRoll: Record "NPR Audit Roll";
        GiftVoucher: Record "NPR Gift Voucher";
        CreditVoucher: Record "NPR Credit Voucher";
    begin
        AuditRoll.SetRange("Register No.", AuditRollIn."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", AuditRollIn."Sales Ticket No.");
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        if AuditRoll.FindSet() then
            repeat
                if GiftVoucher.Get(AuditRoll."Gift voucher ref.") then begin
                    GiftVoucher.SetRecFilter();
                    GiftVoucher.PrintGiftVoucher(false, false);
                end else
                    if CreditVoucher.Get(AuditRoll."Credit voucher ref.") then begin
                        CreditVoucher.SetRecFilter();
                        CreditVoucher.PrintCreditVoucher(false, false);
                    end;
            until AuditRoll.Next = 0;
    end;

    procedure PrintRegisterReceipt(var AuditRollIn: Record "NPR Audit Roll")
    var
        PrintType: Option ,"To Printer","To Screen";
        Text10600008: Label 'To printer,To Screen';
        t001: Label 'It must be a closing ticket!';
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RetailSetup: Record "NPR Retail Setup";
        AuditRoll: Record "NPR Audit Roll";
        RetailReportSelMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        MPOSReporthandler: Codeunit "NPR MPOS Report handler";
    begin
        //-NPR4.14
        if AuditRollIn.Type <> AuditRollIn.Type::"Open/Close" then
            Error(t001);

        PrintType := StrMenu(Text10600008);

        RetailSetup.Get();

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") or (AuditRoll."Balanced on Sales Ticket No." = '') then begin
            AuditRoll.SetRange("Register No.", AuditRollIn."Register No.");
            AuditRoll.SetRange("Sales Ticket No.", AuditRollIn."Sales Ticket No.");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) and (AuditRoll."Balanced on Sales Ticket No." <> '') then begin
            AuditRoll.SetRange("Register No.", AuditRollIn."On Register No.");
            AuditRoll.SetRange("Sales Ticket No.", AuditRollIn."Balanced on Sales Ticket No.");
            AuditRoll.SetRange("Sale Type", AuditRollIn."Sale Type"::Comment);
            AuditRoll.SetRange("Line No.", AuditRollIn."Line No.");
            AuditRoll.SetRange("No.", AuditRollIn."On Register No.");
            AuditRoll.SetRange("Sale Date", AuditRollIn."Sale Date");
        end;

        //-NPR5.27 [254376]
        //IF (AuditRoll.COUNT <> 0) THEN BEGIN
        if not AuditRoll.IsEmpty then begin
            //+NPR5.27 [254376]
            case PrintType of
                PrintType::"To Printer":
                    begin
                        //-NPR5.26 [241549]
                        RecRef.GetTable(AuditRoll);
                        RetailReportSelMgt.SetRegisterNo(AuditRoll."Register No.");
                        RetailReportSelMgt.SetRequestWindow(true);
                        RetailReportSelMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Register Balancing");
                        //+NPR5.26 [241549]
                    end;
                PrintType::"To Screen":
                    begin
                        //-NPR5.34
                        MPOSReporthandler.ExecutionHandlerWithVars(REPORT::"NPR Balancing Ticket IV", AuditRoll, true, false);
                        //REPORT.RUNMODAL(REPORT::"Balancing Ticket IV",TRUE,FALSE,AuditRoll);
                        //+NPR5.34
                    end;
            end;
        end;
        //+NPR4.14
    end;

    procedure PostPrepmtInvoiceYN(var SalesHeader2: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Copy(SalesHeader2);
        with SalesHeader do begin
            SalesPostPrepayments.Invoice(SalesHeader);
            Commit;
            SalesHeader2 := SalesHeader;
        end;
    end;
}

