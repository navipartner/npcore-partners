codeunit 6014553 "NPR Touch: Payment Line POS"
{
    // NPR70.00.01.01/RMT/20150108 CASE 203161 - added HideInputDialog to make it possible to suppress the amount dialog in NoOnvalidate
    // NPR70.00.02.01/MH/20150216  CASE 204110 Removed Loyalty Module
    // 
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.14/MMV/20150729 CASE 216519 Set key to make sure the last line no. is properly hit when inserting payment line.
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.18/AP/20151113 CASE 226725 MobilePay
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.20/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 226725 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.20/BR/20160226 CASE 231481 fixed error message when cancelling a Terminal transaction at screen for enterning amount
    // NPR5.20/JDH/20160321 CASE 237255 Changed function CreateGiftVoucher - parameter ThisAmount changed from text to dec
    // NPR5.25/TTH/20160718 CASE 238859 Adding the Swipp payment method invoke code to NoOnValidate Trigger
    // NPR5.25/TSA/20160617 CASE 244655 Added implementation for already existing Boolean "Match Sales Amount" to suppress NumPad dialog on card payments
    // NPR5.25/VB/20160702 CASE 246015 Caching of payment lines and sending deltas to front end
    // NPR5.25/TTH/20160725 CASE 238859 Commented out message of successful transaction per request from Mark.
    // NPR5.29/TSA/20170110  CASE 263109 Added TRUE for insert trigger on the credit voucher table in function CreateGiftVoucher
    // NPR5.30/TJ /20170213  CASE 264909 Commented out Swipp code
    // NPR5.30.01/JDH/20170330 CASE      Removed references to Swipp objects
    // NPR5.31/CLVA/20161205 CASE 251884 Added support for IOS payment terminal(mPos)
    // NPR5.31/ANEN/2017004014 CASE 269031 Added LCY to caption when showing foreign amount
    // NPR5.36/TJ  /20170906 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.46/MMV /20181002 CASE 290734 EFT Framework refactoring
    // NPR5.47/JDH /20181030 CASE 333988 Removed reference to Object MobilePOSAPI - it was deleted in previous version
    // NPR5.48/JDH /20181106 CASE 334584 Function GetPaymentLines. Renamed Parameter from Grid to DGrid. Grid is a reserved word in Ext V2
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles


    var
        SaleLinePOSGlobal: Record "NPR Sale Line POS";
        RetailSetupGlobal: Record "NPR Retail Setup";
        AmountPayed: Decimal;
        BalanceGlobal: Decimal;
        RoundingAmount: Decimal;
        AmountGlobal: Decimal;
        ReturnRoundingAmount: Decimal;
        VATAmount: Decimal;
        AmountExclVAT: Decimal;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        RoundedAmountGlobal: Decimal;
        Text10600002: Label 'Balance must be negative to enter credit voucher';

    procedure SetTableView(RegisterNo: Code[20]; SalesTicketNo: Code[20])
    begin
        SaleLinePOSGlobal.SetRange(Type, SaleLinePOSGlobal.Type::Payment);
        SaleLinePOSGlobal.SetRange("Register No.", RegisterNo);
        SaleLinePOSGlobal.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOSGlobal.Type := SaleLinePOSGlobal.Type::Payment;
        SaleLinePOSGlobal."Sales Ticket No." := SalesTicketNo;
        SaleLinePOSGlobal."Register No." := RegisterNo;
    end;

    procedure CalculateBalance(var Balance2: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        Decimal: Decimal;
        Counter: Integer;
        Register: Record "NPR Register";
        PaymentType1: Record "NPR Payment Type POS";
        Txt001: Label 'You have to set a return payment type on the register';
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        DiscountRounding: Decimal;
    begin
        //UdregnSaldo
        with SaleLinePOSGlobal do begin
            BalanceGlobal := 0;
            ReturnRoundingAmount := 0;

            SaleLinePOS.SetCurrentKey("Discount Type");
            ;
            SaleLinePOS.SetRange(SaleLinePOS."Register No.", "Register No.");
            SaleLinePOS.SetRange(SaleLinePOS."Sales Ticket No.", "Sales Ticket No.");

            SaleLinePOS.SetFilter("Sale Type", '%1|%2', SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::Deposit);
            SaleLinePOS.SetRange("Discount Type");
            if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
                BalanceGlobal := SaleLinePOS."Amount Including VAT";

            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::"Out payment");
            SaleLinePOS.SetFilter("Discount Type", '<>%1', "Discount Type"::Rounding);
            if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
                BalanceGlobal := BalanceGlobal - SaleLinePOS."Amount Including VAT";

            AmountGlobal := BalanceGlobal;
            Register.Get("Register No.");
            //-NPR5.53 [371955]
            POSUnit.Get("Register No.");
            POSSetup.SetPOSUnit(POSUnit);
            //+NPR5.53 [371955]

            if not TouchScreenFunctions.GetPaymentType(PaymentType1, Register, Register."Return Payment Type") then
                Error(Txt001);
            RoundedAmountGlobal := TouchScreenFunctions.Round2Payment(PaymentType1, AmountGlobal);

            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Payment);
            SaleLinePOS.SetRange("Discount Type");
            if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
                AmountPayed := SaleLinePOS."Amount Including VAT";

            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::"Out payment");
            SaleLinePOS.SetRange("Discount Type", "Discount Type"::Rounding);
            if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
                RoundingAmount := SaleLinePOS."Amount Including VAT";

            DiscountRounding := RetailFormCode.GetDiscountRounding("Sales Ticket No.", "Register No.");

            RoundingAmount += DiscountRounding;

            BalanceGlobal := BalanceGlobal - AmountPayed - RoundingAmount;
            Balance2 := BalanceGlobal;

            if BalanceGlobal < 0 then
                if RetailSetupGlobal.Get then
                    //IF (Register.Rounding <> '') AND (RetailSetupGlobal."Amount Rounding Precision" > 0) THEN BEGIN  //NPR5.53 [371955]-revoked
                    if (POSSetup.RoundingAccount(false) <> '') and (POSSetup.AmountRoundingPrecision > 0) then begin  //NPR5.53 [371955]
                        Decimal := Abs(BalanceGlobal) - Round(Abs(BalanceGlobal), 1, '<');
                        Counter := 0;
                        //ReturnRoundingAmount := Counter * RetailSetupGlobal."Amount Rounding Precision" - Decimal;  //NPR5.53 [371955]-revoked
                        ReturnRoundingAmount := Counter * POSSetup.AmountRoundingPrecision - Decimal;  //NPR5.53 [371955]
                        repeat
                            Counter := Counter + 1;
                            //-NPR5.53 [371955]-revoked
                            //  IF ABS(Counter * RetailSetupGlobal."Amount Rounding Precision" - Decimal) <= ABS(ReturnRoundingAmount) THEN
                            //    ReturnRoundingAmount := Counter * RetailSetupGlobal."Amount Rounding Precision" - Decimal;
                            //UNTIL Counter * RetailSetupGlobal."Amount Rounding Precision" >= 1;
                            //+NPR5.53 [371955]-revoked
                            //-NPR5.53 [371955]
                            if Abs(Counter * POSSetup.AmountRoundingPrecision - Decimal) <= Abs(ReturnRoundingAmount) then
                                ReturnRoundingAmount := Counter * POSSetup.AmountRoundingPrecision - Decimal;
                        until Counter * POSSetup.AmountRoundingPrecision >= 1;
                        //+NPR5.53 [371955]
                    end;

            SaleLinePOS.CalcSums(SaleLinePOS.Amount);
            AmountExclVAT := SaleLinePOS.Amount;
            // Saldo := Linie."Bel�b inkl. moms";
            VATAmount := BalanceGlobal - AmountExclVAT;
        end;
    end;

    procedure CreateGiftVoucher(var SaleLinePOS: Record "NPR Sale Line POS"; thisAmount: Decimal): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
        SalePOS: Record "NPR Sale POS";
        ActionTaken: Action;
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Utility: Codeunit "NPR Utility";
    begin
        //OpretTilgodeBevis
        with SaleLinePOSGlobal do begin
            CreditVoucher.Init;

            CalculateBalance(BalanceGlobal);

            CreditVoucher.Amount := BalanceGlobal;

            //-NPR5.20
            //IF thisAmount <> '' THEN BEGIN
            //  EVALUATE(Tilgodebevis.Amount, thisAmount);
            //  Tilgodebevis.Amount := -Tilgodebevis.Amount;
            //END;
            CreditVoucher.Amount := -thisAmount;
            //+NPR5.20

            if CreditVoucher.Amount >= 0 then
                Error(Text10600002)
            else begin
                if RetailSetup.Get then begin
                    RetailSetup.TestField("Credit Voucher No. Management");
                    NoSeriesMgt.InitSeries(RetailSetup."Credit Voucher No. Management",
                                              RetailSetup."Credit Voucher No. Management", 0D, CreditVoucher."No.", RetailSetup."Credit Voucher No. Management");
                    if RetailSetup."EAN Mgt. Credit voucher" <> '' then
                        CreditVoucher."No." := Utility.CreateEAN(CreditVoucher."No.", Format(RetailSetup."EAN Mgt. Credit voucher"));
                end;
                CreditVoucher.Amount := Abs(CreditVoucher.Amount);

                CreditVoucher."Sales Ticket No." := "Sales Ticket No.";
                CreditVoucher."Register No." := "Register No.";
                CreditVoucher."Issue Date" := Today;
                CreditVoucher.Status := CreditVoucher.Status::Cancelled;
                CreditVoucher."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
                CreditVoucher."Location Code" := SaleLinePOS."Location Code";
                if SalePOS.Get("Register No.", "Sales Ticket No.") then
                    CreditVoucher.Salesperson := SalePOS."Salesperson Code";
                //-+NPR5.29 [263109] Tilgodebevis.INSERT;
                CreditVoucher.Insert(true);
                Commit;
                if RetailSetup."Show Create Credit Voucher" then
                    ActionTaken := PAGE.RunModal(PAGE::"NPR Create Credit Voucher", CreditVoucher);
                if (ActionTaken = ACTION::LookupOK) or not RetailSetup."Show Create Credit Voucher" then begin
                    SaleLinePOS."Unit Price" := CreditVoucher.Amount;
                    SaleLinePOS."Amount Including VAT" := CreditVoucher.Amount;
                    SaleLinePOS.Amount := CreditVoucher.Amount;
                    SaleLinePOS."Credit voucher ref." := CreditVoucher."No.";
                end else begin
                    if CreditVoucher.Get(CreditVoucher."No.") then
                        CreditVoucher.Delete;
                    exit(false);
                end;

            end;
            exit(true);
        end;
    end;

    procedure GETPOSITION(): Text
    begin
        //-NPR4.11
        if SaleLinePOSGlobal.Find then
            exit(SaleLinePOSGlobal.GetPosition())
        else
            exit('');
        //+NPR4.11
    end;
}

