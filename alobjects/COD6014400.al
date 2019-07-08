codeunit 6014400 "Retail Table Code"
{
    // NPR3.1, NPK, DL, 19-05-08, Added replication functions
    // 11-03-09 Jerome Removed replication
    // NPR70.00.00.02/LS/20141222  CASE 201562  Commented code VaregruppeOnInsert
    // NPR4.12/JDH/20150708  CASE 217903 removed old unused code
    // NPR4.18/RA/20160111  CASE 230569 Secure that Giftvoucher is updated in global company
    // NPR4.18/MMV/20160119  CASE 232201 Updated old gift voucher print code.
    // NPR4.21/RMT/20160210 CASE 234145 Checking that the register no. is an integer value
    // NPR5.27/JLK /20160829  CASE NPR5.27 Added function ELCommonCreate to Create Exchange Labels to Global Company depending on Retail Configuration and I-Comm Setup
    // NPR5.27/JDH /20161017  CASE 255575 Removed unused code
    // NPR5.31/BHR/20170426 CASE 269001 Corrected bug so that Global company is updated accordingly.

    TableNo = "Gift Voucher";

    trigger OnRun()
    var
        GiftVoucher: Record "Gift Voucher";
    begin
        //-NPR4.18
        GiftVoucher.SetRange("No.", "No.");
        GiftVoucher.PrintGiftVoucher(false,false);
        //+NPR4.18
    end;

    var
        RetailSetup: Record "Retail Setup";
        Text001: Label '%1 must be an integer';
        IComm: Record "I-Comm";

    procedure CreateItemGroupNoSeries(var ItemGroup: Record "Item Group")
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        PreCode: Label 'vgr';
        txtDescr: Label 'Automatic Created Item Group No. Series';
    begin
        //OpretVaregruppeNummerserie()
        NoSeries.Init;
        NoSeries.Code := PreCode + ItemGroup."No.";
        NoSeries.Description := txtDescr;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert;
        NoSeriesLine.Init;
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := '1';
        NoSeriesLine."Last No. Used" := '1';
        NoSeriesLine.Insert;
        ItemGroup."No. Series" := NoSeries.Code;
        ItemGroup.Modify;
    end;

    procedure CreateCustFromContact(var Contact: Record Contact): Boolean
    var
        Cust: Record Customer;
    begin
        //CreateCustFromContact()
        with Contact do begin
          if Cust.Get( "No." ) then
            exit( false );
          Cust.Init;
          Cust."No." := "No.";
          Cust.Name := Name;
          Cust."Search Name" := "Search Name";
          Cust."Name 2" := "Name 2";
          Cust.Address := Address;
          Cust."Address 2" := "Address 2";
          Cust."Post Code" := "Post Code";
          Cust."Country/Region Code" := "Country/Region Code";
          Cust.City := City;
          Cust.Contact := "No.";
          Cust."Phone No." := "Phone No.";
          Cust."Telex No." := "Telex No.";
          Cust."E-Mail" := "E-Mail";
          Cust."Prices Including VAT" := true;
          Cust.Insert(true);
        end;
        exit( true );
    end;

    procedure GiftVoucherCommonCreate(var GiftVoucher: Record "Gift Voucher")
    var
        GlobalGiftVoucher: Record "Gift Voucher";
        ErrExists: Label 'Gift Voucher %1 is already created in the common company!';
    begin
        //GVCreateCommon()

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit;
        IComm.Get;

        GlobalGiftVoucher.ChangeCompany( IComm."Company - Clearing" );
        if GlobalGiftVoucher.Get( GiftVoucher."No." ) then
          Error( ErrExists, GiftVoucher."No." );
        GlobalGiftVoucher.Copy( GiftVoucher );
        GlobalGiftVoucher.Insert;
        GlobalGiftVoucher."Created in Company" := RetailSetup."Company No.";
        GlobalGiftVoucher.Modify;
    end;

    procedure GiftVoucherCommonValidate(var SaleHeader: Record "Sale POS";GiftVoNo: Code[20];Status: Integer)
    var
        GlobalGiftVoucher: Record "Gift Voucher";
        ErrNotExist: Label 'Gift Voucher %1 does not exist in Common Company';
        ErrNotOpen: Label 'The Gift Voucher has been Cashed in %1 the %2';
        ErrNotCashed: Label 'Gift Voucher %1 is not cashed';
    begin
        //GVValidateCommon()

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit;

        IComm.Get;
        GlobalGiftVoucher.ChangeCompany( IComm."Company - Clearing" );
        if not GlobalGiftVoucher.Get( GiftVoNo ) then
          Error( ErrNotExist, GiftVoNo );

        if Status = GlobalGiftVoucher.Status::Open then begin
          if not ( GlobalGiftVoucher.Status = GlobalGiftVoucher.Status::Cashed ) then
            Error( ErrNotCashed, GiftVoNo );
        end;

        if ( Status = GlobalGiftVoucher.Status::Cancelled ) or ( Status = GlobalGiftVoucher.Status::Cashed ) then begin
          if not ( GlobalGiftVoucher.Status = GlobalGiftVoucher.Status::Open ) then
            Error( ErrNotOpen, GlobalGiftVoucher."Cashed in Store", GlobalGiftVoucher."Cashed Date" );
        end;

        if Status = GlobalGiftVoucher.Status::Cashed then begin
          GlobalGiftVoucher."Cashed in Store"             := RetailSetup."Company No.";
          GlobalGiftVoucher."Cashed on Register No."      := SaleHeader."Register No.";
          GlobalGiftVoucher."Cashed on Sales Ticket No."  := SaleHeader."Sales Ticket No.";
          GlobalGiftVoucher."Cashed Date"                 := Today;
          GlobalGiftVoucher."Cashed Salesperson"          := SaleHeader."Salesperson Code";
          GlobalGiftVoucher."Cashed in Global Dim 1 Code" := SaleHeader."Shortcut Dimension 1 Code";
          GlobalGiftVoucher."Cashed in Global Dim 2 Code" := SaleHeader."Shortcut Dimension 2 Code";
          GlobalGiftVoucher."Cashed in Location Code"     := SaleHeader."Location Code";
          GlobalGiftVoucher."Cashed External"             := true;
        end else begin
          GlobalGiftVoucher."Cashed in Store"             := '';
          GlobalGiftVoucher."Cashed on Register No."      := '';
          GlobalGiftVoucher."Cashed on Sales Ticket No."  := '';
          GlobalGiftVoucher."Cashed Date"                 := 0D;
          GlobalGiftVoucher."Cashed Salesperson"          := '';
          GlobalGiftVoucher."Cashed in Global Dim 1 Code" := '';
          GlobalGiftVoucher."Cashed in Global Dim 2 Code" := '';
          GlobalGiftVoucher."Cashed in Location Code"     := '';
          GlobalGiftVoucher."Cashed External"             := false;
        end;
        GlobalGiftVoucher.Status := Status;
        GiftVoucherCommonClearOrig( GlobalGiftVoucher );
        GlobalGiftVoucher.Modify;
    end;

    procedure GiftVoucherCommonOfflineModify(var GiftVoucher: Record "Gift Voucher")
    var
        GlobalGiftVoucher: Record "Gift Voucher";
        t001: Label 'Gift Voucher %1 is not created in the common company!';
    begin
        //GVCommonModify

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit;

        IComm.Get;
        if IComm."Company - Clearing" = '' then
          exit;

        GlobalGiftVoucher.ChangeCompany( IComm."Company - Clearing" );
        if not GlobalGiftVoucher.Get( GiftVoucher."No." ) then
          Error( t001, GiftVoucher."No." );

        with GiftVoucher do begin
          GlobalGiftVoucher."Register No."              := "Register No.";
          GlobalGiftVoucher."Sales Ticket No."          := "Sales Ticket No.";
          GlobalGiftVoucher.Reference                   := Reference;
          GlobalGiftVoucher."Issue Date"                := "Issue Date";
          GlobalGiftVoucher.Salesperson                 := Salesperson;
          GlobalGiftVoucher."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
          GlobalGiftVoucher."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
          GlobalGiftVoucher."Location Code"             := "Location Code";
          GlobalGiftVoucher.Status                      := Status::Open;
          GlobalGiftVoucher.Amount                      := Amount;
          GlobalGiftVoucher."Customer Type"             := "Customer Type";
          GlobalGiftVoucher."Customer No."              := "Customer No.";
          GlobalGiftVoucher."Offline - No."             := "Offline - No.";
          GlobalGiftVoucher.Offline                     := Offline;
          //-NPR4.18
          GlobalGiftVoucher."Last Date Modified"        := Today;
          GlobalGiftVoucher."Primary Key Length"        := StrLen(GlobalGiftVoucher."No.");
          GlobalGiftVoucher.Modify;
          //+NPR4.18
        end;
    end;

    procedure GiftVoucherCommonClearOrig(var GiftVoucher: Record "Gift Voucher"): Boolean
    var
        CompanyDetailed: Record "Company All";
        GlobalGiftVoucher: Record "Gift Voucher";
    begin
        //GVCommonClearOrig

        exit(true);  // not to be used yet

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit(false);

        IComm.Get;

        CompanyDetailed.Reset;
        CompanyDetailed.SetCurrentKey(Afdeling);
        CompanyDetailed.SetRange(Afdeling, GiftVoucher."Created in Company");
        if not CompanyDetailed.Find('-') then
          exit( false );

        GlobalGiftVoucher.ChangeCompany( CompanyDetailed.Company );

        if not GlobalGiftVoucher.Get( GiftVoucher."No." ) then
          exit( false );

        GlobalGiftVoucher.Status := GiftVoucher.Status;
        GlobalGiftVoucher."Cashed in Store" := GiftVoucher."Cashed in Store";
        GlobalGiftVoucher.Modify;

        exit(true);
    end;

    procedure CreditVoucherCommonCreate(var CreditVoucher: Record "Credit Voucher")
    var
        GlobalCreditVoucher: Record "Credit Voucher";
        ErrExists: Label 'Credit Voucher %1 is already created in the common company!';
    begin
        //CVCreateCommon()

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit;
        IComm.Get;

        GlobalCreditVoucher.ChangeCompany( IComm."Company - Clearing" );
        if GlobalCreditVoucher.Get( CreditVoucher."No." ) then
          Error( ErrExists, CreditVoucher."No." );
        GlobalCreditVoucher.Copy( CreditVoucher );
        GlobalCreditVoucher.Insert;
        GlobalCreditVoucher."Created in Company" := RetailSetup."Company No.";
        GlobalCreditVoucher.Modify;
    end;

    procedure CreditVoucherCommonValidate(var SaleHeader: Record "Sale POS";CreditVoNo: Code[20];Status: Integer)
    var
        ErrNotExist: Label 'Credit Voucher %1 does not exist in Common Company';
        ErrNotOpen: Label 'The Credit Voucher has been Cashed in %1 the %2';
        GlobalCreditVoucher: Record "Credit Voucher";
        ErrNotCashed: Label 'Status for Credit Voucher %1 is not cashed';
    begin
        //CVValidateCommon()

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit;
        IComm.Get;

        GlobalCreditVoucher.ChangeCompany( IComm."Company - Clearing" );
        if not GlobalCreditVoucher.Get( CreditVoNo ) then
          Error( ErrNotExist, CreditVoNo );

        if Status = GlobalCreditVoucher.Status::Open then begin
          if not ( GlobalCreditVoucher.Status = GlobalCreditVoucher.Status::Cashed ) then
            Error( ErrNotCashed, CreditVoNo );
        end;

        if ( Status = GlobalCreditVoucher.Status::Cancelled ) or ( Status = GlobalCreditVoucher.Status::Cashed ) then begin
          if not ( GlobalCreditVoucher.Status = GlobalCreditVoucher.Status::Open ) then
            Error( ErrNotOpen, GlobalCreditVoucher."Cashed in store", GlobalCreditVoucher."Cashed Date" );
        end;

        if Status = GlobalCreditVoucher.Status::Cashed then begin
          GlobalCreditVoucher."Cashed in store" := RetailSetup."Company No.";
          GlobalCreditVoucher."Cashed on Register No." := SaleHeader."Register No.";
          GlobalCreditVoucher."Cashed on Sales Ticket No." := SaleHeader."Sales Ticket No.";
          GlobalCreditVoucher."Cashed Date" := Today;
          GlobalCreditVoucher."Cashed Salesperson" := SaleHeader."Salesperson Code";
          GlobalCreditVoucher."Cashed in Global Dim 1 Code" := SaleHeader."Shortcut Dimension 1 Code";
          GlobalCreditVoucher."Cashed in Location Code" := SaleHeader."Location Code";
          GlobalCreditVoucher."Cashed External" := true;
        end else begin
          GlobalCreditVoucher."Cashed in store" := '';
          GlobalCreditVoucher."Cashed on Register No." := '';
          GlobalCreditVoucher."Cashed on Sales Ticket No." := '';
          GlobalCreditVoucher."Cashed Date" := 0D;
          GlobalCreditVoucher."Cashed Salesperson" := '';
          GlobalCreditVoucher."Cashed in Global Dim 1 Code" := '';
          GlobalCreditVoucher."Cashed in Location Code" := '';
          GlobalCreditVoucher."Cashed External" := false;
        end;
        GlobalCreditVoucher.Status := Status;
        CreditVoucherCommonClearOrig( GlobalCreditVoucher );
        GlobalCreditVoucher.Modify;
    end;

    procedure CreditVoucherCommonClearOrig(var CreditVoucher: Record "Credit Voucher"): Boolean
    var
        CompanyDetailed: Record "Company All";
        GlobalCreditVoucher: Record "Credit Voucher";
    begin
        //GVCommonClearOrig

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit(false);

        IComm.Get;

        CompanyDetailed.Reset;
        CompanyDetailed.SetCurrentKey(Afdeling);
        CompanyDetailed.SetRange(Afdeling, CreditVoucher."Created in Company");
        if not CompanyDetailed.Find('-') then
          exit( false );

        GlobalCreditVoucher.ChangeCompany( CompanyDetailed.Company );

        if not GlobalCreditVoucher.Get( CreditVoucher."No." ) then exit( false );

        GlobalCreditVoucher.Status := CreditVoucher.Status;
        GlobalCreditVoucher."Cashed in store" := CreditVoucher."Cashed in store";
        GlobalCreditVoucher.Modify;

        exit(true);
    end;

    procedure CreditVoucherCommonModify(CreditVoucher: Record "Credit Voucher")
    var
        GlobalCreditVoucher: Record "Credit Voucher";
    begin
        //CVCommonModify

        RetailSetup.Get;
        if not RetailSetup."Use I-Comm" then
          exit;

        IComm.Get;
        if IComm."Company - Clearing" = '' then
          exit;

        GlobalCreditVoucher.ChangeCompany( IComm."Company - Clearing" );
        if not GlobalCreditVoucher.Get(CreditVoucher."No.") then ;

        GlobalCreditVoucher.Status := CreditVoucher.Status;
        //-NPR5.31 [269001]
        //GlobalCreditVoucher.MODIFY( TRUE );
        GlobalCreditVoucher.Modify;
        //-NPR5.31 [269001]
    end;

    procedure RegisterCheckNo(RegisterNo: Code[10])
    var
        int: Integer;
        dec: Decimal;
    begin
        //-NPR4.21
        if not (Evaluate(int,RegisterNo) and Evaluate(dec,RegisterNo)) then
          if not (int=dec) then
            Error(Text001,RegisterNo);
        //+NPR4.21
    end;

    procedure ExchLabelCommonCreate(var ExchangeLabel: Record "Exchange Label")
    var
        ErrorRecordExist: Label 'Exchange label %1 is already created in the common company!';
        GlobalExchangeLabel: Record "Exchange Label";
    begin
        //-NPR5.27
        RetailSetup.Get;

        if not RetailSetup."Use I-Comm" then
          exit;

        IComm.Get;

        if (IComm."Exchange Label Center Company" = '') or (IComm."Company - Clearing" = '') then
          exit;

        GlobalExchangeLabel.ChangeCompany(IComm."Company - Clearing");

        if GlobalExchangeLabel.Get(ExchangeLabel."Store ID",ExchangeLabel."No.",ExchangeLabel."Batch No.") then
          Error(ErrorRecordExist,ExchangeLabel."No.");

        GlobalExchangeLabel.Copy(ExchangeLabel);
        GlobalExchangeLabel.Insert;
        GlobalExchangeLabel."Company Name" := CompanyName;
        GlobalExchangeLabel.Modify;
        //+NPR5.27
    end;
}

