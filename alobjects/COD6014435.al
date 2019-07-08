codeunit 6014435 "Retail Form Code"
{
    // //-NPR3.08a d.14-09-05 v.Simon
    //    Overs�ttelser
    // 
    // 001 NPK,MSP 27-06-03 Gavekort rabat h�ndtering, �ndringer lavet ifm. rabat p� gavekort
    // 002 NPK, MG 250205. Sletter den lokale kopi af et fremmed gavekort, hvis ekspeditionen forkastes
    // 
    // //-NPR3.03, Nikolai Pedersen dec04
    //    �ndret DanBonFraTilbud s� der returneres nummer p� det tilbud der hentes, -1 hvis ikke noget
    // 
    // 003 NPK,OHM - Not nessesary reg. to credit cards etc.
    // 
    // 30D028 NPK,NPE: AfslutEkspedition photobag number transfered to audit role
    // 
    // //NPR3.08x d. 13/12-2005 : Rettet 13 stedder, hvor Shortcut. dim. 1 var udfyldt, men ikke dim. 2 - her er dim. 2 blevet indsat.
    // 
    // //-NPR-PrintRetailDoc1.0
    //   FormAfslutKasse: Tilf�jet funktionalitet til afslutning af kassen
    // 
    // NPR3.12i, NPK, DL, 12-04-07, Tilf�jet k�rsel af rapport til lagerbogf�ring
    // NPR3.12j, NPK, DL, 26-04-07, Tilf�jet k�rsel af rapport til kostpris regulering
    // 
    // NPR3.12om NPK, KSL 18-07-07, Tilf�jet InvoizGuid til audit roll
    // 
    // 004 NPK,MIJ 30/07-08: printLabel_retailJournal: Lavet check p� om qty <> 0
    // NPR3.12q NPK, MIJ, 06-08-08, ItemUnitPriceAfterValidate: Tilf�jet support for standard varianter
    // NPR4.001.020, 25-05-09, MH - Hvis kunden er emailkunde, laves der en faktura.
    // NPR4.001.023, 11-06-09, MH - Tilf�jet feltet "Lock Code", der f�res med fra salgslinie til revisionrulle (Se Sag 65422).
    // NPR4.000.024, 07-07-09, MH - Tilf�jet kode, der kigger p� Contact.Invoice i forhold til udskrivning af kvittering ved salg
    //                              ved salg fra kassen.
    //                              Desuden er der oprettet et felt i "NP Retail Configuration"."Receipt type", der afg�r, hvorvidt
    //                              en bon skal udskrives, mailes eller begge dele.
    // NPR4.003.033, 03-12-09, MH - Added transfer of "Label No." (job 59317).
    // 
    // NPR7.000.002/TS/080114 Case163259   :-Tried to replace the Input box function which is now obsolete by a DotNet
    // NPR70.00.02.11/MH/20150216  CASE 204110 Removed Loyalty Module
    // NPR4.02/MH/20150421  CASE 211739 Removed remnant of loyalty modult
    // NPR4.03/BHR/20140504 CASE 211670 Cancel gift vouchers
    // NPR4.10/VB/20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/RMT/20150618 CASE 216519 Prepayment was not registered on customer if customer was already selected in POS
    // NPR4.11/JDH/20150624 CASE 206743 (Org case 204962)  Do not try to fix the discount rounding. Its handled in the Mix Discount CU
    // NPR4.11/VB/20150629  CASE 213003 Fixed a text caption
    // NPR4.12/JDH/20150702 CASE 217903 Code Cleanup - unused functions and variables have been deleted (and since they are deleted, no documentation is added)
    // NPR4.12/JDH/20150708 CASE 217870 removed "double confirmation"
    // NPR4.14/RMT/20150715 CASE 216519 added prepayment information to audit roll.
    //                                  comment line in "Sale Line POS" added as comment line in audit roll
    // NPR4.14/VB/20150908  CASE 220182 - Fixed text constants
    // NPR4.16/JDH/20151030 CASE 212229 Removed references to old Variant solution "Color Size"
    // NPR4.18/MMV/20151117 CASE 227233 Changed english text constant from 'Return' to 'Change'
    // NPR4.18/MMV/20151123 CASE 227849 Added missing filter on AltNo duplicate check for items.
    // NPR4.18/MMV/20151211 CASE 229221 Updated references to changed label function
    // NPR4.18/RA/20160111  CASE 230569 Secure that Giftvoucher is updated in global company
    // NPR4.18/MMV/20160113 CASE 229221 Commented out function PrintLabelPurchaseOrder (not used anymore)
    // NPR4.18/RMT/20160128 CASE 233094 test for serial numbers if applicable
    // NPR4.18/RA/20160204  CASE 231460 Giftvoucher was set to canseled it it should not do so
    // NPR5.00/VB/20151221  CASE 229375 Limiting search box to 50 characters
    // NPR5.00/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.01/VB/20160121  CASE 231949 Fix for inverse Marshaller.NumPad logic
    // MM1.05/TSA/20160121  CASE 232485 Added Crete memberships
    // TM1.00/TSA/20151124  CASE 219658 Added handling for ticket sales
    // NPR5.20/RMT/20160225 CASE 233336 change local text const t012 in trigger GiftVoucherPush from
    //                                     DAN=Gavekort �-pris:;ENU=Gift Voucher unit price:
    //                                     to
    //                                     DAN=Gavekort �-pris:;ENU=Gift Voucher unit price:
    // NPR5.22/JDH/20160330 CASE 237821 changed check on receipt no. (Due to error -> 9999 > 10000 on code field due to sorting)
    // NPR5.22/MMV/20160420 CASE 237743 Updated references to label library CU.
    // NPR5.23/BHR/20160524 CASE 242341 Popup to display no series and to reuse a GiftVoucher
    // NPR5.26/TS/20160809  CASE 248351 Fix Need to get Customer or Contact before modifying.
    // NPR5.26/OSFI/20160810 CASE 246167 Post POS Info
    // NPR5.26/TJ/20160718  CASE 242297 Fixed an issue where additional non-global dimensions not finding their way into Sale POS and Sale Line POS tables if "Use Adv. dimensions" is used
    // NPR5.26/TSA /20160922 CASE 253098 Added 2 event publishers to the audit role creation loop, OnValidateSaleLinePosBeforePostingEvent, OnBeforeAuditRoleLineInsertEvent
    // NPR5.26/MHA /20160922 CASE 252881 References to old Phone Lookup (Classic) removed
    // NPR5.27/BHR /20160922 CASE 252595 Correct textconstant Text10600073 on function 'FormbalanceRegister'
    // NPR5.27/BHR /20161003 CASE 254066 Flow SalesPerson to Audit Roll
    // NPR5.27/JDH /20161018 CASE 252676 Removed old functions
    // NPR5.27/BR  /20161025 CASE 255131 Added OnBeforeBalancingEvent
    // NPR5.28/BHR /20161110 CASE 256332 Fix SalesReturn for 'Debit sales'
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.28/BR /20161125 CASE 259452 Added support for Item Cross References
    // NPR5.29/MMV /20161216 CASE 241549 Removed deprecated print/report code.
    // NPR5.29/LS  /20170120 CASE 262174 Changed Function CheckSavedSales because when click cancel on selection, it still deletes Saved Sales + txtSelect changed from Local to Global
    // NPR5.30/MHA /20170201  CASE 264918 Np Photo Module removed
    // NPR5.30/TJ  /20170223  CASE 264913 Added code to CreateCustomerOld that uses setup from Config. Template Header rather then from Retail Setup
    // NPR5.31/MMV /20170322 CASE 270332 Validate deletion of saved sale headers to make sure the lines are deleted as well.
    // NPR5.31/BHR /20170327  CASE 229736 Clear currency
    // NPR5.31/AP  /20170302 CASE 248534 Sales Tax to old Audit Roll
    // NPR5.31/AP  /20170302 CASE 262628 POS Sale ID surrogate key to old Audit Roll
    //                                   Orig. POS Sale ID and Orig. POS Line No to old Audit Roll
    // NPR5.31/BHR/20170426 CASE 269001 Corrected bug so that Global company is updated accordingly.
    // NPR5.32/BHR/20170510 CASE 274999 Fill in sell to contact
    // NPR5.32.11/JDH /20170627 CASE 282177 Changed how Type is filled in when doing EOD
    // NPR5.33/AP  /20170518 CASE 262628 Create POS Entries on FinishSale
    // NPR5.36/TJ  /20170809 CASE 286283 Renamed variables/function with danish specific letter into english
    //                                   Removed unused variables
    // NPR5.36/BR  /20170920 CASE 279552 Activated Poseidon
    // NPR5.37.03/MMV /20171122 CASE 296642 Added missing field data on rounding lines.
    // NPR5.38/TSA /20171027 CASE 294623 Added a selective update of dimension regarding payment lines from the SaleStat() function
    // NPR5.38/TSA /20171124 CASE 297087 Added POS Entry synchronization for audit roll balancing
    // NPR5.38/BR  /20170213 CASE 266220 Added support for multiple LCYs for giftcards
    // NPR5.38/TSA /20171128 CASE 294430 ShowProgress is enabled on windows client only
    // NPR5.38/JDH /20180104 CASE 301185 Support for Sales Ticket numbers higher than integer max value
    // NPR5.38/BR  /20180118 CASE 302803 Take the POS Store settings for Gen. Bus. Posting Group Override
    // NPR5.38/BR  /20180118 CASE 302761 Disable Audit Roll Creation for "Create POS Enties Only"
    // NPR5.39/MHA /20180202  CASE 302779 Removed call to POS End Sale in FinishSale()
    // NPR5.39/MHA /20180214  CASE 305139 Added AuditRoll."Discount Authorised by"
    // NPR5.39/BR  /20180215  CASE 305016 Added Fiscal No. support for Balancing
    // NPR5.40/MMV /20180228 CASE 308457 Moved fiscal no. pull inside pos entry create transaction.
    // NPR5.40/TS  /20180308 CASE 307432 Removed reference to MSP Dankort
    // NPR5.41/JC  /20180418 CASE 309296 Fix issue with creating electronic giftvoucher
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.42/JC  /20180515 CASE 315194 Fix issue with getting register no. for Payment Type POS
    // NPR5.44/MMV /20180706 CASE 321816 Get register no. from active transcendence session.
    // NPR5.44/THRO/20180723 CASE 322837 More informative message in GiftVoucherLookup
    // NPR5.45/TSA /20180809 CASE 323615 Making sure "Line Discount Amount" and "Line Discount %" has the same sign as quantity
    // NPR5.45/MHA /20180821 CASE 324395 SaleLinePOS."Unit Price (LCY)" Renamed to "Unit Cost (LCY)"
    // NPR5.47/THRO/20181015 CASE 322837 More informative message in CreditVoucherLookup
    // NPR5.48/MHA /20181115 CASE 334633 Removed function CheckSavedSales() which have been replaced by CleanupPOSQuotes() in codeunit 6151006
    // NPR5.50/TJ  /20190503 CASE 347875 Not updating retail document as cashed if sale has been cancelled

    Permissions = TableData "Sales Invoice Header"=rimd,
                  TableData "Sales Invoice Line"=rimd,
                  TableData "Sales Cr.Memo Header"=rimd,
                  TableData "Sales Cr.Memo Line"=rimd,
                  TableData "Audit Roll"=rimd;
    TableNo = "Retail Document Header";

    trigger OnRun()
    var
        RetailSetup: Record "Retail Setup";
        i: Integer;
    begin
        RetailSetup.Get;
        if RetailSetup."Auto Print Retail Doc" then begin
          PrintRetailDocument(false);
          if RetailSetup."No. of Copies of Selection" > 0 then begin
            for i := 1 to RetailSetup."No. of Copies of Selection" do begin
              PrintRetailDocument(false);
            end;
          end;
        end;
    end;

    var
        RetailSetupGlobal: Record "Retail Setup";
        RetailContractSetup: Record "Retail Contract Setup";
        CustomerGlobal: Record Customer;
        RecIComm: Record "I-Comm";
        RetailContractMgt: Codeunit "Retail Contract Mgt.";
        CuIComm: Codeunit "I-Comm";
        RetailTableCode: Codeunit "Retail Table Code";
        Text10600038: Label 'No lines with sale activity exists!';
        Text10600039: Label 'One payment type must have payment option Cash!';
        Text10600040: Label 'Change';
        Text10600078: Label 'Reverse sales ticket no. %1';
        UsingTS: Boolean;
        ValueforTS: Decimal;
        Text10600200: Label 'Error';
        Text10600400: Label 'Serial Number must be supplied for Item %1 - %2';
        ErrReturnCashExceeded: Label 'Return cash exceeded. Create credit voucher instead.';
        Text0001: Label 'Enter Gift Voucher No.';
        Text0002: Label 'Gift Voucher %1 already exists with the amount of %2\\Would you like to renew this card?';
        TxtSelect: Label 'Delete all saved sales,Terminate/Delete saved sales manually';

    procedure AuditRollCancelSale(var SalePOS: Record "Sale POS";LineDescription: Text[50]): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        AuditRoll: Record "Audit Roll";
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
    begin
        //-NPR5.38 [302761]
        RetailSetup.Get;
        if RetailSetup."Create POS Entries Only" then
          exit;
        //+NPR5.38 [302761]
        //ekspedition forkastet
        //CheckCommonGV(Eksp);
        AuditRoll.Reset;
        AuditRoll.SetRange("Register No.",SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if AuditRoll.Find('-') then
          exit(false);

        AuditRoll.Init;
        AuditRoll."Register No." := SalePOS."Register No.";
        AuditRoll."Sales Ticket No." := SalePOS."Sales Ticket No.";

        if SalePOS.Date <> 0D then
          AuditRoll."Sale Date" := SalePOS.Date
        else
          AuditRoll."Sale Date" := Today;

        AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
        AuditRoll.Type := AuditRoll.Type::Cancelled;
        AuditRoll."Salesperson Code" := SalePOS."Salesperson Code";
        AuditRoll."No." := '';
        AuditRoll.Description := LineDescription;
        AuditRoll."Starting Time" := SalePOS."Start Time";
        AuditRoll."Closing Time" := Time;
        AuditRoll.Posted := true;
        AuditRoll."Drawer Opened" := SalePOS."Drawer Opened";

        SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type,"No.","Item Group",Quantity);
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT",SaleLinePOS.Quantity);

        AuditRoll."Cancelled No. Of Items" := SaleLinePOS.Quantity;
        AuditRoll."Cancelled Amount On Ticket" := SaleLinePOS."Amount Including VAT";

        Register.Get(SalePOS."Register No.");
        if not Register."Connected To Server" then begin
          AuditRoll.Offline := true;
        end;

        AuditRoll."Offline receipt no." := SalePOS."Sales Ticket No.";
        AuditRoll.Insert(true);

        exit(true);
    end;

    procedure BalanceRegister(var SalePOS: Record "Sale POS"): Boolean
    var
        t001: Label 'Register already closed!';
        TouchScreenBalancingWeb: Page "Touch Screen - Balancing (Web)";
        AuditRollCheck: Record "Audit Roll";
        Register: Record Register;
        PaymentTypeDetailed: Record "Payment Type - Detailed";
        RetailFormCode: Codeunit "Retail Form Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Action1: Action;
        t002: Label 'Delete all sales lines before balancing the register';
        t003: Label 'You must close sales window on register no. %1';
        ClosingType: Option Cancel,Normal,Saved;
        txtCannotSendSMSWB: Label 'Could not send SMS with todays sales.';
    begin
        //BalanceRegister
        RetailSetupGlobal.Get;
        RetailSetupGlobal.CheckOnline;

        Register.Get(SalePOS."Register No.");

        AuditRollCheck.SetRange("Register No.",Register."Register No.");
        if AuditRollCheck.Find('+') then begin
          if AuditRollCheck."Sales Ticket No." > SalePOS."Sales Ticket No." then
            SalePOS.Rename(SalePOS."Register No.",FetchSalesTicketNumber(SalePOS."Register No."));
        end;

        if RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL then begin
          if Register.Find('-') then
            repeat
              if (Register."Register No." <> SalePOS."Register No.") then begin
                Message(t003,Register."Register No.");
                exit(false);
              end;
            until Register.Next = 0;
        end;

        if RetailSalesLineCode.LineExists(SalePOS) then
          Error(t002);

        if Register.Status = Register.Status::Afsluttet then
          Error(t001);

        SalePOS."Last Sale" := true;
        SalePOS.Modify;
        Commit;

        //-NPR5.27 [255131]
        OnBeforeBalancingEvent(SalePOS,Register);
        //+NPR5.27 [255131]

        if SalePOS.TouchScreen then begin
          //-NPR5.28
          //  //-NPR4.10
          //  IF SessionMgt.IsDotNet() THEN BEGIN
          //  //+NPR4.10
          //    COMMIT;
          //    formBalancingTS.LOOKUPMODE(TRUE);
          //    formBalancingTS.initForm(Kasse."Register No.", Eksp."Salesperson Code");
          //    Action1 := formBalancingTS.RUNMODAL;
          //    closingType := formBalancingTS.getClosingType;
          //  //-NPR4.10
          //  END ELSE BEGIN
          //+NPR5.28
            TouchScreenBalancingWeb.LookupMode(true);
            TouchScreenBalancingWeb.Initialize(Register."Register No.",SalePOS."Salesperson Code");
            Commit;
            Action1 := TouchScreenBalancingWeb.RunModal;
            ClosingType := TouchScreenBalancingWeb.getClosingType;
          //-NPR5.28
          //  END;
          //+NPR5.28
          //+NPR4.10
        end else begin
          //-NPR4.10
          //formBalancing.LOOKUPMODE(TRUE);
          //+NPR4.10
          Error('Only touch support');
          //-NPR4.10
          ////formBalancing.initForm(Kasse."Register No.", Eksp."Salesperson Code");
          //Action1 := formBalancing.RUNMODAL;
          ////closingType := formBalancing.getClosingType;
          //+NPR4.10
        end;

        case ClosingType of
          ClosingType::Normal:
            begin
              if SalePOS.TouchScreen then
                //-NPR5.28
                //-NPR4.10
                //formBalancing.saveBalancedRegister(Eksp, TODAY, TIME, TRUE);
                //        IF SessionMgt.IsDotNet() THEN
                //          formBalancingTS.saveBalancedRegister(Eksp, TODAY, TIME, TRUE)
                //        ELSE
                //          pageBalancingWeb.saveBalancedRegister(Eksp, TODAY, TIME, TRUE)
                //+NPR4.10
                TouchScreenBalancingWeb.saveBalancedRegister(SalePOS,Today,Time,true)
                //+NPR5.28
              else
                ;
                //formBalancing.saveBalancedRegister(Eksp, TODAY, TIME, TRUE);
              PaymentTypeDetailed.SetRange("Register No.",SalePOS."Register No.");
              PaymentTypeDetailed.DeleteAll(true);
              if not RetailFormCode.FormBalanceRegister(SalePOS,Today) then begin
                SalePOS."Last Sale" := false;
                SalePOS.Modify;
                exit(false);
              end else if not CODEUNIT.Run(CODEUNIT::"Send Register Balance",SalePOS) then
                Message(txtCannotSendSMSWB);
              exit(true);
            end;
          else begin
            SalePOS."Last Sale" := false;
            SalePOS.Modify;
            Commit;
            exit(false);
          end;
        end;
        exit(true);
    end;

    procedure CheckSales(var SalePOS: Record "Sale POS"): Boolean
    var
        Register: Record Register;
        SalesTicketNo: Integer;
        LastSalesTicketNo: Integer;
        TxtOld: Label 'This salesdialog is too old. Please close it and start over';
    begin
        //CheckSales()
        //-NPR5.38 [301185]
        // WITH SalePOS DO BEGIN
        //  Register.GET("Register No.");
        //  EVALUATE(SalesTicketNo,"Sales Ticket No.");
        //  EVALUATE(LastSalesTicketNo,GetLastSalesTicketNumber("Register No."));
        //  IF SalesTicketNo < LastSalesTicketNo THEN
        //    ERROR(TxtOld,FALSE);
        //  EXIT(TRUE);
        // END;

        if SalePOS."Sales Ticket No." < GetLastSalesTicketNumber(SalePOS."Register No.") then
          Error(TxtOld);
        exit(true);
        //+NPR5.38 [301185]
    end;

    procedure CancelSalesTicket(var SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        ErrorTermApproved: Label 'Sale could not be discarded because one or more approved terminal transaction(s) exists.';
        GiftVoucher: Record "Gift Voucher";
        RetailFormCode: Codeunit "Retail Form Code";
        Text10600004: Label 'Sale discarded';
        RetailComment: Record "Retail Comment";
    begin
        //AnnullerBon()
        // Accessory Matrix clean-up
        // Retail comment lines
        RetailComment.Reset;
        RetailComment.SetRange("Table ID", 6014405);
        RetailComment.SetRange("No.",SalePOS."Register No.");
        RetailComment.SetRange("No. 2",SalePOS."Sales Ticket No.");
        RetailComment.DeleteAll;

        AuditRollCancelSale(SalePOS,Text10600004);

        // Check sales lines
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.Find('-') then
          repeat
            if (SaleLinePOS.Type = SaleLinePOS.Type::Payment) and
               SaleLinePOS."Cash Terminal Approved" then
              Error(ErrorTermApproved);
          until SaleLinePOS.Next = 0;
        SaleLinePOS.DeleteAll(true);

        GiftVoucher.Reset;
        GiftVoucher.SetCurrentKey("Sales Ticket No.");
        GiftVoucher.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if GiftVoucher.Find('-') then
          repeat
            GiftVoucher.Status := GiftVoucher.Status::Cancelled;
            GiftVoucher.Salesperson := SalePOS."Salesperson Code";
            GiftVoucher.Modify;
            RetailTableCode.GiftVoucherCommonValidate(SalePOS,GiftVoucher."No.",GiftVoucher.Status::Cancelled);
          until GiftVoucher.Next = 0;

        RetailFormCode.CheckCustomization(SalePOS);
        //CheckUdvalg;
        ///checkfoto;
    end;

    procedure CustomerPayment(var SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        LineNo: Integer;
        UnitPrice: Decimal;
        Txt001: Label 'Payment amount';
        CustNo: Code[20];
        Cust: Record Customer;
        Txt003: Label 'Payment #1##########';
    begin
        //customerPayment
        CustNo := SalePOS."Customer No.";

        if CustNo = '' then begin
          if SalePOS.TouchScreen then begin
            if PAGE.RunModal(PAGE::"Touch Screen - Customers",Cust) <> ACTION::LookupOK then
              exit(false);
          end else begin
            if PAGE.RunModal(PAGE::"Customer List",Cust) <> ACTION::LookupOK then
              exit(false);
          end;
          //-NPR4.11
          CustNo := Cust."No.";
          //+NPR4.11
        end;

        //-NPR4.11
        //custNo := cust."No.";
        //+NPR4.11

        if not POSEventMarshaller.NumPad(Txt001,UnitPrice,true,false) then
          exit;

        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        LineNo := 10000;

        if SaleLinePOS.Find('+') then
          LineNo += SaleLinePOS."Line No.";

        SaleLinePOS.Init;
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := SalePOS.Date;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Date := SalePOS.Date;
        SaleLinePOS.Insert(true);

        SalePOS.Validate("Customer No.",CustNo);

        SaleLinePOS.Validate(Quantity,1);
        SaleLinePOS.Validate("No.",CustNo);
        //SaleLine."Price Includes VAT"  := false;
        SaleLinePOS.Validate("Unit Price",UnitPrice);
        SaleLinePOS.Description := StrSubstNo(Txt003,CustNo);
        SaleLinePOS.Modify(true);

        exit(true);
    end;

    procedure CreateItemTrackingFromSaleLine(var SaleLinePOS: Record "Sale Line POS";LineNo: Integer;HeaderNo: Code[20];IsOrder: Boolean;IsReturnOrder: Boolean)
    var
        ReservationEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalePOS: Record "Sale POS";
        SalesType: Option "Order",Invoice,"Credit Memo";
    begin
        //OpretVareSporingFraEkspLinie
        with SaleLinePOS do begin
          if IsOrder then
            SalesType := SalesType::Order
          else if Quantity > 0 then
            SalesType := SalesType::Invoice
          else
            SalesType := SalesType::"Credit Memo";

          ReservationEntry.SetCurrentKey(Positive);
          ReservationEntry.SetRange(Positive,Quantity < 0);
          if ReservationEntry.Find('+') then;
          ReservationEntry.Init;
          ReservationEntry."Entry No." += 1;
          ReservationEntry.Positive := Quantity < 0;
          ReservationEntry."Item No." := "No.";
          ReservationEntry."Location Code" := "Location Code";
          if SalesType = SalesType::"Credit Memo" then begin
            ReservationEntry."Quantity (Base)" := Quantity;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
            ReservationEntry."Source Subtype" := 3;
          end;
          if SalesType = SalesType::Invoice then begin
            ReservationEntry."Quantity (Base)" := -Quantity;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
            ReservationEntry."Source Subtype" := 2;
          end;
          if SalesType = SalesType::Order then begin
            ReservationEntry."Quantity (Base)" := -Quantity;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
            if IsReturnOrder then
              ReservationEntry."Source Subtype" := 5
            else
              ReservationEntry."Source Subtype" := 1;
          end;

          ReservationEntry.Quantity := -Quantity;
          ReservationEntry."Qty. to Handle (Base)" := -Quantity;
          ReservationEntry."Qty. to Invoice (Base)" := -Quantity;

          if (Quantity > 0) and not (SalesType = SalesType::"Credit Memo") then begin
            ItemLedgerEntry.SetCurrentKey(Open,Positive,"Item No.","Serial No.");
            ItemLedgerEntry.SetRange(Open,true);
            ItemLedgerEntry.SetRange(Positive,true);
            ItemLedgerEntry.SetRange("Serial No.","Serial No.");
            ItemLedgerEntry.SetRange("Item No.","No.");
            if ItemLedgerEntry.Find('-') then
              ReservationEntry."Creation Date" := ItemLedgerEntry."Posting Date";
          end else
            ReservationEntry."Creation Date" := Today;

          ReservationEntry."Qty. per Unit of Measure" := 1;
          ReservationEntry."Source Type" := 37;
          ReservationEntry."Source ID" := HeaderNo;
          ReservationEntry."Source Ref. No." := LineNo;
          ReservationEntry."Expected Receipt Date" := Today;
          ReservationEntry."Serial No." := "Serial No.";

          SalePOS.Get("Register No.","Sales Ticket No.");
          ReservationEntry."Created By" := SalePOS."Salesperson Code";
          ReservationEntry.Insert;
        end;
    end;

    procedure CreateSalesHeader(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header" temporary)
    var
        RegisterNo: Code[20];
        Register: Record Register;
        POSStore: Record "POS Store";
    begin
        //OpretSalgshoved()
        RegisterNo := FetchRegisterNumber;
        Register.Get(RegisterNo);

        if SalesHeader."No." <> '' then
          exit;

        SalesHeader.DeleteAll;
        if (SalePOS."Customer No." <> '') and (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) then begin
          SalesHeader.Init;
          SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
          SalesHeader."No." := SalePOS."Register No." + '-' + SalePOS."Sales Ticket No.";
          SalesHeader."Posting Date" := WorkDate;
          SalesHeader."Document Date" := WorkDate;
          SalesHeader."Document Time" := Time;
          SalesHeader.Validate("Sell-to Customer No.",SalePOS."Customer No.");
          //-NPR5.38 [302803]
          //IF Register."Gen. Business Posting Override" = 1 THEN
          //   SalesHeader."Gen. Bus. Posting Group" := Register."Gen. Business Posting Group";
          if SalePOS."POS Store Code" <> '' then begin
            POSStore.Get(SalePOS."POS Store Code");
            if POSStore."Default POS Posting Setup" = POSStore."Default POS Posting Setup"::Store then
              if POSStore."Gen. Bus. Posting Group" <> '' then
                SalesHeader."Gen. Bus. Posting Group" := POSStore."Gen. Bus. Posting Group";
          end;
          //+NPR5.38 [302803]

          SalesHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
          SalesHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        //-NPR4.21
          SalesHeader."Dimension Set ID" := SalePOS."Dimension Set ID";
        //+NPR4.21

          SalesHeader."Location Code" := SalePOS."Location Code";
          SalesHeader."Salesperson Code" := SalePOS."Salesperson Code";
          SalesHeader."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SalesHeader."Bill-to Contact" := SalePOS."Contact No.";
          //-NPR5.32 [274999]
          if SalesHeader."Sell-to Contact" = '' then
            SalesHeader."Sell-to Contact" := SalePOS."Contact No.";
        //+NPR5.32 [274999]
          SalesHeader."Your Reference" := SalePOS.Reference;
          SalesHeader."External Document No." := SalePOS.Reference;
          //-NPR5.31 [229736]
          SalesHeader.Validate("Currency Code",'');
          //+NPR5.31 [229736]
          SalesHeader.Insert;
        end;
    end;

    procedure CreateNewAltItem(var Rec: Record Item;xRec: Record Item;AltNo: Code[20];VariantCode: Code[10]): Boolean
    var
        InputDialog: Page "Input Dialog";
        RetailSetup: Record "Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InterNo: Code[10];
        InterEANCode: Code[10];
        Text10600006: Label 'Chack digits are incorrect on EAN no.';
        Text10600007: Label 'Item No. #1###';
        Item: Record Item;
        Text10600008: Label 'Item %1 exists already!';
        Text10600009: Label 'No. %1 exists already on item %2!';
        AlternativeNo: Record "Alternative No.";
    begin
        //CreateNewAltItem
        if AltNo = '*' then begin
          RetailSetup.Get;
          RetailSetup.TestField("Internal EAN No. Management");
          NoSeriesMgt.InitSeries(RetailSetup."Internal EAN No. Management",xRec."No. Series",0D,InterNo,Rec."No. Series");

          InterEANCode := Format(RetailSetup."EAN-Internal");
          AltNo := InterEANCode + PadStr('',10 - StrLen(Format(InterNo)),'0') + Format(InterNo);
          AltNo := AltNo + Format(StrCheckSum(AltNo,'131313131313'));
          if StrCheckSum(AltNo,'1313131313131') <> 0 then
            Error(Text10600006);
        end;

        if AltNo = '**' then begin
          RetailSetup.Get;
          RetailSetup.TestField("External EAN-No. Management");
          NoSeriesMgt.InitSeries(RetailSetup."External EAN-No. Management",xRec."No. Series",0D,InterNo,Rec."No. Series");

          AltNo := '';
          InputDialog.SetInput(1,AltNo,Text10600007);
          if InputDialog.RunModal = ACTION::OK then
            InputDialog.InputCode(1,AltNo);

          InterEANCode := Format(RetailSetup."EAN-External");
          AltNo := InterEANCode + PadStr('',5 - StrLen(Format(AltNo)),'0') + Format(AltNo);
          AltNo := AltNo + Format(StrCheckSum(AltNo,'131313131313'));
          if StrCheckSum(AltNo,'1313131313131') <> 0 then
            Error(Text10600006);
        end;

        if Item.Get(AltNo) then
          Error(Text10600008,Item."No.");

        //-NPR5.28 [259452]
        if VariantCode = '' then
          VariantCode := SelectVariant(Rec);
        if UseCrossReference then begin
          exit(CreateNewCrossReference(Rec,AltNo,VariantCode));
        end;
        //+NPR5.28 [259452]

        AlternativeNo.SetCurrentKey("Alt. No.");
        AlternativeNo.SetRange("Alt. No.",AltNo);
        //-NPR4.18
        AlternativeNo.SetRange(Type,AlternativeNo.Type::Item);
        //+NPR4.18
        if AlternativeNo.Find('-') then
          Error(Text10600009,AltNo,AlternativeNo.Code);

        AlternativeNo.Reset;
        AlternativeNo.Type := AlternativeNo.Type::Item;
        AlternativeNo.Code := Rec."No.";
        AlternativeNo."Alt. No." := AltNo;
        AlternativeNo."Variant Code" := VariantCode;
        AlternativeNo.Insert(true);
        Rec."Label Barcode" := AlternativeNo."Alt. No.";

        AltNo := '';

        exit(true);
    end;

    local procedure UseCrossReference(): Boolean
    var
        VarietySetup: Record "Variety Setup";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.28 [259452]
        if VarietySetup.Get then begin
          if VarietySetup."Create Item Cross Ref. auto." then
            exit(true);
          if VarietySetup."Create Alt. No. automatic" then
            exit(false);
        end;
        if not ItemCrossReference.IsEmpty then
          exit(true);
        exit(false);
        //+NPR5.28 [259452]
    end;

    procedure SelectVariant(Item: Record Item): Code[20]
    var
        ItemVariant: Record "Item Variant";
        ItemVariants: Page "Item Variants";
    begin
        //-NPR5.28 [259452]
        Item.CalcFields("Has Variants");
        if Item."Has Variants" then begin
          ItemVariant.Reset;
          ItemVariant.SetRange("Item No.",Item."No.");
          ItemVariant.SetRange(Blocked,false);
          Clear(ItemVariants);
          ItemVariants.SetTableView(ItemVariant);
          ItemVariants.LookupMode := true;
          if ItemVariants.RunModal = ACTION::LookupOK then begin
            ItemVariants.GetRecord(ItemVariant);
            ItemVariant.TestField("Item No.",Item."No.");
            exit(ItemVariant.Code);
          end else
            exit('');
        end else begin
          exit('');
        end;
        //+NPR5.28 [259452]
    end;

    procedure CreateNewCrossReference(var Item: Record Item;var CrossReferenceCode: Code[20];VariantCode: Code[10]): Boolean
    var
        ItemCrossReference: Record "Item Cross Reference";
        VarietyCloneData: Codeunit "Variety Clone Data";
    begin
        //-NPR5.28 [259452]
        if VarietyCloneData.GetVRTSetup then begin
          VarietyCloneData.InsertItemCrossRef(Item."No.",VariantCode,CrossReferenceCode,3,'');
        end else begin
          ItemCrossReference.Reset;
          ItemCrossReference."Cross-Reference Type"  := ItemCrossReference."Cross-Reference Type"::"Bar Code";
          ItemCrossReference."Item No." := Item."No.";
          ItemCrossReference."Cross-Reference No." := CrossReferenceCode;
          ItemCrossReference."Variant Code" := VariantCode;
          ItemCrossReference.Insert(true);
        end;
        if VariantCode = '' then
          Item."Label Barcode" := CrossReferenceCode;
        CrossReferenceCode := '';
        exit(true);
        //+NPR5.28 [259452]
    end;

    procedure EditComments(var SalePOS: Record "Sale POS")
    var
        RetailComment: Record "Retail Comment";
        RetailComments: Page "Retail Comments";
    begin
        //editComments
        RetailComment.Reset;
        RetailComment.SetRange("Table ID", 6014405);
        RetailComment.SetRange("No.",SalePOS."Register No.");
        RetailComment.SetRange("No. 2",SalePOS."Sales Ticket No.");

        Clear(RetailComments);
        RetailComments.SetTableView(RetailComment);
        RetailComments.RunModal;
    end;

    procedure FinishSale(var Sale: Record "Sale POS";AfslKontrol: Decimal;Art: Integer;IsRounding: Boolean;var SalesHeader2: Record "Sales Header";SalePOSBalance: Decimal) Retur: Decimal
    var
        BetalingsvalgLok: Record "Payment Type POS";
        SaleCopy: Record "Sale POS" temporary;
        RevisionsrulleLok: Record "Audit Roll";
        GavekortLok: Record "Gift Voucher";
        SalesHeader: Record "Sales Header";
        TilgodebevisLok: Record "Credit Voucher";
        Finans: Record "G/L Account";
        "Eks. Linie": Record "Sale Line POS";
        NewSale: Record "Sale Line POS";
        RepListe: Record "Customer Repair";
        Betalingsvalg: Record "Payment Type POS";
        Gavekort: Record "Gift Voucher";
        Tilgodebevis: Record "Credit Voucher";
        Ekspeditionslinie: Record "Sale Line POS";
        Kasse: Record Register;
        Vare: Record Item;
        Revisionsrulle: Record "Audit Roll";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        KDebitor: Record Contact;
        Udlejning: Record "Retail Document Header";
        ServiceItemGrp: Record "Service Item Group";
        ItemVariant: Record "Item Variant";
        FromComment: Record "Retail Comment";
        ToComment: Record "Retail Comment";
        ItemTrackingCode: Record "Item Tracking Code";
        SerialNoInfo: Record "Serial No. Information";
        FormCode: Codeunit "Retail Form Code";
        "Retail Document Handling": Codeunit "Retail Document Handling";
        Utility: Codeunit Utility;
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        Decimal: Decimal;
        Afrunding: Decimal;
        TempAmount: Decimal;
        LineNo: Integer;
        nLinie: Integer;
        Nr: Integer;
        PaymentType: Option Gift,Credit;
        RepText: Text[50];
        bNegBon: Boolean;
        bGaranti: Boolean;
        t001: Label 'Repair %1 has been delivered';
        ErrFremGaveAmount: Label 'The amount on giftcard no. %1 on the server does not match the salesline';
        ErrFremTilAmount: Label 'The amount on the credit voucher %1 on the server does not match with the payment line';
        ErrNoCustForWarranty: Label 'A customer no. must be entered, as one or more items must be moved to warranty';
        ErrServiceNoCust: Label 'A Customer must be chosen, because the sale contains items which are to be transferred to service items.';
        txtPayout: Label 'Payout';
        ErrMaxExceeded: Label 'The amount on payment option %1 must not surpass %2';
        ErrMinExceeded: Label 'The amount on payment option %1 must not be below %2';
        ErrItemVariant: Label 'A line with item no. %1 must have a variant code';
        txtRevComment: Label '%1-No %3 to %2';
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        Ticketmanagement: Codeunit "TM Ticket Management";
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MSPOSSaleLine: Record "Sale Line POS";
        saleNegCashSum: Decimal;
        POSInfoManagement: Codeunit "POS Info Management";
        NPRetailSetup: Record "NP Retail Setup";
        GLSetup: Record "General Ledger Setup";
        SaleLinePOS: Record "Sale Line POS";
    begin
        //AfslutEkspedition()
        with Sale do begin
          RetailSetupGlobal.Get;
        
          // Accessory matrix clean-up
          bGaranti := false;
        
          /*---------------------------------------------------------------------------------------------*/
          /* CHECK: IS A NEGATIVE RECEIPT */
          /*---------------------------------------------------------------------------------------------*/
        
          Ekspeditionslinie.Reset;
          Ekspeditionslinie.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
          Ekspeditionslinie.SetRange("Register No.","Register No.");
          Ekspeditionslinie.SetRange("Sales Ticket No.","Sales Ticket No.");
          if Ekspeditionslinie.FindFirst then
            repeat
              Ekspeditionslinie.Validate("Shortcut Dimension 1 Code");
              Ekspeditionslinie.Validate("Shortcut Dimension 2 Code");
            until Ekspeditionslinie.Next = 0;
        
          Ekspeditionslinie.SetRange("Sale Type",Ekspeditionslinie."Sale Type"::Sale);
          Ekspeditionslinie.SetRange(Type,Ekspeditionslinie.Type::Item);
          Ekspeditionslinie.CalcSums("Amount Including VAT");
          bNegBon := Ekspeditionslinie."Amount Including VAT" < 0;
        
        
        /*---------------------------------------------------------------------------------------------*/
        /* CHECK: IS RETURN CASH EXCEEDED IF SALE IS NEGATIVE */
        /*---------------------------------------------------------------------------------------------*/
          if bNegBon then begin
            saleNegCashSum := 0;
            Clear(Ekspeditionslinie);
            if SalespersonPurchaser.Get("Salesperson Code") then
              if SalespersonPurchaser."Maximum Cash Returnsale" > 0 then begin
                if (AfslKontrol < 0) and (Abs(AfslKontrol) > Abs(SalespersonPurchaser."Maximum Cash Returnsale")) then
                  Error(ErrReturnCashExceeded);
        
                Ekspeditionslinie.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
                Ekspeditionslinie.SetRange("Register No.","Register No.");
                Ekspeditionslinie.SetRange("Sales Ticket No.","Sales Ticket No.");
                Ekspeditionslinie.SetRange("Sale Type",Ekspeditionslinie."Sale Type"::Payment);
                Ekspeditionslinie.SetRange(Type,Ekspeditionslinie.Type::Payment);
                if Ekspeditionslinie.Find('-') then
                  repeat
                    if BetalingsvalgLok.Get(Ekspeditionslinie."No.") then
                      if (BetalingsvalgLok."Processing Type" = BetalingsvalgLok."Processing Type"::Cash) and
                          (Ekspeditionslinie."Amount Including VAT" < 0) then begin
                        saleNegCashSum := saleNegCashSum + Ekspeditionslinie."Amount Including VAT";
                        if Abs(saleNegCashSum) > Abs(SalespersonPurchaser."Maximum Cash Returnsale") then
                          Error(ErrReturnCashExceeded);
                      end;
                  until Ekspeditionslinie.Next = 0;
              end;
          end;
        
        
        /*---------------------------------------------------------------------------------------------*/
        /* SET TO THIS RECEIPT NO. */
        /*---------------------------------------------------------------------------------------------*/
        
          Clear(Ekspeditionslinie);
          Ekspeditionslinie.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
          Ekspeditionslinie.SetRange("Register No.","Register No.");
          Ekspeditionslinie.SetRange("Sales Ticket No.","Sales Ticket No.");
        
          NewSale.Reset;
          NewSale.SetRange("Register No.","Register No.");
          NewSale.SetRange("Sales Ticket No.","Sales Ticket No.");
          if NewSale.Find('+') then;
          nLinie := Round(NewSale."Line No.",10000,'<') + 1;
          NewSale.SetRange(Type,NewSale.Type::"BOM List");
          if NewSale.Find('-') then
            repeat
              Vare.Get(NewSale."No.");
              if not Vare."Explode BOM auto" then begin
                NewSale.ExplodeBOM(NewSale."No.",0,0,Nr,0,0);
                NewSale.Amount := 0;
                NewSale."Amount Including VAT" := 0;
                NewSale."Unit Price" := 0;
                NewSale.Quantity := 1;
                NewSale.Modify;
              end;
            until NewSale.Next = 0;
        
          FixDiscountRounding("Sales Ticket No.","Register No.",Sale);
        
        /*---------------------------------------------------------------------------------------------*/
        /* GO THROUGH ALL SALES LINES */
        /*---------------------------------------------------------------------------------------------*/
        
          if Ekspeditionslinie.Find('-') then begin
            repeat
        
              /*---------------------------------------------------------------------------------------------*/
              /* Service Module */
              /*---------------------------------------------------------------------------------------------*/
        
              if (Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Sale) and
                 (Ekspeditionslinie.Type = Ekspeditionslinie.Type::Item)
              then begin
                Vare.Get(Ekspeditionslinie."No.");
                if Vare."Service Item Group" <> '' then begin
                  ServiceItemGrp.Get(Vare."Service Item Group");
                  if ServiceItemGrp."Create Service Item" and (Vare."Costing Method" = Vare."Costing Method"::Specific) and
                                                              (Ekspeditionslinie.Quantity > 0) then begin
                    if not (("Customer Type" = "Customer Type"::Ord) and ("Customer No." <> '')) then
                      Error(ErrServiceNoCust);
                    Ekspeditionslinie.TransferToService;
                  end;
                end;
                //-NPR4.18
                if Vare."Item Tracking Code"<>'' then begin
                  ItemTrackingCode.Get(Vare."Item Tracking Code");
                  ItemTrackingManagement.GetItemTrackingSettings(ItemTrackingCode,1,false,SNRequired,LotRequired,SNInfoRequired,LotInfoRequired);
                  if SNRequired then begin
                    if Ekspeditionslinie."Serial No."='' then
                      Error(Text10600400,Ekspeditionslinie."No.",Ekspeditionslinie.Description);
                  end;
                  if SNInfoRequired then begin
                    SerialNoInfo.Get(Ekspeditionslinie."No.",Ekspeditionslinie."Variant Code",Ekspeditionslinie."Serial No.");
                    SerialNoInfo.TestField(Blocked,false);
                  end;
                end else begin
                  if SerialNoInfo.Get(Ekspeditionslinie."No.",Ekspeditionslinie."Variant Code",Ekspeditionslinie."Serial No.") then
                    SerialNoInfo.TestField(Blocked,false);
                end;
                //+NPR4.18
              end;
        
            /*---------------------------------------------------------------------------------------------*/
            /* NOT BOM AND NOT COMMENT */
            /*---------------------------------------------------------------------------------------------*/
        
              if (Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Sale)
                  and not (Ekspeditionslinie.Type = Ekspeditionslinie.Type::"BOM List")
                  and not (Ekspeditionslinie.Type = Ekspeditionslinie.Type::Comment) then begin
                Ekspeditionslinie.TestField("Gen. Bus. Posting Group");
                Ekspeditionslinie.TestField("Gen. Prod. Posting Group");
                Ekspeditionslinie.TestField("VAT Bus. Posting Group");
                Ekspeditionslinie.TestField("VAT Prod. Posting Group");
                Vare.Get(Ekspeditionslinie."No.");
                if Vare."Costing Method" = Vare."Costing Method"::Specific then
                  Ekspeditionslinie.TestField("Serial No.");
              end;
        
            /*---------------------------------------------------------------------------------------------*/
            /* CLEARING TYPE */
            /*---------------------------------------------------------------------------------------------*/
        
              case Ekspeditionslinie.Clearing of
                Ekspeditionslinie.Clearing::Gavekort:
                  begin
                    Gavekort.Get(Ekspeditionslinie."Gift Voucher Ref.");
                    Ekspeditionslinie."Foreign No." := Gavekort."No.";
                    Gavekort.RedeemFromSaleLinePOS(Ekspeditionslinie,"Salesperson Code",Ekspeditionslinie."Line No.");
                    Gavekort.Modify;
                  end;
                Ekspeditionslinie.Clearing::Tilgodebevis:
                  begin
                    Tilgodebevis.Get(Ekspeditionslinie."Credit voucher ref.");
                    Ekspeditionslinie."Foreign No." := Tilgodebevis."No.";
                    Tilgodebevis.RedeemFromSaleLinePOS(Ekspeditionslinie,"Salesperson Code",Ekspeditionslinie."Line No.");
                    Tilgodebevis.Modify;
                  end;
              end;
        
            /*---------------------------------------------------------------------------------------------*/
            /* DISCOUNT */
            /*---------------------------------------------------------------------------------------------*/
        
              if (Ekspeditionslinie."Discount %" = 0) and
                 (Ekspeditionslinie."Discount Type" = Ekspeditionslinie."Discount Type"::Manual) then begin
                Ekspeditionslinie."Discount Type" := Ekspeditionslinie."Discount Type"::" ";
                Ekspeditionslinie."Discount Code" := '';
              end;
        
            //-NPR5.30 [264918]
            // {---------------------------------------------------------------------------------------------}
            // { PHOTO BAG }
            // {---------------------------------------------------------------------------------------------}
            //
            // IF Ekspeditionslinie.Photobag <> '' THEN BEGIN
            //  FotoPose.Indl�sFraEksp( Ekspeditionslinie );
            // END;
            //NPR5.30 [264918]+
        
            /*---------------------------------------------------------------------------------------------*/
            /* ASSURE: ALWAYS LOCATION CODE AND DEPT. CODE ETC. IN THE AUDIT ROLL */
            /*---------------------------------------------------------------------------------------------*/
        
              if Ekspeditionslinie."Location Code" = '' then
                Ekspeditionslinie."Location Code" := Kasse."Location Code";
        
              if Ekspeditionslinie."Shortcut Dimension 1 Code" = '' then
                Ekspeditionslinie."Shortcut Dimension 1 Code" := Kasse."Global Dimension 1 Code";
        
              if Ekspeditionslinie."Shortcut Dimension 2 Code" = '' then
                Ekspeditionslinie."Shortcut Dimension 2 Code" := Kasse."Global Dimension 2 Code";
        
            /*---------------------------------------------------------------------------------------------*/
            /* MAKE AUDIT ROLL LINES */
            /*---------------------------------------------------------------------------------------------*/
        
              Revisionsrulle.Init;
        
              //-NPR5.26 [253098]
              OnValidateSaleLinePosBeforePostingEvent(Sale,Ekspeditionslinie,Revisionsrulle);
              //+NPR5.26 [253098]
        
              Revisionsrulle."Register No." := Ekspeditionslinie."Register No.";
              Revisionsrulle."Sales Ticket No." := Ekspeditionslinie."Sales Ticket No.";
              //-NPR5.31
              Revisionsrulle."POS Sale ID" := Sale."POS Sale ID";
              Revisionsrulle."Orig. POS Sale ID" := Ekspeditionslinie."Orig. POS Sale ID";
              Revisionsrulle."Orig. POS Line No." := Ekspeditionslinie."Orig. POS Line No.";
              //+NPR5.31
              Revisionsrulle."Sale Type" := Ekspeditionslinie."Sale Type";
              Revisionsrulle."Touch Screen sale" := Sale.TouchScreen;
              Revisionsrulle."External Document No." := Sale."External Document No.";
              case Ekspeditionslinie.Type of
                Ekspeditionslinie.Type::Item:
                  begin
                    /* Variant Code Check */
                    if Ekspeditionslinie."Variant Code" = '' then begin
                      ItemVariant.SetRange( "Item No.", Ekspeditionslinie."No." );
                      if ItemVariant.Find('-') then
                        Error( ErrItemVariant, Ekspeditionslinie."No." );
                    end;
                    Revisionsrulle.Type := Revisionsrulle.Type::Item;
                  end;
                Ekspeditionslinie.Type::Customer:
                  begin
                    Revisionsrulle.Type := Revisionsrulle.Type::Customer;
                  end;
                Ekspeditionslinie.Type::"G/L Entry" :
                  Revisionsrulle.Type := Revisionsrulle.Type::"G/L";
                Ekspeditionslinie.Type::"Open/Close":
                  Revisionsrulle.Type := Revisionsrulle.Type::"Open/Close";
                Ekspeditionslinie.Type::Payment:
                  begin
                    //-NPR5.42 [315194]
                    if RetailSetupGlobal."Payment Type By Register" then begin
                      if not Betalingsvalg.Get(Ekspeditionslinie."No.", Ekspeditionslinie."Register No.") then
                        Betalingsvalg.Get(Ekspeditionslinie."No.", '');
                    end else
                    //+NPR5.42
                      Betalingsvalg.Get(Ekspeditionslinie."No.");
                    if Betalingsvalg."Maximum Amount" <> 0 then begin
                      if Abs(Ekspeditionslinie."Amount Including VAT") > Betalingsvalg."Maximum Amount" then
                        Error(ErrMaxExceeded,Ekspeditionslinie."No.",Betalingsvalg."Maximum Amount");
                    end;
                    if Betalingsvalg."Minimum Amount" <> 0 then begin
                      if Abs(Ekspeditionslinie."Amount Including VAT") < Betalingsvalg."Minimum Amount" then
                        Error(ErrMinExceeded,Ekspeditionslinie."No.", Betalingsvalg."Minimum Amount");
                    end;
                    Revisionsrulle.Type := Revisionsrulle.Type::Payment;
                    if Betalingsvalg."On Sale End Codeunit" <> 0 then
                      CODEUNIT.Run(Betalingsvalg."On Sale End Codeunit",Ekspeditionslinie);
                  end;
                Ekspeditionslinie.Type::"BOM List":
                  Revisionsrulle.Type := Revisionsrulle."Sale Type"::Comment;
                //-NPR4.14
                //-NPR5.32.11 [282177]
                //Ekspeditionslinie.Type::Comment : Revisionsrulle."Sale Type" := Revisionsrulle."Sale Type"::Bem�rkning;
                Ekspeditionslinie.Type::Comment:
                  begin
                    if Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Cancelled then
                      Revisionsrulle.Type := Revisionsrulle.Type::Cancelled;
                    Revisionsrulle."Sale Type" := Revisionsrulle."Sale Type"::Comment;
                  end;
                //+NPR5.32.11 [282177]
                //+NPR4.14
              end;
        
            // >> NPK (FM) tilbagef�r debetsalg! Arv type fra tilbagef�rt bon.
              if Ekspeditionslinie."Return Sale Sales Ticket No." <> '' then begin
                if RevisionsrulleLok.Get(Ekspeditionslinie."Return Sale Register No.",Ekspeditionslinie."Return Sale Sales Ticket No.",
                                         Ekspeditionslinie."Return Sales Sales Type",Ekspeditionslinie."Return Sale Line No.",
                                         Ekspeditionslinie."Return Sale No.",Ekspeditionslinie."Return Sales Sales Date") then begin
                  Revisionsrulle.Type := RevisionsrulleLok.Type;
                end;
              end;
        
              Revisionsrulle."Line No." := Ekspeditionslinie."Line No.";
              Revisionsrulle."No." := Ekspeditionslinie."No.";
              Revisionsrulle.Lokationskode := Ekspeditionslinie."Location Code";
              Revisionsrulle."Posting Group" := Ekspeditionslinie."Posting Group";
              Revisionsrulle."Qty. Discount Code" := Ekspeditionslinie."Qty. Discount Code";
              Revisionsrulle.Description := Ekspeditionslinie.Description;
              Revisionsrulle."Description 2" := Ekspeditionslinie."Description 2";
              Revisionsrulle."Unit of Measure Code" := Ekspeditionslinie."Unit of Measure Code";
              Revisionsrulle.Quantity := Ekspeditionslinie.Quantity;
              Revisionsrulle."Invoice (Qty)" := Ekspeditionslinie."Invoice (Qty)";
              Revisionsrulle."To Ship (Qty)" := Ekspeditionslinie."To Ship (Qty)";
              Revisionsrulle."Unit Price" := Ekspeditionslinie."Unit Price";
              //-NPR5.45 [324395]
              //Revisionsrulle."Unit Cost (LCY)" := Ekspeditionslinie."Unit Price (LCY)";
              Revisionsrulle."Unit Cost (LCY)" := Ekspeditionslinie."Unit Cost (LCY)";
              //+NPR5.45 [324395]
              Revisionsrulle."VAT %" := Ekspeditionslinie."VAT %";
              Revisionsrulle."Qty. Discount %" := Ekspeditionslinie."Qty. Discount %";
        
              //-NPR5.45 [323615]
              // Revisionsrulle."Line Discount %" := Ekspeditionslinie."Discount %" * Utility.Sign(Ekspeditionslinie.Quantity);
              // Revisionsrulle."Line Discount Amount" := Ekspeditionslinie."Discount Amount" * Utility.Sign(Ekspeditionslinie.Quantity);
              Revisionsrulle."Line Discount %" := Abs (Ekspeditionslinie."Discount %") * Utility.Sign(Ekspeditionslinie.Quantity);
              Revisionsrulle."Line Discount Amount" := Abs (Ekspeditionslinie."Discount Amount") * Utility.Sign(Ekspeditionslinie.Quantity);
              //+NPR5.45 [323615]
        
              Revisionsrulle."External Document No." := Ekspeditionslinie."External Document No.";
              Revisionsrulle."Discount Type" := Ekspeditionslinie."Discount Type";
              Revisionsrulle."Discount Code" := Ekspeditionslinie."Discount Code";
              //-NPR5.39 [305139]
              Revisionsrulle."Discount Authorised by" := Ekspeditionslinie."Discount Authorised by";
              //+NPR5.39 [305139]
              Revisionsrulle."Sale Date" := Ekspeditionslinie.Date;
              Revisionsrulle.Amount := Ekspeditionslinie.Amount;
              Revisionsrulle."Amount Including VAT" := Ekspeditionslinie."Amount Including VAT";
              Revisionsrulle."Allow Invoice Discount" := Ekspeditionslinie."Allow Invoice Discount";
              Revisionsrulle."Shortcut Dimension 1 Code" := Ekspeditionslinie."Shortcut Dimension 1 Code";
              Revisionsrulle."Dimension Set ID" := Ekspeditionslinie."Dimension Set ID";
              Revisionsrulle."Price Group Code" := Ekspeditionslinie."Customer Price Group";
              Revisionsrulle."Allow Quantity Discount" := Ekspeditionslinie."Allow Quantity Discount";
              Revisionsrulle."Serial No." := Ekspeditionslinie."Serial No.";
              Revisionsrulle."Customer/Item Discount %" := Ekspeditionslinie."Customer/Item Discount %";
              Revisionsrulle."Invoice to Customer No." := Ekspeditionslinie."Invoice to Customer No.";
              Revisionsrulle."Invoice Discount Amount" := Ekspeditionslinie."Invoice Discount Amount";
              Revisionsrulle."Gen. Bus. Posting Group" := Ekspeditionslinie."Gen. Bus. Posting Group";
              Revisionsrulle."Gen. Prod. Posting Group" := Ekspeditionslinie."Gen. Prod. Posting Group";
              Revisionsrulle."VAT Bus. Posting Group" := Ekspeditionslinie."VAT Bus. Posting Group";
              Revisionsrulle."VAT Prod. Posting Group" := Ekspeditionslinie."VAT Prod. Posting Group";
              Revisionsrulle."Currency Code" := Ekspeditionslinie."Currency Code";
              Revisionsrulle."Claim (LCY)" := Ekspeditionslinie."Claim (LCY)";
              Revisionsrulle."VAT Base Amount" := Ekspeditionslinie."VAT Base Amount";
              Revisionsrulle."Unit Cost" := Ekspeditionslinie."Unit Cost";
              Revisionsrulle.Cost := Ekspeditionslinie."Unit Cost";
              Revisionsrulle."System-Created Entry" := Ekspeditionslinie."System-Created Entry";
              Revisionsrulle."Credit Card Tax Free" := Ekspeditionslinie."Credit Card Tax Free";
              Revisionsrulle."Variant Code" := Ekspeditionslinie."Variant Code";
              Revisionsrulle."Salesperson Code" := "Salesperson Code";
              //-NPR5.39 [305139]
              //Revisionsrulle."Discount Type" := Ekspeditionslinie."Discount Type";
              //Revisionsrulle."Discount Code" := Ekspeditionslinie."Discount Code";
              //+NPR5.39 [305139]
              Revisionsrulle."Period Discount code" := Ekspeditionslinie."Period Discount code";
              Revisionsrulle."Cash Terminal Approved" := Ekspeditionslinie."Cash Terminal Approved";
              Revisionsrulle."Total Qty" := Ekspeditionslinie."Sales Order Amount";
              Revisionsrulle."Starting Time" := "Start Time";
              Revisionsrulle."Closing Time" := Time;
              Revisionsrulle.Posted := false;
              Revisionsrulle.Accessory := Ekspeditionslinie.Accessory;
              Revisionsrulle."Retail Document Type" := Sale."Retail Document Type";
              Revisionsrulle."Retail Document No." := Sale."Retail Document No.";
            //-NPR4.16
            //IF (( Ekspeditionslinie.Size <> '' ) OR
            //    ( Ekspeditionslinie.Color <> '' )) AND
            //   ( NPC."Check col./size when Purchase" ) THEN
            //     BEGIN
            //       IF ( Ekspeditionslinie.Size = '' ) OR ( Ekspeditionslinie.Color = '' ) THEN
            //         ERROR( ErrFarve, Ekspeditionslinie."No." );
            //     END;
            //Revisionsrulle.Color                          := Ekspeditionslinie.Color;
            //Revisionsrulle.Size                           := Ekspeditionslinie.Size;
            //+NPR4.16
              Revisionsrulle."Customer No." := "Customer No.";
              Revisionsrulle.Cost := Ekspeditionslinie.Cost;
              Revisionsrulle."Buffer Document Type" := Ekspeditionslinie."Buffer Document Type";
              Revisionsrulle."Buffer ID" := Ekspeditionslinie."Buffer ID";
              Revisionsrulle."Buffer Invoice No." := Ekspeditionslinie."Buffer Document No.";
              Revisionsrulle."Salgspris inkl. moms" := Ekspeditionslinie."Price Includes VAT";
              Revisionsrulle."Currency Amount" := Ekspeditionslinie."Currency Amount";
              Revisionsrulle.Internal := Ekspeditionslinie.Internal;
              Revisionsrulle."Cash Customer No." := Kontankundenr;
              Revisionsrulle."Customer Type" := "Customer Type";
              Revisionsrulle."Item Group" := Ekspeditionslinie."Item Group";
              Revisionsrulle.Vendor := Ekspeditionslinie."Vendor No.";
              Revisionsrulle."Serial No. not Created" := Ekspeditionslinie."Serial No. not Created";
            //-NPR5.30 [264918]
            //Revisionsrulle.Photobag                       := Ekspeditionslinie.Photobag;
            //+NPR5.30 [264918]
              Revisionsrulle.Reference := Sale.Reference;
              //-NPR4.14
              Revisionsrulle."Sales Document Type" := Ekspeditionslinie."Sales Document Type";
              Revisionsrulle."Sales Document No." := Ekspeditionslinie."Sales Document No.";
              Revisionsrulle."Sales Document Line No." := Ekspeditionslinie."Sales Document Line No.";
              Revisionsrulle."Sales Document Prepayment" := Ekspeditionslinie."Sales Document Prepayment";
              Revisionsrulle."Sales Doc. Prepayment %" := Ekspeditionslinie."Sales Doc. Prepayment %";
              Revisionsrulle."Sales Document Invoice" := Ekspeditionslinie."Sales Document Invoice";
              Revisionsrulle."Sales Document Ship" := Ekspeditionslinie."Sales Document Ship";
              //+NPR4.14
              //-NPR5.31
              Revisionsrulle."Tax Area Code" := Ekspeditionslinie."Tax Area Code";
              Revisionsrulle."Tax Liable" := Ekspeditionslinie."Tax Liable";
              Revisionsrulle."Tax Group Code" := Ekspeditionslinie."Tax Group Code";
              Revisionsrulle."Use Tax" := Ekspeditionslinie."Use Tax";
            //+NPR5.31
        
              if bNegBon then begin
                if Revisionsrulle."Amount Including VAT" > 0 then
                  Revisionsrulle."Receipt Type" := Revisionsrulle."Receipt Type"::"Sales in negative receipt"
                else
                  Revisionsrulle."Receipt Type" := Revisionsrulle."Receipt Type"::"Negative receipt"
              end else if Ekspeditionslinie.Quantity < 0 then
                Revisionsrulle."Receipt Type" := Revisionsrulle."Receipt Type"::"Return items";
        
              Revisionsrulle."Return Reason Code" := Ekspeditionslinie."Return Reason Code";
              Revisionsrulle."Reason Code" := Ekspeditionslinie."Reason Code";
        
              //-NPR3.12o
              Revisionsrulle."Invoiz Guid" := Ekspeditionslinie."Invoiz Guid";
              //+NPR3.12o
        
              Revisionsrulle."Order No. from Web" := Ekspeditionslinie."Order No. from Web";
              Revisionsrulle."Order Line No. from Web" := Ekspeditionslinie."Order Line No. from Web";
        
              Revisionsrulle."Lock Code" := Ekspeditionslinie."Lock Code";
              Revisionsrulle."Label No." := Ekspeditionslinie."Label No.";
        
            /*---------------------------------------------------------------------------------------------*/
            /* Point Card Handling / Loyalty Handling                                                      */
            /*---------------------------------------------------------------------------------------------*/
        
            //-NPR4.02
            //IF (Revisionsrulle."Sale Type" = Revisionsrulle."Sale Type"::Betaling) AND
            //   (Betalingsvalg."Processing Type" = Betalingsvalg."Processing Type"::"Point Card") THEN
            //+NPR4.02
              //-NPR70.00.02.11
              //PointCardHandling.DebitCard(Revisionsrulle);
              //+NPR70.00.01.11
        
        
            //-TM80.1.00
            /*---------------------------------------------------------------------------------------------*/
            /* Confirm Access Tickets                                                                      */
            /*---------------------------------------------------------------------------------------------*/
              if (Revisionsrulle.Type = Revisionsrulle.Type::Item) then
                Ticketmanagement.IssueTicketsFromAuditRoll(Revisionsrulle);
            //+TM80.1.00
        
            //-MM80.1.05
            /*---------------------------------------------------------------------------------------------*/
            /* Confirm Membership                                                                          */
            /*---------------------------------------------------------------------------------------------*/
              if (Revisionsrulle.Type = Revisionsrulle.Type::Item) then
                MemberRetailIntegration.IssueMembershipFromAuditRolePosting(Revisionsrulle);
        
            //+MM80.1.05
            /*---------------------------------------------------------------------------------------------*/
            /* GIFT VOUCHER */
            /*---------------------------------------------------------------------------------------------*/
        
              if (Ekspeditionslinie."Gift Voucher Ref." <> '') and
                 (Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Deposit) then begin
                Revisionsrulle."Gift voucher ref." := Ekspeditionslinie."Gift Voucher Ref.";
                Revisionsrulle."Offline - Gift voucher ref." := Ekspeditionslinie."Gift Voucher Ref.";
                Gavekort.Get(Ekspeditionslinie."Gift Voucher Ref.");
                Gavekort.CreateFromAuditRoll(Revisionsrulle);
                //-NPR4.18
                //Gavekort.MODIFY;
                Gavekort.Modify(true);
                //+NPR4.18
              end;
              if (Ekspeditionslinie."Gift Voucher Ref." <> '') and
                 (Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Payment) then
                Revisionsrulle."Gift voucher ref." := Ekspeditionslinie."Gift Voucher Ref.";
            /*---------------------------------------------------------------------------------------------*/
            /* CREDIT VOUCHER */
            /*---------------------------------------------------------------------------------------------*/
        
              if (Ekspeditionslinie."Credit voucher ref." <> '') and
                 (Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Deposit) then begin
                Revisionsrulle."Credit voucher ref." := Ekspeditionslinie."Credit voucher ref.";
                Revisionsrulle."Offline - Credit voucher ref." := Ekspeditionslinie."Credit voucher ref.";
                Tilgodebevis.Get(Ekspeditionslinie."Credit voucher ref.");
                Tilgodebevis.CreateFromAuditRoll(Revisionsrulle);
                //-NPR5.31 [269001]
                //Tilgodebevis.MODIFY;
                Tilgodebevis.Modify(true);
                //+NPR5.31 [269001]
              end;
        
              Revisionsrulle."Wish List" := Ekspeditionslinie."Wish List";
              Revisionsrulle."Wish List Line No." := Ekspeditionslinie."Wish List Line No.";
              Revisionsrulle."Special price" := Ekspeditionslinie."Special price";
        
            /* POST CODE STATS. */
        
              if Sale."Stats - Customer Post Code" <> '' then
                Revisionsrulle."Customer Post Code" := Sale."Stats - Customer Post Code"
              else
                Revisionsrulle."Customer Post Code" := Sale."Post Code";
        
              if Kasse.Get(Revisionsrulle."Register No.") then
                if not Kasse."Connected To Server" then begin
                  Revisionsrulle.Offline := true;
                  Revisionsrulle."Offline receipt no." := Ekspeditionslinie."Sales Ticket No.";
                end;
        
            /* CANCEL GIFT VOUCHER WHEN RETURN SALES TICKET */
        
              if (Ekspeditionslinie."Return Sale Register No." <> '') then begin
                if (Ekspeditionslinie."Gift Voucher Ref." <> '') and (Ekspeditionslinie.Quantity < 0) then
                  SetGiftVoucherStatus(Ekspeditionslinie."Gift Voucher Ref.",GavekortLok.Status::Cancelled);
                if (Ekspeditionslinie."Credit voucher ref." <> '') and (Ekspeditionslinie.Quantity < 0) then
                  SetCreditVoucherStatus(Ekspeditionslinie."Credit voucher ref.",Tilgodebevis.Status::Cancelled);
              end;
        
            //-NPR4.03
              if (Revisionsrulle."Receipt Type" in
                 [Revisionsrulle."Receipt Type"::"Sales in negative receipt",
                 Revisionsrulle."Receipt Type"::"Negative receipt",
                 Revisionsrulle."Receipt Type"::"Return items"]) and
                (Ekspeditionslinie."Gift Voucher Ref." <> '' )  and
                //-NPR4.18
                (Ekspeditionslinie.Quantity < 0) then
                //+NPR4.18
                SetGiftVoucherStatus(Ekspeditionslinie."Gift Voucher Ref.",GavekortLok.Status::Cancelled);
            //+NPR4.03
        
        
              if "Salesperson Code" <> SalespersonPurchaser.Code then
                Revisionsrulle."Reversed by Salesperson Code" := SalespersonPurchaser.Code;
        
              Revisionsrulle."Reverseing Sales Ticket No." := Ekspeditionslinie."Return Sale Sales Ticket No.";
        
              Clear(RevisionsrulleLok);
              if Ekspeditionslinie."Return Sale No." <> '' then
                if RevisionsrulleLok.Get(Ekspeditionslinie."Return Sale Register No.",Ekspeditionslinie."Return Sale Sales Ticket No.",
                                         Ekspeditionslinie."Return Sales Sales Type",Ekspeditionslinie."Return Sale Line No.",
                                         Ekspeditionslinie."Return Sale No.",Ekspeditionslinie."Return Sales Sales Date") then begin
                  RevisionsrulleLok."Reversed by Sales Ticket No." := Revisionsrulle."Sales Ticket No.";
                  RevisionsrulleLok.Modify;
                end;
              Clear(RevisionsrulleLok);
        
              bGaranti := bGaranti or ((Vare."Guarantee Index" =  Vare."Guarantee Index"::"Flyt til garanti kar.") and
                                      (Ekspeditionslinie.Quantity > 0));
        
              Revisionsrulle."Fremmed nummer" := Ekspeditionslinie."Foreign No.";
        
            /*---------------------------------------------------------------------------------------------*/
            /* PAYMENT ------------------------------------------------------------------------------- */
            /*---------------------------------------------------------------------------------------------*/
        
              if Ekspeditionslinie."Sale Type" = Ekspeditionslinie."Sale Type"::Payment then begin
                //-NPR5.42
                if RetailSetupGlobal."Payment Type By Register" then begin
                  if not Betalingsvalg.Get(Ekspeditionslinie."No.", Ekspeditionslinie."Register No.") then
                    Betalingsvalg.Get(Ekspeditionslinie."No.",'');
                end else
                //+NPR5.42
                  Betalingsvalg.Get(Ekspeditionslinie."No.");
                if "Customer Type" = "Customer Type"::Ord then
                if CustomerGlobal.Get("Customer No.") then;
                if "Customer Type" = "Customer Type"::Cash then
                if KDebitor.Get("Customer No.") then;
        
              /*---------------------------------------------------------------------------------------------*/
              /* GIFT VOUCHERS ---------------------------------------------------------------------- */
              /*---------------------------------------------------------------------------------------------*/
        
                case Betalingsvalg."Processing Type" of
                  Betalingsvalg."Processing Type"::"Foreign Gift Voucher":
                    begin
        
                      /* Common company clearing */
        
                      if RetailSetupGlobal."Use I-Comm" and Betalingsvalg."Common Company Clearing" then begin
                        RecIComm.Get;
        
                        /* Company in same database clearing */
        
                        if RecIComm."Company - Clearing" <> '' then begin
                          if Ekspeditionslinie."Return Sale Sales Ticket No." = '' then begin
                            if Ekspeditionslinie."Amount Including VAT" <> FormCode.GetGCVoAmount(Ekspeditionslinie,PaymentType::Gift,true) then
                              Error(ErrFremGaveAmount);
                            RetailTableCode.GiftVoucherCommonValidate(Sale,Ekspeditionslinie."Foreign No.",Gavekort.Status::Cashed);
                          end else begin
                            if Ekspeditionslinie."Amount Including VAT" <> -FormCode.GetGCVoAmount(Ekspeditionslinie,PaymentType::Gift,true) then
                              Error(ErrFremGaveAmount);
                            RetailTableCode.GiftVoucherCommonValidate(Sale,Ekspeditionslinie."Foreign No.",Gavekort.Status::Open);
                          end;
                        end;
        
                        /* Company in another SQL clearing */
                        if RecIComm."Clearing - SQL" then begin
                          if (RecIComm."Company - Clearing" <> '') and Ekspeditionslinie.TestOnServer then begin
                            if CuIComm.TestForeignGiftVoucher(Ekspeditionslinie."Foreign No.") <> Ekspeditionslinie."Amount Including VAT" then
                              Error(ErrFremGaveAmount)
                            else begin
                              Clear(Gavekort);
                              Gavekort."No." := Ekspeditionslinie."Foreign No.";
                              Gavekort.Status := Gavekort.Status::Cashed;
                              CuIComm.DBGiftVoucher(Gavekort,false,true,true,TempAmount);
                            end;
                          end;
                        end;
                      end;
        
                      Clear(Gavekort);
                      Gavekort.Init;
                      Gavekort."Register No." := "Register No.";
                      Gavekort."Sales Ticket No." := "Sales Ticket No.";
                      Gavekort."External Gift Voucher" := true;
                      Gavekort."External No." := Ekspeditionslinie."Foreign No.";
                      Gavekort.Insert(true);
                      Gavekort."Issue Date" := Today;
                      Gavekort.Salesperson := "Salesperson Code";
                      Gavekort."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                      Gavekort."Location Code" := "Location Code";
                      Gavekort.Status := Gavekort.Status::Cashed;
                      Gavekort.Amount := Ekspeditionslinie."Amount Including VAT";
                      Gavekort."Cashed on Register No." := "Register No.";
                      Gavekort."Cashed on Sales Ticket No." := "Sales Ticket No.";
                      Gavekort."Cashed Date" := Today;
                      Gavekort."Cashed Salesperson" := "Salesperson Code";
                      Gavekort."Cashed in Global Dim 1 Code" := "Shortcut Dimension 1 Code";
                      Gavekort."Cashed in Location Code" := "Location Code";
                      Gavekort."Last Date Modified" := Today;
                      Gavekort.Reference := Ekspeditionslinie.Reference;
                      Gavekort."Customer Type" := "Customer Type";
                      Gavekort."Customer No." := "Customer No.";
        
                      //-NPR5.38 [266220]
                      Gavekort."Currency Code" := Ekspeditionslinie."Currency Code";
                      if Gavekort."Currency Code" = '' then begin
                        GLSetup.Get;
                        Gavekort."Currency Code" := GLSetup."LCY Code";
                      end;
                      //+NPR5.38 [266220]
        
                      RecIComm.Get;
        
                  /* Who is the customer (shop) for this clearing */
        
                      if (RecIComm."Company - Clearing" <> '') then begin
                        Gavekort."Customer No." := CuIComm.GetStore(Ekspeditionslinie."Foreign No.",true);
                      end;
        
                      Gavekort.Modify(true);
                    end;
        
                /*---------------------------------------------------------------------------------------------*/
                /* CREDIT VOUCHERS ------------------------------------------------------------------------------- */
                /*---------------------------------------------------------------------------------------------*/
        
                  Betalingsvalg."Processing Type"::"Foreign Credit Voucher":
                    begin
                      if RetailSetupGlobal."Use I-Comm" and Betalingsvalg."Common Company Clearing" then begin
                        RecIComm.Get;
        
                        /* Company in same database clearing */
        
                        if RecIComm."Company - Clearing" <> '' then begin
                          if Ekspeditionslinie."Return Sale Sales Ticket No." = '' then begin
                            if Ekspeditionslinie."Amount Including VAT" <> FormCode.GetGCVoAmount(Ekspeditionslinie,PaymentType::Credit,true) then
                              Error(ErrFremGaveAmount);
                            RetailTableCode.CreditVoucherCommonValidate(Sale,Ekspeditionslinie."Foreign No.",Tilgodebevis.Status::Cashed);
                          end else begin
                            if Ekspeditionslinie."Amount Including VAT" <> -FormCode.GetGCVoAmount(Ekspeditionslinie,PaymentType::Credit,true) then
                              Error(ErrFremGaveAmount);
                            RetailTableCode.CreditVoucherCommonValidate(Sale,Ekspeditionslinie."Foreign No.",Tilgodebevis.Status::Open);
                          end;
                        end;
        
                    /*---------------------------------------------------------------------------------------------*/
                    /* SQL Company clearing */
                    /*---------------------------------------------------------------------------------------------*/
        
                        if RecIComm."Clearing - SQL" then begin
                          if (RecIComm."Company - Clearing" <> '') then begin
                            if CuIComm.TestForeignCreditVoucher(Ekspeditionslinie."Foreign No.") <> Ekspeditionslinie."Amount Including VAT" then
                              Error(ErrFremTilAmount)
                            else begin
                              Clear(Tilgodebevis);
                              Tilgodebevis."No." := Ekspeditionslinie."Foreign No.";
                              Tilgodebevis.Status := Tilgodebevis.Status::Cashed;
                              CuIComm.DBCreditVoucher(Tilgodebevis,false,true,true,TempAmount);
                            end;
                          end;
                        end;
                      end;
                      Clear(Tilgodebevis);
                      Tilgodebevis.Init;
                      Tilgodebevis."Register No." := "Register No.";
                      Tilgodebevis."Sales Ticket No." := "Sales Ticket No.";
                      Tilgodebevis."External Credit Voucher" := true;
                      Tilgodebevis."External no" := Ekspeditionslinie."Foreign No.";
                      Tilgodebevis.Insert( true );
                      Tilgodebevis."Issue Date" := Today;
                      Tilgodebevis.Salesperson := "Salesperson Code";
                      Tilgodebevis."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                      Tilgodebevis."Location Code" := "Location Code";
                      Tilgodebevis.Status := Tilgodebevis.Status::Cashed;
                      Tilgodebevis.Amount := Ekspeditionslinie."Amount Including VAT";
                      Tilgodebevis."Cashed on Register No." := "Register No.";
                      Tilgodebevis."Cashed on Sales Ticket No." := "Sales Ticket No.";
                      Tilgodebevis."Cashed Date" := Today;
                      Tilgodebevis."Cashed Salesperson" := "Salesperson Code";
                      Tilgodebevis."Cashed in Global Dim 1 Code" := "Shortcut Dimension 1 Code";
                      Tilgodebevis."Cashed in Location Code" := "Location Code";
                      Tilgodebevis."Last Date Modified" := Today;
                      Tilgodebevis.Reference := Ekspeditionslinie.Reference;
                      Tilgodebevis."Customer Type" := "Customer Type";
                      Tilgodebevis."Customer No" := "Customer No.";
                      //-NPR5.38 [266220]
                      Tilgodebevis."Currency Code" := Ekspeditionslinie."Currency Code";
                      if Tilgodebevis."Currency Code" = '' then begin
                        GLSetup.Get;
                        Tilgodebevis."Currency Code" := GLSetup."LCY Code";
                      end;
                      //+NPR5.38 [266220]
                      RecIComm.Get;
                      if (RecIComm."Company - Clearing" <> '') then begin
                        Tilgodebevis."Customer No" := CuIComm.GetStore( Ekspeditionslinie."Foreign No.", false );
                      end;
                      Tilgodebevis.Modify;
                    end;
                end;
              end;
        
              MoveSalesLineDim2AuditRoll(Ekspeditionslinie,Revisionsrulle);
              Revisionsrulle."Offline receipt no." := Sale."Sales Ticket No.";
        
            //-NPR5.26 [253098]
              OnBeforeAuditRoleLineInsertEvent (Sale, Ekspeditionslinie, Revisionsrulle);
            //+NPR5.26 [253098]
              //-NPR5.38 [302761]
              if not RetailSetupGlobal."Create POS Entries Only" then
              //+NPR5.38 [302761]
                Revisionsrulle.Insert(true);
              if Ekspeditionslinie."Rep. Nummer" <> '' then begin
                RepListe.Get( Ekspeditionslinie."Rep. Nummer" );
                RepListe.TransferFromAuditRoll( Revisionsrulle );
                RepListe.Modify;
                RepText := StrSubstNo( t001, Ekspeditionslinie."Rep. Nummer" );
                InsertAuditRollComment( Sale, RepText, Ekspeditionslinie."Line No." );
              end;
              LineNo := Ekspeditionslinie."Line No.";
            until Ekspeditionslinie.Next = 0;
          end else
            Error(Text10600038);
        
        /*---------------------------------------------------------------------------------------------*/
        /* COMMENTS SALE > AUDIT ROLL----------------------------------------------------------------- */
        /*---------------------------------------------------------------------------------------------*/
        
          FromComment.SetRange("Table ID",6014405);
          FromComment.SetRange("No.",Sale."Register No.");
          FromComment.SetRange("No. 2",Sale."Sales Ticket No.");
          ToComment.SetRange("Table ID",6014407);
          ToComment.SetRange("No.",Sale."Register No.");
          ToComment.SetRange("No. 2",Sale."Sales Ticket No.");
          ToComment.Copylines(FromComment);
        
        /*---------------------------------------------------------------------------------------------*/
        /* WARRANTY AND INSURRANCE --------------------------------------------------------------------- */
        /*---------------------------------------------------------------------------------------------*/
        
          if bGaranti then begin
            if RetailSetupGlobal."Use I-Comm" then
              if RetailContractMgt.CheckInsurance(Sale) then begin
                if ("Customer No." = '') and ("Eks. Linie".Quantity > 0) then
                  Error(ErrNoCustForWarranty);
                RetailContractMgt.PosSaleToWarranty(Sale);
              end;
          end;
        
        /*---------------------------------------------------------------------------------------------*/
        /* Cash retail documents ----------------------------------------------------------------------*/
        /*---------------------------------------------------------------------------------------------*/
        //-MultiSelection
          MSPOSSaleLine.SetRange("Register No.",Sale."Register No.");
          MSPOSSaleLine.SetRange("Sales Ticket No.",Sale."Sales Ticket No.");
          if MSPOSSaleLine.Find('-') then
            repeat
              "Retail Document Handling".CashRetailDocument(MSPOSSaleLine."Retail Document Type",MSPOSSaleLine."Retail Document No.");
            until MSPOSSaleLine.Next = 0;
        //+MultiSelection
        
        
          if RetailSetupGlobal."Use I-Comm" then
            RetailContractMgt.PrintInsurance(Sale."Register No.",Sale."Sales Ticket No.",false);
        
          /*---------------------------------------------------------------------------------------------*/
          /* OPEN PAYMENTS CANCEL SALE: GIFT VOUCHER AND CREDIT VOUCHER --------------------------------- */
          /*---------------------------------------------------------------------------------------------*/
        
          if (Ekspeditionslinie."Return Sale Register No." <> '') then begin
            RevisionsrulleLok.SetRange("Register No.",Ekspeditionslinie."Return Sale Register No.");
            RevisionsrulleLok.SetRange("Sales Ticket No.",Ekspeditionslinie."Return Sale Sales Ticket No.");
            RevisionsrulleLok.SetRange("Sale Date",Ekspeditionslinie."Return Sales Sales Date");
            RevisionsrulleLok.SetRange("Sale Type",RevisionsrulleLok."Sale Type"::Payment);
            BetalingsvalgLok.SetRange(Status,BetalingsvalgLok.Status::Active);
            if RevisionsrulleLok.Find('-') then
              repeat
                BetalingsvalgLok.SetRange("No.",RevisionsrulleLok."No.");
                if BetalingsvalgLok.Find('-') then begin
                  case BetalingsvalgLok."Processing Type" of
                    BetalingsvalgLok."Processing Type"::"Credit Voucher":
                      begin
                        TilgodebevisLok.SetRange("Cashed on Register No.",RevisionsrulleLok."Register No.");
                        TilgodebevisLok.SetRange("Cashed on Sales Ticket No.",RevisionsrulleLok."Sales Ticket No.");
                        TilgodebevisLok.SetRange(Amount,RevisionsrulleLok."Amount Including VAT");
                        TilgodebevisLok.SetRange(Status,TilgodebevisLok.Status::Cashed);
                        if TilgodebevisLok.Find('-') then begin
                          TilgodebevisLok.TestField(Status,TilgodebevisLok.Status::Cashed);
                          TilgodebevisLok.Validate(Status,TilgodebevisLok.Status::Open);
                          TilgodebevisLok.Validate("Cashed on Register No.",'');
                          TilgodebevisLok.Validate("Cashed on Sales Ticket No.",'');
                          TilgodebevisLok.Validate("Cashed Date",0D);
                          TilgodebevisLok.Validate("Cashed Salesperson",'');
                          TilgodebevisLok.Validate("Cashed in Global Dim 1 Code",'');
                          TilgodebevisLok.Validate("Cashed in Location Code",'');
                          TilgodebevisLok.Validate("Cashed External",false);
                          TilgodebevisLok.Modify(true);
                        end;
                      end;
                    BetalingsvalgLok."Processing Type"::"Gift Voucher":
                      begin
                        GavekortLok.SetRange("Cashed on Register No.",RevisionsrulleLok."Register No.");
                        GavekortLok.SetRange("Cashed on Sales Ticket No.",RevisionsrulleLok."Sales Ticket No.");
                        GavekortLok.SetRange(Amount,RevisionsrulleLok."Amount Including VAT");
                        GavekortLok.SetRange(Status,TilgodebevisLok.Status::Cashed);
                        if GavekortLok.Find('-') then begin
                          GavekortLok.TestField(Status,TilgodebevisLok.Status::Cashed);
                          GavekortLok.Validate(Status,GavekortLok.Status::Open);
                          GavekortLok.Validate("Cashed on Register No.",'');
                          GavekortLok.Validate("Cashed on Sales Ticket No.",'');
                          GavekortLok.Validate("Cashed Date",0D);
                          GavekortLok.Validate("Cashed Salesperson",'');
                          GavekortLok.Validate("Cashed in Global Dim 1 Code",'');
                          GavekortLok.Validate("Cashed in Location Code",'');
                          GavekortLok.Validate("Cashed External",false);
                          GavekortLok.Modify(true);
                        end;
                      end;
                  end;
                end;
              until RevisionsrulleLok.Next = 0;
          end;
        
        //-NPR5.26
        /*---------------------------------------------------------------------------------------------*/
        /* POS Info------------------------------------------------------------------------------- */
        /*---------------------------------------------------------------------------------------------*/
          POSInfoManagement.PostPOSInfo(Sale);
        //+NPR5.26
        
        
        // << "�ben" betalingsgavekort...
        
        /*---------------------------------------------------------------------------------------------*/
        /* MONEY IN RETURN TO THE CUSTOMER ------------------------------------------------------------- */
        /*---------------------------------------------------------------------------------------------*/
        
          if AfslKontrol <> 0 then begin
            Decimal := 0; Afrunding := 0;
            Revisionsrulle.Init;
            Revisionsrulle."Register No."                 := Ekspeditionslinie."Register No.";
            Revisionsrulle."Sales Ticket No."             := Ekspeditionslinie."Sales Ticket No.";
            LineNo := LineNo + 10000;
            Revisionsrulle."Sale Type"                    := Revisionsrulle."Sale Type"::Payment;
            Revisionsrulle."Sale Date"                    := Date;
            Revisionsrulle.Lokationskode                  := Kasse."Location Code";
            Revisionsrulle."Shortcut Dimension 1 Code"    := Kasse."Global Dimension 1 Code";
            Revisionsrulle."Shortcut Dimension 2 Code"    := Kasse."Global Dimension 2 Code";
            Revisionsrulle."Closing Time"                 := Time;
            Revisionsrulle."Retail Document Type"         := Sale."Retail Document Type";
            Revisionsrulle."Retail Document No."          := Sale."Retail Document No.";
            Revisionsrulle.Reference                      := Sale.Reference;
        
            if bNegBon then
              Revisionsrulle."Receipt Type"                      := Revisionsrulle."Receipt Type"::"Negative receipt";
        
            Kasse.Get( "Register No." );
            Betalingsvalg.Reset;
            Betalingsvalg.SetRange("Processing Type",Betalingsvalg."Processing Type"::Cash);
            Betalingsvalg.SetRange(Status,Betalingsvalg.Status::Active);
            if RetailSetupGlobal."Payment Type By Register" then
              Betalingsvalg.SetRange("Register No.","Register No.");
            Betalingsvalg.SetRange("No.",Kasse."Return Payment Type");
            if Betalingsvalg.Find('-') then
              Revisionsrulle."No." := Betalingsvalg."No."
            else
              Error(Text10600039);
        
            MoveSaleDim2AuditRoll(Sale,Revisionsrulle);
        
            //OHM
            // �reafrunding og byttepenge.
            Kasse.TestField(Rounding);
            if (Kasse.Rounding <> '') and (RetailSetupGlobal."Amount Rounding Precision" > 0) then begin
              Afrunding := AfslKontrol - Round(AfslKontrol,RetailSetupGlobal."Amount Rounding Precision",'=');
              if (Afrunding <> 0) then begin
                LineNo += 10000;
                Finans.Get(Kasse.Rounding);
                Revisionsrulle."Amount Including VAT" := AfslKontrol - Afrunding;
                InsertReturnAmountRounding(Sale,Afrunding,Finans,IsRounding,bNegBon,LineNo);
              end;
            end;
            if (Round(AfslKontrol,RetailSetupGlobal."Amount Rounding Precision",'=') <> 0) then begin
              if Revisionsrulle."Amount Including VAT" = 0 then
                Revisionsrulle."Amount Including VAT" := AfslKontrol;
              if not bNegBon then begin
                if Art = Ekspeditionslinie."Sale Type"::"Out payment" then begin
                  Revisionsrulle.Description := txtPayout;
                  Revisionsrulle."Receipt Type" := Revisionsrulle."Receipt Type"::Outpayment;
                end else begin
                  Revisionsrulle.Description := Text10600040;
                  Revisionsrulle."Receipt Type" := Revisionsrulle."Receipt Type"::"Change money";
                end;
              end else begin
                Revisionsrulle.Description := Text10600040;
                Revisionsrulle."Receipt Type" := Revisionsrulle."Receipt Type"::"Negative receipt";
              end;
              Revisionsrulle."Line No."         := LineNo;
              Revisionsrulle."Salesperson Code" := "Salesperson Code";
              Revisionsrulle.Type := Revisionsrulle.Type::Payment;
              Revisionsrulle.Offline := not Kasse."Connected To Server";
              Revisionsrulle."Offline receipt no." := Sale."Sales Ticket No.";
              //-NPR5.38 [302761]
              if not RetailSetupGlobal."Create POS Entries Only" then
              //+NPR5.38 [302761]
                Revisionsrulle.Insert(true);                        //afslutekspedition
              Retur := -Revisionsrulle."Amount Including VAT";
            end else
              Retur := 0;
          end;
        
        /*---------------------------------------------------------------------------------------------*/
        /* CONTRACTS --------------------------------------------------------------------------------- */
        /*---------------------------------------------------------------------------------------------*/
          //-NPR5.50 [347875]
          SaleLinePOS.SetRange("Register No.","Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Comment);
          SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::Cancelled);
          if SaleLinePOS.IsEmpty then
          //+NPR5.50 [347875]
          Udlejning.CashFromSale( Sale );
        
          if Sale."Retail Document No." <> '' then begin
            LineNo += 10000;
            Revisionsrulle.Init;
            Revisionsrulle."Register No."           := Sale."Register No.";
            Revisionsrulle."Sales Ticket No."       := Sale."Sales Ticket No.";
            Revisionsrulle."Sale Type"              := Revisionsrulle."Sale Type"::Comment;
            Revisionsrulle."Line No."               := LineNo;
            //-254066 [254066]
             Revisionsrulle."Salesperson Code"      := Sale."Salesperson Code";
            //+254066 [254066]
            Revisionsrulle."No."                    := Format(Sale."Retail Document Type");
            Revisionsrulle."Sale Date"              := Today;
            Revisionsrulle.Description              := StrSubstNo( txtRevComment,
                                                       Sale."Retail Document Type", Sale."Customer No.", Sale."Retail Document No.");
            Revisionsrulle."Allocated No."          := Sale."Retail Document No.";
            Revisionsrulle.Type                     := Revisionsrulle.Type::"Debit Sale";
            Revisionsrulle.Lokationskode            := Kasse."Location Code";
            Revisionsrulle."Shortcut Dimension 1 Code" := Kasse."Global Dimension 1 Code";
            Revisionsrulle."Shortcut Dimension 2 Code" := Kasse."Global Dimension 2 Code";
            Revisionsrulle.Posted                   := true;
            Revisionsrulle."Closing Time"           := Time;
            Revisionsrulle."Retail Document Type"   := Sale."Retail Document Type";
            Revisionsrulle."Retail Document No."    := Sale."Retail Document No.";
            Revisionsrulle."Customer No."           := Sale."Customer No.";
            //-NPR5.38 [302761]
            if not RetailSetupGlobal."Create POS Entries Only" then
            //+NPR5.38 [302761]
              Revisionsrulle.Insert(true);
          end;
        
        /*---------------------------------------------------------------------------------------------*/
        /* RETURN SALE COMMENT ------------------------------------------------------------------------- */
        /*---------------------------------------------------------------------------------------------*/
        
          if "Sale type" = "Sale type"::Annullment then begin
            Revisionsrulle.Init;
            LineNo += 10000;
            //ohm- 02/01/06
            Revisionsrulle."Register No."     := Sale."Register No.";
            Revisionsrulle."Sales Ticket No." := Sale."Sales Ticket No.";
            //ohm+
            Revisionsrulle."Line No."         := LineNo;
            Revisionsrulle."Sale Type"        := Revisionsrulle."Sale Type"::Comment;
            Revisionsrulle."Closing Time"     := Time;
            Revisionsrulle."No." := '*';
            Revisionsrulle.Description := StrSubstNo(Text10600078,Ekspeditionslinie."Return Sale Sales Ticket No.");
            Revisionsrulle."Reverseing Sales Ticket No."  := Ekspeditionslinie."Return Sale Sales Ticket No.";
            Revisionsrulle."Offline receipt no."          := Sale."Sales Ticket No.";
            Revisionsrulle."Retail Document Type"         := Sale."Retail Document Type";
            Revisionsrulle."Retail Document No."          := Sale."Retail Document No.";
            Revisionsrulle.Reference                      := Sale.Reference;
            //-NPR5.38 [302761]
            if not RetailSetupGlobal."Create POS Entries Only" then
            //+NPR5.38 [302761]
              Revisionsrulle.Insert(true);
          end;
        
          if RetailSetupGlobal."Global Sale POS" then begin
            InsertGlobalSalePOS(Sale);
            ModifyGlobalSalePOSAudit(Sale);
          end;
        
        //-NPR5.33 [262628]
        //Insert of POS Entry
          NPRetailSetup.Get;
          if NPRetailSetup."Advanced POS Entries Activated" then begin
            //-NPR5.36 [279552]
            CODEUNIT.Run(CODEUNIT::"POS Create Entry",Sale);
            //+NPR5.36 [279552]
          end;
          //+NPR5.33 [262628]
        
          Ekspeditionslinie.DeleteAll;
          DeleteDimOnEkspAndLines;
          SaleCopy := Sale;
        
          if Delete then;
        
        /*----------------------------------------------*/
        /* Clean Sales Order If From Sales Header ------*/
        /*----------------------------------------------*/
        
          if SalesHeader.Get(SalesHeader2."Document Type",SalesHeader2."No.") then
            SalesHeader.Delete(true);
        
          InsertNaviDocsEntry(Revisionsrulle);
        
          Commit;
        
        // Handle non crucial processing such as print and posting.
        // All post processing should be put in this codeunit as the code
        // in this state is inconsistent due to the commit above.
          //-NPR5.39 [302779]
          //IF CODEUNIT.RUN(CODEUNIT::"POS End Sale Post Processing", SaleCopy) THEN;
          Sale := SaleCopy;
          //+NPR5.39 [302779]
        end;

    end;

    procedure GetRegisterFromAltNo(Input1: Code[50]): Code[20]
    var
        Alt: Record "Alternative No.";
    begin
        //getRegisterFromAltNo

        Alt.SetCurrentKey("Alt. No.", Type);
        Alt.SetRange("Alt. No.", Input1);
        Alt.SetRange(Type, Alt.Type::Register);
        if Alt.Find('-') then
          exit(Alt.Code)
        else
          exit('');
    end;

    procedure GetLastSalesTicketNumber(Kassenummer: Code[20]): Code[20]
    var
        Kasse: Record Register;
        NrSerie: Codeunit NoSeriesManagement;
        NrSerieLinie: Record "No. Series Line";
    begin
        //HentSidsteBonnummer()

        Kasse.Get( Kassenummer );
        NrSerie.SetNoSeriesLineFilter( NrSerieLinie, Kasse."Sales Ticket Series", 0D );
        NrSerieLinie.Find('-');
        exit( NrSerieLinie."Last No. Used" );
    end;

    [Scope('Personalization')]
    procedure FetchRegisterNumber(): Code[10]
    var
        Register: Record Register;
        UserSetup: Record "User Setup";
        EnvironmentMgt: Codeunit "NPR Environment Mgt.";
        RegisterNo: Code[10];
        SystemSetupFile: File;
        Decimal: Decimal;
        Text10600055: Label 'Error in settings, NPK-initialisation file is missing! Contact your Navision Solution Center';
        Text10600056: Label 'Error in register settings, NPK settings file is defect! Contact your Navision Solution Center';
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSetup: Codeunit "POS Setup";
    begin
        //-NPR5.44 [321816]
        if POSSession.IsActiveSession(POSFrontEnd) then begin
          POSFrontEnd.GetSession(POSSession);
          POSSession.GetSetup(POSSetup);
          exit(POSSetup.Register());
        end;
        //+NPR5.44 [321816]

        if not RetailSetupGlobal.Get then
          exit('?');

        case RetailSetupGlobal."Get register no. using" of
          RetailSetupGlobal."Get register no. using"::USERPROFILE:
            begin
              SystemSetupFile.TextMode(true);
              if RetailSetupGlobal."Use WIN User Profile" then begin
                if SystemSetupFile.Open(EnvironmentMgt.ClientEnvironment(Format(RetailSetupGlobal."Get register no. using")) + '\NPK.DLL') then begin
                  SystemSetupFile.Read(Decimal);
                  SystemSetupFile.Close;
                end else begin
                  Message(Text10600055);
                  //IF PAGE.RUNMODAL(PAGE::"Register List", register) = ACTION::LookupOK THEN BEGIN
                  //  register.setThisRegisterNo(register."Register No.");
                  //  COMMIT;
                  //  EXIT(register."Register No.");
                  //END ELSE
                    exit('?');
                end;
              end else begin
                if SystemSetupFile.Open(RetailSetupGlobal."Path Filename to User Profile") then begin
                  SystemSetupFile.Read(Decimal);
                  SystemSetupFile.Close;
                end else begin
                  Message(Text10600055);
                  //IF PAGE.RUNMODAL(PAGE::"Register List", register) = ACTION::LookupOK THEN BEGIN
                  //  COMMIT;
                  //  register.setThisRegisterNo(register."Register No.");
                  //  EXIT(register."Register No.");
                  //END ELSE
                    exit('?');
                end;
              end;
              RegisterNo := StrSubstNo('%1',(Decimal/3.5 + 2));
              if RegisterNo <> '0' then
                exit(RegisterNo)
              else begin
                Message(Text10600056);
                exit('?');
              end;
            end;
          RetailSetupGlobal."Get register no. using"::COMPUTERNAME,
          RetailSetupGlobal."Get register no. using"::CLIENTNAME,
          RetailSetupGlobal."Get register no. using"::SESSIONNAME,
          RetailSetupGlobal."Get register no. using"::USERNAME,
          RetailSetupGlobal."Get register no. using"::USERID:
            begin
              Register.Reset;
              Register.SetCurrentKey("Logon-User Name");
              Register.SetRange("Logon-User Name",EnvironmentMgt.ClientEnvironment(Format(RetailSetupGlobal."Get register no. using")));
              if Register.Find('-') then
                exit(Register."Register No.")
              else
                //IF PAGE.RUNMODAL(PAGE::"Register List", register) = ACTION::LookupOK THEN BEGIN
                //  register.setThisRegisterNo(register."Register No.");
                //  COMMIT;
                //  EXIT(register."Register No.");
                //END ELSE
                  exit('?');
            end;
          RetailSetupGlobal."Get register no. using"::USERDOMAINID:
            exit('?');
          RetailSetupGlobal."Get register no. using"::"USER SETUP TABLE":
            begin
              if not UserSetup.Get(UserId) then begin
                //IF PAGE.RUNMODAL(PAGE::"Register List", register) = ACTION::LookupOK THEN BEGIN
                //  register.setThisRegisterNo(register."Register No.");
                //  COMMIT;
                //  EXIT(register."Register No.");
                //END ELSE
                  exit('?');
              end;
              exit(UserSetup."Backoffice Register No.");
            end;
        end;
    end;

    procedure FetchSalesTicketNumber(Kassenummer: Code[10]) Bonnummer: Code[20]
    var
        Kasse: Record Register;
        NrSerieStyring: Codeunit NoSeriesManagement;
        "Audit Roll": Record "Audit Roll";
        t002: Label 'Then receipt numbers are more than 2.100.000.000! Contact your solution center.';
        t003: Label 'The sales ticket no. is allready existing in the audit roll. Contact your solution center!';
    begin
        //HentBonnummer()
        
        Kasse.Get( Kassenummer );
        Kasse.TestField( "Sales Ticket Series" );
        
        //d.OPEN(t001 + '#1####################');
        
        //REPEAT
          /*
          NrSerieStyring.InitSeries( Kasse."Sales Ticket Series",
                                     Kasse."Sales Ticket Series",
                                     TODAY,
                                     Bonnummer,
                                     Kasse."Sales Ticket Series");
          */
        
          Bonnummer := NrSerieStyring.GetNextNo(Kasse."Sales Ticket Series",Today, true);
          Commit;
          //d.UPDATE(1, Bonnummer);
        
          /* Check Audit Roll */
          "Audit Roll".Reset;
          "Audit Roll".SetRange("Register No.", Kassenummer);
          //-NPR5.22 - ticket 70019 is not "lower" than 9999
          //"Audit Roll".SETFILTER("Sales Ticket No.", '>=%1', Bonnummer);
          "Audit Roll".SetRange("Sales Ticket No.", Bonnummer);
          //+NPR5.22
          if not "Audit Roll".Find('-') then begin
            //d.CLOSE;
            exit(Bonnummer);
          end else
            Error(t003);
        //UNTIL Bonnummer = '2100000000';
        
        Error(t002);
        
        //d.CLOSE;

    end;

    procedure ForeignCurrency(var EkspLinie: Record "Sale Line POS")
    var
        Betaling: Record "Payment Type POS";
    begin
        //FremValuta
        with EkspLinie do begin
          Betaling.Get( "No." );

          if Betaling."Fixed Rate" = 0 then
            "Currency Amount" := "Amount Including VAT"
          else
            "Currency Amount" := "Amount Including VAT" / ( Betaling."Fixed Rate" / 100 );

          if "Currency Amount" < 0 then
            "Currency Amount" := 0;

          if UsingTS then
            "Currency Amount" := ValueforTS;

          if Betaling."Fixed Rate" <> 0 then
            Validate( "Amount Including VAT", Round( "Currency Amount" * Betaling."Fixed Rate" / 100, 0.01, '=' ));
        end;
    end;

    procedure InitTS(useTS: Boolean;valueTS: Decimal)
    begin
        //initTS
        UsingTS := useTS;
        ValueforTS := valueTS;
    end;

    procedure InsertAuditRollComment(var SalePOS: Record "Sale POS";Description: Text[50];var i: Integer)
    var
        AuditRoll: Record "Audit Roll";
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
    begin
        //Inds�tRevRulleBem�rkning()
        //-NPR5.38 [302761]
        RetailSetup.Get;
        if RetailSetup."Create POS Entries Only" then
          exit;
        //+NPR5.38 [302761]
        with SalePOS do begin
          i += 1;
          AuditRoll.Init;
          AuditRoll."Register No." := "Register No.";
          AuditRoll."Sales Ticket No." := "Sales Ticket No.";
          AuditRoll."Sale Date" := Date;
          AuditRoll."Line No." := i;
          AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
          AuditRoll.Type := AuditRoll.Type::Comment;
          AuditRoll."Salesperson Code" := "Salesperson Code";
          AuditRoll."No." := '';
          AuditRoll.Description := Description;
          AuditRoll."Starting Time" := "Start Time";
          AuditRoll."Closing Time" := Time;
          AuditRoll.Posted := true;

          if Register.Get("Register No.") then
            AuditRoll.Offline := not Register."Connected To Server";

          AuditRoll."Offline receipt no." := SalePOS."Sales Ticket No.";
          AuditRoll.Insert(true);
        end;
    end;

    procedure InsertReturnAmountRounding(var SalePOS: Record "Sale POS";var RoundingAmount: Decimal;var GLAccount: Record "G/L Account";IsRounding: Boolean;IsNegativeSalesTicket: Boolean;AuditRollLineNo: Integer)
    var
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
        RetailSetup: Record "Retail Setup";
    begin
        //-NPR5.38 [302761]
        RetailSetup.Get;
        if RetailSetup."Create POS Entries Only" then
          exit;
        //+NPR5.38 [302761]
        //inds�treturbel�bafrunding
        with SalePOS do begin
          if IsRounding then begin
            Register.Get("Register No.");

            AuditRoll.Init;
            AuditRoll."Register No." := "Register No.";
            AuditRoll."Sales Ticket No." := "Sales Ticket No.";
            AuditRoll.Lokationskode := Register."Location Code";
            AuditRoll."Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
            AuditRoll."Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
            AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Out payment";
            AuditRoll."Sale Date" := Date;
            AuditRoll."Line No." := AuditRollLineNo;
            AuditRoll."No." := GLAccount."No.";
            AuditRoll.Description := GLAccount.Name;
            AuditRoll.Type := AuditRoll.Type::"G/L";
            //-NPR5.37.03 [296642]
            AuditRoll."Discount Type" := AuditRoll."Discount Type"::Rounding;
            AuditRoll."Starting Time" := SalePOS."Start Time";
            AuditRoll."Closing Time" := Time;
            //+NPR5.37.03 [296642]
            AuditRoll."Amount Including VAT" := RoundingAmount;
            if IsNegativeSalesTicket then begin
              AuditRoll."Receipt Type" := AuditRoll."Receipt Type"::"Negative receipt";
            end;
            MoveSaleDim2AuditRoll(SalePOS,AuditRoll);
            AuditRoll.Insert(true);
          end;
        end;
    end;

    procedure InsertNaviDocsEntry(AuditRoll: Record "Audit Roll")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(AuditRoll);
        //ERROR('Missing stub!');
        /*
        IF "Customer E-mail" <> '' THEN
          NaviDocsMgt.SetEmailAddress("Customer E-mail");
        NaviDocsMgt.AddEntry(RecRef,2);
        RecRef.CLOSE;
        "Customer E-mail" := '';*/

    end;

    procedure MoveSaleDim2AuditRoll(var EkspeditionLoc: Record "Sale POS";var RevisionsrulleLoc: Record "Audit Roll")
    begin
        //MoveEkspDim2Revrulle
        RevisionsrulleLoc."Shortcut Dimension 1 Code" := EkspeditionLoc."Shortcut Dimension 1 Code";
        RevisionsrulleLoc."Shortcut Dimension 2 Code" := EkspeditionLoc."Shortcut Dimension 2 Code";
        RevisionsrulleLoc."Dimension Set ID"          := EkspeditionLoc."Dimension Set ID";
    end;

    procedure MoveSalesLineDim2AuditRoll(var EkspeditionLinieLoc: Record "Sale Line POS";var RevisionsrulleLoc: Record "Audit Roll")
    begin
        //MoveEkspLineDim2Revrulle
        RevisionsrulleLoc."Shortcut Dimension 1 Code" := EkspeditionLinieLoc."Shortcut Dimension 1 Code";
        RevisionsrulleLoc."Shortcut Dimension 2 Code" := EkspeditionLinieLoc."Shortcut Dimension 2 Code";
        RevisionsrulleLoc."Dimension Set ID"          := EkspeditionLinieLoc."Dimension Set ID";
    end;

    procedure OnCancelSale(var rec: Record "Sale POS")
    begin
        //onCancelSale
    end;

    procedure OnEndsaleChecklines(var Sale: Record "Sale POS";Balance: Decimal)
    var
        Ekspeditionslinie: Record "Sale Line POS";
        NPConfig: Record "Retail Setup";
        Marshaller: Codeunit "POS Event Marshaller";
        t004: Label 'A customer must be selected for negative sale';
        Item: Record Item;
        CustomerRequired: Boolean;
        Register: Record Register;
        errStr: Text[250];
    begin
        //onEndsaleChecklines

        NPConfig.Get;
        Register.Get(Sale."Register No.");

        errStr := '';
        CustomerRequired := false;

        Ekspeditionslinie.Reset;
        Ekspeditionslinie.SetRange( "Register No.", Sale."Register No." );
        Ekspeditionslinie.SetRange( "Sales Ticket No.", Sale."Sales Ticket No." );
        Ekspeditionslinie.SetRange( Type, Ekspeditionslinie.Type::Item );
        Ekspeditionslinie.SetRange( "Sale Type", Ekspeditionslinie."Sale Type"::Sale );
        if Ekspeditionslinie.Find('-') then repeat
          Item.Get(Ekspeditionslinie."No.");
          if errStr <> '' then begin
            if Register.Touchscreen then
              Marshaller.DisplayError(Text10600200,errStr,true)
            else
              Error(errStr);
          end;
        until Ekspeditionslinie.Next = 0;

        Ekspeditionslinie.SetRange( "Return Sale No.", '' );
        if ( Balance < 0 ) and NPConfig."Demand Cash Cust on Neg Sale" and ( Sale."Customer No." = '' ) and
           Ekspeditionslinie.Find('-') then
             errStr := t004;

        if errStr <> '' then begin
          if Register.Touchscreen then
            Marshaller.DisplayError(Text10600200,errStr,true)
          else
            Error(errStr);
        end;
    end;

    procedure OpenRegister()
    var
        LinePrintBuffer: Codeunit "RP Line Print Mgt.";
        "Table": Variant;
    begin
        Table := 0;
        LinePrintBuffer.ProcessCodeunit(CODEUNIT::"Report - Open drawer IV", Table);
    end;

    procedure RegisterLogonnameAutofill(var Reg: Record Register)
    var
        UserSetup: Record "User Setup";
        Environment: Codeunit "NPR Environment Mgt.";
        Text10600055: Label 'Error in settings, NPK-initialisation file is missing! Contact your Navision Solution Center';
        t001: Label 'Not possible using USERDOMAINID';
    begin
        //RegisterLogonnameAutofill
        RetailSetupGlobal.Get;

        case RetailSetupGlobal."Get register no. using" of
          RetailSetupGlobal."Get register no. using"::USERPROFILE:
            begin
              Error(Text10600055);
            end;
          RetailSetupGlobal."Get register no. using"::COMPUTERNAME,
          RetailSetupGlobal."Get register no. using"::CLIENTNAME,
          RetailSetupGlobal."Get register no. using"::SESSIONNAME,
          RetailSetupGlobal."Get register no. using"::USERNAME,
          RetailSetupGlobal."Get register no. using"::USERID:
            begin
              Reg."Logon-User Name" := Format(Environment.ClientEnvironment(Format(RetailSetupGlobal."Get register no. using")));
            end;
          RetailSetupGlobal."Get register no. using"::USERDOMAINID: Error(t001);
          RetailSetupGlobal."Get register no. using"::"USER SETUP TABLE":
            begin
              UserSetup.Reset;
              UserSetup.SetRange("Backoffice Register No.",Reg."Register No.");
              UserSetup.Find('-');
              Reg."Logon-User Name" := UserSetup."User ID";
            end;
        end;

        Reg.Modify;
    end;

    procedure ReturnSale(var Sale: Record "Sale POS";var ReturnValue: Boolean): Boolean
    var
        RevisionsrulleLoc: Record "Audit Roll";
        EkspeditionlinieLoc: Record "Sale Line POS";
        Gavekort: Record "Gift Voucher";
        Tilgodebevis: Record "Credit Voucher";
        DebetSalg: Boolean;
        ErrGI: Label 'Giftvoucher %1 has allready been read, and the ticket cannot be returned';
        ErrTI: Label 'Creditvoucher %1 has allready been read, and the ticket cannot be returned';
    begin
        with Sale do begin

          // >> NPK (FM)
          if ReturnValue then begin
            DebetSalg := false;
            EkspeditionlinieLoc.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
            EkspeditionlinieLoc.SetRange("Register No.","Register No.");
            EkspeditionlinieLoc.SetRange("Sales Ticket No.","Sales Ticket No.");
            if EkspeditionlinieLoc.Find('-') then repeat
              if EkspeditionlinieLoc."Return Sale Sales Ticket No." <> '' then
                if RevisionsrulleLoc.Get(EkspeditionlinieLoc."Return Sale Register No.",EkspeditionlinieLoc."Return Sale Sales Ticket No.",
                                         EkspeditionlinieLoc."Return Sales Sales Type",EkspeditionlinieLoc.
        "Return Sale Line No.",
                                         EkspeditionlinieLoc."Return Sale No.",EkspeditionlinieLoc."Return Sales Sales Date")
                  then begin
                  //-NPR5.28 [256332]
                  //  IF RevisionsrulleLoc.Type = RevisionsrulleLoc.Type::"Debit Sale" THEN
                  if RevisionsrulleLoc."Sale Type" = RevisionsrulleLoc."Sale Type"::"Debit Sale" then
                  //-NPR5.28 [256332]
                      DebetSalg := true;
                  end;
            until EkspeditionlinieLoc.Next = 0;
            with EkspeditionlinieLoc do begin

              if Find('-') then repeat
                if Type = Type::"G/L Entry" then begin
                  if "Gift Voucher Ref." <> '' then begin
                    if GetGiftVoucherStatus( "Gift Voucher Ref." ) = Gavekort.Status::Cashed then
                      Error( ErrGI, "Gift Voucher Ref." );
                    SetGiftVoucherStatus( "Gift Voucher Ref.", Gavekort.Status::Cancelled );
                  end;
                  if "Credit voucher ref." <> '' then begin
                    if GetGiftVoucherStatus( "Credit voucher ref." ) = Tilgodebevis.Status::Cashed then
                      Error( ErrTI, "Credit voucher ref." );
                    SetCreditVoucherStatus( "Credit voucher ref.", Tilgodebevis.Status::Cancelled );
                  end;
                end;
                if Type = Type::Payment then begin
                  if "Gift Voucher Ref." <> '' then begin
                    SetGiftVoucherStatus( "Gift Voucher Ref.", Gavekort.Status::Open );
                  end;
                  if "Credit voucher ref." <> '' then begin
                    SetCreditVoucherStatus( "Credit voucher ref.", Tilgodebevis.Status::Open );
                  end;
                end;
              until Next = 0;
            end;
          end;
        end;
        exit( DebetSalg );
    end;

    procedure SaleStat(var Sale: Record "Sale POS")
    var
        DimTSForm: Page "Touch Screen - Dim. Value List";
        DimValue: Record "Dimension Value";
        DimLine: Record "NPR Line Dimension";
        Register: Record Register;
        Marshaller: Codeunit "POS Event Marshaller";
        t002: Label 'Statistics';
        t003: Label 'Customer zip code';
        t004: Label 'ERROR';
        dlgInput: Code[20];
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimSetEntry: Record "Dimension Set Entry";
        Dim: Record Dimension;
        WrongDimValueErr: Label 'This %1 does not exist. Leave field blank to skip.';
    begin
        RetailSetupGlobal.Get;
        if (RetailSetupGlobal."Stat. Dimension" = '') then
          exit;
        
        if RetailSetupGlobal."No. of Sales pr. Stat" = 0 then
          exit;
        
        Randomize;
        if Random(RetailSetupGlobal."No. of Sales pr. Stat") > 1 then
          exit;
        
        Register.Get(Sale."Register No.");
        if not Register."Use Sales Statistics" then
          exit;
        
        DimValue.SetRange("Dimension Code",RetailSetupGlobal."Stat. Dimension");
        case RetailSetupGlobal."Dim Stat Method" of
          RetailSetupGlobal."Dim Stat Method"::"Global Dim List":
            begin
              DimTSForm.LookupMode(true);
              DimTSForm.SetTableView(DimValue);
              if DimTSForm.RunModal <> ACTION::LookupOK then
                exit;
              DimTSForm.GetRecord(DimValue);
            end;
          RetailSetupGlobal."Dim Stat Method"::"Global Dim Dialog":
            begin
              repeat
                dlgInput := '';
        //-NPR5.26
        //        IF Marshaller.NumPadCode(t002 + '\' + t003,dlgInput,FALSE,FALSE) THEN BEGIN
                Dim.Get(RetailSetupGlobal."Stat. Dimension");
                if Marshaller.NumPadCode(t002 + '\' + Dim.Name,dlgInput,false,false) then begin
        //+NPR5.26
                  case RetailSetupGlobal."Dim Stat Value" of
                    RetailSetupGlobal."Dim Stat Value"::Check:
                      begin
        //-NPR5.26
        /*
                        IF NOT DimValue.GET(NPC.DimStat, dlgInput) THEN
                          Marshaller.Error(t004,t005,FALSE);
        */
                        if not DimValue.Get(RetailSetupGlobal."Stat. Dimension",dlgInput) and (dlgInput <> '') then
                          Marshaller.DisplayError(t004,StrSubstNo(WrongDimValueErr,Dim.Name),false);
        //+NPR5.26
                      end;
                    RetailSetupGlobal."Dim Stat Value"::Create :
                      begin
                        if not DimValue.Get(RetailSetupGlobal."Stat. Dimension",dlgInput) then begin
                          DimValue.Init;
                          DimValue."Dimension Code" := RetailSetupGlobal."Stat. Dimension";
                          DimValue.Code := dlgInput;
                          //DimValue.Name             := dlgInput;
                          DimValue."Dimension Value Type" := DimValue."Dimension Value Type"::Standard;
                          DimValue.Insert(true);
                        end;
                      end;
                  end;
                end;
              until DimValue.Get(RetailSetupGlobal."Stat. Dimension",dlgInput) or (dlgInput = '');
            end;
          RetailSetupGlobal."Dim Stat Method"::"Post Code":
            begin
              if (Sale."Post Code" = '') then begin
                if Marshaller.NumPadCode(t002 + '\' + t003,dlgInput,false,false) then begin
                  Sale."Stats - Customer Post Code" := dlgInput;
                  Sale.Modify(true);
                end;
              end;
              exit;
            end;
        end;
        
        if RetailSetupGlobal."Use Adv. dimensions" then begin
          if DimValue.Code = '' then
            exit;
          DimLine."Table ID" := 6014405;
          DimLine."Register No." := Sale."Register No.";
          DimLine."Sales Ticket No." := Sale."Sales Ticket No.";
          DimLine."Sale Type" := DimLine."Sale Type"::Sale;
          DimLine."Dimension Code" := DimValue."Dimension Code";
          DimLine."Dimension Value Code" := DimValue.Code;
        
        //-NPR5.26
        /*
        //in the INSERT/MODIFY there is a code that updates global dimensions on Sale POS and Sale Line POS tables and therefor causing
        //an error regarding different versions of the same record when calling MODIFY again in this function (or if we comment this new code out completelly)
        //it happens in codeunit 6014630 in EndSale function
        //I don't see a reason why to keep TRUE parameter as with the fix we're handling dimensions completelly on Sale POS and Sale Line POS tables.
          IF NOT DimLine.INSERT( TRUE ) THEN
            DimLine.MODIFY(TRUE);
        */
          if not DimLine.Insert then
            DimLine.Modify;
        
          if not DimSetEntry.Get(Sale."Dimension Set ID",DimLine."Dimension Code") or
            (DimSetEntry."Dimension Value Code" <> DimLine."Dimension Value Code") then begin
            DimSetEntry.SetRange("Dimension Set ID",Sale."Dimension Set ID");
            if DimSetEntry.FindSet then
              repeat
                TempDimSetEntry := DimSetEntry;
                if DimSetEntry."Dimension Code" = DimLine."Dimension Code" then
                  TempDimSetEntry.Validate("Dimension Value Code",DimLine."Dimension Value Code");
                TempDimSetEntry.Insert;
              until DimSetEntry.Next = 0;
            if not TempDimSetEntry.Get(Sale."Dimension Set ID",DimLine."Dimension Code") then begin
              TempDimSetEntry.Init;
              TempDimSetEntry."Dimension Set ID" := Sale."Dimension Set ID";
              TempDimSetEntry.Validate("Dimension Code",DimLine."Dimension Code");
              TempDimSetEntry.Validate("Dimension Value Code",DimLine."Dimension Value Code");
              TempDimSetEntry.Insert;
            end;
            Sale.Validate("Dimension Set ID",DimMgt.GetDimensionSetID(TempDimSetEntry));
            DimMgt.UpdateGlobalDimFromDimSetID(Sale."Dimension Set ID",Sale."Shortcut Dimension 1 Code",Sale."Shortcut Dimension 2 Code");
            Sale.Modify(true);
            //-NPR5.38 [294623]
            //Sale.UpdateAllLineDim(Sale."Dimension Set ID",TempDimSetEntry."Dimension Set ID");
            UpdateLineDimExcludePayment (Sale."Register No.", Sale."Sales Ticket No.", Sale."Dimension Set ID",TempDimSetEntry."Dimension Set ID");
            //+NPR5.38 [294623]
        
          end;
        //+NPR5.26
        
        end else begin
          if DimValue."Global Dimension No." = 1 then
            Sale.Validate( "Shortcut Dimension 1 Code", DimValue.Code );
          if DimValue."Global Dimension No." = 2 then
            Sale.Validate( "Shortcut Dimension 2 Code", DimValue.Code );
          Sale.Modify(true);
        end;

    end;

    procedure UpdateLineDimExcludePayment(RegisterNo: Code[10];ReceiptNo: Code[20];NewParentDimSetID: Integer;OldParentDimSetID: Integer)
    var
        SaleLinePOS: Record "Sale Line POS";
        NewDimSetID: Integer;
        DimMgt: Codeunit DimensionManagement;
    begin
        //-NPR5.38 [294623]
        // Update all lines but exclude payment lines with changed dimensions.
        // Used from SaleStat since SaleStat dimension code value prevents compressed posting of payment lines

        if NewParentDimSetID = OldParentDimSetID then
          exit;

        SaleLinePOS.SetFilter ("Register No.", '=%1', RegisterNo);
        SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', ReceiptNo);
        SaleLinePOS.SetFilter ("Sale Type", '<>%1', SaleLinePOS."Sale Type"::Payment);

        SaleLinePOS.LockTable;
        if (SaleLinePOS.FindSet()) then
          repeat
            NewDimSetID := DimMgt.GetDeltaDimSetID(SaleLinePOS."Dimension Set ID",NewParentDimSetID,OldParentDimSetID);
            if SaleLinePOS."Dimension Set ID" <> NewDimSetID then begin
              SaleLinePOS."Dimension Set ID" := NewDimSetID;
              DimMgt.UpdateGlobalDimFromDimSetID(
                SaleLinePOS."Dimension Set ID",SaleLinePOS."Shortcut Dimension 1 Code",SaleLinePOS."Shortcut Dimension 2 Code");
              SaleLinePOS.Modify;
            end;
          until SaleLinePOS.Next = 0;
        //+NPR5.38 [294623]
    end;

    procedure "-- Vouchers"()
    begin
    end;

    procedure CityGiftVoucherPush(var SalePOS: Record "Sale POS";var Register: Record Register;var GiftCertCreated: Boolean;isTS: Boolean;var SaleLinePOS: Record "Sale Line POS";isInit: Boolean)
    var
        SaleLinePOS2: Record "Sale Line POS";
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        UnitPrice: Decimal;
        Quantity: Decimal;
        AmountWithDiscount: Decimal;
        Amount: Decimal;
        LineNo: Integer;
        ErrCreditVoucher: Label 'Acount No. %1 has been used for Credit Voucher.';
        ErrRegister: Label 'Acount No. %1 has been used for Register Acount.';
        ContinueQuest: Label 'Create %1 city giftcertificates at kr. %2 each';
        ErrContinue: Label 'Creating city giftcertificate was interupted by the user';
        i: Integer;
        ErrQuantity: Label 'The quantity cannot be 0';
        NameText: Text[250];
        Txt001: Label 'City gift voucher';
        TempText: Text[30];
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        Txt011: Label 'City gift vouchers\Quantity';
        Txt012: Label 'City Gift Voucher\Unit price';
        Txt013: Label 'City Gift voucher\Discount %';
        Txt026: Label 'City Gift voucher discount percent can not be less than 0 or more than 100 percent.';
        Txt027: Label 'City Gift voucher sales price can not be less than 0 or more than 100 percent.';
        DecimalInput: Decimal;
        GLSetup: Record "General Ledger Setup";
        Txt028: Label 'City gift voucher reference number for gift voucher';
        CreditGiftVoucherReferenceNo: array [1000] of Code[20];
        Txt029: Label 'A city gift voucher has a pre defined number. Type it here or leave blank. Press OK.';
    begin
        //CityGiftVoucherPush
        with SalePOS do begin
          TestField("Salesperson Code");
          SaleLinePOS2.SetCurrentKey("Register No.","Sales Ticket No.",Date,"Sale Type","Line No.");
          SaleLinePOS2.SetRange("Register No.","Register No.");
          SaleLinePOS2.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS2.SetRange(Date,Date);
          SaleLinePOS2.SetFilter("Sale Type",'%1|%2|%3',SaleLinePOS2."Sale Type"::Sale
                                                             ,SaleLinePOS2."Sale Type"::Deposit
                                                             ,SaleLinePOS2."Sale Type"::"Out payment");
          if SaleLinePOS2.Find('+') then
            LineNo := SaleLinePOS2."Line No." + 10000
          else
            LineNo := 10000;
        
          Quantity := 1;
          AmountWithDiscount := 0.0;
          DiscountPct := 0;
          DiscountAmount := 0;
          UnitPrice := 0.0;
        
          Register.TestField("City Gift Voucher Account");
        
          if Register."City Gift Voucher Account" = Register."Credit Voucher Account" then
            Error(ErrCreditVoucher,Register."Credit Voucher Account");
        
          if Register."City Gift Voucher Account" = Register.Account then
            Error(ErrRegister,Register."City Gift Voucher Account");
        
          /* QUANTITY */
        
          Quantity := 1;
          if not POSEventMarshaller.NumPad(Txt011,Quantity,true,false) then
            Error('');
        
          /* Unit price */
        
          DecimalInput := 0;
          if not POSEventMarshaller.NumPad(Txt012,DecimalInput,true,false) then
            Error('');
          if DecimalInput < 0 then
            POSEventMarshaller.DisplayError(Text10600200,Txt027,true);
          UnitPrice := DecimalInput;
        
          /* Discount % */
        
          DecimalInput := 0;
          if not POSEventMarshaller.NumPad(Txt013,DecimalInput,true,false) then
            Error('');
          if (DecimalInput > 100) or (DecimalInput < 0) then
            POSEventMarshaller.DisplayError(Text10600200,Txt026,true);
          DiscountPct := DecimalInput;
        
          /* Reference number */
        
          for i := 1 to Quantity do begin
            TempText := POSEventMarshaller.SearchBox(Txt028 + ' ' + Format(i) + '/' + Format(Quantity),Txt029,50);
            if TempText <> '<CANCEL>' then begin
              CreditGiftVoucherReferenceNo[i] := TempText;
            end else
              Error('');
          end;
        
          AmountWithDiscount := Quantity * UnitPrice - DiscountAmount;
          Amount := UnitPrice * Quantity;
          DiscountAmount := UnitPrice * DiscountPct / 100;
          GLSetup.Get;
        
          if Quantity <> 0 then
            Amount := Amount / Quantity
          else
            Error(ErrQuantity);
        
          if Quantity > 1 then
            if not Confirm(StrSubstNo(ContinueQuest,Quantity,Amount,GLSetup."LCY Code"),false) then
              Error(ErrContinue);
        
          if DiscountAmount <> 0 then
            Register.TestField("Gift Voucher Discount Account");
        
          GiftCertCreated := false;
        
          NameText := '';
        
          for i := 1 to Quantity do begin
            SaleLinePOS2.Init;
            SaleLinePOS2."Register No." := "Register No.";
            SaleLinePOS2."Sales Ticket No." := "Sales Ticket No.";
            SaleLinePOS2."Line No." := LineNo;
            SaleLinePOS2."Sale Type" := SaleLinePOS2."Sale Type"::Deposit;
            SaleLinePOS2.Date := Date;
            SaleLinePOS2.Type := SaleLinePOS2.Type::"G/L Entry";
            SaleLinePOS2.Validate("No.",Register."City Gift Voucher Account");
            SaleLinePOS2.Description := CopyStr(Txt001,1,MaxStrLen(SaleLinePOS2.Description));
            SaleLinePOS2."Location Code" := Register."Location Code";
            SaleLinePOS2."Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
            SaleLinePOS2."Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
            SaleLinePOS2.Quantity := 1;
            SaleLinePOS2.Validate("Unit Price",Amount);
            //Ekspeditionslinie.Amount                 := bBel�b;
            SaleLinePOS2."Price Includes VAT" := true;
            SaleLinePOS2."Foreign No." := CreditGiftVoucherReferenceNo[i];
            SaleLinePOS2.Insert;
            /*
            IF EkspLinieForm.OpretGavekort(Ekspeditionslinie, tNavn ) THEN BEGIN
              Ekspeditionslinie.INSERT;
              Ekspeditionslinie.VALIDATE("No.");
              Ekspeditionslinie.Description :=
                COPYSTR(
                  Gavekort.TABLECAPTION + ' ' + Gavekort.FIELDCAPTION("No.") + ' ' + Ekspeditionslinie."Gift Voucher Ref.",
                  1,MAXSTRLEN(Ekspeditionslinie.Description));
              Ekspeditionslinie.MODIFY;
              GiftCertCreated := TRUE;
            END;
            */
            LineNo := LineNo + 10000;
            if (DiscountAmount <> 0) then begin
              SaleLinePOS2.GiftCrtLine := InsertGiftCrtDiscLine(SaleLinePOS2,LineNo,DiscountAmount);
              SaleLinePOS2.Modify;
            end;
          end;
        end;

    end;

    procedure CreateGiftVoucher(var SaleLinePOS: Record "Sale Line POS";var Name: Text[250]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        GiftVoucher: Record "Gift Voucher";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
        Contact: Record Contact;
        ActionTaken: Action;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Utility: Codeunit Utility;
        Text10600007: Label 'cancelled by sales person';
        TempNo: Code[20];
        NewTempNo: Code[20];
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        GLSetup: Record "General Ledger Setup";
    begin
        //CreateGiftVoucher
        GiftVoucher.Init;

        if RetailSetup.Get then begin
          RetailSetup.TestField("Gift Voucher No. Management");

        //-NPR5.23[242341]
        // Nrseriestyring.InitSeries(Ops�tning."Gift Voucher No. Management",
        //    Ops�tning."Gift Voucher No. Management",0D,Gavekort."No.",Ops�tning."Gift Voucher No. Management");
        //
        //  IF Ops�tning."EAN Mgt. Gift voucher" <> '' THEN
        //    Gavekort."No." := Utility.CreateEAN( Gavekort."No.", FORMAT(Ops�tning."EAN Mgt. Gift voucher") );

          TempNo := NoSeriesMgt.GetNextNo(RetailSetup."Gift Voucher No. Management",Today,false);
          if RetailSetup."EAN Mgt. Gift voucher" <> '' then
             TempNo := Utility.CreateEAN(TempNo,Format(RetailSetup."EAN Mgt. Gift voucher"));

          //NewTempNo := TouchScreen.PopupNumpad(Text0001,TempNo,FALSE,FALSE);
          NewTempNo := TempNo;
          Commit;
          POSEventMarshaller.NumPadCode(Text0001,NewTempNo,true,false);

          if GiftVoucher.Get(NewTempNo) then begin
            if GiftVoucher.Amount >0 then begin
              if Confirm(StrSubstNo(Text0002,NewTempNo,GiftVoucher.Amount),false) then
                GiftVoucher.Delete(true)
              else
                exit;
            end else
             GiftVoucher.Delete(true);
          end;

          if NewTempNo = TempNo then begin
            NoSeriesMgt.InitSeries(RetailSetup."Gift Voucher No. Management",RetailSetup."Gift Voucher No. Management",0D,GiftVoucher."No.",RetailSetup."Gift Voucher No. Management");
            if RetailSetup."EAN Mgt. Gift voucher" <> '' then
              GiftVoucher."No." := Utility.CreateEAN(GiftVoucher."No.",Format(RetailSetup."EAN Mgt. Gift voucher"));
           end else
             GiftVoucher."No." := NewTempNo;
        //+NPR5.23[242341]

          if GiftVoucher.Amount < 0 then
            GiftVoucher.Amount := Abs(GiftVoucher.Amount)
          else
            GiftVoucher.Amount := SaleLinePOS.Amount;

          GiftVoucher."Register No." := SaleLinePOS."Register No.";
          GiftVoucher."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          GiftVoucher."Issue Date" := SaleLinePOS.Date;
          GiftVoucher."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
          GiftVoucher."Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
          GiftVoucher."Location Code" := SaleLinePOS."Location Code";
          GiftVoucher.Status := GiftVoucher.Status::Cancelled;
          GiftVoucher.Name := Name;
          GiftVoucher."Created in Company" := Format(RetailSetup."Company No.");
          if SalePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.") then begin
            GiftVoucher.Salesperson := SalePOS."Salesperson Code";
            GiftVoucher."Customer No." := SalePOS."Customer No.";
          end;
          //-NPR5.38 [266220]
          GiftVoucher."Currency Code" := SaleLinePOS."Currency Code";
          if GiftVoucher."Currency Code" = '' then begin
            GLSetup.Get;
            GiftVoucher."Currency Code" := GLSetup."LCY Code";
          end;
          //+NPR5.38 [266220]
          GiftVoucher.Insert(true);

          Commit;
          if RetailSetup."Show Create Giftcertificat" then begin
            GiftVoucher.SetRecFilter;
            // Fetch customer information
            if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and
               Customer.Get(GiftVoucher."Customer No.") then begin
              GiftVoucher.Name := Customer.Name;
              GiftVoucher.Address := Customer.Address;
              GiftVoucher."ZIP Code" := Customer."Post Code";
              GiftVoucher.City := Customer.City;
              ActionTaken := ACTION::LookupOK;
              GiftVoucher.Modify;
            end
            // Fetch contact information
            else if (SalePOS."Customer Type" = SalePOS."Customer Type"::Cash) and
              Contact.Get(GiftVoucher."Customer No.") then begin
              GiftVoucher.Name := Contact.Name;
              GiftVoucher.Address := Contact.Address;
              GiftVoucher."ZIP Code" := Contact."Post Code";
              GiftVoucher.City := Contact.City;
              ActionTaken := ACTION::LookupOK;
              GiftVoucher.Modify;
            end else
            // Type in manually
              ActionTaken := PAGE.RunModal(PAGE::"Create Gift Voucher",GiftVoucher);
          end;

          Name := GiftVoucher.Name;
          if (ActionTaken = ACTION::LookupOK) or not RetailSetup."Show Create Giftcertificat" then begin
            SaleLinePOS.Quantity := 1;
            SaleLinePOS."Unit Price" := GiftVoucher.Amount;
            SaleLinePOS."Amount Including VAT" := GiftVoucher.Amount;
            SaleLinePOS."Gift Voucher Ref." := GiftVoucher."No.";
          end else begin
            if GiftVoucher.Get(GiftVoucher."No.") then begin
              GiftVoucher.Name := Text10600007 + SalePOS."Salesperson Code";
              GiftVoucher.Address := '';
              GiftVoucher."ZIP Code" := '';
              GiftVoucher.City := '';
              GiftVoucher.Status := GiftVoucher.Status::Cancelled;
              GiftVoucher.Amount := 0;
              GiftVoucher.Modify;
            end;
            exit(false);
          end;
        end;

        exit(true);
    end;

    procedure CreditVoucherLookup(var EkspLinie: Record "Sale Line POS";var CommStr1: Text[100]): Boolean
    var
        Kasse: Record Register;
        CheckEkspLinie: Record "Sale Line POS";
        Tilgodebevis: Record "Credit Voucher";
        Result: Action;
        Betaling: Record "Payment Type POS";
        Err002: Label 'The credit voucher does not exist!';
        "I-Comm": Record "I-Comm";
        validering: Code[50];
        Marshaller: Codeunit "POS Event Marshaller";
        t001: Label 'Type/Scan credit voucher number.';
        cvFound: Boolean;
        common_cv: Record "Credit Voucher";
        local_cv: Record "Credit Voucher";
        Err004: Label 'Credit voucher amount is 0,00.';
        VoucherBlocked: Label 'Voucher %1 is Blocked.';
        VoucherStatusNotOpen: Label 'Voucher %1 is %2.';
    begin
        with EkspLinie do begin
          Kasse.Get("Register No.");
          RetailSetupGlobal.Get;
          "I-Comm".Get;
          Commit;
          Tilgodebevis.Reset;
          Tilgodebevis.SetRange(Status,Tilgodebevis.Status::Open);
          Tilgodebevis.SetRange(Blocked,false);
        
          /* Touch Screen sales forms */
          if UsingTS then begin
            if CommStr1 = '' then begin
              if not Marshaller.NumPadCode(t001,validering,false,false) then
                validering := '<CANCEL>';
            end else
              validering := CommStr1;
        
            if validering = '<CANCEL>' then begin
                EkspLinie.Delete(true);
                Commit;
                Error('');
            end;
        
            if validering = '' then begin  /* lookup */
              Result := PAGE.RunModal(6014533, Tilgodebevis);
              if Result <> ACTION::LookupOK then begin
                EkspLinie.Delete(true);
                Commit;
                Error('');
              end;
              validering := Tilgodebevis."No.";
            end;
        
            Tilgodebevis.SetRange("No.", validering);
            if not Tilgodebevis.Find('-') then begin  /* look in common */
              Tilgodebevis.Reset;
              Tilgodebevis.SetCurrentKey("Offline - No.");
              Tilgodebevis.SetRange("Offline - No.",validering);
              Tilgodebevis.SetRange(Status,Tilgodebevis.Status::Open);
              Tilgodebevis.SetRange(Blocked,false);
              if Tilgodebevis.Find('-') then begin
                if Tilgodebevis.Count > 1 then begin
                  Result := PAGE.RunModal(6014533, Tilgodebevis);
                  if Result <> ACTION::LookupOK then begin
                    EkspLinie.Delete(true);
                    Commit;
                    Error('');
                  end;
                  validering := Tilgodebevis."No.";
                  cvFound := true;
                end else begin
                  cvFound := true;
                end;
              end;
              if not cvFound then begin
                if RetailSetupGlobal."Use I-Comm" then begin
                  RecIComm.Get;
                  if RecIComm."Company - Clearing" <> '' then begin  /* common clearing */
                    common_cv.ChangeCompany(RecIComm."Company - Clearing");
                    common_cv.SetRange("No.", validering);
                    if not common_cv.Find('-') then begin  /* not found in common */
                      CommStr1 := Err002;
                      exit(false);
                    end else begin   /* found in common, but not in local => create local */
                      local_cv.Init;
                      local_cv.Copy(common_cv);
                      local_cv."External Credit Voucher" := true;
                      local_cv."Issued on Drawer No" := common_cv."Register No.";
                      local_cv."Issued on Ticket No" := common_cv."Sales Ticket No.";
                      if local_cv.Insert then;
                      Tilgodebevis.Get( local_cv."No." );
                    end;  /* found in common */
                  end else begin  /* local gv not found */
                    CommStr1 := Err002;
                    exit(false);
                  end;
                end else begin  /* local gv not found */
                  CommStr1 := Err002;
                  //-NPR5.47 [322837]
                  if Tilgodebevis.Get(validering) then begin
                    if Tilgodebevis.Blocked then
                      CommStr1 := StrSubstNo(VoucherBlocked,validering);
                    if Tilgodebevis.Status <> Tilgodebevis.Status::Open then
                      CommStr1 := StrSubstNo(VoucherStatusNotOpen,validering,Tilgodebevis.Status);
                  end;
                  //+NPR5.47 [322837]
                  exit(false);
                end;
              end;
            end else begin
              //-NPR4.12
              //REPEAT
              //  tmpTilgodebevis.INIT;
              //  tmpTilgodebevis := Tilgodebevis;
              //  tmpTilgodebevis.INSERT;
              //UNTIL Tilgodebevis.NEXT = 0;
              //Tilgodebevis.RESET;
              //Tilgodebevis.SETCURRENTKEY("Offline - No.");
              //Tilgodebevis.SETRANGE("Offline - No.", validering);
              //Tilgodebevis.SETRANGE( Status, Tilgodebevis.Status::Open );
              //Tilgodebevis.SETRANGE( Blocked, FALSE );
              //Tilgodebevis.SETRANGE( Offline, TRUE );
              //IF Tilgodebevis.FIND('-') THEN REPEAT
              //  tmpTilgodebevis.INIT;
              //  tmpTilgodebevis := Tilgodebevis;
              //  tmpTilgodebevis.INSERT;
              //UNTIL Tilgodebevis.NEXT = 0;
              //Result := PAGE.RUNMODAL(6014533, tmpTilgodebevis);
              //IF Result <> ACTION::LookupOK THEN BEGIN
              //  EkspLinie.DELETE(TRUE);
              //  COMMIT;
              //  ERROR('');
              //END;
              //validering := tmpTilgodebevis."No.";
              //+NPR4.12
              cvFound := true;
            end;
        
            CommStr1 := '';
            if Tilgodebevis.Amount = 0 then begin
              CommStr1 := Err004;
              exit(false);
            end;
            Betaling.Get(EkspLinie."No.");
            Validate(Description,Betaling."Sales Line Text" + ' - ' + Tilgodebevis."No.");
            EkspLinie."Custom Descr" := true;
            "Credit voucher ref." := Tilgodebevis."No.";
        
            if (Tilgodebevis."External Credit Voucher") and (Tilgodebevis."Created in Company" <> '') then
              Reference := Tilgodebevis."Sales Ticket No.";
        
            Clearing := Clearing::Tilgodebevis;
            "Amount Including VAT" := Tilgodebevis.Amount;
            "Discount Code" := Tilgodebevis."No.";
        
            exit(true);
          end;
        
          /* NORMAL SALES MODE */
        
          Result := PAGE.RunModal(6014430,Tilgodebevis);
        
          RetailSetupGlobal.Get;
        //  IF npc."Brug dimensionsstyring" THEN
          Commit;
        
          if (Result = ACTION::LookupOK) and (Tilgodebevis."No." <> '') then begin
            "Credit voucher ref." := Tilgodebevis."No.";
            Betaling.Get(EkspLinie."No.");
            Validate(Description,Betaling."Sales Line Text" + ' - ' + Tilgodebevis."No.");
            EkspLinie."Custom Descr" := true;
            Clearing := Clearing::Tilgodebevis;
            "Amount Including VAT" := Tilgodebevis.Amount;
            "Discount Code" := Tilgodebevis."No.";
          end else begin
            CheckEkspLinie.Reset;
            CheckEkspLinie.SetRange( "Register No.", "Register No." );
            CheckEkspLinie.SetRange( "Sales Ticket No.", "Sales Ticket No." );
            CheckEkspLinie.SetRange( Date, Date );
            CheckEkspLinie.SetRange( "Sale Type", "Sale Type"::Payment );
            CheckEkspLinie.SetFilter( "Line No.", '<>%1', "Line No." );
            CheckEkspLinie.SetRange( "No.", Kasse."Primary Payment Type" );
            if not CheckEkspLinie.Find('-') then begin
              Kasse.Get( "Register No." );
              Validate( Type, Type::Payment );
              Validate( "No.", Kasse."Primary Payment Type" );
              if "Amount Including VAT" < 0 then
                Validate( "No.", '' );
            end else
              Validate( "No.", '' );
            exit;
          end;
        end;

    end;

    procedure GetGCVoAmount(var SaleLine: Record "Sale Line POS";PaymentType: Option Gift,Credit;Force: Boolean): Decimal
    var
        GiftVo: Record "Gift Voucher";
        CreditVo: Record "Credit Voucher";
        IComm: Record "I-Comm";
        ErrGiftNotSelected: Label 'No Gift Voucher was selected';
        ErrCreditNotSelected: Label 'No Credit Voucher was selected';
    begin
        //GetGCVoAmount()

        IComm.Get;
        if PaymentType = PaymentType::Gift then begin
          GiftVo.ChangeCompany( IComm."Company - Clearing" );
          GiftVo.SetRange( Status, GiftVo.Status::Open );
          if SaleLine."Foreign No." = '' then begin
            if UsingTS then begin
              if not ( PAGE.RunModal( PAGE::"Touch Screen - Gift Vouchers", GiftVo ) = ACTION::LookupOK ) then
                exit( 0 );
            end else begin
              if not ( PAGE.RunModal( PAGE::"Gift Voucher List", GiftVo ) = ACTION::LookupOK ) then
                Error( ErrGiftNotSelected );
            end;
          end else begin
            if not GiftVo.Get( SaleLine."Foreign No." ) then
              exit( 0 );
          end;

          SaleLine."Foreign No." := GiftVo."No.";
          exit( GiftVo.Amount );
        end;

        if PaymentType = PaymentType::Credit then begin
          CreditVo.ChangeCompany( IComm."Company - Clearing" );
          CreditVo.SetRange( Status, CreditVo.Status::Open );
          if SaleLine."Foreign No." = '' then begin
            if UsingTS then begin
              if not ( PAGE.RunModal( PAGE::"Touch Screen - Credit Vouchers", CreditVo ) = ACTION::LookupOK ) then
                exit( 0 );
            end else begin
              if not ( PAGE.RunModal( PAGE::"Credit Voucher List", CreditVo ) = ACTION::LookupOK ) then
                Error( ErrCreditNotSelected );
            end;
          end else begin
            if not CreditVo.Get( SaleLine."Foreign No." ) then
              exit( 0 );
          end;

          SaleLine."Foreign No." := CreditVo."No.";
          exit( CreditVo.Amount );
        end;
    end;

    procedure GetGiftVoucherStatus(Ref: Code[20]): Integer
    var
        Gavekort: Record "Gift Voucher";
    begin
        //GetGavekortStatus()
        Gavekort.Get( Ref );
        exit( Gavekort.Status );
    end;

    procedure GiftVoucherLookup(var EkspLinie: Record "Sale Line POS";var CommStr1: Text[100]): Boolean
    var
        Kasse: Record Register;
        CheckEkspLinie: Record "Sale Line POS";
        Gavekort: Record "Gift Voucher";
        Result: Action;
        Betaling: Record "Payment Type POS";
        TempSaldo: Decimal;
        "I-Comm": Record "I-Comm";
        Err002: Label 'The gift voucher does not exist!';
        Marshaller: Codeunit "POS Event Marshaller";
        Validering: Code[20];
        t001: Label 'Type/Scan gift voucher number';
        common_gv: Record "Gift Voucher";
        local_gv: Record "Gift Voucher";
        Err004: Label 'Gift voucher amount is 0,00';
        gvFound: Boolean;
        VoucherBlocked: Label 'Voucher %1 is Blocked.';
        VoucherStatusNotOpen: Label 'Voucher %1 is %2.';
    begin
        //GavekortLookup()
        
        with EkspLinie do begin
          Kasse.Get( "Register No." );
          RetailSetupGlobal.Get;
          "I-Comm".Get;
          Commit;
          Gavekort.Reset;
          Gavekort.SetRange(Status,Gavekort.Status::Open);
          Gavekort.SetRange(Blocked,false);
        
          /* Touch Screen sales forms */
          if UsingTS then begin
            if CommStr1 = '' then begin
              if not Marshaller.NumPadCode(t001,Validering,false,false) then
                Validering := '<CANCEL>';
            end else
              Validering := CommStr1;
        
            if Validering = '<CANCEL>' then begin
                EkspLinie.Delete(true);
                Commit;
                Error('');
            end;
        
            if Validering = '' then begin  /* lookup */
              Result := PAGE.RunModal(6014545, Gavekort);
              if Result <> ACTION::LookupOK then begin
                EkspLinie.Delete(true);
                Commit;
                Error('');
              end;
              Validering := Gavekort."No.";
            end;
        
            Gavekort.SetRange("No.", Validering);
            if not Gavekort.Find('-') then begin  /* look in common */
              Gavekort.Reset;
              Gavekort.SetCurrentKey("Offline - No.");
              Gavekort.SetRange("Offline - No.", Validering);
              Gavekort.SetRange( Status, Gavekort.Status::Open );
              Gavekort.SetRange( Blocked, false );
              if Gavekort.Find('-') then begin
                if Gavekort.Count > 1 then begin
                  Result := PAGE.RunModal(6014545, Gavekort);
                  if Result <> ACTION::LookupOK then begin
                    EkspLinie.Delete(true);
                    Commit;
                    Error('');
                  end;
                  Validering := Gavekort."No.";
                  gvFound := true;
                end else begin
                  gvFound := true;
                end;
              end;
              if not gvFound then begin
                if RetailSetupGlobal."Use I-Comm" then begin
                  RecIComm.Get;
                  if RecIComm."Company - Clearing" <> '' then begin  /* common clearing */
                    common_gv.ChangeCompany(RecIComm."Company - Clearing");
                    common_gv.SetRange("No.", Validering);
                    if not common_gv.Find('-') then begin  /* not found in common */
                      CommStr1 := Err002;
                      exit(false);
                    end else begin   /* found in common, but not in local => create local */
                      local_gv.Init;
                      local_gv.Copy(common_gv);
                      local_gv."External Gift Voucher" := true;
                      local_gv."Issuing Register No." := common_gv."Register No.";
                      local_gv."Issuing Sales Ticket No."   := common_gv."Sales Ticket No.";
                      if local_gv.Insert then;
                      Gavekort.Get( local_gv."No." );
                    end;  /* found in common */
                  end else begin  /* local gv not found */
                    CommStr1 := Err002;
                    exit(false);
                  end;
                end else begin  /* local gv not found */
                  CommStr1 := Err002;
                  //-NPR5.44 [322837]
                  if Gavekort.Get(Validering) then begin
                    if Gavekort.Blocked then
                      CommStr1 := StrSubstNo(VoucherBlocked,Validering);
                    if Gavekort.Status <> Gavekort.Status::Open then
                      CommStr1 := StrSubstNo(VoucherStatusNotOpen,Validering,Gavekort.Status);
                  end;
                  //+NPR5.44 [322837]
                  exit(false);
                end;
              end;
            end else begin
             /*
              REPEAT
                tmpGavekort.INIT;
                tmpGavekort := Gavekort;
                tmpGavekort.INSERT;
              UNTIL Gavekort.NEXT = 0;
              Gavekort.RESET;
              Gavekort.SETCURRENTKEY("Offline - No.");
              Gavekort.SETRANGE("Offline - No.", Validering);
              Gavekort.SETRANGE( Status, Gavekort.Status::�ben );
              Gavekort.SETRANGE( Blocked, FALSE );
              Gavekort.SETRANGE( Offline, TRUE );
              IF Gavekort.FIND('-') THEN REPEAT
                tmpGavekort.INIT;
                tmpGavekort := Gavekort;
                tmpGavekort.INSERT;
              UNTIL Gavekort.NEXT = 0;
              Result := PAGE.RUNMODAL(6014545, tmpGavekort);
              IF Result <> ACTION::LookupOK THEN BEGIN
                EkspLinie.DELETE(TRUE);
                COMMIT;
                ERROR('');
              END;
              Validering := tmpGavekort."No.";*/
        
              gvFound := true;
        
            end;
        
            CommStr1 := '';
            if Gavekort.Amount = 0 then begin
              CommStr1 := Err004;
              exit(false);
            end;
            Betaling.Get( EkspLinie."No." );
            Validate( Description, Betaling."Sales Line Text" + ' - ' + Gavekort."No." );
            EkspLinie."Custom Descr" := true;
            "Gift Voucher Ref." := Gavekort."No.";
        
            if (Gavekort."External Gift Voucher") and (Gavekort."Created in Company" <> '') then
              Reference := Gavekort."Sales Ticket No.";
        
            Clearing := Clearing::Gavekort;
            "Amount Including VAT" := Gavekort.Amount;
            "Discount Code" := Gavekort."No.";
        
            exit(true);
          end;
        
          /* Normal sales forms */
        
          Result := PAGE.RunModal(6014431, Gavekort);
        
          RetailSetupGlobal.Get;
          if RetailSetupGlobal."Use Adv. dimensions" then
            Commit;
        
          if (Result = ACTION::LookupOK) and (Gavekort."No." <> '') then begin
            Betaling.Get( EkspLinie."No." );
            Validate( Description, Betaling."Sales Line Text" + ' - ' + Gavekort."No." );
            EkspLinie."Custom Descr" := true;
            "Gift Voucher Ref." := Gavekort."No.";
        
            if (Gavekort."External Gift Voucher") and (Gavekort."Created in Company"<>'') then
              Reference:=Gavekort."Sales Ticket No.";
        
            Clearing := Clearing::Gavekort;
            Validate( "Amount Including VAT", Gavekort.Amount );
            "Discount Code" := Gavekort."No.";
          end else begin
            CheckEkspLinie.Reset;
            CheckEkspLinie.SetRange( "Register No.", "Register No." );
            CheckEkspLinie.SetRange( "Sales Ticket No.", "Sales Ticket No." );
            CheckEkspLinie.SetRange( Date, Date );
            CheckEkspLinie.SetRange( "Sale Type", "Sale Type"::Payment );
            CheckEkspLinie.SetFilter( "Line No.", '<>%1', "Line No." );
            CheckEkspLinie.SetRange( "No.", Kasse."Primary Payment Type" );
            if not CheckEkspLinie.Find('-') then begin
              if "Amount Including VAT" >= 0 then begin
                TempSaldo := "Amount Including VAT";
                Init;
                Validate( Type, Type::Payment );
                Validate( "No.", Kasse."Primary Payment Type" );
                Validate( "Amount Including VAT", TempSaldo );
              end else begin
                Validate( "No.", '' );
              end;
            end else
              Validate( "No.", '' );
            exit;
          end;
        end;

    end;

    procedure GiftVoucherPush(var SalePOS: Record "Sale POS";var Register: Record Register;var GiftCertCreated: Boolean;isTS: Boolean;var SaleLinePOS: Record "Sale Line POS";isInit: Boolean)
    var
        SaleLinePOS2: Record "Sale Line POS";
        PaymentTypePOS: Record "Payment Type POS";
        SaleLinePOS3: Record "Sale Line POS";
        Gavekort: Record "Gift Voucher";
        GLSetup: Record "General Ledger Setup";
        RetailSetup: Record "Retail Setup";
        CallTerminalIntegration: Codeunit "Call Terminal Integration";
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        Barcode: Code[19];
        DecimalInput: Decimal;
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        UnitPrice: Decimal;
        Quantity: Decimal;
        AmountWithoutDiscount: Decimal;
        Amount: Decimal;
        GiftVoucherType: Integer;
        IndexSelected: Integer;
        LineNo: Integer;
        ErrCreditVoucher: Label 'Acount No. %1 has been used for Credit Voucher.';
        ErrRegister: Label 'Acount No. %1 has been used for Register Acount.';
        ContinueQuest: Label 'Create %1 giftcertificates at %3 %2 each';
        ErrContinue: Label 'Creating giftcertificate was interupted by the user';
        i: Integer;
        ErrQuantity: Label 'The quantity must be different from 0!';
        NameText: Text[250];
        Txt011: Label 'Quantity of gift vouchers';
        Txt012: Label 'Gift Voucher unit price:';
        Txt013: Label 'Gift voucher discount %:';
        Txt026: Label 'Gift voucher discount percent can not be less than 0 or more than 100 percent.';
        Txt027: Label 'Gift voucher sales price can not be less than 0 or more than 100 percent.';
        GiftVoucherDescriptions: Text[250];
        GiftVoucherAccounts: Text[250];
        GiftVoucherCodes: Text[250];
        AccountSelected: Code[20];
        MsgCreateGiftVoucher: Label 'Create gift voucher No. %1?';
        ErrCreate: Label 'Creation failed.\Continue\Try again?';
        InputBarcode: Label 'Scan giftvoucher';
    begin
        //GavekortPush()
        RetailSetup.Get;

        with SalePOS do begin
          PaymentTypePOS.SetCurrentKey("Search Description");
          PaymentTypePOS.Ascending(false);
          PaymentTypePOS.SetRange("Processing Type",PaymentTypePOS."Processing Type"::"Gift Voucher");
          PaymentTypePOS.SetRange(Status,PaymentTypePOS.Status::Active);
          if PaymentTypePOS.Find('-') then
            repeat
              GiftVoucherDescriptions += ',' + PaymentTypePOS.Description;
              GiftVoucherAccounts += ',' + PaymentTypePOS."G/L Account No.";
              GiftVoucherCodes += ',' + PaymentTypePOS."No.";
              GiftVoucherType += 1;
            until PaymentTypePOS.Next = 0;
          GiftVoucherDescriptions := DelStr(GiftVoucherDescriptions,1,1);
          GiftVoucherAccounts := DelStr(GiftVoucherAccounts,1,1);
          GiftVoucherCodes := DelStr(GiftVoucherCodes,1,1);

          if GiftVoucherType > 1 then begin
            IndexSelected := StrMenu(GiftVoucherDescriptions);
            if IndexSelected < 1 then
              exit;
            AccountSelected := SelectStr(IndexSelected,GiftVoucherAccounts);
            PaymentTypePOS.Get(SelectStr(IndexSelected,GiftVoucherCodes));
          end else
            AccountSelected := PaymentTypePOS."G/L Account No.";

          TestField("Salesperson Code");
          SaleLinePOS3.SetCurrentKey("Register No.","Sales Ticket No.",Date,"Sale Type","Line No.");
          SaleLinePOS3.SetRange("Register No.","Register No.");
          SaleLinePOS3.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS3.SetRange(Date,Date);
          SaleLinePOS3.SetFilter("Sale Type",'%1|%2|%3',SaleLinePOS3."Sale Type"::Sale
                                                        ,SaleLinePOS3."Sale Type"::Deposit
                                                        ,SaleLinePOS3."Sale Type"::"Out payment");
          if SaleLinePOS3.Find('+') then
            LineNo := SaleLinePOS3."Line No." + 10000
          else
            LineNo := 10000;

          Quantity := 1;
          AmountWithoutDiscount := 0.0;
          DiscountPct := 0;
          DiscountAmount := 0;
          UnitPrice := 0.0;

          if Register."Gift Voucher Account" = Register."Credit Voucher Account" then
            Error(ErrCreditVoucher,Register."Credit Voucher Account");

          if Register."Gift Voucher Account" = Register.Account then
            Error(ErrRegister,Register.Account);


          if RetailSetup."Popup Gift Voucher Quantity" then begin
            Quantity := 1;
            if not POSEventMarshaller.NumPad(Txt011,Quantity,true,false) then
              Error('');
          end;

          DecimalInput := 0;
          //-NPR5.01
          //IF NOT Marshaller.NumPad(t012,dec,TRUE,FALSE) THEN BEGIN
          if POSEventMarshaller.NumPad(Txt012,DecimalInput,true,false) then begin
          //+NPR5.01
            if (DecimalInput < 0) then
              POSEventMarshaller.DisplayError(Text10600200,Txt027,true);
            UnitPrice := DecimalInput;
          end else
            Error('');

          if RetailSetup."Popup Gift Voucher Quantity" then begin
            DecimalInput := 0;
          //-NPR5.01
          //  IF NOT Marshaller.NumPad(t013,dec,TRUE,FALSE) THEN BEGIN
            if POSEventMarshaller.NumPad(Txt013,DecimalInput,true,false) then begin
          //+NPR5.01
              if (DecimalInput > 100) or (DecimalInput < 0) then
                POSEventMarshaller.DisplayError(Text10600200,Txt026,true);
              DiscountPct := DecimalInput;
            end else
              Error('');
          end;

          AmountWithoutDiscount := Quantity * UnitPrice - DiscountAmount;
          Amount := UnitPrice * Quantity;
          DiscountAmount := UnitPrice * DiscountPct / 100;
          GLSetup.Get;

          if Quantity <> 0 then
            Amount := Amount / Quantity
          else
            Error(ErrQuantity);

          if Quantity > 1 then
            if not Confirm(StrSubstNo(ContinueQuest,Quantity,Amount,GLSetup."LCY Code"),false) then
              Error(ErrContinue);

          if DiscountAmount <> 0 then
            Register.TestField("Gift Voucher Discount Account");

          GiftCertCreated := false;

          NameText := '';

          for i := Quantity downto 1 do begin
            SaleLinePOS3.Init;
            SaleLinePOS3."Register No." := "Register No.";
            SaleLinePOS3."Sales Ticket No." := "Sales Ticket No.";
            SaleLinePOS3."Line No." := LineNo;
            SaleLinePOS3."Sale Type" := SaleLinePOS3."Sale Type"::Deposit;
            SaleLinePOS3.Date := Date;
            SaleLinePOS3.Type := SaleLinePOS3.Type::"G/L Entry";
            //Ekspeditionslinie.Nummer                  := Kasse."Gift Voucher Account";
            SaleLinePOS3.Validate("No.",AccountSelected);

            SaleLinePOS3."Location Code" := Register."Location Code";
            SaleLinePOS3."Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
            SaleLinePOS3."Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
            SaleLinePOS3.Quantity := 1;
            SaleLinePOS3."Price Includes VAT" := SalePOS."Price including VAT";
            SaleLinePOS3.Amount := Amount;
            //Ekspeditionslinie."Amount Including VAT"       := bBel�b;
            if PaymentTypePOS."Via Terminal" then begin
              SaleLinePOS2.Copy(SaleLinePOS3);
              SaleLinePOS2.Type := SaleLinePOS2.Type::Payment;
              SaleLinePOS2."Sale Type" := SaleLinePOS2."Sale Type"::Payment;
              //-NPR5.41 [309296]
              //SaleLinePOS2."No." := SaleLinePOS2."No.";
              SaleLinePOS2."No." := PaymentTypePOS."No.";
              //+NPR5.41
              SaleLinePOS2."Line No." -= 500;
              SaleLinePOS2."Amount Including VAT" := -SaleLinePOS3.Amount;
              if SaleLinePOS2.Insert(false) then
                Commit;
              if Quantity > 1 then begin
                if Confirm(StrSubstNo(MsgCreateGiftVoucher,(Quantity - i) + 1),true) then begin
                  if PaymentTypePOS."PBS Gift Voucher Barcode" then begin
                    Barcode := POSEventMarshaller.SearchBox(InputBarcode,InputBarcode,50);
                    CallTerminalIntegration.SetBarcode(Barcode);
                  end;
                  if CallTerminalIntegration.Run(SaleLinePOS2) then;
                end;
              end else begin
                if PaymentTypePOS."PBS Gift Voucher Barcode" then begin
                  Barcode := POSEventMarshaller.SearchBox(InputBarcode,InputBarcode,50);
                  CallTerminalIntegration.SetBarcode(Barcode);
                end;
                if CallTerminalIntegration.Run(SaleLinePOS2) then;
              end;
              if SaleLinePOS2."Cash Terminal Approved" then begin
                SaleLinePOS3."Unit Price" := -SaleLinePOS2."Amount Including VAT";
                SaleLinePOS3."Amount Including VAT" := -SaleLinePOS2."Amount Including VAT";
                SaleLinePOS3.Insert;
                SaleLinePOS3.Validate("No.");
                SaleLinePOS3."Cash Terminal Approved" := true;
                SaleLinePOS3.Modify;
                GiftCertCreated := true;
              end else begin
                if Confirm(ErrCreate) then
                  i += 1
                else
                  i := 1; // End loop
              end;
              if SaleLinePOS2.Delete(false) then;
            end else if CreateGiftVoucher(SaleLinePOS3,NameText) then begin
              SaleLinePOS3.Insert;
              //Ekspeditionslinie.VALIDATE("No.");
              SaleLinePOS3.Description :=
                CopyStr(
                  Gavekort.TableCaption + ' ' + Gavekort.FieldCaption("No.") + ' ' + SaleLinePOS3."Gift Voucher Ref.",
                  1,MaxStrLen(SaleLinePOS3.Description));
              SaleLinePOS3.Modify;
              GiftCertCreated := true;
            end;
            LineNo := LineNo + 10000;
            if (DiscountAmount <> 0) and GiftCertCreated then begin
              SaleLinePOS3.GiftCrtLine := InsertGiftCrtDiscLine(SaleLinePOS3,LineNo,DiscountAmount);
              SaleLinePOS3.Modify;
              LineNo := LineNo + 10000;
            end;
          end;
        end;
    end;

    procedure InsertGiftCrtDiscLine(var "Sale Line": Record "Sale Line POS";Linienummer: Integer;nRabat: Decimal): Integer
    var
        DiscLine: Record "Sale Line POS";
        Kasse: Record Register;
        txtDescr: Label 'Discount for Gift Voucher %1';
    begin
        //InsertGiftCrtDiscLine
        with "Sale Line" do begin
          Kasse.Get( "Register No." );
          DiscLine."Register No."              := "Register No.";
          DiscLine."Sales Ticket No."          := "Sales Ticket No.";
          DiscLine."Line No."                  := Linienummer;
          DiscLine."Sale Type"                 := "Sale Type"::"Out payment";
          DiscLine.Date                        := Date;
          DiscLine.Type                        := DiscLine.Type::"G/L Entry";
          DiscLine."No."                       := Kasse."Gift Voucher Discount Account";
          DiscLine."Location Code"             := Kasse."Location Code";
          DiscLine."Shortcut Dimension 1 Code" := Kasse."Global Dimension 1 Code";
          DiscLine."Shortcut Dimension 2 Code" := Kasse."Global Dimension 2 Code";
          DiscLine.Validate(Quantity,1);
          DiscLine.Amount                      := nRabat;
          DiscLine."Unit Price"                := nRabat;
          DiscLine."Amount Including VAT"      := nRabat;
          DiscLine.Insert;
          DiscLine.Validate("No.");
          DiscLine.Validate( Description, StrSubstNo( txtDescr, "Sale Line"."Gift Voucher Ref." ));
          DiscLine.Modify;
        end;
        exit( DiscLine."Line No." );
    end;

    procedure PaymentGCVo(var SaleLine: Record "Sale Line POS";var Payment: Record "Payment Type POS"): Boolean
    var
        npc: Record "Retail Setup";
        recIComm: Record "I-Comm";
        tAmount: Decimal;
        PaymentType: Option Gift,Credit;
        t001: Label 'Gift Voucher value is zero - Can not be used';
    begin
        //PaymentGCVo()
        
        npc.Get;
        
        if npc."Use I-Comm" then begin
          recIComm.Get;
          Commit;
          if Payment."Common Company Clearing" then begin
        
            /* SQL Clearing */
        
            if recIComm."Clearing - SQL" then begin
              if recIComm."Company - Clearing" <> '' then begin
                TransferForeignGiftVoucher( SaleLine, Payment );
              end;
            end;
        
            /* Intercompany Clearing */
        
            if recIComm."Company - Clearing" <> '' then begin
              if Payment."Processing Type" = Payment."Processing Type"::"Foreign Gift Voucher" then
                PaymentType := PaymentType::Gift;
              if Payment."Processing Type" = Payment."Processing Type"::"Foreign Credit Voucher" then
                PaymentType := PaymentType::Credit;
        
              tAmount := GetGCVoAmount( SaleLine, PaymentType, true );
              if tAmount <= 0 then begin
                Message(t001);
                exit(false);
              end;
              SaleLine.Validate( "Amount Including VAT", tAmount );
              exit(true);
            end;
          end;
        end;

    end;

    procedure SetGiftVoucherStatus(Ref: Code[20];Status: Integer)
    var
        Gavekort: Record "Gift Voucher";
    begin
        //SetGavekort()
        Gavekort.Get( Ref );
        Gavekort.Status := Status;
        Gavekort.Modify;
    end;

    procedure SetCreditVoucherStatus(Ref: Code[20];Status: Integer)
    var
        Tilgode: Record "Credit Voucher";
    begin
        //SetTilgodebevis()
        Tilgode.Get( Ref );
        Tilgode.Status := Status;
        Tilgode.Modify;
    end;

    procedure TransferForeignGiftVoucher(var EkspLinie: Record "Sale Line POS";var Betaling: Record "Payment Type POS")
    var
        MsgServer: Label 'Check on server?';
        GaveDlg: Label 'Gift voucher #1########';
        TilDlg: Label 'Credit voucher #1########';
        InputDialog: Page "Input Dialog";
        FremNummer: Code[20];
        IComm: Codeunit "I-Comm";
    begin
        //EksternGaveTil()

        with EkspLinie do begin
          if Betaling."Processing Type" = Betaling."Processing Type"::"Foreign Gift Voucher" then begin
            TestOnServer := false;
            if Confirm( MsgServer, true ) then begin
              repeat
                Clear(InputDialog);
                InputDialog.SetInput(1,FremNummer,GaveDlg);
                if InputDialog.RunModal = ACTION::OK then
                  InputDialog.InputCode(1,FremNummer);
              until FremNummer <> '';
              "Amount Including VAT" := IComm.TestForeignGiftVoucher( FremNummer );
              TestOnServer       := true;
            end;
          end;
          if Betaling."Processing Type" = Betaling."Processing Type"::"Foreign Credit Voucher" then begin
            TestOnServer := false;
            if Confirm( MsgServer, true ) then begin
              repeat
                Clear(InputDialog);
                InputDialog.SetInput(1,FremNummer,TilDlg);
                if InputDialog.RunModal = ACTION::OK then
                  InputDialog.InputCode(1,FremNummer);
              until FremNummer <> '';
              "Amount Including VAT" := IComm.TestForeignCreditVoucher( FremNummer );
              TestOnServer       := true;
            end;
          end;
          "Foreign No."   := FremNummer;
        end;
    end;

    procedure "-- Balancing"()
    begin
    end;

    procedure FormBalanceRegister(var SalePOS: Record "Sale POS";RegisterEndDate: Date) ret: Boolean
    var
        Register2: Record Register;
        ReportSelectionRetail: Record "Report Selection Retail";
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Period: Record Period;
        PostAuditRoll: Codeunit "Post audit roll";
        CallTerminalIntegration: Codeunit "Call Terminal Integration";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        EndSalesTicketNo: Code[10];
        PostingRegisterNo: Code[20];
        EndRegisterNo: Code[10];
        Separator: Text[1];
        RegisterFilter: Text[30];
        Text10600049: Label 'Register balanced by %1 with %2';
        Text10600050: Label 'Register %1 is balanced!';
        Text10600073: Label 'The register %1 is balanced but the posting of the audit roll failed. Try to post it by push F11 on the Audit roll';
        LukVindueFejl: Label 'You have to close the POS window on Register %1';
        t002: Label 'An error occurred printing the register report. Do it manually from the Audit roll form!';
        t003: Label 'Error occured! \The receipt number on the balancing [%1] is not the same as on the current sale [%2]. \The balancing is saved for a retry.';
        RetailSetup: Record "Retail Setup";
        RetailDataModelARUpgrade: Codeunit "Retail Data Model AR Upgrade";
        POSSale: Codeunit "POS Sale";
    begin
        //FormAfslutKasse()
        
        with SalePOS do begin
          "Last Sale" := true;
          Modify;
        
          /* Clear Terminal Comm File */
          CallTerminalIntegration.FlushFile("Register No.");
        
          ret := true;
        
          Period.Reset;
          Period.SetRange("Register No.","Register No.");
          Period.SetRange("Sales Ticket No.","Sales Ticket No.");
          Period.Find('+');
        
          /* Check if the right closing data */
        
          if Period."Sales Ticket No." <> SalePOS."Sales Ticket No." then begin
            Message(t003,Period."Sales Ticket No.",SalePOS."Sales Ticket No.");
            exit(false);
          end;
        
          /* ** Opretter filter p� kasse ** */
        
          Clear(RegisterFilter);
          RetailSetupGlobal.Get();
          case RetailSetupGlobal."Balancing Posting Type" of
            RetailSetupGlobal."Balancing Posting Type"::TOTAL:
              begin
                if Register.Find('-') then
                  repeat
                    RegisterFilter += Separator + Format(Register."Register No.");
                    if (Register."Register No." <> FetchRegisterNumber) then
                      Error(LukVindueFejl,Register."Register No.");
                    Separator := '|';
                  until Register.Next = 0;
              end;
            RetailSetupGlobal."Balancing Posting Type"::"PER REGISTER":
              begin
                RegisterFilter := Format("Register No.");
              end;
          end;
        
        /* ** Fjerner gemte ekspeditioner ** */
        /*
          Ekspeditionshoved.SETFILTER(Kassenummer,Kassefilter);
          Ekspeditionshoved.SETRANGE("Gemt Ekspedition",TRUE);
          IF Ekspeditionshoved.FIND('-') THEN REPEAT
            Ekspeditionshoved.DeleteSavedVouchers;
            Ekspeditionslinie.SETRANGE(Kassenummer,Ekspeditionshoved.Kassenummer);
            Ekspeditionslinie.SETRANGE(Bonnummer,Ekspeditionshoved.Bonnummer);
        
            Ekspeditionslinie.DeleteDimOnLines;
            Ekspeditionslinie.DELETEALL;
            Ekspeditionshoved.DeleteDimOnEkspAndLines;
            Ekspeditionshoved.DELETE;
          UNTIL Ekspeditionshoved.NEXT = 0;
        */
        
        /* ** Finder f�rste kasse (Har kun betydning ved samlet kasseafslutning) ** */
        
          Register.Find('-');
          PostingRegisterNo := Register."Register No.";
        
          /* ** Skriver i revisionsrullen ** */
        
          Clear(AuditRoll);
        
          Register.SetFilter("Register No.",RegisterFilter);
          if Register.Find('-') then
            repeat
              Register.Validate(Status,Register.Status::Afsluttet);
              Register."Status Set By Sales Ticket" := "Sales Ticket No.";
              Register.Balanced := Today;
              Register."Closing Cash" := Period."Closing Cash";
              Register."Change Register" := Period."Change Register";
              Register.TestField(Account);
              Register.TestField("Gift Voucher Account");
              Register.TestField("Credit Voucher Account");
              Register.TestField("Difference Account");
              Register.TestField("Difference Account - Neg.");
              Register.TestField("Balance Account");
        
              AuditRoll.Init;
              AuditRoll."Register No." := Register."Register No.";
              AuditRoll."No." := Register."Register No.";
              AuditRoll.Lokationskode := Register."Location Code";
              AuditRoll."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
              AuditRoll."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
              AuditRoll."Dimension Set ID" := "Dimension Set ID";
              AuditRoll."Salesperson Code" := "Salesperson Code";
              AuditRoll.Type := AuditRoll.Type::"Open/Close";
              AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
              AuditRoll."Starting Time" := "Start Time";
              AuditRoll."Closing Time" := Time;
              AuditRoll."Sale Date" := Today;
        
              AuditRoll.Balancing := true;
              AuditRoll.Offline := not Register."Connected To Server";
              AuditRoll."Sales Ticket No." := "Sales Ticket No.";
        
            //  MoveEkspDim2Revrulle( Eksp, Revisionsrulle );
        
            //++0027 MG 8/5-02 S�lgernavn med i afslutningstekst
              if SalespersonPurchaser.Get("Salesperson Code") then
                AuditRoll.Description := CopyStr(StrSubstNo(Text10600049,SalespersonPurchaser.Name,Register."Closing Cash"),1,MaxStrLen(AuditRoll.Description));
            //--0027 MG 8/5-02   ��
              AuditRoll."Closing Cash" := Period."Closing Cash";
              AuditRoll."Transferred to Balance Account" := Period."Deposit in Bank";
              AuditRoll.Difference := Period.Difference;
              AuditRoll.EuroDifference := Period."Euro Difference";
              AuditRoll."Balance Amount" := Period."Balance Per Denomination";
              AuditRoll."Balance Sundries" := Period."Balanced Sec. Currency";
              AuditRoll."Balance amount euro" := Period."Balanced Euro";
              AuditRoll."Change Register" := Period."Change Register";
        
            // 0016 - start
              if (RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL) and (PostingRegisterNo = Register."Register No.") then begin
                EndSalesTicketNo := AuditRoll."Sales Ticket No.";
                EndRegisterNo := AuditRoll."Register No.";
                AuditRoll."Balanced on Sales Ticket No." := EndSalesTicketNo;
                AuditRoll."On Register No." := EndRegisterNo;
              end;
            // 0016 + slut
        
              if (RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL) and (PostingRegisterNo <> Register."Register No.") then begin
                AuditRoll."Closing Cash" := 0;
                AuditRoll."Transferred to Balance Account" := 0;
                AuditRoll.Difference := 0;
                AuditRoll."Balance Amount" := '';
                AuditRoll."Balance Sundries" := '';
            // 0016 - start
                AuditRoll."Balanced on Sales Ticket No." := EndSalesTicketNo;
                AuditRoll."On Register No." := EndRegisterNo;
            // 0016 + slut
        
              end;
              AuditRoll."Offline receipt no." := SalePOS."Sales Ticket No.";
              AuditRoll."Money bag no." := Period."Money bag no.";
              AuditRoll.Balancing := true; //ohm
              AuditRoll.Insert(true);                          //formAfslutKasse
        
              MoveSaleDim2AuditRoll(SalePOS,AuditRoll);
        
              Register."Opened Date" := 0D;
              Register."Balanced on Sales Ticket" := AuditRoll."Sales Ticket No.";
              Register.Modify;
        
              //Sender SMS med bruttooms�tning
              //  Flyttet til efter commit af opg�relsen.
            until Register.Next = 0;
        
          //-NPR5.38 [297087]
          RetailDataModelARUpgrade.DuplicateAuditRollTicketToPosEntry ("Sales Ticket No.");
          //+NPR5.38 [297087]
        
        /* *************************************************************************************** */
          Commit;
        /* *************************************************************************************** */
        
         //-NPR5.40 [308457]
         //-NPR5.39 [305016]
        // POSSale.FillFiscalNoOnPOSEntry(SalePOS);
        // COMMIT;
         //+NPR5.39 [305016]
         //+NPR5.40 [308457]
        
         if not RetailSalesLineCode.Run(SalePOS) then
            Message(t002);
        
        /* Code for running Credit Card dataport and delete file */
        
        /* *************************************************************************************** */
          Commit;
        /* *************************************************************************************** */
        
          Message(Text10600050,ConvertStr(RegisterFilter,'|','+'));
        
          if RetailSetupGlobal."Posting Audit Roll" = RetailSetupGlobal."Posting Audit Roll"::Automatic then begin
        
            //-NPR5.38 [294430]
            // PostAuditRoll.ShowProgress(TRUE);
            PostAuditRoll.ShowProgress(CurrentClientType = CLIENTTYPE::Windows);
            //+NPR5.38 [294430]
        
            case RetailSetupGlobal."Posting When Balancing" of
              RetailSetupGlobal."Posting When Balancing"::"Per Register":
                begin
                  AuditRoll.Reset;
                  AuditRoll.SetRange("Register No.","Register No.");
                  if not PostAuditRoll.Run(AuditRoll) then
                    Message(Text10600073,Register."Register No.",AuditRoll.TableCaption,AuditRoll.TableCaption);
                end;
              RetailSetupGlobal."Posting When Balancing"::Total:
                begin
                  Register2.Reset;
                  Register2.SetCurrentKey(Status);
                  Register2.SetFilter(Status,'<>%1',Register2.Status::Afsluttet);
                  Clear(AuditRoll);
                  if not Register2.Find('-' ) then
                    if not PostAuditRoll.Run(AuditRoll) then
                      Message(Text10600073,Register."Register No.",AuditRoll.TableCaption,AuditRoll.TableCaption);
                end;
            end;
          end;
        
          Commit;
          //-NPR5.40
          //IF Register."Import credit card transact." THEN BEGIN
          //  MSPDankort.LoadJournal;
          //  COMMIT;
          //END;
        
          //CLEAR(AuditRoll);
          //CLEAR(ReportSelectionRetail);
          //COMMIT;
          //+NPR5.40
        /*  Rapportvalg.SETRANGE("Report Type",Rapportvalg."Report Type"::Kasseafslut);
          Rapportvalg.SETFILTER("Report ID",'<>0');
          Rapportvalg.SETRANGE( "Register No.", "Register No." );
          IF NOT Rapportvalg.FIND('-') THEN
            Rapportvalg.SETRANGE( "Register No.", '' );
          IF Rapportvalg.FIND('-') THEN
          REPEAT
            REPORT.RUNMODAL(Rapportvalg."Report ID",TRUE,FALSE,Revisionsrulle);
          UNTIL Rapportvalg.NEXT = 0;
        
          // Test For Codeunit
          Rapportvalg.SETRANGE("Report ID");
          Rapportvalg.SETFILTER("Codeunit ID",'<>0');
          IF NOT Rapportvalg.FIND('-') THEN
            Rapportvalg.SETRANGE("Register No.", '');
        
          IF Rapportvalg.FIND('-') THEN REPEAT
            Table := Revisionsrulle;
            LinePrintBuffer.ProcessPrint(Rapportvalg."Codeunit ID", Table);
          UNTIL Rapportvalg.NEXT = 0;       */
        
        end;
        
        //-NPR-PrintRetailDoc1.0
        Clear(Register2);
        Register2.Get(SalePOS."Register No.");
        if Register2."Credit Card Solution" = Register2."Credit Card Solution"::POINT then begin
          RetailSetup.Get();
        end;
        //-NPR5.40
        //IF Register."Auto Open/Close Terminal" THEN
        //  MSPDankort.CloseTerminal;
        //+NPR5.40
        //+NPR-PrintRetailDoc1.0
        
        //-NPR3.12i
        RetailSetup.Get();
        if RetailSetup."Automatic inventory posting" then
        //  REPORT.RUNMODAL(6014530,FALSE,FALSE);
        //+NPR3.12i
        
        //-NPR3.12j
        if RetailSetup."Automatic Cost Adjustment" then
         // REPORT.RUNMODAL(6059769,FALSE,FALSE);
        //+NPR3.12j
        
        exit(true);

    end;

    procedure "-- Retail Documents"()
    begin
    end;

    procedure CheckCustomization(var SalePOS: Record "Sale POS")
    var
        RetailDocumentHeader: Record "Retail Document Header";
    begin
        //CheckSkr�dder
        with SalePOS do begin
          RetailDocumentHeader.Reset;
          RetailDocumentHeader.SetCurrentKey("Return Register","Return Sales Ticket");
          RetailDocumentHeader.SetRange("Return Register","Register No.");
          RetailDocumentHeader.SetRange("Document Type",RetailDocumentHeader."Document Type"::"Retail Order");
          if "Org. Bonnr." = '' then
            RetailDocumentHeader.SetRange("Return Sales Ticket","Sales Ticket No.")
          else
            RetailDocumentHeader.SetRange("Return Sales Ticket","Org. Bonnr.");
          if RetailDocumentHeader.Find('-') then begin
            RetailDocumentHeader."Return Salesperson" := '';
            RetailDocumentHeader."Return Register" := '';
            RetailDocumentHeader."Return Department" := '';
            RetailDocumentHeader."Return Sales Ticket" := '';
            RetailDocumentHeader."Return Date 2" := 0D;
            RetailDocumentHeader."Return Time 2" := 0T;
            RetailDocumentHeader.Cashed := false;
            RetailDocumentHeader.Modify;
          end;
        end;
    end;

    procedure CheckSelection(var Sale: Record "Sale POS")
    var
        UdvalgHoved: Record "Retail Document Header";
    begin
        //CheckUdvalg()
        with Sale do begin
          UdvalgHoved.Reset;
          //UdvalgHoved.SETCURRENTKEY( "Return Register", "Return Sales Ticket" );
          UdvalgHoved.SetCurrentKey("Document Type", "No.");
          UdvalgHoved.SetRange( "Return Register", "Register No." );
          UdvalgHoved.SetRange( "Document Type", Sale."Retail Document Type" );
          UdvalgHoved.SetRange( "No.", Sale."Retail Document No." );
          /*
          IF "Org. Bonnr." = '' THEN
            UdvalgHoved.SETRANGE( "Return Sales Ticket", "Sales Ticket No." )
          ELSE
            UdvalgHoved.SETRANGE( "Return Sales Ticket", "Org. Bonnr." );
          */
        
          if UdvalgHoved.Find('-') then begin
            UdvalgHoved."Return Salesperson"    :='';
            UdvalgHoved."Return Register"     :='';
            UdvalgHoved."Return Department"  :='';
            UdvalgHoved."Return Sales Ticket"       :='';
            UdvalgHoved."Return Date 2"      :=0D;
            UdvalgHoved."Return Time 2"       :=0T;
            UdvalgHoved.Cashed := false;
            UdvalgHoved.Modify;
          end;
        end;

    end;

    procedure FetchRepair(var SalePOS: Record "Sale POS")
    var
        CustomerRepair: Record "Customer Repair";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
        TxtBrand: Label 'Brand :';
        TxtSerialNo: Label 'Serial No. :';
    begin
        //HentReparation()
        Error('Not Supported');
        with SalePOS do begin
          //FORM RepForm.LOOKUPMODE( TRUE );
          //FORM Rep.RESET;
          //FORM Rep.SETFILTER( Status, '<>%1', Rep.Status::Afhentet );
          //FORM RepForm.SETTABLEVIEW( Rep );
          //FORM IF NOT ( RepPAGE.RUNMODAL = ACTION::LookupOK ) THEN
          //FORM   EXIT;

          //FORM RepForm.GETRECORD( Rep );
          SaleLinePOS.Reset;
          SaleLinePOS.SetRange("Register No.","Register No.");
          if SaleLinePOS.Find('-') then;
          LineNo := Round(SaleLinePOS."Line No.",10000,'<') + 10000;
          SaleLinePOS.Init;
          SaleLinePOS."Register No." := "Register No.";
          SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
          SaleLinePOS.Date := Today;
          SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
          SaleLinePOS."Line No." := LineNo;
          SaleLinePOS.Type := SaleLinePOS.Type::Item;
          SaleLinePOS.Insert(true);

          RetailContractSetup.Get;
          RetailContractSetup.TestField("Repair Item No.");
          SaleLinePOS.Validate("No.",RetailContractSetup."Repair Item No.");
          SaleLinePOS.Validate(Quantity,1);
          SaleLinePOS.Validate("Unit Price",CustomerRepair."Prices Including VAT");
          SaleLinePOS.Validate("Amount Including VAT",CustomerRepair."Prices Including VAT");
          SaleLinePOS.Validate("Unit Cost",CustomerRepair."Unit Cost");
          //-NPR5.45 [324395]
          //SaleLinePOS.VALIDATE("Unit Price (LCY)",CustomerRepair."Unit Cost");
          SaleLinePOS.Validate("Unit Cost (LCY)",CustomerRepair."Unit Cost");
          //+NPR5.45 [324395]
          SaleLinePOS."Rep. Nummer" := CustomerRepair."No.";
          SaleLinePOS.Modify;

          SaleLinePOS.Init;
          SaleLinePOS."Register No." := "Register No.";
          SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
          SaleLinePOS."Line No." := LineNo + 10;
          SaleLinePOS.Date := Today;
          SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Comment;
          SaleLinePOS.Type := SaleLinePOS.Type::Comment;
          SaleLinePOS.Description := TxtBrand + CustomerRepair.Brand;
          SaleLinePOS."No." := '*';
          SaleLinePOS.Insert(true);
          SaleLinePOS."Line No." := LineNo + 20;
          SaleLinePOS.Description := TxtSerialNo + CustomerRepair."Serial No.";
          SaleLinePOS.Insert(true);
        end;
    end;

    procedure ReceiptToRetailOrder(var Sale: Record "Sale POS";nField: Integer;isTS: Boolean;Type: Option " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote)
    var
        txtGetBon2: Label 'Sales Ticket No. to be transferred to Tailor ';
        MsgNoSale: Label 'Sales Ticket %1 doesn''t contain any entries, which can be transferred to Tailor';
        BNummer: Code[20];
        TempSale: Record "Sale POS";
        FakturaLinie: Record "Sales Invoice Line";
        OrdreLinie: Record "Sales Line";
        DebitorType: Integer;
        npc: Record "Retail Setup";
        AuditRoll: Record "Audit Roll";
        SalesLinePOS: Record "Sale Line POS";
        AuditRollList: Page "Audit Roll";
        FormCode: Codeunit "Retail Form Code";
        Marshaller: Codeunit "POS Event Marshaller";
        "Retail Document Handling": Codeunit "Retail Document Handling";
    begin
        //Receipt2NPOrder

        npc.Get;
        AuditRoll.Reset;
        AuditRoll.SetRange( "Register No.", Sale."Register No." );
        //AuditRoll.SETFILTER( "Sale Type", '=%1|=%2', AuditRoll."Sale Type"::Salg,
        //                                                      AuditRoll."Sale Type"::Bem�rkning );
        AuditRoll.SetFilter( "Sale Type", '=%1|=%2', AuditRoll."Sale Type"::Sale,
                                                              AuditRoll."Sale Type"::"Debit Sale" );
        AuditRoll.SetFilter( Type, '=%1|=%2', AuditRoll.Type::Item, AuditRoll.Type::"Debit Sale" );
        if AuditRoll.Find('+') then
          BNummer := AuditRoll."Sales Ticket No."
        else
          Error( MsgNoSale );


        if (not Marshaller.NumPadCode(txtGetBon2,BNummer,true,false)) or (BNummer = '') then
          exit;

        if BNummer = '*' then begin
          AuditRollList.LookupMode := true;
          AuditRollList.SetTableView( AuditRoll );
          if AuditRollList.RunModal = ACTION::LookupOK then begin
            AuditRollList.GetRecord( AuditRoll );
            BNummer := AuditRoll."Sales Ticket No.";
          end else
            exit;
        end;

        if AuditRoll."Document Type" = AuditRoll."Document Type"::Invoice then
          nField := 2;

        if AuditRoll."Document Type" = AuditRoll."Document Type"::Order then
          nField := 1;

        if AuditRoll."Document No." = '' then
          nField := 0;

        AuditRoll.SetRange( "Sales Ticket No.", BNummer );
        if not AuditRoll.Find('-') then
          Error( MsgNoSale, BNummer );

        TempSale.Copy( Sale );
        TempSale."Sales Ticket No." := BNummer;
        TempSale."Customer Type" := AuditRoll."Customer Type";
        TempSale."Customer No." := AuditRoll."Customer No.";

        case nField of
          0 : begin
            TempSale."Salesperson Code" := AuditRoll."Salesperson Code";
            repeat
              if not (( AuditRoll."Sale Type" = AuditRoll."Sale Type"::Comment ) and
                                            ( AuditRoll.Type = AuditRoll.Type::"Debit Sale" )) then begin
                SalesLinePOS.Init;
                SalesLinePOS."Register No."     := Sale."Register No.";
                SalesLinePOS."Sales Ticket No." := BNummer;
                SalesLinePOS.Description        := AuditRoll.Description;
                SalesLinePOS.Date               := TempSale.Date;
                SalesLinePOS."Sale Type"        := SalesLinePOS."Sale Type"::Sale;
                SalesLinePOS.Type               := SalesLinePOS.Type::Item;
                SalesLinePOS."Line No."         := AuditRoll."Line No.";
                SalesLinePOS."No."              := AuditRoll."No.";
                SalesLinePOS.Quantity           := AuditRoll.Quantity;
                SalesLinePOS."Unit of Measure Code"               := AuditRoll."Unit of Measure Code";
                SalesLinePOS."Unit Price"       := AuditRoll."Unit Price";
                SalesLinePOS."Amount Including VAT" := AuditRoll."Amount Including VAT";
                SalesLinePOS."Discount %"      := AuditRoll."Line Discount %";
                SalesLinePOS."Price Includes VAT" := AuditRoll."Salgspris inkl. moms";
                SalesLinePOS."Discount Amount" := AuditRoll."Line Discount Amount";
                SalesLinePOS.Insert;
              end;
            until AuditRoll.Next = 0;
            DebitorType := Sale."Customer Type"::Ord;
          end;
          1 : begin
            OrdreLinie.SetRange( "Document Type", OrdreLinie."Document Type"::Order );
            OrdreLinie.SetRange( "Document No.", AuditRoll."Allocated No." );
            if not OrdreLinie.Find('-') then
              Error( MsgNoSale );
            TempSale."Customer No." := OrdreLinie."Sell-to Customer No.";
            TempSale."Salesperson Code" := OrdreLinie."Salesperson Code";
            repeat
              SalesLinePOS.Init;
              SalesLinePOS."Register No." := Sale."Register No.";
              SalesLinePOS."Sales Ticket No." := BNummer;
              SalesLinePOS.Description := OrdreLinie.Description;
              SalesLinePOS."Sale Type" := SalesLinePOS."Sale Type"::Sale;
              SalesLinePOS.Type := SalesLinePOS.Type::Item;
              SalesLinePOS.Date               := TempSale.Date;
              SalesLinePOS."Line No." := OrdreLinie."Line No.";
              SalesLinePOS."No." := OrdreLinie."No.";
              SalesLinePOS.Quantity := OrdreLinie.Quantity;
              SalesLinePOS."Unit of Measure Code" := OrdreLinie."Unit of Measure";
              SalesLinePOS."Unit Price" := OrdreLinie."Unit Price";
              SalesLinePOS."Discount %" := OrdreLinie."Line Discount %";
              SalesLinePOS."Discount Amount" := OrdreLinie."Line Discount Amount";
              SalesLinePOS."Amount Including VAT" := OrdreLinie."Amount Including VAT";
              SalesLinePOS.Insert;
            until OrdreLinie.Next = 0;
            DebitorType := Sale."Customer Type"::Ord;
          end;
          2 : begin
            FakturaLinie.SetRange( "Document No.", AuditRoll."Document No." );
            if not FakturaLinie.Find('-') then
              Error( MsgNoSale );
            TempSale."Customer No." := FakturaLinie."Sell-to Customer No.";
            TempSale."Salesperson Code" := FakturaLinie."Salesperson Code";
            repeat
              SalesLinePOS.Init;
              SalesLinePOS."Register No." := Sale."Register No.";
              SalesLinePOS."Sales Ticket No." := BNummer;
              SalesLinePOS.Description := FakturaLinie.Description;
              SalesLinePOS."Sale Type" := SalesLinePOS."Sale Type"::Sale;
              SalesLinePOS.Type := SalesLinePOS.Type::Item;
              SalesLinePOS."Line No." := FakturaLinie."Line No.";
              SalesLinePOS.Date               := TempSale.Date;
              SalesLinePOS."No." := FakturaLinie."No.";
              SalesLinePOS."Unit of Measure Code" := FakturaLinie."Unit of Measure";
              SalesLinePOS.Quantity := FakturaLinie.Quantity;
              SalesLinePOS."Unit Price" := FakturaLinie."Unit Price";
              SalesLinePOS."Discount %" := FakturaLinie."Line Discount %";
              SalesLinePOS."Discount Amount" := FakturaLinie."Line Discount Amount";
              SalesLinePOS."Amount Including VAT" := FakturaLinie."Amount Including VAT";
              SalesLinePOS.Insert;
            until FakturaLinie.Next = 0;
            DebitorType := Sale."Customer Type"::Ord;
          end;
        end;


        TempSale."Retail Document Type" := Type;

        if not TempSale.Modify then
          TempSale.Insert;

        Commit;

        "Retail Document Handling".Sale2RetailDocument( TempSale );

        Sale."Sales Ticket No." := FormCode.FetchSalesTicketNumber( Sale."Register No." );
    end;

    procedure ShipmentToRetailOrder(var Sale: Record "Sale POS";isTS: Boolean)
    var
        Salgsoversigt: Page "Sales List";
        Salgshoved: Record "Sales Header";
        TempSale: Record "Sale POS";
        Salgslinie: Record "Sales Line";
        Ekspeditionslinie: Record "Sale Line POS";
        ErrorNoLines: Label 'There are no lines to transfer!';
    begin
        //Delievery2NPOrder

        Salgsoversigt.LookupMode := true;
        Salgshoved.Reset;
        Salgshoved.SetRange( "Document Type", Salgshoved."Document Type"::Order );
        Salgsoversigt.SetTableView( Salgshoved );
        if not ( Salgsoversigt.RunModal = ACTION::LookupOK ) then
          exit;
        Salgsoversigt.GetRecord( Salgshoved );

        TempSale.Copy( Sale );
        TempSale."Salesperson Code" := Salgshoved."Salesperson Code";
        TempSale.Validate( "Customer No.", Salgshoved."Sell-to Customer No." );

        Salgslinie.SetRange( "Document Type", Salgshoved."Document Type" );
        Salgslinie.SetRange( "Document No.", Salgshoved."No." );
        Salgslinie.SetRange( Type, Salgslinie.Type::Item );

        if Salgslinie.Find('-') then begin
          repeat
            Ekspeditionslinie.Init;
            Ekspeditionslinie."Register No." := Sale."Register No.";
            Ekspeditionslinie."Sales Ticket No." := Sale."Sales Ticket No.";
            Ekspeditionslinie.Description := Salgslinie.Description;
            Ekspeditionslinie."Sale Type" := Ekspeditionslinie."Sale Type"::Sale;
            Ekspeditionslinie.Type := Ekspeditionslinie.Type::Item;
            Ekspeditionslinie."Line No." := Salgslinie."Line No.";
            Ekspeditionslinie."No." := Salgslinie."No.";
            Ekspeditionslinie.Quantity := Salgslinie.Quantity;
            Ekspeditionslinie."Unit Price" := Salgslinie."Unit Price";
            Ekspeditionslinie."Amount Including VAT" := Salgslinie."Amount Including VAT";
            Ekspeditionslinie."Discount %" := Salgslinie."Line Discount %";
            Ekspeditionslinie."Discount Amount" := Salgslinie."Line Discount Amount";
            Ekspeditionslinie.Insert;
          until Salgslinie.Next = 0;
        end else
          Error( ErrorNoLines );

        TempSale."Retail Document Type" := TempSale."Retail Document Type"::"Retail Order";
        //"Retail Sales Code".Sale2RetailDocument(TempSale);
        TempSale.Modify;
    end;

    procedure "-- Rounding"()
    begin
    end;

    procedure GetDiscountRounding("Sales Ticket No.": Code[20];"Register No.": Code[20]) Rounding: Decimal
    var
        NPC: Record "Retail Setup";
        Linie: Record "Sale Line POS";
        Total: Decimal;
        TotalRounded: Decimal;
    begin
        //-NPR4.11
        exit(0);
        //+NPR4.11

        NPC.Get;

        Linie.SetCurrentKey("Discount Type");;
        Linie.SetRange(Linie."Register No.","Register No.");
        Linie.SetRange(Linie."Sales Ticket No.","Sales Ticket No.");
        Linie.SetRange(Linie.Type,Linie.Type::Item);
        Linie.SetFilter(Linie."Discount Type",'%1|%2|%3',Linie."Discount Type"::Mix,Linie."Discount Type"::"BOM List",Linie."Discount Type"::Manual);
        Linie.SetFilter("Discount %",'>%1',0);

        if Linie.FindSet then repeat
          Total += Linie."Amount Including VAT";
        until Linie.Next = 0 else exit;

        if Linie.FindSet then repeat
          TotalRounded += Linie."Unit Price" * ((100-Linie."Discount %")/100) * Linie.Quantity;
        until Linie.Next = 0 else exit;

        TotalRounded := Round(TotalRounded, 0.01);

        Rounding := Total - TotalRounded;

        if Abs(Rounding) > NPC."Amount Rounding Precision" then Rounding := 0;
    end;

    procedure FixDiscountRounding("Sales Ticket No.": Code[20];"Register No.": Code[20];var Sale: Record "Sale POS") Rounding: Decimal
    var
        NPC: Record "Retail Setup";
        Linie: Record "Sale Line POS";
        Total: Decimal;
        TotalRounded: Decimal;
    begin
        //-NPR4.11
        exit(0);
        //+NPR4.11

        NPC.Get;

        Linie.SetCurrentKey("Discount Type");;
        Linie.SetRange(Linie."Register No.","Register No.");
        Linie.SetRange(Linie."Sales Ticket No.","Sales Ticket No.");
        Linie.SetRange(Linie.Type,Linie.Type::Item);
        Linie.SetFilter(Linie."Discount Type",'%1|%2',Linie."Discount Type"::Mix,Linie."Discount Type"::"BOM List");
        Linie.SetFilter("Discount %",'>%1',0);

        if Linie.Find('-') then repeat
          Total += Linie."Amount Including VAT";
        until Linie.Next = 0 else exit;

        if Linie.Find('-') then repeat
          TotalRounded += Linie."Unit Price" * ((100-Linie."Discount %")/100) * Linie.Quantity;
        until Linie.Next = 0 else exit;

        TotalRounded := Round(TotalRounded, 0.01);

        Rounding := Total - TotalRounded;

        if Abs(Rounding) > NPC."Amount Rounding Precision" then Rounding := 0;

        Linie.Find('-');
        Linie."Amount Including VAT" -= Rounding;
        Linie.Modify;
    end;

    procedure "--- Globale Sales Ticket"()
    begin
    end;

    procedure InsertGlobalSalePOS(Sale: Record "Sale POS")
    var
        GlobalSalePOS: Record "Global Sale POS";
        SaleLinePOS: Record "Sale Line POS";
    begin
        GlobalSalePOS.SetRange("Company Name", CompanyName);
        GlobalSalePOS.SetRange("Register No.", Sale."Register No.");
        GlobalSalePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if not GlobalSalePOS.FindFirst then begin
          GlobalSalePOS.Init;
          GlobalSalePOS."Company Name" := CompanyName;
          GlobalSalePOS."Register No." := Sale."Register No.";
          GlobalSalePOS."Sales Ticket No." := Sale."Sales Ticket No.";
          //GlobalSalePOS."Audit Roll Line No." := 0;
          GlobalSalePOS.Insert(true);
        
          SaleLinePOS.SetRange("Register No.", Sale."Register No." );
          SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No." );
          SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
          if SaleLinePOS.Find('-') then repeat
            Clear(GlobalSalePOS);
            GlobalSalePOS.Init;
            GlobalSalePOS."Company Name" := CompanyName;
            GlobalSalePOS."Register No." := Sale."Register No.";
            GlobalSalePOS."Sales Ticket No." := Sale."Sales Ticket No.";
            //GlobalSalePOS."Audit Roll Line No." := 0;
            GlobalSalePOS."Sales Line No." := SaleLinePOS."Line No.";
            GlobalSalePOS."Sales Item No." := SaleLinePOS."No.";
            GlobalSalePOS."Sales Quantity" := SaleLinePOS.Quantity;
            GlobalSalePOS.Insert(true);
        
          until SaleLinePOS.Next = 0;
        
        /*
        AuditRoll.SETRANGE(AuditRoll."Register No.", Sale."Register No.");
        AuditRoll.SETRANGE(AuditRoll."Sales Ticket No.", Sale."Sales Ticket No.");
        AuditRoll.SETRANGE(AuditRoll."Sale Type", AuditRoll."Sale Type"::Salg);
        AuditRoll.SETRANGE(AuditRoll."Sale Date", Sale.Date);
        
        IF AuditRoll.FIND('-') THEN REPEAT
          CLEAR(GlobalSalePOS);
          GlobalSalePOS.INIT;
          GlobalSalePOS."Company Name" := COMPANYNAME;
          GlobalSalePOS."Register No." := Sale."Register No.";
          GlobalSalePOS."Sales Ticket No." := Sale."Sales Ticket No.";
          GlobalSalePOS."Audit Roll Line No." := AuditRoll."Line No.";
          IF GlobalSalePOS.INSERT(TRUE) THEN;
        UNTIL AuditRoll.NEXT = 0;
        */
        
        end;

    end;

    procedure ModifyGlobalSalePOSAudit(Sale: Record "Sale POS")
    var
        GlobalSalePOS: Record "Global Sale POS";
        AuditRoll: Record "Audit Roll";
        SaleLinePOS: Record "Sale Line POS";
    begin

        SaleLinePOS.SetRange("Register No.", Sale."Register No." );
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No." );
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        if SaleLinePOS.Find('-') then repeat
          Clear(GlobalSalePOS);
          GlobalSalePOS.SetRange("Company Name", CompanyName);
          GlobalSalePOS.SetRange("Register No.", Sale."Register No.");
          GlobalSalePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
          GlobalSalePOS.SetRange("Sales Line No.", SaleLinePOS."Line No." );
          GlobalSalePOS.SetRange("Sales Item No.", SaleLinePOS."No." );
          GlobalSalePOS.SetRange("Sales Quantity", SaleLinePOS.Quantity);
          if GlobalSalePOS.FindFirst then begin
            Clear( AuditRoll);
            AuditRoll.SetRange(AuditRoll."Register No.", Sale."Register No.");
            AuditRoll.SetRange(AuditRoll."Sales Ticket No.", Sale."Sales Ticket No.");
            AuditRoll.SetRange(AuditRoll."Sale Type", AuditRoll."Sale Type"::Sale);
            AuditRoll.SetRange(AuditRoll."Sale Date", Sale.Date);
            AuditRoll.SetRange(AuditRoll."No.", SaleLinePOS."No.");
            AuditRoll.SetRange(AuditRoll.Quantity, SaleLinePOS.Quantity);
            if AuditRoll.FindFirst then begin
              GlobalSalePOS."Audit Roll Line No." := AuditRoll."Line No.";
              GlobalSalePOS.Modify(true);
            end;

          end;
        until SaleLinePOS.Next = 0;
    end;

    procedure "--- Print"()
    begin
    end;

    procedure PrintLabelItemCard(var PrintVare: Record Item;bQuery: Boolean;dQuantity: Integer;bLastLine: Boolean) "EAN Quantity": Decimal
    var
        LabelLibrary: Codeunit "Label Library";
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        exit(LabelLibrary.PrintItem(PrintVare,bQuery,dQuantity,bLastLine,ReportSelectionRetail."Report Type"::"Price Label"));
    end;

    procedure PrintLabelExchangeLabel(type1: Option Single,LineQuantity,All;var eksplinie1: Record "Sale Line POS";var lastDateUsed: Date): Boolean
    var
        "Print Label and Display": Codeunit "Label Library";
    begin
        exit("Print Label and Display".PrintExchangeLabels(type1,eksplinie1,lastDateUsed));
    end;

    procedure "--- Customer/Vendor Mgt."()
    begin
    end;

    procedure CreateCustomerOld(CustomerNo: Code[20];"Customer Type": Option Ord,Cash;SalespersonCode: Code[20]): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Contact: Record Contact;
        ContactCard: Page "Contact Card";
        CustomerCard: Page "Customer Card";
        Return: Action;
        DeleteCust: Label 'Do you want to delete customer no. %1/name %2?';
        ErrNoCash: Label 'Cash Customers may not be created';
        ErrNoCust: Label 'Customers may not be created';
        TempCustomer: Record Customer temporary;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        //CreateCustomer
        RetailSetupGlobal.Get;
        
        if CustomerNo = '' then
          exit(false);
        
        if "Customer Type" = "Customer Type"::Cash then begin
          if Contact.Get(CustomerNo) then
            exit(true);
        
          Contact.Init;
        
          if RetailSetupGlobal."Create New Customer" then begin
            if RetailSetupGlobal."New Customer Creation" = RetailSetupGlobal."New Customer Creation"::"User Managed" then begin
            end;
          end else begin
            Error(ErrNoCash);
          end;
        
          //-NPR5.26 [252881]
          //IF CONFIRM(MsgTDC,TRUE) THEN
          //  IF Navneopslag.GetTDCCustBuffer( CustomerNo, TDCNavneBufferRecTmp, FALSE ) THEN
          //    TDCNavneBufferRecTmp.NavneBuff2Contact( TDCNavneBufferRecTmp, Contact );
          //
          //Contact."No." := CustomerNo;
          Contact.Validate("No.",CustomerNo);
          //+NPR5.26 [252881]
          Contact.Type := Contact.Type::Person;
        
          Contact.Insert;
        
          Commit;
          Contact.SetRecFilter;
        
          ContactCard.LookupMode(true);
          ContactCard.SetTableView(Contact);
          Return := ContactCard.RunModal;
          if (Return = ACTION::OK) or (Return = ACTION::LookupOK) then begin
            //-NPR5.26
            if Contact.Get then
            //+NPR5.26
              Contact.Modify;
            exit(true);
          end else begin
            if Contact."No." <> '' then
              if Confirm( DeleteCust, true, Contact."No.", Contact.Name ) then
                Contact.Delete;
            exit(false);
          end;
        end else begin
          if Customer.Get(CustomerNo) then
            exit(true);
        
          if RetailSetupGlobal."Create New Customer" then begin
            case RetailSetupGlobal."New Customer Creation" of
              RetailSetupGlobal."New Customer Creation"::"Cash Customer":
                Error(ErrNoCust);
              RetailSetupGlobal."New Customer Creation"::"User Managed":
                begin
                  Salesperson.Get(SalespersonCode);
                  case Salesperson."Customer Creation" of
                    Salesperson."Customer Creation"::"Not allowed" :
                      Error(ErrNoCust);
                    Salesperson."Customer Creation"::"Only cash" :
                      Error(ErrNoCust);
                  end;
                end;
            end;
          end else begin
            Error(ErrNoCust);
          end;
        
          //-NPR5.26 [252881]
          //IF CONFIRM( MsgTDC, TRUE ) THEN BEGIN
          //  IF Navneopslag.GetTDCCustBuffer( CustomerNo, TDCNavneBufferRecTmp, FALSE) THEN
          //    TDCNavneBufferRecTmp.NavneBuff2Debitor( TDCNavneBufferRecTmp, Customer );
          //END;
          //
          //Customer."No." := CustomerNo;
          Customer.Validate("No.",CustomerNo);
          //+NPR5.26 [252881]
          Customer.Type := RetailSetupGlobal."Customer type";
        
          //-NPR5.30 [264913]
          /*
          Customer."Payment Terms Code" := NPC."Terms of Payment";
          Customer.VALIDATE( "Gen. Bus. Posting Group", NPC."Gen. Bus. Posting Group" );
          Customer.VALIDATE( "Customer Posting Group", NPC."Customer Posting Group" );
          */
          if RetailSetupGlobal."Customer Config. Template" <> '' then begin
            ConfigTemplateHeader.Get(RetailSetupGlobal."Customer Config. Template");
            TempCustomer := Customer;
            TempCustomer.Insert;
            RecRef.GetTable(TempCustomer);
            ConfigTemplateMgt.ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader,RecRef);
            RecRef.SetTable(TempCustomer);
            Customer."Payment Terms Code" := TempCustomer."Payment Terms Code";
            Customer.Validate("Gen. Bus. Posting Group",TempCustomer."Gen. Bus. Posting Group");
            Customer.Validate("Customer Posting Group",TempCustomer."Customer Posting Group");
          end;
          //+NPR5.30 [264913]
        
          Customer."Prices Including VAT" := RetailSetupGlobal."Prices Include VAT";
          Customer.Insert;
        
          Commit;
          Customer.SetRecFilter;
          CustomerCard.SetTableView(Customer);
          CustomerCard.LookupMode(true);
          Return := CustomerCard.RunModal;
          if (Return = ACTION::OK) or (Return = ACTION::LookupOK) then begin
            //-NPR5.26
            if Customer.Get then
            //+NPR5.26
              Customer.Modify;
            exit(true);
          end else begin
            if Customer."No." <> '' then
              if Confirm(DeleteCust,true,Customer."No.",Customer.Name) then
                Customer.Delete;
            exit(false);
          end;
        end;

    end;

    procedure CreateCustomer(var cno: Code[20]): Boolean
    var
        t001: Label 'The customer is not found. Do you wish to create?';
        Customer1: Record Customer;
        npc: Record "Retail Setup";
        CustomerCard: Page "Customer Card";
    begin
        //CreateCustomer

        if cno = '' then exit;

        npc.Get;

        if Confirm(t001, false) then begin
            Customer1.Init;
            Customer1.Validate("No.",cno);
            Customer1.Insert(true);
            Customer1.SetRecFilter;
            Commit;
            CustomerCard.SetTableView(Customer1);
            CustomerCard.LookupMode(true);
            if CustomerCard.RunModal <> ACTION::OK then begin
              cno := '';
              Customer1.Delete(true);
            end;
        end else
            cno := '';
    end;

    procedure CreateContact(var cno: Code[20])
    var
        t001: Label 'The contact  is not found. Do you wish to create?';
        contact1: Record Contact;
        npc: Record "Retail Setup";
    begin
        //CreateContact
        if cno = '' then
          exit;

        npc.Get;

        if Confirm(t001, false) then begin
          contact1.Init;
          contact1.Validate("No.",cno);
          contact1.Insert;
          //-NPR5.26 [252881]
          //StdTableCode.ContactNoOnValidate(contact1);
          //contact1.MODIFY;
          //+NPR5.26 [252881]
          Commit;
          contact1.SetRecFilter;
          if PAGE.RunModal(PAGE::"Contact Card", contact1)  <> ACTION::OK then begin
            cno := '';
            contact1.Delete(true);
          end;
        end else
          cno := '';
    end;

    procedure GetRegisterNo(): Code[10]
    var
        Register2: Record Register;
        UserSetup: Record "User Setup";
        EnvironmentMgt: Codeunit "NPR Environment Mgt.";
        RegisterNo: Code[10];
        SystemSetupFile: File;
        Decimal: Decimal;
        Text10600055: Label 'Error in settings, NPK-initialisation file is missing! Contact your Navision Solution Center';
        Text10600056: Label 'Error in register settings, NPK settings file is defect! Contact your Navision Solution Center';
        Register: Record Register;
    begin
        //HentKassenummer()
        RetailSetupGlobal.Get;

        case RetailSetupGlobal."Get register no. using" of
          RetailSetupGlobal."Get register no. using"::USERPROFILE:
            begin
              SystemSetupFile.TextMode(true);
              if RetailSetupGlobal."Use WIN User Profile" then begin
                if SystemSetupFile.Open(EnvironmentMgt.ClientEnvironment(Format(RetailSetupGlobal."Get register no. using")) + '\NPK.DLL') then begin
                  SystemSetupFile.Read(Decimal);
                  SystemSetupFile.Close;
                end else begin
                  Message(Text10600055);
                  if PAGE.RunModal(PAGE::"Register List",Register) = ACTION::LookupOK then begin
                    Register.setThisRegisterNo(Register."Register No.");
                    Commit;
                    exit(Register."Register No.");
                  end else
                    exit('?');
                end;
              end else begin
                if SystemSetupFile.Open(RetailSetupGlobal."Path Filename to User Profile" ) then begin
                  SystemSetupFile.Read(Decimal);
                  SystemSetupFile.Close;
                end else begin
                  Message(Text10600055);
                  if PAGE.RunModal(PAGE::"Register List", Register) = ACTION::LookupOK then begin
                    Commit;
                    Register.setThisRegisterNo(Register."Register No.");
                    exit(Register."Register No.");
                  end else
                    exit('?');
                end;
              end;
              RegisterNo := StrSubstNo('%1',(Decimal/3.5 + 2));
              if RegisterNo <> '0' then
                exit(RegisterNo)
              else begin
                Message(Text10600056);
                exit('?');
              end;
            end;
          RetailSetupGlobal."Get register no. using"::COMPUTERNAME,
          RetailSetupGlobal."Get register no. using"::CLIENTNAME,
          RetailSetupGlobal."Get register no. using"::SESSIONNAME,
          RetailSetupGlobal."Get register no. using"::USERNAME,
          RetailSetupGlobal."Get register no. using"::USERID:
            begin
              Register2.Reset;
              Register2.SetCurrentKey("Logon-User Name");
              Register2.SetRange("Logon-User Name",EnvironmentMgt.ClientEnvironment(Format(RetailSetupGlobal."Get register no. using")));
              if Register2.Find('-') then
                exit(Register2."Register No.")
              else
                if PAGE.RunModal(PAGE::"Register List", Register) = ACTION::LookupOK then begin
                  Register.setThisRegisterNo(Register."Register No.");
                  Commit;
                  exit(Register."Register No.");
                end else
                  exit('?');
            end;
          RetailSetupGlobal."Get register no. using"::USERDOMAINID:
            exit('?');
          RetailSetupGlobal."Get register no. using"::"USER SETUP TABLE":
            begin
              if not UserSetup.Get(UserId) then begin
                if PAGE.RunModal(PAGE::"Register List", Register) = ACTION::LookupOK then begin
                  Register.setThisRegisterNo(Register."Register No.");
                  Commit;
                  exit(Register."Register No.");
                end else
                  exit('?');
              end;
              exit(UserSetup."Backoffice Register No.");
            end;
        end;
    end;

    local procedure "--Events"()
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnValidateSaleLinePosBeforePostingEvent(var SalePOS: Record "Sale POS";var SaleLinePos: Record "Sale Line POS";var AuditRole: Record "Audit Roll")
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnBeforeAuditRoleLineInsertEvent(var SalePOS: Record "Sale POS";var SaleLinePos: Record "Sale Line POS";var AuditRole: Record "Audit Roll")
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnBeforeBalancingEvent(var SalePOS: Record "Sale POS";var Register: Record Register)
    begin
    end;
}

