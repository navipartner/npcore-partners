// TODO: CTRLUPGRADE - there are errors in this codeunit related to Standard framework usage
codeunit 6014417 "Call Terminal Integration"
{
    // Stor opdatering startet 090703 af AP-NPK
    //   - St�rre oprydning og effektivisering.
    //   - Dankortl�sning kassestyret.
    // 
    // //-1.1c ved Nikolai Pedersen
    //   Tilf�jet mulighed for at bruge sagem p� server
    // //1.1d
    //   tilf�jet mulighed for at v�lge den norske Steria terminal
    // //-1.1e ved Nicolai Esbensen
    //   tilf�jet valg til .NET integration ad Sagem Flexiterminal
    // 
    // NPR70.00.00.06/MMV/20150126 CASE 199445 Prevented call to terminal ticket codeunit if there is no ticket to print.
    // 
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.10/JDH/20150609 CASE 215893 Added Location code so its possible to set up payments per location (undocumented, since its an old merge error)
    // NPR4.11/AP/20150618  CASE 216496  Fixed problem with refunds. With the .net interop terminal integration the Type=3 line (approved result) may
    //                                   not be the last line.
    // NPR5.00/VB/20151203  CASE 228807 Added case for "SAGEM Flexiterm JavaScript"
    // NPR4.18/MMV/20160202 CASE 224257 New tax free integration
    // NPR4.21/MMV/20160210 CASE 224257 Correct tax free code.
    // NPR5.00/NPKNAV/20160113  CASE 228807 NP Retail 2016
    // NPR5.20/BR/20160215 CASE 231481 Support for Pepper
    // NPR5.22/BR/20160412 CASE 231481 Offline Support for Pepper
    // NPR5.26/MMV /20160704 CASE 246204 Added tax free support in javascript & pepper case.
    // NPR5.26/TSA/20160919 CASE 248043 Changed Steria integration to be Major Tom enabled.
    // NPR5.27/MMV /20161006 CASE 254376 Small performance improvements.
    // NPR5.28/VB/20161122 CASE 259086 Removing blocks of code for handling various credit-card handling solutions that do no longer work
    // NPR5.28/BR/20161128 CASE 259563 Added support for "Open Terminal and Retry"
    // NPR5.29/NPKNAV/20170127  CASE 261672 Transport NPR5.29 - 27 januar 2017
    // NPR5.30/MMV /20170207 CASE 261964 Refactored tax free integration.
    // NPR5.34/BR /20170320  CASE 268697 Added support for Min. Length Authorisation No. and Max. Length Authorisation No.
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback
    // NPR5.36/TJ /20170920  CASE 286283 Renamed variables/function with danish specific letters into english
    //                                   Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Removed redundant '0' from Case sentence and deleted unused function LoadDankort()
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring

    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        PaymentTypePrefix: Record "Payment Type - Prefix";
        PaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        ConnectionProfileMgt: Codeunit "Connection Profile Management";
        // TODO: CTRLUPGRADE - this variable must not be used, the codeunit is removed
        //DankortProtocol: Codeunit "Credit Card Protocol C-sharp";
        PepperProtocol: Codeunit "Pepper Protocol";
        // TODO: CTRLUPGRADE - this variable must not be used, the page is removed
        // ProxyDialog: Page "Proxy Dialog";
        XMLPortCreditCardTransaction: XMLport "Dankort Transaktion";
        i: Integer;
        t001: Label 'Credit card solution not set up on cash register %1, or the solution is not supported.';
        MaskedCardNo: Text[30];
        AuthorisationNo: Text;
        TaxFreeUnit: Record "Tax Free POS Unit";
        TaxFree: Codeunit "Tax Free Handler Mgt.";
        MinLengthAuthNo: Integer;
        MaxLengthAuthNo: Integer;
        CashBackAmount: Decimal;
    begin
        RegisterGlobal.Get("Register No.");
        RegisterGlobal.TestField("Credit Card");
        Betalingsvalg.Get("No.");
        Betalingsvalg.TestField("G/L Account No.");
        RetailSetup.Get;

        if Betalingsvalg."Dev Term" then begin
            "Cash Terminal Approved" := true;
            Description := 'Dev Term';
            exit;
        end;

        //Starten p� noget nyt! af AP, 090703
        case RegisterGlobal."Credit Card Solution" of

            //-NPR5.00
            RegisterGlobal."Credit Card Solution"::Steria, //-+NPR5.26 [248043]
            RegisterGlobal."Credit Card Solution"::"SAGEM Flexiterm JavaScript":
                // TODO: CTRLUPGRADE - Invoking old Stargate1-based protocols that were removed - INVESTIGATE
                ERROR('CTRLUPGRADE');
            /*
            begin
                PaymentTypePOS.Get("No.");
                Register.Get("Register No.");

                DankortProtocol.InitializeProtocol();
                if not DankortProtocol.Init("Amount Including VAT", Rec,
                  Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",
                  PaymentTypePOS."PBS Gift Voucher Barcode")
                then begin
                    Error(DankortProtocol.GetInitErrorText());
                end;

                //-NPR5.26 [248043]
                if (RegisterGlobal."Credit Card Solution" = RegisterGlobal."Credit Card Solution"::Steria) then
                    DankortProtocol.InitSteriaSupport();
                //+NPR5.26 [248043]

                if Barcode <> '' then
                    DankortProtocol.SetBarcode(Barcode);
                Commit;

                ProxyDialog.RunProtocolModal(CODEUNIT::"Credit Card Protocol C-sharp");

                Validate("Amount Including VAT", DankortProtocol.GetCapturedAmount);
                Validate("Currency Amount", DankortProtocol.GetCapturedAmount);

                Dankorttransaktion.SetCurrentKey("Register No.", "Sales Ticket No.", Date);//Alt. kan prim�rn�gle bruges. "Art" m� IKKE indg�.
                Dankorttransaktion.SetRange("Register No.", "Register No.");
                Dankorttransaktion.SetRange("Sales Ticket No.", "Sales Ticket No.");
                Dankorttransaktion.SetRange("Line No.", "Line No.");

                Dankorttransaktion.SetFilter(Type, '3');
                if Dankorttransaktion.FindLast then begin
                    Filter := Dankorttransaktion.Text;
                    MaskedCardNo := Dankorttransaktion.Text;
                    Len := StrLen(Filter);
                    while (Len > 0) and not ("Cash Terminal Approved") do begin
                        PaymentTypePrefix.SetRange(Prefix, Filter);
                        if PaymentTypePrefix.Find('-') then
                            repeat
                                Betalingsvalg.Reset;
                                Betalingsvalg.SetCurrentKey("No.", "Via Terminal");
                                Betalingsvalg.SetRange("No.", PaymentTypePrefix."Payment Type");
                                Betalingsvalg.SetRange("Via Terminal", true);
                                Betalingsvalg.SetRange("Location Code", Register."Location Code");

                                //-NPR5.27 [254376]
                                //IF NOT (Betalingsvalg.FINDSET) THEN
                                if Betalingsvalg.IsEmpty then
                                    //+NPR5.27 [254376]
                                    Betalingsvalg.SetRange("Location Code");

                                if Betalingsvalg.FindFirst then begin
                                    if (Betalingsvalg."Location Code" = Register."Location Code") or
                                       not ("Cash Terminal Approved")
                                    then begin
                                        "No." := Betalingsvalg."No.";
                                        Description := Betalingsvalg.Description;
                                        Quantity := 0;
                                        "Cash Terminal Approved" := true;
                                    end;
                                end;
                            until PaymentTypePrefix.Next = 0;
                        Len := Len - 1;
                        Filter := CopyStr(Filter, 1, Len);
                    end;
                    if (not "Cash Terminal Approved") then begin
                        Description := StrSubstNo('%1/%2', Description, Dankorttransaktion.Text);
                        "Cash Terminal Approved" := true;
                    end;

                end else
                    "Cash Terminal Approved" := false;

                Modify;
                Commit;

                DkTrans.Reset;
                DkTrans.FilterGroup := 2;
                DkTrans.SetCurrentKey("Register No.", "Sales Ticket No.", Type);
                DkTrans.SetRange("Register No.", "Register No.");
                DkTrans.SetRange("Sales Ticket No.", "Sales Ticket No.");
                DkTrans.SetRange(Type, 0);
                DkTrans.FilterGroup := 0;
                DkTrans.SetRange("No. Printed", 0);
                if (not RegisterGlobal."Terminal Auto Print") and (not DkTrans.IsEmpty) then
                    //-NPR5.46 [290734]
                    DkTrans.PrintTerminalReceipt();
                //      DkTrans.PrintTerminalReceipt(FALSE);
                //+NPR5.46 [290734]

                if "Cash Terminal Approved" then
                    if TaxFreeUnit.Get("Register No.") then
                        if TaxFreeUnit."Check POS Terminal IIN" then
                            //-NPR5.40 [293106]
                            //          IF TaxFree.IsValidTerminalIIN(TaxFreeUnit, MaskedCardNo, "Sales Ticket No.") THEN BEGIN
                            if TaxFree.IsValidTerminalIIN(TaxFreeUnit, MaskedCardNo) then begin
                                //+NPR5.40 [293106]
                                "Credit Card Tax Free" := true;
                                Modify;
                            end;

            end;
        */
            //+NPR5.00

            //-NPR5.00
            RegisterGlobal."Credit Card Solution"::Pepper:
                begin
                    PaymentTypePOS.Get("No.");
                    Register.Get("Register No.");

                    PepperProtocol.InitializeProtocol();
                    //-NPR5.35 [284379]
                    //IF NOT PepperProtocol.Init("Amount Including VAT", Rec,
                    CashBackAmount := PepperProtocol.CalcCashBackAmount("Amount Including VAT", "Register No.", "Sales Ticket No.");
                    if not PepperProtocol.Init("Amount Including VAT", CashBackAmount, Rec,
                      //+NPR5.35 [284379]
                      Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",
                      PaymentTypePOS."PBS Gift Voucher Barcode")
                    then begin
                        Error(PepperProtocol.GetInitErrorText());
                        exit;
                    end;

                    //-NPR5.22
                    if PepperProtocol.IsOffline then begin
                        AuthorisationNo := '';
                        PepperProtocol.GetAuthNoParameters(MinLengthAuthNo, MaxLengthAuthNo);
                        if PepperProtocol.AuthNoRequired and (MinLengthAuthNo = 0) then
                            MinLengthAuthNo := 1;
                        if MaxLengthAuthNo = 0 then
                            MaxLengthAuthNo := 16;
                        if MinLengthAuthNo > MaxLengthAuthNo then
                            MinLengthAuthNo := MaxLengthAuthNo;
                        repeat
                            // TODO: CTRLUPGRADE - The block below must be refactored to not use Marshaller
                            ERROR('CTRLUPGRADE');
                            /*
                            if MinLengthAuthNo = MaxLengthAuthNo then
                                Marshaller.NumPadText(StrSubstNo(PepperText001, MinLengthAuthNo), AuthorisationNo, false, false)
                            else
                                Marshaller.NumPadText(StrSubstNo(PepperText002, MinLengthAuthNo, MaxLengthAuthNo), AuthorisationNo, false, false);
                            */
                            if StrLen(AuthorisationNo) > MaxLengthAuthNo then
                                Error(PepperText003, MaxLengthAuthNo);
                            if PepperProtocol.AuthNoRequired and (StrLen(AuthorisationNo) < MinLengthAuthNo) then begin
                                if Confirm(PepperText004, FALSE, MinLengthAuthNo) then begin
                                    Error(PepperText005);
                                    exit;
                                end;
                            end;
                        until (StrLen(AuthorisationNo) <= MaxLengthAuthNo) and (StrLen(AuthorisationNo) >= MinLengthAuthNo);
                        //+NPR5.34 [268697]
                        //-NPR5.29 [261672]
                        if (not PepperProtocol.AuthNoRequired) and (StrLen(AuthorisationNo) = 0) then
                            AuthorisationNo := '0';
                        //+NPR5.29 [261672]
                        PepperProtocol.SetAuthorisationNo(AuthorisationNo);
                    end;
                    //+NPR5.22

                    if Barcode <> '' then
                        PepperProtocol.SetBarcode(Barcode);
                    Commit;
                    PepperProtocol.SetTransaction(0);
                    "Cash Terminal Approved" := PepperProtocol.SendTransaction;
                    //-NPR5.28 [259563]
                    if (not "Cash Terminal Approved") then begin
                        if PepperProtocol.GetRetrytransaction then begin
                            PepperProtocol.SetTerminalToUnknown;
                            PepperProtocol.InitializeProtocol;
                            //-NPR5.35 [284379]
                            //IF NOT PepperProtocol.Init("Amount Including VAT", Rec,
                            if not PepperProtocol.Init("Amount Including VAT", CashBackAmount, Rec,
                              //+NPR5.35 [284379]
                              Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",
                              PaymentTypePOS."PBS Gift Voucher Barcode")
                            then begin
                                Error(PepperProtocol.GetInitErrorText());
                                exit;
                            end;
                            if Barcode <> '' then
                                PepperProtocol.SetBarcode(Barcode);
                            Commit;
                            PepperProtocol.SetTransaction(0);
                            "Cash Terminal Approved" := PepperProtocol.SendTransaction;
                        end;
                    end;
                    //+NPR5.28 [259563]
                    Validate("Amount Including VAT", PepperProtocol.GetCapturedAmount);
                    Validate("Currency Amount", "Amount Including VAT");
                    if "Cash Terminal Approved" then begin
                        Clear(Betalingsvalg);
                        if PepperProtocol.GetPaymentTypePOS <> '' then begin
                            if Betalingsvalg.Get(PepperProtocol.GetPaymentTypePOS, Register."Register No.") then begin
                                if not Betalingsvalg."Via Terminal" then
                                    Clear(Betalingsvalg);
                            end else begin
                                if Betalingsvalg.Get(PepperProtocol.GetPaymentTypePOS, '') then begin
                                    if not Betalingsvalg."Via Terminal" then
                                        Clear(Betalingsvalg);
                                end;
                            end;
                        end;
                        if Betalingsvalg."No." = '' then begin
                            Filter := PepperProtocol.GetCardNumber;
                            MaskedCardNo := Filter;
                            Len := StrLen(Filter);
                            while (Len > 0) and (Betalingsvalg."No." = '') do begin
                                PaymentTypePrefix.SetRange(Prefix, Filter);
                                if PaymentTypePrefix.Find('-') then
                                    repeat
                                        Betalingsvalg.Reset;
                                        Betalingsvalg.SetCurrentKey("No.", "Via Terminal");
                                        Betalingsvalg.SetRange("No.", PaymentTypePrefix."Payment Type");
                                        Betalingsvalg.SetRange("Via Terminal", true);
                                        Betalingsvalg.SetRange("Location Code", Register."Location Code");

                                        if not (Betalingsvalg.FindSet) then begin
                                            Betalingsvalg.SetRange("Location Code");

                                            if Betalingsvalg.FindFirst then;
                                        end;
                                    until (PaymentTypePrefix.Next = 0) or (Betalingsvalg."No." <> '');
                                Len := Len - 1;
                                Filter := CopyStr(Filter, 1, Len);
                            end;
                        end;
                        if Betalingsvalg."No." = '' then begin
                            //Description := COPYSTR(STRSUBSTNO('%1/%2',Description,PepperProtocol.GetCardNumber),1,MAXSTRLEN(Description));
                            Description := CopyStr(PepperProtocol.GetPaymentDescription(0), 1, MaxStrLen(Description));
                            Reference := CopyStr(PepperProtocol.GetPaymentDescription(1), 1, MaxStrLen(Reference));
                        end else begin
                            "No." := Betalingsvalg."No.";
                            //Description              := Betalingsvalg.Description;
                            Description := CopyStr(PepperProtocol.GetPaymentDescription(0), 1, MaxStrLen(Description));
                            Reference := CopyStr(PepperProtocol.GetPaymentDescription(1), 1, MaxStrLen(Reference));
                            Quantity := 0;
                        end;

                    end;

                    Modify;
                    Commit;
                    DkTrans.Reset;
                    DkTrans.FilterGroup := 2;
                    DkTrans.SetCurrentKey("Register No.", "Sales Ticket No.", Type);
                    DkTrans.SetRange("Register No.", "Register No.");
                    DkTrans.SetRange("Sales Ticket No.", "Sales Ticket No.");
                    DkTrans.SetRange(Type, 0);
                    DkTrans.FilterGroup := 0;
                    DkTrans.SetRange("No. Printed", 0);
                    if (not RegisterGlobal."Terminal Auto Print") and (not DkTrans.IsEmpty) then
                        //-NPR5.46 [290734]
                        DkTrans.PrintTerminalReceipt();
                    //      DkTrans.PrintTerminalReceipt(FALSE);
                    //+NPR5.46 [290734]

                    if "Cash Terminal Approved" then
                        if TaxFreeUnit.Get("Register No.") then
                            if TaxFreeUnit."Check POS Terminal IIN" then
                                //-NPR5.40 [293106]
                                //          IF TaxFree.IsValidTerminalIIN(TaxFreeUnit, MaskedCardNo, "Sales Ticket No.") THEN BEGIN
                                if TaxFree.IsValidTerminalIIN(TaxFreeUnit, MaskedCardNo) then begin
                                    //+NPR5.40 [293106]
                                    "Credit Card Tax Free" := true;
                                    Modify;
                                end;
                end;
            //+NPR5.00

            //-NPR5.46 [290734]
            //  RegisterGlobal."Credit Card Solution"::"MSP DOS" : BEGIN
            //    SletFil;
            //    Filter := '';
            //    //sikre at man aldrig kan kalde dankort programmet hvis der findes en dankort.txt fil
            //    Filnavn := STRSUBSTNO(ConnectionProfileMgt.GetCreditCardExtension()+'dankort.txt');
            //    SletFil;
            //
            //    //Hvis integreret l�sning:
            //    //IF Ops�tning."Integreret Dankortdialog" THEN BEGIN
            //
            //    //-NPR5.38 [301053]
            //    //RunModal := Utility.RunCmdModal(HentSti+''+FORMAT("Amount Including VAT" * 100,0,1)+''+ ConnectionProfileMgt.GetCreditCardExtension());
            //    RunProcess(HentSti + FORMAT("Amount Including VAT" * 100,0,1) + ConnectionProfileMgt.GetCreditCardExtension(),'',TRUE);
            //    //+NPR5.38 [301053]
            //
            //    IF ConnectionProfileMgt.GetCreditCardExtension()='' THEN
            //      Filnavn := STRSUBSTNO(RetailSetup."Credit Card Path"+'dankort.txt')
            //    ELSE
            //      Filnavn := STRSUBSTNO(ConnectionProfileMgt.GetCreditCardExtension()+'dankort.txt');
            //
            //    //l�sning s� man ikke bruge sleep funktionen, men bare venter p�
            //    //at filen er dannet helt f�rdig g�res med writemode
            //    WHILE (NOT FILE.EXISTS(Filnavn)) AND (i < 25) DO BEGIN
            //      SLEEP(200);
            //      i:=i+1;
            //    END;
            //    IF FILE.EXISTS(Filnavn) THEN BEGIN
            //      filrec.WRITEMODE(TRUE);
            //      AttemptNo := 1;
            //    REPEAT
            //      SLEEP(500);
            //      AttemptNo := AttemptNo + 1;
            //    UNTIL (filrec.OPEN(Filnavn)) OR (AttemptNo = 30);
            //
            //    filrec.WRITEMODE(FALSE);
            //    filrec.CLOSE;
            //
            //    IF AttemptNo = 30 THEN BEGIN
            //     //  MESSAGE('File not opened!'); //Debug
            //       EXIT;
            //    END;
            //
            //    XMLPortCreditCardTransaction.init(Rec);
            //    XMLPortCreditCardTransaction.RUN;
            //    COMMIT;
            //
            //    nullinie := FALSE;
            //    trelinie := FALSE;
            //    "Cash Terminal Approved" := FALSE;
            //
            //    Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
            //    Dankorttransaktion.SETRANGE("Register No.","Register No.");
            //    Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            //    Dankorttransaktion.SETRANGE(Date,Date);
            //    Dankorttransaktion.SETFILTER(Type,'=0');
            //
            //    IF Dankorttransaktion.FIND('+') THEN
            //      nullinie := TRUE;
            //
            //    //special ting ifm. hvor der kommer bon'er over som ikke er f�rdige med at blive
            //    //dannet, dvs. bon kun har en bon linie og ikke andet.
            //    //for at transaktionen er godkendt skal der i sidste linie v�re en art 3
            //
            //    Dankorttransaktion.SETFILTER(Type,'<>8');
            //    IF Dankorttransaktion.FIND('+') THEN
            //      IF Dankorttransaktion.Type = 3 THEN trelinie := TRUE;
            //
            //    IF (Dankorttransaktion.FIND('+')) AND (trelinie = TRUE) AND (nullinie = TRUE) THEN BEGIN
            //      IF (Dankorttransaktion.Text <> '') THEN BEGIN
            //        FOR i := 1 TO STRLEN(Dankorttransaktion.Text) DO
            //          CASE COPYSTR(Dankorttransaktion.Text,i,1) OF
            //            //-NPR5.38 [301053]
            //            //'0','1','2','3','4','5','6','7','8','9','0' : Filter := Filter + COPYSTR(Dankorttransaktion.Text,i,1);
            //            '0','1','2','3','4','5','6','7','8','9':
            //              Filter := Filter + COPYSTR(Dankorttransaktion.Text,i,1);
            //            //+NPR5.38 [301053]
            //          END;
            //        //Betalingsvalg.SETCURRENTKEY("Via terminal",Pr�fix);
            //        Len := STRLEN(Filter);
            //        WHILE Len > 0 DO BEGIN
            //          PaymentTypePrefix.SETRANGE( Prefix, Filter );
            //          IF PaymentTypePrefix.FIND('-') THEN REPEAT
            //            Betalingsvalg.RESET;
            //            Betalingsvalg.SETCURRENTKEY( "No.", "Via Terminal" );
            //            Betalingsvalg.SETRANGE( "No.", PaymentTypePrefix."Payment Type" );
            //            Betalingsvalg.SETRANGE( "Via Terminal", TRUE );
            //            //Betalingsvalg.SETRANGE("Via terminal",TRUE);
            //            //Betalingsvalg.SETRANGE(Pr�fix,Filter);
            //            IF Betalingsvalg.FIND('-') AND NOT ("Cash Terminal Approved") THEN BEGIN
            //              "No."              := Betalingsvalg."No.";
            //              Description         := Betalingsvalg.Description;
            //              Quantity               := 0;
            //              "Cash Terminal Approved" := TRUE;
            //            END;
            //          UNTIL "Cash Terminal Approved" OR (PaymentTypePrefix.NEXT = 0);
            //          Len := Len - 1;
            //          Filter := COPYSTR(Filter,1,Len);
            //        END;
            //      END;
            //      IF (NOT "Cash Terminal Approved") THEN BEGIN
            //        Description := STRSUBSTNO('%1/%2',Description,Dankorttransaktion.Text);
            //        "Cash Terminal Approved" := TRUE;
            //      END;
            //    END ELSE BEGIN
            //      Dankorttransaktion.SETFILTER(Type,'=0');
            //      IF Dankorttransaktion.FIND('+') THEN ;
            //      "Cash Terminal Approved" := FALSE;
            //    END;
            //    MODIFY;
            //    COMMIT;
            //
            //    DkTrans.RESET;
            //    DkTrans.FILTERGROUP :=2;
            //    DkTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
            //    DkTrans.SETRANGE("Register No.","Register No.");
            //    DkTrans.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            //    DkTrans.SETRANGE(Type,0);
            //    DkTrans.SETRANGE("No. Printed",0);
            //    DkTrans.FILTERGROUP := 0;
            //    //-NPR70.00.00.06
            //    IF (NOT RegisterGlobal."Terminal Auto Print") AND (NOT DkTrans.ISEMPTY) THEN
            //      DkTrans.PrintTerminalReceipt(FALSE);
            //    //+NPR70.00.00.06
            //  END ELSE;
            //  //  MESSAGE('File does not exist!');
            //  END;
            //+NPR5.46 [290734]

            RegisterGlobal."Credit Card Solution"::"MSP Navision":
                begin
                    //-NPR4.10
                    //ERROR('No longer supported.');
                    Error('No longer supported.');
                    //+NPR4.10
                end;

            RegisterGlobal."Credit Card Solution"::"SAGEM Flexiterminal":
                begin
                    //-NPR5.28
                    //    "Flexi-DK-dialog".Init("Amount Including VAT", Rec,
                    //                           Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",FALSE);
                    //    COMMIT;
                    //    "Flexi-DK-dialog".RUNMODAL;
                    //
                    //    Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Date);//Alt. kan prim�rn�gle bruges. "Art" m� IKKE indg�.
                    //    Dankorttransaktion.SETRANGE("Register No.","Register No.");
                    //    Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //    Dankorttransaktion.SETRANGE("Line No.", "Line No.");
                    //    //Dankorttransaktion.SETFILTER(Art,'=3');//Dette filter skal IKKE bruges da der netop skal testes om den sidste linie er 3-linie
                    //
                    //    IF Dankorttransaktion.FIND('+') AND (Dankorttransaktion.Type = 3) THEN BEGIN
                    //      //-NIK
                    //      IF ("Flexi-DK-dialog".GetFee <> 0) THEN BEGIN
                    //        VALIDATE("Amount Including VAT", "Amount Including VAT" + "Flexi-DK-dialog".GetFee);
                    //      END;
                    //      //+NIK
                    //
                    //      Filter := Dankorttransaktion.Text;
                    //      Len := STRLEN(Filter);
                    //      WHILE Len > 0 DO BEGIN
                    //        Pr�fixList.SETRANGE( Prefix, Filter);
                    //        IF Pr�fixList.FIND('-') THEN BEGIN
                    //          Pr�fixList.SETRANGE("Register No.",KasseOps�t."Register No.");
                    //          IF NOT Pr�fixList.FIND('-') THEN BEGIN
                    //            Pr�fixList.SETRANGE("Register No.");
                    //            IF Pr�fixList.FIND('-') THEN;
                    //          END;
                    //          Betalingsvalg.RESET;
                    //          Betalingsvalg.SETCURRENTKEY( "No.", "Via Terminal" );
                    //          Betalingsvalg.SETRANGE( "No.", Pr�fixList."Payment Type" );
                    //          Betalingsvalg.SETRANGE( "Via Terminal", TRUE );
                    //          IF Betalingsvalg.FIND('-') AND NOT ("Cash Terminal Approved") THEN BEGIN
                    //            "No."              := Betalingsvalg."No.";
                    //            Description         := Betalingsvalg.Description;
                    //            Quantity               := 0;
                    //            "Cash Terminal Approved" := TRUE;
                    //          END;
                    //        END;
                    //        Len := Len - 1;
                    //        Filter := COPYSTR(Filter,1,Len);
                    //      END;
                    //      IF (NOT "Cash Terminal Approved") THEN BEGIN
                    //        Description := STRSUBSTNO('%1/%2',Description,Dankorttransaktion.Text);
                    //        "Cash Terminal Approved" := TRUE;
                    //      END;
                    //    END ELSE
                    //      "Cash Terminal Approved" := FALSE;
                    //    MODIFY;
                    //    COMMIT;
                    //
                    //    DkTrans.RESET;
                    //    DkTrans.FILTERGROUP :=2;
                    //    DkTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
                    //    DkTrans.SETRANGE("Register No.","Register No.");
                    //    DkTrans.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //    DkTrans.SETRANGE(Type,0);
                    //    DkTrans.FILTERGROUP := 0;
                    //    DkTrans.SETRANGE("No. Printed", 0);
                    //    //-NPR70.00.00.06
                    //    IF (NOT KasseOps�t."Terminal Auto Print") AND (NOT DkTrans.ISEMPTY) THEN
                    //      DkTrans.PrintTerminalReceipt(FALSE);
                    //    //+NPR70.00.00.06
                    Error('No longer supported.');
                    //+NPR5.28
                end;

            //-NPR5.00
            /*
            "KasseOps�t"."Credit Card Solution"::"SAGEM Flexiterm via console":
            BEGIN
            //"Flexi-DK-dialog".Init("Bel�b inkl. moms", Rec);
            //"Flexi-DK-dialog".RUNMODAL;
            "DK-Codeunit".RemoveOldFlex(ConnectionProfileMgt.GetCreditCardExtension(), Rec);
            //RunModal := SHELL(Ops�tning."Credit Card Path" + 'NPFlexiConsole.exe'
            //                                           , FORMAT("Amount Including VAT" * 100,0,1), ConnectionProfileMgt.GetCreditCardExtension()
            //                                           , FORMAT("Register No.") + ' - ' + FORMAT("Sales Ticket No."));
        
            RunModal:= Utility.RunCmdModal("Ops�tning"."Credit Card Path" + 'NPFlexiConsole.exe'+''+
                                      FORMAT("Amount Including VAT" * 100,0,1)+''+ConnectionProfileMgt.GetCreditCardExtension()+''+FORMAT("Register No.")+''+' - ' + FORMAT("Sales Ticket No."));
            IF ("DK-Codeunit".ReadFlexiReciept(Rec, ConnectionProfileMgt.GetCreditCardExtension())) THEN;
            IF ("DK-Codeunit".CheckFlexiResult(Rec, ConnectionProfileMgt.GetCreditCardExtension(), FlexiResult, ActionCode)) THEN;
        
        
            Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
            Dankorttransaktion.SETRANGE("Register No.","Register No.");
            Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            Dankorttransaktion.SETFILTER(Type,'=3');
        
            IF FlexiResult <> 0 THEN BEGIN
              //"Terminal godkendt" := TRUE;
              IF Dankorttransaktion.FIND('+') THEN BEGIN
                Filter := Dankorttransaktion.Text;
                Len := STRLEN(Filter);
                WHILE Len > 0 DO BEGIN
                  "Pr�fixList".SETRANGE( Prefix, Filter );
                  IF "Pr�fixList".FIND('-') THEN BEGIN
                    "Pr�fixList".SETRANGE("Global Dimension 1 Code","KasseOps�t"."Global Dimension 1 Code");
                    IF NOT "Pr�fixList".FIND('-') THEN BEGIN
                      "Pr�fixList".SETFILTER("Register No.",'');
                      IF "Pr�fixList".FIND('-') THEN;
                    END;
        
                    Betalingsvalg.RESET;
                    Betalingsvalg.SETCURRENTKEY( "No.", "Via terminal" );
                    Betalingsvalg.SETRANGE( "No.", "Pr�fixList"."Payment Type" );
                    Betalingsvalg.SETRANGE( "Via terminal", TRUE );
                    IF Betalingsvalg.FIND('-') AND NOT ("Cash Terminal Approved") THEN BEGIN
                      "No."              := Betalingsvalg."No.";
                      Description         := Betalingsvalg.Description;
                      Quantity               := 0;
                      "Cash Terminal Approved" := TRUE;
                    END;
                  END;
                  Len := Len - 1;
                  Filter := COPYSTR(Filter,1,Len);
                END;
                IF (NOT "Cash Terminal Approved") THEN BEGIN
                  Description := STRSUBSTNO('%1/%2',Description,Dankorttransaktion.Text);
                  "Cash Terminal Approved" := TRUE;
                END;
              END;
            END ELSE
              "Cash Terminal Approved" := FALSE;
            MODIFY;
            COMMIT;
        
            DkTrans.RESET;
            DkTrans.FILTERGROUP :=2;
            DkTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
            DkTrans.SETRANGE("Register No.","Register No.");
            DkTrans.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            DkTrans.SETRANGE(Type,0);
            DkTrans.FILTERGROUP := 0;
            DkTrans.SETRANGE("No. Printed", 0);
            //-NPR70.00.00.06
            IF (NOT "KasseOps�t"."Terminal Auto Print") AND (NOT DkTrans.ISEMPTY) THEN
              DkTrans.UdskrivBon(FALSE);
            //+NPR70.00.00.06
          END;
          */
            //+NPR5.00

            RegisterGlobal."Credit Card Solution"::"SAGEM Flexitermina from server":
                begin
                    //-NPR5.28
                    //    "Flexi-DK-dialog".Init("Amount Including VAT", Rec,
                    //                           Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",FALSE);
                    //    COMMIT;
                    //    "Flexi-DK-dialog".RUNMODAL;
                    //
                    //    Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Date);//Alt. kan prim�rn�gle bruges. "Art" m� IKKE indg�.
                    //    Dankorttransaktion.SETRANGE("Register No.","Register No.");
                    //    Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //    Dankorttransaktion.SETRANGE("Line No.", "Line No.");
                    //    //Dankorttransaktion.SETFILTER(Art,'=3');//Dette filter skal IKKE bruges da der netop skal testes om den sidste linie er 3-linie
                    //
                    //    IF Dankorttransaktion.FIND('+') AND (Dankorttransaktion.Type = 3) THEN BEGIN
                    //      Filter := Dankorttransaktion.Text;
                    //      Len := STRLEN(Filter);
                    //      WHILE Len > 0 DO BEGIN
                    //        Pr�fixList.SETRANGE( Prefix, Filter );
                    //        IF Pr�fixList.FIND('-') THEN BEGIN
                    //          Betalingsvalg.RESET;
                    //          Betalingsvalg.SETCURRENTKEY( "No.", "Via Terminal" );
                    //          Betalingsvalg.SETRANGE( "No.", Pr�fixList."Payment Type" );
                    //          Betalingsvalg.SETRANGE( "Via Terminal", TRUE );
                    //          IF Betalingsvalg.FIND('-') AND NOT ("Cash Terminal Approved") THEN BEGIN
                    //            "No."              := Betalingsvalg."No.";
                    //            Description         := Betalingsvalg.Description;
                    //            Quantity               := 0;
                    //            "Cash Terminal Approved" := TRUE;
                    //          END;
                    //        END;
                    //        Len := Len - 1;
                    //        Filter := COPYSTR(Filter,1,Len);
                    //      END;
                    //      IF (NOT "Cash Terminal Approved") THEN BEGIN
                    //        Description := STRSUBSTNO('%1/%2',Description,Dankorttransaktion.Text);
                    //        "Cash Terminal Approved" := TRUE;
                    //      END;
                    //    END ELSE
                    //      "Cash Terminal Approved" := FALSE;
                    //    MODIFY;
                    //    COMMIT;
                    //
                    //    DkTrans.RESET;
                    //    DkTrans.FILTERGROUP :=2;
                    //    DkTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
                    //    DkTrans.SETRANGE("Register No.","Register No.");
                    //    DkTrans.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //    DkTrans.SETRANGE(Type,0);
                    //    DkTrans.FILTERGROUP := 0;
                    //    DkTrans.SETRANGE("No. Printed", 0);
                    //    //-NPR70.00.00.06
                    //    IF (NOT KasseOps�t."Terminal Auto Print") AND (NOT DkTrans.ISEMPTY) THEN
                    //      DkTrans.PrintTerminalReceipt(FALSE);
                    //    //+NPR70.00.00.06
                    Error('No longer supported.');
                    //+NPR5.28
                end;
            RegisterGlobal."Credit Card Solution"::POINT:
                begin
                    //-NPR5.28
                    //    "Flexi-DK-dialog".Init("Amount Including VAT", Rec,
                    //                           Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",FALSE);
                    //    COMMIT;
                    //    "Flexi-DK-dialog".RUNMODAL;
                    //
                    //    Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Date);//Alt. kan prim�rn�gle bruges. "Art" m� IKKE indg�.
                    //    Dankorttransaktion.SETRANGE("Register No.","Register No.");
                    //    Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //    Dankorttransaktion.SETRANGE("Line No.", "Line No.");
                    //    //Dankorttransaktion.SETFILTER(Art,'=3');//Dette filter skal IKKE bruges da der netop skal testes om den sidste linie er 3-linie
                    //
                    //    IF Dankorttransaktion.FIND('+') AND (Dankorttransaktion.Type = 3) THEN BEGIN
                    //      //-NIK
                    //      IF ("Flexi-DK-dialog".GetFee <> 0) THEN BEGIN
                    //        VALIDATE("Amount Including VAT", "Amount Including VAT" + "Flexi-DK-dialog".GetFee);
                    //      END;
                    //
                    //      //+NIK
                    //      Filter := Dankorttransaktion.Text;
                    //      Len := STRLEN(Filter);
                    //      WHILE Len > 0 DO BEGIN
                    //        Pr�fixList.SETRANGE( Prefix, Filter );
                    //        IF Pr�fixList.FIND('-') THEN BEGIN
                    //          Pr�fixList.SETRANGE("Global Dimension 1 Code",KasseOps�t."Global Dimension 1 Code");
                    //          IF NOT Pr�fixList.FIND('-') THEN BEGIN
                    //            Pr�fixList.SETFILTER("Global Dimension 1 Code",'');
                    //            IF Pr�fixList.FIND('-') THEN;
                    //          END;
                    //          Betalingsvalg.RESET;
                    //          Betalingsvalg.SETCURRENTKEY( "No.", "Via Terminal" );
                    //          Betalingsvalg.SETRANGE( "No.", Pr�fixList."Payment Type" );
                    //          Betalingsvalg.SETRANGE( "Via Terminal", TRUE );
                    //          IF Betalingsvalg.FIND('-') AND NOT ("Cash Terminal Approved") THEN BEGIN
                    //            "No."              := Betalingsvalg."No.";
                    //            Description         := Betalingsvalg.Description;
                    //            Quantity               := 0;
                    //            "Cash Terminal Approved" := TRUE;
                    //          END;
                    //        END;
                    //        Len := Len - 1;
                    //        Filter := COPYSTR(Filter,1,Len);
                    //      END;
                    //      IF (NOT "Cash Terminal Approved") THEN BEGIN
                    //        Description := STRSUBSTNO('%1/%2',Description,
                    //                             'XXXX XXXX XXXX '+ COPYSTR(Dankorttransaktion.Text, STRLEN(Dankorttransaktion.Text)-4));
                    //        "Cash Terminal Approved" := TRUE;
                    //      END;
                    //    END ELSE
                    //      "Cash Terminal Approved" := FALSE;
                    //    MODIFY;
                    //    COMMIT;
                    //
                    //    DkTrans.RESET;
                    //    DkTrans.FILTERGROUP :=2;
                    //    DkTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
                    //    DkTrans.SETRANGE("Register No.","Register No.");
                    //    DkTrans.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //
                    //    DkTrans.FILTERGROUP := 0;
                    //    DkTrans.SETRANGE("No. Printed", 0);
                    //    IF DkTrans.FIND('-') THEN REPEAT
                    //      DkTrans."No. Printed" := 1;
                    //      DkTrans.MODIFY()
                    //    UNTIL DkTrans.NEXT = 0;
                    Error('No longer supported.');
                    //+NPR5.28
                end;

            //-NPR5.26 [248043]
            //   KasseOps�t."Credit Card Solution"::Steria : BEGIN
            //     "Flexi-DK-dialog".Init("Amount Including VAT", Rec,
            //                            Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of transaction",FALSE);
            //     COMMIT;
            //     "Flexi-DK-dialog".RUNMODAL;
            //
            //     Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Date);//Alt. kan prim�rn�gle bruges. "Art" m� IKKE indg�.
            //     Dankorttransaktion.SETRANGE("Register No.","Register No.");
            //     Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            //     Dankorttransaktion.SETRANGE("Line No.", "Line No.");
            //     //Dankorttransaktion.SETFILTER(Art,'=3');//Dette filter skal IKKE bruges da der netop skal testes om den sidste linie er 3-linie
            //
            //     IF Dankorttransaktion.FIND('+') AND (Dankorttransaktion.Type = 3) THEN BEGIN
            //       //-NIK
            //       IF ("Flexi-DK-dialog".GetFee <> 0) THEN BEGIN
            //         VALIDATE("Amount Including VAT", "Amount Including VAT" + "Flexi-DK-dialog".GetFee);
            //       END;
            //       //+NIK
            //
            //       Filter := Dankorttransaktion.Text;
            //       Len := STRLEN(Filter);
            //       WHILE Len > 0 DO BEGIN
            //         Pr�fixList.SETRANGE( Prefix, Filter );
            //         IF Pr�fixList.FIND('-') THEN BEGIN
            //           Betalingsvalg.RESET;
            //           Betalingsvalg.SETCURRENTKEY( "No.", "Via terminal" );
            //           Betalingsvalg.SETRANGE( "No.", Pr�fixList."Payment Type" );
            //           Betalingsvalg.SETRANGE( "Via terminal", TRUE );
            //           IF Betalingsvalg.FIND('-') AND NOT ("Cash Terminal Approved") THEN BEGIN
            //             "No."                    := Betalingsvalg."No.";
            //             Description              := Betalingsvalg.Description;
            //             Quantity                 := 0;
            //             "Cash Terminal Approved" := TRUE;
            //           END;
            //         END;
            //         Len := Len - 1;
            //         Filter := COPYSTR(Filter,1,Len);
            //       END;
            //       IF (NOT "Cash Terminal Approved") THEN BEGIN
            //         Description := STRSUBSTNO('%1/%2',Description,Dankorttransaktion.Text);
            //         "Cash Terminal Approved" := TRUE;
            //       END;
            //     END ELSE
            //       "Cash Terminal Approved" := FALSE;
            //     MODIFY;
            //     COMMIT;
            //
            //     DkTrans.RESET;
            //     DkTrans.FILTERGROUP :=2;
            //     DkTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
            //     DkTrans.SETRANGE("Register No.","Register No.");
            //     DkTrans.SETRANGE("Sales Ticket No.","Sales Ticket No.");
            //     DkTrans.SETRANGE(Type,0);
            //     DkTrans.FILTERGROUP := 0;
            //     DkTrans.SETRANGE("No. Printed", 0);
            //     //-NPR70.00.00.06
            //     IF (NOT KasseOps�t."Terminal Auto Print") AND (NOT DkTrans.ISEMPTY) THEN
            //       DkTrans.UdskrivBon(FALSE);
            //     //+NPR70.00.00.06
            //   END;
            //
            // //+1.1c
            // //-1.1d
            // //-1.1d
            //+NPR5.26 [248043]

            //-1.1e
            RegisterGlobal."Credit Card Solution"::"SAGEM Flexiterm .NET":
                begin
                    //-NPR5.28
                    //    PaymentTypePOS.GET("No.");
                    //    Register.GET("Register No.");
                    //    "Flexi-DK-dialog".Init("Amount Including VAT", Rec,
                    //                           Betalingsvalg."Cardholder Verification Method", Betalingsvalg."Type of Transaction",
                    //                           PaymentTypePOS."PBS Gift Voucher Barcode");
                    //    IF Barcode <> '' THEN
                    //      "Flexi-DK-dialog".SetBarcode(Barcode);
                    //    COMMIT;
                    //    "Flexi-DK-dialog".RUNMODAL;
                    //    VALIDATE("Amount Including VAT","Flexi-DK-dialog".GetCapturedAmount);
                    //    VALIDATE("Currency Amount","Flexi-DK-dialog".GetCapturedAmount);
                    //    CLEAR("Flexi-DK-dialog");
                    //
                    //    Dankorttransaktion.SETCURRENTKEY("Register No.","Sales Ticket No.",Date);//Alt. kan prim�rn�gle bruges. "Art" m� IKKE indg�.
                    //    Dankorttransaktion.SETRANGE("Register No.","Register No.");
                    //    Dankorttransaktion.SETRANGE("Sales Ticket No.","Sales Ticket No.");
                    //    Dankorttransaktion.SETRANGE("Line No.", "Line No.");
                    //
                    //    //Dankorttransaktion.SETFILTER(Art,'=3');//Dette filter skal IKKE bruges da der netop skal testes om den sidste linie er 3-linie
                    //
                    //    //-NPR4.11
                    //    //Since we have "Line No." as part of filter and the fact that we can only have one approved
                    //    //transaction per line its ok to use "Type"-filter and test if any line exits (FINDLAST)
                    //    //This should solve the issue when result-line (type 3 line) is created between receipts (eg when refund)
                    //    //IF Dankorttransaktion.FIND('+') AND (Dankorttransaktion.Type = 3) THEN BEGIN
                    //    Dankorttransaktion.SETFILTER(Type,'3');
                    //    IF Dankorttransaktion.FINDLAST THEN BEGIN
                    //    //+NPR4.11
                    //      Filter := Dankorttransaktion.Text;
                    //      //-NPR4.21
                    //      MaskedCardNo := Dankorttransaktion.Text;
                    //      //+NPR4.21
                    //      Len := STRLEN(Filter);
                    //      WHILE (Len > 0) AND NOT ("Cash Terminal Approved") DO BEGIN
                    //        Pr�fixList.SETRANGE( Prefix, Filter );
                    //        IF Pr�fixList.FIND('-') THEN REPEAT
                    //          Betalingsvalg.RESET;
                    //          Betalingsvalg.SETCURRENTKEY( "No.", "Via Terminal" );
                    //          Betalingsvalg.SETRANGE( "No.", Pr�fixList."Payment Type" );
                    //          Betalingsvalg.SETRANGE( "Via Terminal", TRUE );
                    //          Betalingsvalg.SETRANGE("Location Code", Register."Location Code");
                    //
                    //          IF NOT (Betalingsvalg.FINDSET) THEN
                    //            Betalingsvalg.SETRANGE("Location Code");
                    //
                    //          IF Betalingsvalg.FINDFIRST THEN BEGIN
                    //            IF (Betalingsvalg."Location Code" = Register."Location Code") OR
                    //               NOT ("Cash Terminal Approved")
                    //            THEN BEGIN
                    //              "No."                    := Betalingsvalg."No.";
                    //              Description              := Betalingsvalg.Description;
                    //              Quantity                 := 0;
                    //              "Cash Terminal Approved" := TRUE;
                    //            END;
                    //          END;
                    //        UNTIL Pr�fixList.NEXT = 0;
                    //        Len := Len - 1;
                    //        Filter := COPYSTR(Filter,1,Len);
                    //      END;
                    //      IF (NOT "Cash Terminal Approved") THEN BEGIN
                    //        Description := STRSUBSTNO('%1/%2',Description,Dankorttransaktion.Text);
                    //        "Cash Terminal Approved" := TRUE;
                    //      END;
                    //      //-NPR4.21
                    // //      IF "Cash Terminal Approved" THEN
                    //        //-NPR4.18
                    // //        IF Register."Use Euro Refund" THEN
                    // //          "Credit Card Tax Free" := EuroRefund.IsTransactionEligible(CardNo);
                    // //        IF Register."Enable Tax Free" THEN BEGIN
                    // //          RecRef.GETTABLE(Rec);
                    // //          "Credit Card Tax Free" := PremierTaxFreeMgt.EligibleTransaction(CardNo,RecRef);
                    // //        END;
                    //        //+NPR4.18
                    //      //-NPR4.21
                    //    END ELSE
                    //      "Cash Terminal Approved" := FALSE;
                    //
                    //    MODIFY;
                    //    COMMIT;
                    //
                    //    //-NPR4.21
                    //    IF "Cash Terminal Approved" AND Register."Tax Free Enabled" AND Register."Tax Free Check Terminal Prefix" THEN BEGIN
                    //        RecRef.GETTABLE(Rec);
                    //        "Credit Card Tax Free" := PremierTaxFreeMgt.EligibleTransaction(MaskedCardNo,RecRef);
                    //        MODIFY;
                    //    END;
                    //    //+NPR4.21
                    //
                    //    DkTrans.RESET;
                    //    DkTrans.FILTERGROUP :=2;
                    //    DkTrans.SETCURRENTKEY("Register No.", "Sales Ticket No.",Type);
                    //    DkTrans.SETRANGE("Register No.", "Register No.");
                    //    DkTrans.SETRANGE("Sales Ticket No.", "Sales Ticket No.");
                    //    DkTrans.SETRANGE(Type, 0);
                    //    DkTrans.FILTERGROUP := 0;
                    //    DkTrans.SETRANGE("No. Printed", 0);
                    //    //-NPR70.00.00.06
                    //    IF (NOT KasseOps�t."Terminal Auto Print") AND (NOT DkTrans.ISEMPTY) THEN
                    //      DkTrans.PrintTerminalReceipt(FALSE);
                    //    //+NPR70.00.00.06
                    Error('No longer supported.');
                    //+NPR5.28
                end;
            //+1.1e
            else begin
                    Error(t001, "Register No.");
                end;
        end;
    end;

    var
        Dankorttransaktion: Record "Credit Card Transaction";
        Betalingsvalg: Record "Payment Type POS";
        RetailSetup: Record "Retail Setup";
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //Marshaller: Codeunit "POS Event Marshaller";
        Filnavn: Text[80];
        Len: Integer;
        "Filter": Code[30];
        DkTrans: Record "Credit Card Transaction";
        filrec: File;
        AttemptNo: Integer;
        nullinie: Boolean;
        trelinie: Boolean;
        RegisterGlobal: Record Register;
        Barcode: Code[19];
        PepperText001: Label 'Terminal is in Offline mode. Please enter Authorisation No. given by the Payment Provider (%1 digits)';
        PepperText002: Label 'Terminal is in Offline mode. Please enter Authorisation No. given by the Payment Provider (%1 - %2 digits)';
        PepperText003: Label 'Please enter a maximum of %1 digits.';
        PepperText004: Label 'Invalid Authorisation No. Authorisation no , at least %1 digits required. Would you like to cancel the transaction?';
        PepperText005: Label 'No authorisation number. Transaction aborted.';

    procedure HentSti() sti: Text[120]
    begin
        RetailSetup.Get();
        sti := RetailSetup."Credit Card Path" + RetailSetup."Credit Card Program";
        exit(sti);
    end;

    procedure SletFil()
    var
        ConnectionProfileMgt: Codeunit "Connection Profile Management";
    begin
        RetailSetup.Get;
        Filnavn := StrSubstNo(ConnectionProfileMgt.GetCreditCardExtension() + 'dankort.txt');
        if Exists(Filnavn) then Erase(Filnavn);

        // Filnavn := STRSUBSTNO(Ops�tning."Dankort extension"+'besked.txt');
        // IF EXISTS(Filnavn) THEN ERASE(Filnavn);

        // Filnavn := STRSUBSTNO(Ops�tning."Sti til Dankort"+'belob.txt');
        // IF EXISTS(Filnavn) THEN ERASE(Filnavn);
    end;

    procedure FlushFile("Register No.": Code[10])
    var
        txtWait: Label 'The Credit Card Terminal is being closed.... please wait @1@@@@@@@';
        dlg: Dialog;
        nStep: Integer;
        nTime: Integer;
    begin
        //FlushFile()
        RetailSetup.Get;
        Filnavn := StrSubstNo(RetailSetup."Credit Card Path" + 'belob.txt');

        RegisterGlobal.Get("Register No.");
        if (not RegisterGlobal.CloseOnRegBal) or (not RegisterGlobal."Credit Card") then
            exit;
        if not Exists(Filnavn) then
            if not filrec.Create(Filnavn) then
                exit;
        filrec.TextMode(true);
        filrec.WriteMode(true);
        if filrec.Open(Filnavn) then begin
            filrec.Seek(filrec.Len);
            filrec.Write('');
            filrec.Write('CLOSE');
            filrec.WriteMode(false);
            filrec.Close;
            nStep := 0;
            nTime := 1500; // The delay in hundreth of seconds
            dlg.Open(txtWait);
            for nStep := 1 to nTime do begin
                dlg.Update(1, Round(nStep / nTime * 10000, 1, '='));
                Sleep(10);
            end;
        end;
    end;

    procedure SetBarcode(InBarcode: Code[19])
    begin
        Barcode := InBarcode;
    end;

    local procedure RunProcess(Filename: Text; Arguments: Text; Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
    begin
        //-NPR5.38 [301053]
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
            Process.WaitForExit();
        //+NPR5.38 [301053]
    end;
}

