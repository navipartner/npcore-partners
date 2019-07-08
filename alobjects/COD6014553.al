codeunit 6014553 "Touch - Payment Line POS"
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


    trigger OnRun()
    begin
    end;

    var
        SaleLinePOSGlobal: Record "Sale Line POS";
        RetailSetupGlobal: Record "Retail Setup";
        AmountPayed: Decimal;
        BalanceGlobal: Decimal;
        RoundingAmount: Decimal;
        AmountGlobal: Decimal;
        ReturnRoundingAmount: Decimal;
        SaleLinePOSGlobal2: Record "Sale Line POS";
        FindSaleLinePOS: Boolean;
        VATAmount: Decimal;
        AmountExclVAT: Decimal;
        RetailFormCode: Codeunit "Retail Form Code";
        PaymentTypePOSGlobal: Record "Payment Type POS";
        Register: Record Register;
        ErrorStr: Text[250];
        RoundedAmountGlobal: Decimal;
        Text10600002: Label 'Balance must be negative to enter credit voucher';
        Text10600003: Label 'Error';
        HideInputDialog: Boolean;
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        POSWebUIMgt: Codeunit "POS Web UI Management";
        mPOSTransCancelErr: Label 'Payment was not successful';
        mPOSNoCashBackErr: Label 'It is not allowed to enter an amount that is bigger than what is stated on the receipt for this payment type';

    procedure SetTableView(RegisterNo: Code[20];SalesTicketNo: Code[20])
    begin
        SaleLinePOSGlobal.SetRange(Type,SaleLinePOSGlobal.Type::Payment);
        SaleLinePOSGlobal.SetRange("Register No.",RegisterNo);
        SaleLinePOSGlobal.SetRange("Sales Ticket No.",SalesTicketNo);
        SaleLinePOSGlobal.Type := SaleLinePOSGlobal.Type::Payment;
        SaleLinePOSGlobal."Sales Ticket No." := SalesTicketNo;
        SaleLinePOSGlobal."Register No." := RegisterNo;
    end;

    procedure CalculateBalance(var Balance2: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        Decimal: Decimal;
        Counter: Integer;
        Register: Record Register;
        PaymentType1: Record "Payment Type POS";
        Txt001: Label 'You have to set a return payment type on the register';
        DiscountRounding: Decimal;
    begin
        //UdregnSaldo
        with SaleLinePOSGlobal do begin
          BalanceGlobal := 0;
          ReturnRoundingAmount := 0;

          SaleLinePOS.SetCurrentKey("Discount Type");;
          SaleLinePOS.SetRange(SaleLinePOS."Register No.","Register No.");
          SaleLinePOS.SetRange(SaleLinePOS."Sales Ticket No.","Sales Ticket No.");

          SaleLinePOS.SetFilter("Sale Type",'%1|%2',SaleLinePOS."Sale Type"::Sale,SaleLinePOS."Sale Type"::Deposit);
          SaleLinePOS.SetRange("Discount Type");
          if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
            BalanceGlobal := SaleLinePOS."Amount Including VAT";

          SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::"Out payment");
          SaleLinePOS.SetFilter("Discount Type",'<>%1',"Discount Type"::Rounding);
          if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
            BalanceGlobal := BalanceGlobal - SaleLinePOS."Amount Including VAT";

          AmountGlobal := BalanceGlobal;
          Register.Get("Register No.");

          if not TouchScreenFunctions.GetPaymentType(PaymentType1,Register,Register."Return Payment Type") then
            Error(Txt001);
          RoundedAmountGlobal := TouchScreenFunctions.Round2Payment(PaymentType1,AmountGlobal);

          SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::Payment);
          SaleLinePOS.SetRange("Discount Type");
          if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
            AmountPayed := SaleLinePOS."Amount Including VAT";

          SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::"Out payment");
          SaleLinePOS.SetRange("Discount Type","Discount Type"::Rounding);
          if SaleLinePOS.CalcSums(SaleLinePOS."Amount Including VAT") then
            RoundingAmount := SaleLinePOS."Amount Including VAT";

          DiscountRounding := RetailFormCode.GetDiscountRounding("Sales Ticket No.","Register No.");

          RoundingAmount += DiscountRounding;

          BalanceGlobal := BalanceGlobal - AmountPayed - RoundingAmount;
          Balance2 := BalanceGlobal;

          if BalanceGlobal < 0 then
            if RetailSetupGlobal.Get then
              if (Register.Rounding <> '') and (RetailSetupGlobal."Amount Rounding Precision" > 0) then begin
                Decimal := Abs(BalanceGlobal) - Round(Abs(BalanceGlobal),1,'<');
                Counter := 0;
                ReturnRoundingAmount := Counter * RetailSetupGlobal."Amount Rounding Precision" - Decimal;
                repeat
                  Counter := Counter + 1;
                  if Abs(Counter * RetailSetupGlobal."Amount Rounding Precision" - Decimal) <= Abs(ReturnRoundingAmount) then
                    ReturnRoundingAmount := Counter * RetailSetupGlobal."Amount Rounding Precision" - Decimal;
                until Counter * RetailSetupGlobal."Amount Rounding Precision" >= 1;
              end;


          SaleLinePOS.CalcSums(SaleLinePOS.Amount);
          AmountExclVAT := SaleLinePOS.Amount;
          // Saldo := Linie."Bel�b inkl. moms";
          VATAmount := BalanceGlobal - AmountExclVAT;
        end;
    end;

    procedure CreatePaymentLine(PaymentMethodCode: Code[10];AmountInclVAT: Decimal;RegisterNo: Code[10];SalesTicketNo: Code[10];SaleLinePOSDate: Date;DiscountCode: Code[10];Entered: Boolean;TransferText: Text[30]) ReturnNo: Integer
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS2: Record "Sale Line POS";
        LineNo: Integer;
    begin
        //OpretBetalingslinie
        with SaleLinePOSGlobal do begin
          ReturnNo := 1;
        
          PaymentTypePOSGlobal.Get(PaymentMethodCode);
        
          SaleLinePOS.Reset;
          //-NPR4.14
          SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
          //+NPR4.14
          SaleLinePOS.SetRange("Register No.",RegisterNo);
          SaleLinePOS.SetRange("Sales Ticket No.",SalesTicketNo);
          SaleLinePOS.SetFilter("Line No.",'> %1',"Line No.");
        
          if SaleLinePOS.Find('+') then begin
             LineNo := SaleLinePOS."Line No." + 10000;
          end else begin
             LineNo := "Line No." + 10000;
          end;
        
          SaleLinePOS2."Register No." := RegisterNo;
          SaleLinePOS2."Sales Ticket No." := SalesTicketNo;
          SaleLinePOS2."Line No." := LineNo;
          SaleLinePOS2.Date := SaleLinePOSDate;
          SaleLinePOS2."Sale Type" := "Sale Type"::Payment;
          SaleLinePOS2.Type := Type::Payment;
          SaleLinePOS2.Quantity := 0;               // skal v�re 0
          SaleLinePOS2."Discount Code" := DiscountCode;
          SaleLinePOS2."Amount Including VAT" := AmountInclVAT;
          SaleLinePOS2.Validate("No.",PaymentMethodCode);
          SaleLinePOS2.Quantity := 0;               // skal v�re 0
          SaleLinePOS2.Insert(true);
        
          if NoOnValidate(SaleLinePOS2,TransferText) then begin
            SaleLinePOS2.Modify(true)
          end else begin
            SaleLinePOS2.Delete(true);
            Commit;
            exit(1);
          end;
        
          SaleLinePOSGlobal2 := SaleLinePOS2;
          FindSaleLinePOS := false; /*true*/
          CalculateBalance(BalanceGlobal);
        
          if "Amount Including VAT" <> 0 then
            exit(0)
          else
            exit(3);
        end;

    end;

    procedure CurrAmount(SaleLinePOS: Record "Sale Line POS") ReturnAmount: Decimal
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //valutabeloeb
        PaymentTypePOS.Reset;
        PaymentTypePOS.SetRange("No.",SaleLinePOS."No.");
        if PaymentTypePOS.Find('-') then begin
          if PaymentTypePOS."Fixed Rate" <> 0 then
            ReturnAmount := SaleLinePOS."Amount Including VAT" / PaymentTypePOS."Fixed Rate" * 100
          else
            ReturnAmount := SaleLinePOS."Amount Including VAT";
        end else
          ReturnAmount := 0;
    end;

    procedure CurrAmountDec(PaymentCode: Code[10];Amount: Decimal) ReturnAmount: Decimal
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //valutabeloeb
        PaymentTypePOS.Reset;
        PaymentTypePOS.SetRange("No.",PaymentCode);
        if PaymentTypePOS.Find('-') then begin
          if PaymentTypePOS."Fixed Rate" <> 0 then
            ReturnAmount := Amount / PaymentTypePOS."Fixed Rate"*100
          else
            ReturnAmount := Amount;
        end else
          ReturnAmount := 0;
    end;

    procedure DeleteRecord(SaleLinePOSNo: Code[50])
    var
        Txt001: Label 'You can''t delete a transaction completed!';
    begin
        //delrec
        with SaleLinePOSGlobal do begin
          Register.Get("Register No.");

          if SaleLinePOSNo = '' then begin
             if "Cash Terminal Approved" then
               POSEventMarshaller.DisplayError(Text10600003,Txt001,true);
             Delete(true);
             exit;
          end;

          SetRange("No.",SaleLinePOSNo);

          case SaleLinePOSNo of
            Register."Touch Screen Credit Card",
            Register."Touch Screen Terminal Offline":
              begin
                SetRange("Cash Terminal Approved",false);
              end;
          end;

          if Find('-') then
            Delete(true);

          SetRange("No.");
          SetRange("Cash Terminal Approved");

        end;
    end;

    procedure DeleteRecordIfZero()
    var
        L1: Record "Sale Line POS";
    begin
        //delrec
        with SaleLinePOSGlobal do begin
          if "Amount Including VAT" = 0 then
            Delete(true);
        end;
    end;

    procedure CreateGiftVoucher(var SaleLinePOS: Record "Sale Line POS";thisAmount: Decimal): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
        SalePOS: Record "Sale POS";
        ActionTaken: Action;
        RetailSetup: Record "Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Utility: Codeunit Utility;
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
            POSEventMarshaller.DisplayError(Text10600003,Text10600002,true)
          else begin
            if RetailSetup.Get then begin
              RetailSetup.TestField("Credit Voucher No. Management");
              NoSeriesMgt.InitSeries(RetailSetup."Credit Voucher No. Management",
                                        RetailSetup."Credit Voucher No. Management",0D,CreditVoucher."No.",RetailSetup."Credit Voucher No. Management");
              if RetailSetup."EAN Mgt. Credit voucher" <> '' then
                CreditVoucher."No." := Utility.CreateEAN(CreditVoucher."No.",Format(RetailSetup."EAN Mgt. Credit voucher") );
            end;
              CreditVoucher.Amount := Abs(CreditVoucher.Amount);

              CreditVoucher."Sales Ticket No." := "Sales Ticket No.";
              CreditVoucher."Register No." := "Register No.";
              CreditVoucher."Issue Date" := Today;
              CreditVoucher.Status := CreditVoucher.Status::Cancelled;
              CreditVoucher."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
              CreditVoucher."Location Code" := SaleLinePOS."Location Code";
              if SalePOS.Get("Register No.","Sales Ticket No.") then
                CreditVoucher.Salesperson := SalePOS."Salesperson Code";
              //-+NPR5.29 [263109] Tilgodebevis.INSERT;
              CreditVoucher.Insert(true);
              Commit;
              if RetailSetup."Show Create Credit Voucher" then
                ActionTaken := PAGE.RunModal(PAGE::"Create Credit Voucher",CreditVoucher);
              if (ActionTaken = ACTION::LookupOK) or not RetailSetup."Show Create Credit Voucher" then begin
                 SaleLinePOS."Unit Price" := CreditVoucher.Amount;
                 SaleLinePOS."Amount Including VAT" := CreditVoucher.Amount;
                 SaleLinePOS.Amount := CreditVoucher.Amount;
                 SaleLinePOS."Credit voucher ref."  := CreditVoucher."No.";
              end else begin
                if CreditVoucher.Get(CreditVoucher."No.") then
                  CreditVoucher.Delete;
                exit(false);
              end;

          end;
          exit(true);
        end;
    end;

    procedure ExistTerminalApproved() Exists: Boolean
    begin
        //existsTerminalGodkendt
        with SaleLinePOSGlobal do begin
          SetRange("Cash Terminal Approved",true);
          if Find('-') then
            Exists := true
          else
            Exists := false;

          SetRange("Cash Terminal Approved");
          exit(Exists);
        end;
    end;

    procedure GetErrorText(): Text[250]
    begin
        //geterrorstr
        exit(ErrorStr);
    end;

    procedure JumpEnd()
    begin
        //jumpend
        //-NPR4.11
        with SaleLinePOSGlobal do begin
          if FindLast then;
        end;
        //+NPR4.11
    end;

    procedure LastSale(AmountType: Integer): Decimal
    begin
        case AmountType of
          1: exit(AmountGlobal);
          2: exit(AmountPayed);
          3: exit(BalanceGlobal - ReturnRoundingAmount)
        end;
    end;

    procedure LineIsEmpty(): Boolean
    begin
        //isLineEmpty
        with SaleLinePOSGlobal do begin
          exit(IsEmpty);
        end;
    end;

    procedure NoOnValidate(var SaleLinePOS: Record "Sale Line POS";InputString: Text[30]) LookupProcessed: Boolean
    var
        IComm: Codeunit "I-Comm";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        FormattedDecimal: Text[30];
        Txt002: Label 'Terminal solution not setup on this register!';
        Txt003: Label 'No G/L Account defined on the payment type TERMINAL!';
        Txt004: Label 'Terminal Rejected!';
        DecimalVaue: Decimal;
        Txt006: Label 'Type in amount of payment type %1\Amount = %2';
        FormattedDecimal2: Text[30];
        FormattedDecimal3: Text[30];
        Utility: Codeunit Utility;
        Txt010: Label 'No amount given!';
        Txt011: Label 'Maximum payment amount on %1 is %2';
        Txt012: Label 'Minimum payment amount on %1 is %2';
        Txt013: Label 'You can not change the amount of a terminal transaction that has been accepted!';
        Txt014: Label 'You cannot type letters here. Only amount!';
        AddMode: Boolean;
        OldDecimalValue: Decimal;
        ReferenceNo: Code[20];
        Txt015: Label 'Type/scan the gift voucher reference number';
        Txt016: Label 'Type/scan the credit voucher reference number';
        SaleLinePOS2: Record "Sale Line POS";
        PurchaseAmount: Decimal;
        GVLines: Integer;
        MaxAmount: Decimal;
        ExitWithError: Boolean;
        Txt017: Label 'Payment cancelled. ';
        MPOSPaymentAPI: Codeunit "MPOS Payment API";
        Txt006LCY: Label 'Type in amount of payment type %1\Amount = %2, (%3 %4)';
    begin
        //onValidate - Nummer(VAR Lin1 : Record "Ekspedition linie")
        with SaleLinePOSGlobal do begin
          PaymentTypePOSGlobal.Get(SaleLinePOS."No.");
        
          ReferenceNo := '';
        
          FormattedDecimal := POSWebUIMgt.FormatDecimal(CurrAmount(SaleLinePOS));
          //tekst := FORMAT(Lin1."Currency Amount");
          if InputString <> '' then
            FormattedDecimal := InputString;
          if FormattedDecimal <> '' then
            DecimalVaue := POSWebUIMgt.ParseDecimal(FormattedDecimal);
        
          FormattedDecimal2 := POSWebUIMgt.FormatDecimal(DecimalVaue);
          FormattedDecimal3 := POSWebUIMgt.FormatDecimal(TouchScreenFunctions.Round2Payment(PaymentTypePOSGlobal,DecimalVaue));
        
          if PaymentTypePOSGlobal."Forced Amount" then begin
            FormattedDecimal2 := '';
            FormattedDecimal3 := '';
          end;
        
          //-NPR4.18
          MaxAmount := DecimalVaue; //Store initial value to prevent cash-back
          //+NPR4.18
        
          Commit;
        
          /*-----------------------------*/
          /* Betaling."Processing Type" pre-proc. */
        
          if PaymentTypePOSGlobal."Validation Codeunit" <> 0 then begin
            CODEUNIT.Run(PaymentTypePOSGlobal."Validation Codeunit",SaleLinePOS);
            DecimalVaue := SaleLinePOS."Amount Including VAT";
            FormattedDecimal := POSWebUIMgt.FormatDecimal(DecimalVaue);
            if DecimalVaue = 0 then
              exit(false);
          end else begin
            case PaymentTypePOSGlobal."Processing Type" of
                PaymentTypePOSGlobal."Processing Type"::Cash:
                  begin
                    FormattedDecimal := FormattedDecimal3;
                    if not HideInputDialog then
                      ExitWithError := not POSEventMarshaller.NumPadText(StrSubstNo(Txt006,PaymentTypePOSGlobal.Description,DecimalVaue),FormattedDecimal,PaymentTypePOSGlobal."Forced Amount",false)
                    else
                      FormattedDecimal := POSWebUIMgt.FormatDecimal(DecimalVaue);
                  end;
                PaymentTypePOSGlobal."Processing Type"::"Manual Card",PaymentTypePOSGlobal."Processing Type"::"Other Credit Cards",
                PaymentTypePOSGlobal."Processing Type"::"Terminal Card",PaymentTypePOSGlobal."Processing Type"::EFT,
                PaymentTypePOSGlobal."Processing Type"::DIBS:
                  begin
                    if SaleLinePOS."Cash Terminal Approved" then
                      POSEventMarshaller.DisplayError(Text10600003,Txt013,true);
                    FormattedDecimal := FormattedDecimal2;
                    //-NPR5.23 [244655]
                    //IF str = '' THEN
                    if ((InputString = '') and (PaymentTypePOSGlobal."Match Sales Amount" = false)) then
                    //+NPR5.23 [244655]
                      if not POSEventMarshaller.NumPadText(StrSubstNo(Txt006,PaymentTypePOSGlobal.Description,DecimalVaue),FormattedDecimal,PaymentTypePOSGlobal."Forced Amount",false) then begin
                        SaleLinePOS.Delete(true);
                        Commit;
                        //-NPR5.20
                        //Marshaller.Error(Text10600003, STRSUBSTNO(t005,Betaling.Description),TRUE);
                        POSEventMarshaller.DisplayError(Text10600003,StrSubstNo(Txt017,PaymentTypePOSGlobal.Description),true);
                        //+NPR5.20
                      end;
                  end;
                PaymentTypePOSGlobal."Processing Type"::"Credit Voucher",
                PaymentTypePOSGlobal."Processing Type"::"Gift Voucher":;
                PaymentTypePOSGlobal."Processing Type"::"Foreign Currency":
                  begin
                    DecimalVaue := Utility.FormatDec2Dec(DecimalVaue,2);
                    FormattedDecimal := FormattedDecimal3;
                    //-NPR5.31
                    //ExitWithError := NOT Marshaller.NumPadText(STRSUBSTNO(t006,Betaling.Description,dec),tekst,Betaling."Forced Amount",FALSE);
                    ExitWithError := not POSEventMarshaller.NumPadText(StrSubstNo(Txt006LCY,PaymentTypePOSGlobal.Description,DecimalVaue,Utility.FormatDec2Dec(SaleLinePOS."Amount Including VAT",2),'LCY'),
                                                                       FormattedDecimal,PaymentTypePOSGlobal."Forced Amount",false);
                    //+NPR5.31
                    //ExitWithError := NOT Marshaller.NumPadText(STRSUBSTNO(t006,Betaling.Description,dec),tekst,Betaling."Forced Amount",FALSE);
                  end;
                PaymentTypePOSGlobal."Processing Type"::"Foreign Gift Voucher":
                  begin
                    if not PaymentTypePOSGlobal."Common Company Clearing" then begin
                      FormattedDecimal := FormattedDecimal3;
                      ExitWithError := not POSEventMarshaller.NumPadText(StrSubstNo(Txt006,PaymentTypePOSGlobal.Description,DecimalVaue),FormattedDecimal,PaymentTypePOSGlobal."Forced Amount",false);
                      if PaymentTypePOSGlobal."Reference Incoming" then begin
                        if not POSEventMarshaller.NumPadCode(Txt015,ReferenceNo,true,false) then
                          exit(false);
                        DecimalVaue := IComm.TestForeignGiftVoucher(ReferenceNo);
                        SaleLinePOS.Reference := ReferenceNo;
                        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' ' + ReferenceNo,1,30);
                      end;
                    end;
                  end;
                PaymentTypePOSGlobal."Processing Type"::"Foreign Credit Voucher":
                  begin
                    if not PaymentTypePOSGlobal."Common Company Clearing" then begin
                      FormattedDecimal := FormattedDecimal3;
                      ExitWithError := not POSEventMarshaller.NumPadText(StrSubstNo(Txt006,PaymentTypePOSGlobal.Description,DecimalVaue),FormattedDecimal,PaymentTypePOSGlobal."Forced Amount",false);
                      if PaymentTypePOSGlobal."Reference Incoming" then begin
                        if not POSEventMarshaller.NumPadCode(Txt016,ReferenceNo,true,false) then
                          exit(false);
                        DecimalVaue := IComm.TestForeignCreditVoucher(ReferenceNo);
                        SaleLinePOS.Reference := ReferenceNo;
                        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' ' + ReferenceNo,1,30);
                      end;
                    end;
                  end;
                PaymentTypePOSGlobal."Processing Type"::Invoice:
                  begin
                    FormattedDecimal := FormattedDecimal3;
                    ExitWithError := not POSEventMarshaller.NumPadText(StrSubstNo(Txt006,PaymentTypePOSGlobal.Description,DecimalVaue),FormattedDecimal,PaymentTypePOSGlobal."Forced Amount",false);
                  end;
            end;
          end;
        
          if ExitWithError then begin
            ErrorStr := Txt010;
            exit(false);
          end;
        
          AddMode := false;
          if CopyStr(FormattedDecimal,1,1) in ['+','�'] then begin
            FormattedDecimal := CopyStr(FormattedDecimal,3);
            AddMode := true;
          end;
        
          OldDecimalValue := DecimalVaue;
        
          if FormattedDecimal = '' then
            FormattedDecimal := '0';
          if not POSWebUIMgt.TryParseDecimal(DecimalVaue,FormattedDecimal) then begin
            ErrorStr := Txt014 + '\' + FormattedDecimal;
            exit(false);
          end;
        
          if AddMode then
            DecimalVaue += OldDecimalValue;
        
          if PaymentTypePOSGlobal."Maximum Amount" <> 0 then begin
            if DecimalVaue > PaymentTypePOSGlobal."Maximum Amount" then begin
              ErrorStr := StrSubstNo(Txt011,PaymentTypePOSGlobal.Description,PaymentTypePOSGlobal."Maximum Amount");
              exit(false);
            end;
          end;
          if PaymentTypePOSGlobal."Minimum Amount" <> 0 then begin
            if DecimalVaue < PaymentTypePOSGlobal."Minimum Amount" then begin
              ErrorStr := StrSubstNo(Txt012,PaymentTypePOSGlobal.Description,PaymentTypePOSGlobal."Minimum Amount");
              exit(false);
            end;
          end;
        
          SaleLinePOS."Amount Including VAT" := DecimalVaue;
          SaleLinePOS.Modify;
        
          RetailFormCode.InitTS(true,DecimalVaue);
          RetailFormCode.ForeignCurrency(SaleLinePOS);
        
          SaleLinePOS.Modify;
        
          if PaymentTypePOSGlobal."Processing Type" = PaymentTypePOSGlobal."Processing Type"::"Gift Voucher" then begin
            if not PaymentTypePOSGlobal."Human Validation" then begin
              RetailFormCode.InitTS(true,DecimalVaue);
              ErrorStr := InputString;
              LookupProcessed := RetailFormCode.GiftVoucherLookup(SaleLinePOS,ErrorStr);
              exit(LookupProcessed);
            end else begin
              if PaymentTypePOSGlobal."Fixed Amount" > 0 then begin
                SaleLinePOS2.SetCurrentKey("Discount Type");;
                SaleLinePOS2.SetRange(SaleLinePOS2."Register No.","Register No.");
                SaleLinePOS2.SetRange(SaleLinePOS2."Sales Ticket No.","Sales Ticket No.");
                SaleLinePOS2.SetFilter("Sale Type",'%1|%2',SaleLinePOS2."Sale Type"::Sale,SaleLinePOS2."Sale Type"::Deposit);
                SaleLinePOS2.SetRange("Discount Type");
                if SaleLinePOS2.CalcSums(SaleLinePOS2."Amount Including VAT") then
                  PurchaseAmount := SaleLinePOS2."Amount Including VAT";
                Clear(SaleLinePOS2);
                SaleLinePOS2.SetRange(SaleLinePOS2."Register No.","Register No.");
                SaleLinePOS2.SetRange(SaleLinePOS2."Sales Ticket No.","Sales Ticket No.");
                SaleLinePOS2.SetRange(SaleLinePOS2."No.",PaymentTypePOSGlobal."No.");
                SaleLinePOS2.SetFilter("Sale Type",'%1',SaleLinePOS2."Sale Type"::Payment);
                GVLines := SaleLinePOS2.Count;
                if ((GVLines <= PaymentTypePOSGlobal."Qty. Per Sale") or
                    (PaymentTypePOSGlobal."Qty. Per Sale" = 0)) and
                    (PurchaseAmount >= PaymentTypePOSGlobal."Minimum Sales Amount") then begin
                  SaleLinePOS.Validate("Amount Including VAT",PaymentTypePOSGlobal."Fixed Amount");
                  SaleLinePOS.Validate(Amount,PaymentTypePOSGlobal."Fixed Amount");
                  SaleLinePOS.Validate("Currency Amount",PaymentTypePOSGlobal."Fixed Amount");
                  exit(true);
                end else
                  exit(false);
              end;
            end;
          end;
        
          //-NPR70.00.02.01
          //IF Betaling."Processing Type" = Betaling."Processing Type"::"Point Card" THEN BEGIN
          //  ret := PointCardHandling.InsertLoyaltyPaymentLine(Lin1);
          //END;
          //+NPR70.00.02.01
        
          if PaymentTypePOSGlobal."Processing Type" = PaymentTypePOSGlobal."Processing Type"::"Credit Voucher" then begin
            RetailFormCode.InitTS(true,POSWebUIMgt.ParseDecimal(InputString));
            ErrorStr := InputString;
            LookupProcessed := RetailFormCode.CreditVoucherLookup(SaleLinePOS,ErrorStr);
            exit(LookupProcessed);
          end;
        
          if ((PaymentTypePOSGlobal."Processing Type" = PaymentTypePOSGlobal."Processing Type"::"Foreign Gift Voucher") or
              (PaymentTypePOSGlobal."Processing Type" = PaymentTypePOSGlobal."Processing Type"::"Foreign Credit Voucher")) and
             (PaymentTypePOSGlobal."Common Company Clearing") then begin
                RetailFormCode.InitTS(true,POSWebUIMgt.ParseDecimal(InputString));
                exit(RetailFormCode.PaymentGCVo(SaleLinePOS,PaymentTypePOSGlobal));
          end;
        
          if PaymentTypePOSGlobal."Processing Type" = PaymentTypePOSGlobal."Processing Type"::EFT then begin
            Register.Get("Register No.");
            if (Register."Credit Card" = false) or
               (Register."Credit Card Solution" = Register."Credit Card Solution"::" ") then begin
              ErrorStr := Txt002;
              exit(false);
            end;
            if PaymentTypePOSGlobal."G/L Account No." = '' then begin
              ErrorStr := Txt003;
              exit(false);
            end;
            Commit;
            CODEUNIT.Run(CODEUNIT::"Call Terminal Integration",SaleLinePOS);
            if not SaleLinePOS."Cash Terminal Approved" then
              ErrorStr := Txt004;
            exit(SaleLinePOS."Cash Terminal Approved");
          end;
        
          if PaymentTypePOSGlobal."Processing Type" = PaymentTypePOSGlobal."Processing Type"::DIBS then begin
            Commit;
            Commit;
            if not SaleLinePOS."Cash Terminal Approved" then
              ErrorStr := Txt004;
            exit(SaleLinePOS."Cash Terminal Approved");
          end;
        
          //-NPR5.46 [290734]
          //-NPR4.18
        //  Register.GET("Register No.");
        //  IF PaymentTypePOSGlobal."No." = Register."MobilePay Payment Type" THEN BEGIN
        //    IF SaleLinePOS."Amount Including VAT" > MaxAmount THEN BEGIN
        //      ErrorStr := MobilePayNoCashBackErr;
        //      EXIT(FALSE);
        //    END;
        //    MobilePayPoSAPIIntegration.CallPaymentStart(SaleLinePOS);
        //    IF NOT SaleLinePOS."Cash Terminal Approved" THEN
        //      ErrorStr := MobilePayTransCancelErr;
        //    EXIT(SaleLinePOS."Cash Terminal Approved");
        //  END;
          //+NPR4.18
          //+NPR5.46 [290734]
        
          //-NPR5.31
          Register.Get("Register No.");
          if PaymentTypePOSGlobal."No." = Register."mPos Payment Type" then begin
            if SaleLinePOS."Amount Including VAT" > MaxAmount then begin
              ErrorStr := mPOSNoCashBackErr;
              exit(false);
            end;
            MPOSPaymentAPI.CallPaymentStart(SaleLinePOS);
            if not SaleLinePOS."Cash Terminal Approved" then
              ErrorStr := mPOSTransCancelErr;
            exit(SaleLinePOS."Cash Terminal Approved");
          end;
          //+NPR5.31
        
          //-NPR5.30 [264909]
          /*
          //-NPR5.25
          IF Betaling."No." = Kasse."Swipp Payment Type" THEN BEGIN
            IF Lin1."Amount Including VAT" > MaxAmount THEN BEGIN
              ErrorStr := MobilePayNoCashBackErr;
              EXIT(FALSE);
            END;
            SwippPoSAPIIntegration.CallPaymentStart(Lin1);
            IF NOT(Lin1."Cash Terminal Approved") THEN BEGIN
              SwippTransaction.RESET;
              SwippTransaction.SETRANGE("Register No.", Lin1."Register No.");
              SwippTransaction.SETRANGE("Sales Ticket No.", Lin1."Sales Ticket No.");
              SwippTransaction.SETRANGE("Sales Line No.", Lin1."Line No.");
              IF SwippTransaction.FINDFIRST THEN BEGIN
                CASE SwippTransaction."Payment Status" OF
                SwippTransaction."Payment Status"::CANCELLED:
                  ErrorStr := SwippTransCancelErr;
                SwippTransaction."Payment Status"::FAILED:
                  BEGIN
                    IF (STRLEN(SwippTransaction."Failure Code") >0) THEN
                      ErrorStr := SwippTransaction."Failure Code"
                    ELSE
                      ErrorStr := SwippTransFaillErr;
                  END;
                SwippTransaction."Payment Status"::TIMEOUT:
                  ErrorStr := SwippTransTimeOut;
                END;
              END;
            END;
           //-NPR5.25
           {
            ELSE BEGIN
              ErrorStr := '';
              SwippTransaction.RESET;
              SwippTransaction.SETRANGE("Register No.", Lin1."Register No.");
              SwippTransaction.SETRANGE("Sales Ticket No.", Lin1."Sales Ticket No.");
              SwippTransaction.SETRANGE("Sales Line No.", Lin1."Line No.");
              IF SwippTransaction.FINDFIRST THEN
                IF SwippTransaction."Payment Amount" <> 0 THEN
                  MESSAGE(STRSUBSTNO(SwippTransComplete, SwippTransaction."Payment Amount"/100, DT2DATE(SwippTransaction."Payment Status Timestamp"),
                    DT2TIME(SwippTransaction."Payment Status Timestamp")));
            END;
            }
            //-NPR5.25
            EXIT(Lin1."Cash Terminal Approved");
          END;
          //+NPR5.25
          */
          //+NPR5.30 [264909]
        
          exit(true);
        end;

    end;

    procedure GETRECORD(var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS := SaleLinePOSGlobal;
    end;

    procedure SETPOSITION(Position: Text[250])
    begin
        if (SaleLinePOSGlobal.Count = 0) or
           (Position = '') then
          exit;
        SaleLinePOSGlobal.SetPosition(Position);
        SaleLinePOSGlobal.Find;
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

    procedure GetRecordReference(var RecRef: RecordRef)
    begin
        RecRef.GetTable(SaleLinePOSGlobal);
    end;

    procedure GetDescriptorArray(var FieldArray: array [40] of Integer)
    var
        Index: Integer;
    begin
        Index := 1;
        with SaleLinePOSGlobal do begin
          TestAndSetColumn(Index,FieldArray[Index],FieldName(Description),FieldNo(Description));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Currency Amount"),FieldNo("Currency Amount"));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Amount Including VAT"),FieldNo("Amount Including VAT"));
        end;
    end;

    procedure TestAndSetColumn(var Index: Integer;var VarToSet: Integer;FieldName: Text[30];FieldNumber: Integer): Boolean
    var
        RetailSetup: Record "Retail Setup";
    begin
        RetailSetup.Get;
        VarToSet := FieldNumber;
        Index += 1;
        exit(true);
    end;

    procedure SetHideInputDialog(NewHideInputDialog: Boolean)
    begin
        //-NPR70.00.01.01
        HideInputDialog := NewHideInputDialog;
        //+NPR70.00.01.01
    end;

    procedure GetPaymentLines(DGrid: DotNet DataGrid;var LastLineTemp: Record "Sale Line POS" temporary)
    var
        PaymentLinePOS: Record "Sale Line POS";
        CurrentLineTemp: Record "Sale Line POS" temporary;
        PaymentLinePOSNewTemp: Record "Sale Line POS" temporary;
        POSWebUtilities: Codeunit "POS Web Utilities";
        RecRef: RecordRef;
        DeletedGrid: DotNet DataGrid;
        Row: DotNet Dictionary_Of_T_U;
    begin
        PaymentLinePOS := SaleLinePOSGlobal;
        PaymentLinePOS.CopyFilters(SaleLinePOSGlobal);

        //-NPR5.25
        //RecRef.GETTABLE(PaymentLinePOS);
        //Util.NavRecordToRows(RecRef,Grid);
        if PaymentLinePOS.FindSet() then
          repeat
            LastLineTemp := PaymentLinePOS;
            if (not LastLineTemp.Find()) or (LastLineTemp."SQL Server Timestamp" <> PaymentLinePOS."SQL Server Timestamp") then begin
              PaymentLinePOSNewTemp := PaymentLinePOS;
              PaymentLinePOSNewTemp.Insert();
            end;
            CurrentLineTemp := PaymentLinePOS;
            CurrentLineTemp.Insert();
          until PaymentLinePOS.Next = 0;

        RecRef.GetTable(PaymentLinePOSNewTemp);
        POSWebUtilities.NavRecordToRows(RecRef,DGrid);
        if (PaymentLinePOSNewTemp.Count = 1) and (PaymentLinePOS.Count > 1) and PaymentLinePOSNewTemp.FindFirst() then begin
          PaymentLinePOS := PaymentLinePOSNewTemp;
          if PaymentLinePOS.Find('>') then
            foreach Row in DGrid.Rows do
              Row.Add('__afterRow__',PaymentLinePOS.GetPosition(false));
        end;

        PaymentLinePOSNewTemp.DeleteAll();
        DeletedGrid := DeletedGrid.DataGrid();
        if LastLineTemp.FindSet() then
          repeat
            CurrentLineTemp := LastLineTemp;
            if not CurrentLineTemp.Find() then begin
              PaymentLinePOSNewTemp := LastLineTemp;
              PaymentLinePOSNewTemp.Insert();
            end;
          until LastLineTemp.Next = 0;

        RecRef.GetTable(PaymentLinePOSNewTemp);
        POSWebUtilities.NavRecordToRows(RecRef,DeletedGrid);
        foreach Row in DeletedGrid.Rows do begin
          Row.Add('__deleted__',true);
          DGrid.Rows.Add(Row);
        end;

        LastLineTemp.DeleteAll();
        if PaymentLinePOS.FindSet() then
          repeat
            LastLineTemp := PaymentLinePOS;
            LastLineTemp.Insert();
          until PaymentLinePOS.Next = 0;
        exit;
        //+NPR5.25
    end;
}

