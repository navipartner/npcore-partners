codeunit 6059966 "MPOS Payment API"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // /CLVA/20170925 CASE 291311 Fixed wrong calculation
    // NPR5.36/MMV /20170926 CASE 291652 Added print quick fix.
    // NPR5.36/NPKNAV/20171003  CASE 291311 Transport NPR5.36 - 3 October 2017
    // NPR5.37/MMV /20171012 CASE 291652 Only print terminal receipts once from NAV.
    // NPR5.38/CLVA/20171109 CASE 295903 Handling credit card return sale.
    // NPR5.38/CLVA/20171114 CASE 296200 Handling Payment Type description
    // NPR5.42/MMV /20180507 CASE 306689 Added support for location specific payment type.
    // NPR5.45/CLVA/20180828 CASE 324506 Change error to message dialog
    // NPR5.46/MMV /20180920 CASE 290734 New EFT print flow
    // NPR5.46/CLVA/20180829 CASE 323996 Added print element to json


    trigger OnRun()
    begin
    end;

    var
        ErrorCurrencyIsNotDefined: Label 'Currency is not defined';
        MPOSTransCancelErr: Label 'MPOS - payment was not successful';
        MPOSNoCashBackErr: Label 'It is not allowed to enter an amount that is bigger than what is stated on the receipt for this payment type';
        ValidateSignature: Label 'Is the signatur on the credit note identical with the card signatur?';
        EmptyJasonResult: Label '{}';

    [EventSubscriber(ObjectType::Codeunit, 6150725, 'OnBeforeAction', '', true, true)]
    local procedure OnAction(WorkflowStep: Text; PaymentType: Record "Payment Type POS"; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Setup: Codeunit "POS Setup";
        POSPaymentLine: Codeunit "POS Payment Line";
        JSON: Codeunit "POS JSON Management";
        POSLine: Record "Sale Line POS";
        Register: Record Register;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        //-NPR5.34
        if (WorkflowStep <> 'capture_payment') then
            exit;

        POSSession.GetSetup(Setup);
        Register.Get(Setup.Register());
        if (PaymentType."No." <> Register."mPos Payment Type") then
            exit;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        Clear(POSLine);
        POSLine."No." := PaymentType."No.";

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('/', true);
        JSON.SetScope('$amount', true);
        POSLine."Amount Including VAT" := JSON.GetDecimal('numpad', true);

        //-NPR5.38
        //IF (POSLine."Amount Including VAT" < 0) THEN
        if (POSLine."Amount Including VAT" < 0) and (POSLine.Quantity > 0) then
            //+NPR5.38
            Error(MPOSNoCashBackErr);

        if (POSLine."Amount Including VAT" > Abs(SubTotal)) then
            Error(MPOSNoCashBackErr);

        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);

        CallPaymentStart(POSLine);

        if (not POSLine."EFT Approved") then begin
            POSLine.Description := MPOSTransCancelErr;
            POSLine."Amount Including VAT" := 0;
            POSLine.Modify();

            //-NPR5.45 [324506]
            //ERROR(MPOSTransCancelErr);
            Message(MPOSTransCancelErr);
            //-NPR5.45 [324506]
        end;

        Handled := true;

        //+NPR5.34
    end;

    procedure CallPaymentStart(var SaleLinePOS: Record "Sale Line POS")
    var
        mPOSAdyenTransactions: Record "MPOS Adyen Transactions";
        mPOSProxy: Page "MPOS Proxy";
        JSON: Text;
        CallBackUrl: Text;
        DateTimeTick: DotNet npNetDateTime;
        CurrSessionId: Code[20];
        mPOSAdyenTransactionsResponse: Record "MPOS Adyen Transactions";
        BigTextVar: BigText;
        Ostream: OutStream;
        mPosAppSetup: Record "MPOS App Setup";
        mPOSPaymentGateway: Record "MPOS Payment Gateway";
        mPOSNetsTransactions: Record "MPOS Nets Transactions";
        mPOSNetsTransactionsResponse: Record "MPOS Nets Transactions";
        Cancelled: Boolean;
        TempBlob: Record TempBlob temporary;
        CreditCardProtocolHelper: Codeunit "Credit Card Protocol Helper";
        PaymentTypePOS: Record "Payment Type POS";
        PaymentTypeFounded: Boolean;
        SalePOS: Record "Sale POS";
        InAppPrinting: Integer;
    begin
        mPosAppSetup.Get(SaleLinePOS."Register No.");

        if not mPosAppSetup.Enable then
            exit;

        //-NPR5.46 [323996]
        if mPosAppSetup."Handle EFT Print in NAV" then
            InAppPrinting := 0
        else
            InAppPrinting := 1;
        //+NPR5.46 [323996]

        mPosAppSetup.TestField(Enable, true);
        mPosAppSetup.TestField("Payment Gateway");
        mPOSPaymentGateway.Get(mPosAppSetup."Payment Gateway");
        mPOSPaymentGateway.TestField("Merchant Id");

        DateTimeTick := DateTimeTick.Now();
        CurrSessionId := Format(DateTimeTick.Ticks);

        case mPOSPaymentGateway.Provider of
            mPOSPaymentGateway.Provider::ADYEN:
                begin
                    mPOSAdyenTransactions.Init;
                    mPOSAdyenTransactions."Register No." := SaleLinePOS."Register No.";
                    mPOSAdyenTransactions."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                    mPOSAdyenTransactions."Sales Line No." := SaleLinePOS."Line No.";
                    mPOSAdyenTransactions.Amount := SaleLinePOS."Amount Including VAT";
                    mPOSAdyenTransactions."Session Id" := CurrSessionId;
                    mPOSAdyenTransactions."Created Date" := CurrentDateTime;
                    mPOSAdyenTransactions."Currency Code" := GetCurrencyCode(SaleLinePOS."Currency Code");
                    mPOSAdyenTransactions."Merchant Reference" := CurrSessionId;
                    mPOSAdyenTransactions."Payment Amount In Cents" := mPOSAdyenTransactions.Amount * 100;
                    mPOSAdyenTransactions."Payment Gateway" := mPosAppSetup."Payment Gateway";
                    mPOSAdyenTransactions."Merchant Id" := mPOSPaymentGateway."Merchant Id";

                    JSON := '{ "mPosRequest" : [{ "debug":"false" , "amount":"' + Format(mPOSAdyenTransactions."Payment Amount In Cents")
                      + '", "currency":"' + mPOSAdyenTransactions."Currency Code"
                      + '", "reference":"' + mPOSAdyenTransactions."Session Id"
                      //-NPR5.46 [323996]
                      + '", "inappprinting":"' + Format(InAppPrinting)
                      //+NPR5.46 [323996]
                      + '", "transactionType":"", "paymentGateWay":"' + mPOSAdyenTransactions."Payment Gateway"
                      + '", "merchantId":"' + mPOSAdyenTransactions."Merchant Id" + '" }]}';

                    BigTextVar.AddText(JSON);
                    mPOSAdyenTransactions."Request Json".CreateOutStream(Ostream);
                    BigTextVar.Write(Ostream);
                    mPOSAdyenTransactions.Insert;
                    Commit;
                end;
            mPOSPaymentGateway.Provider::NETS:
                begin
                    mPOSNetsTransactions.Init;
                    mPOSNetsTransactions."Register No." := SaleLinePOS."Register No.";
                    mPOSNetsTransactions."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                    mPOSNetsTransactions."Sales Line No." := SaleLinePOS."Line No.";
                    mPOSNetsTransactions."Session Id" := CurrSessionId;
                    mPOSNetsTransactions."Created Date" := CurrentDateTime;
                    mPOSNetsTransactions."Currency Code" := GetCurrencyCode(SaleLinePOS."Currency Code");
                    mPOSNetsTransactions."Merchant Reference" := CurrSessionId;

                    if SaleLinePOS."Amount Including VAT" < 0 then begin
                        mPOSNetsTransactions."Transaction Type" := mPOSNetsTransactions."Transaction Type"::REFUND;
                        mPOSNetsTransactions."Transaction Type Id" := 49;
                        mPOSNetsTransactions.Amount := SaleLinePOS."Amount Including VAT" * -1;
                        //-NPR5.36
                        //mPOSNetsTransactions."Payment Amount In Cents" := (mPOSNetsTransactions.Amount * 100) * -1;
                        mPOSNetsTransactions."Payment Amount In Cents" := (mPOSNetsTransactions.Amount * 100);
                        //+NPR5.36
                    end else begin
                        mPOSNetsTransactions."Transaction Type" := mPOSNetsTransactions."Transaction Type"::PAY;
                        mPOSNetsTransactions."Transaction Type Id" := 48;
                        mPOSNetsTransactions.Amount := SaleLinePOS."Amount Including VAT";
                        mPOSNetsTransactions."Payment Amount In Cents" := mPOSNetsTransactions.Amount * 100;
                    end;

                    mPOSNetsTransactions."Payment Gateway" := mPosAppSetup."Payment Gateway";
                    mPOSNetsTransactions."Merchant Id" := mPOSPaymentGateway."Merchant Id";

                    JSON := '{ "mPosRequest" : [{ "debug":"false" , "amount":"'
                            + Format(mPOSNetsTransactions."Payment Amount In Cents")
                            + '", "currency":"' + mPOSNetsTransactions."Currency Code"
                            + '", "reference":"' + mPOSNetsTransactions."Session Id"
                            //-NPR5.46 [323996]
                            + '", "inappprinting":"' + Format(InAppPrinting)
                            //+NPR5.46 [323996]
                            + '", "transactionType":"' + Format(mPOSNetsTransactions."Transaction Type Id")
                            + '", "paymentGateWay":"' + mPOSNetsTransactions."Payment Gateway"
                            + '","merchantId":"' + mPOSNetsTransactions."Merchant Id" + '" }]}';

                    BigTextVar.AddText(JSON);
                    mPOSNetsTransactions."Request Json".CreateOutStream(Ostream);
                    BigTextVar.Write(Ostream);
                    mPOSNetsTransactions.Insert;
                    Commit;

                end;
        end;

        mPOSProxy.SetProvider(mPOSPaymentGateway.Provider);
        mPOSProxy.SetState(mPOSAdyenTransactions, mPOSNetsTransactions);
        mPOSProxy.RunModal;

        case mPOSPaymentGateway.Provider of
            mPOSPaymentGateway.Provider::ADYEN:
                begin
                    mPOSAdyenTransactionsResponse.Get(mPOSAdyenTransactions."Transaction No.");

                    ParseAdyenJson(mPOSAdyenTransactionsResponse);

                    if (mPOSAdyenTransactionsResponse."Callback Result" = 'APPROVED') and (mPOSAdyenTransactionsResponse.Handled) then begin
              SaleLinePOS."EFT Approved" := true;
                        SaleLinePOS.Description := SaleLinePOS.Description + ' ' + Format(mPOSAdyenTransactionsResponse."Transaction No.");
                    end else
              SaleLinePOS."EFT Approved" := false;
                    SaleLinePOS.Modify;
                    Commit;
                end;
            mPOSPaymentGateway.Provider::NETS:
                begin
                    mPOSNetsTransactionsResponse.Get(mPOSNetsTransactions."Transaction No.");

                    ParseNetsJson(mPOSNetsTransactionsResponse);

                    //-NPR5.36 [291652]
                    HandlePrint(mPOSNetsTransactionsResponse);
                    //+NPR5.36 [291652]

                    if (mPOSNetsTransactionsResponse."Callback Result" = 0) and (mPOSNetsTransactionsResponse.Handled) then begin

                        //-NPR5.42 [306689]
                        //PaymentTypeFounded := CreditCardProtocolHelper.FindPaymentType(mPOSNetsTransactionsResponse."Callback TruncatedPan",PaymentTypePOS);
                        SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                        PaymentTypeFounded := CreditCardProtocolHelper.FindPaymentType(mPOSNetsTransactionsResponse."Callback TruncatedPan", PaymentTypePOS, SalePOS."Location Code");
                        //+NPR5.42 [306689]

                        if mPOSNetsTransactionsResponse."Callback Receipt 2".HasValue then begin
                            if Confirm(ValidateSignature, true) then begin
                  SaleLinePOS."EFT Approved" := true;
                                //-NPR5.38
                                if PaymentTypeFounded then begin
                                    SaleLinePOS."No." := PaymentTypePOS."No.";
                                    SaleLinePOS.Description := PaymentTypePOS.Description;
                                end else begin
                                    SaleLinePOS.Description := SaleLinePOS.Description + ' ' + Format(mPOSNetsTransactionsResponse."Transaction No.");
                                end;
                                //+NPR5.38
                            end else begin
                                Cancelled := CallCancelStart(SaleLinePOS);
                  SaleLinePOS."EFT Approved" := false;
                            end;
                        end else begin
                SaleLinePOS."EFT Approved" := true;
                            //-NPR5.38
                            if PaymentTypeFounded then begin
                                SaleLinePOS."No." := PaymentTypePOS."No.";
                                SaleLinePOS.Description := PaymentTypePOS.Description;
                            end else begin
                                SaleLinePOS.Description := SaleLinePOS.Description + ' ' + Format(mPOSNetsTransactionsResponse."Transaction No.");
                            end;
                            //+NPR5.38
                        end;
                    end else
              SaleLinePOS."EFT Approved" := false;
                    SaleLinePOS.Modify;
                    Commit;
                end;
        end;
    end;

    local procedure ParseAdyenJson(var mPOSAdyenTransactions: Record "MPOS Adyen Transactions")
    var
        JObject: JsonObject;
        ResponsData: Text;
        IStream: InStream;
    begin
        mPOSAdyenTransactions.CalcFields("Response Json");

        if not mPOSAdyenTransactions."Response Json".HasValue then
            exit
        else begin
            mPOSAdyenTransactions."Response Json".CreateInStream(IStream);
            IStream.Read(ResponsData, MaxStrLen(ResponsData));
        end;

        JObject.ReadFrom(ResponsData);

        mPOSAdyenTransactions."Callback Result" := GetString(JObject, 'result');
        mPOSAdyenTransactions."Callback CS" := GetString(JObject, 'cs');
        mPOSAdyenTransactions."Callback Merchant Account" := GetString(JObject, 'merchantAccount');
        mPOSAdyenTransactions."Callback Merchant Reference" := GetString(JObject, 'merchantReference');

        case mPOSAdyenTransactions."Callback Result" of
            'ERROR':
                begin
                    mPOSAdyenTransactions."Callback Code" := GetString(JObject, 'errorCode');
                    mPOSAdyenTransactions."Callback Message" := GetString(JObject, 'errorMessage');
                end;
            'CANCELLED':
                begin
                    mPOSAdyenTransactions."Callback Code" := GetString(JObject, 'cancelCode');
                    mPOSAdyenTransactions."Callback Message" := GetString(JObject, 'cancelMessage');
                end;
            'APPROVED':
                begin
                    mPOSAdyenTransactions."Callback Panseq" := GetString(JObject, 'panseq');
                    mPOSAdyenTransactions."Callback POS Entry Mode" := GetString(JObject, 'posEntryMode');
                    mPOSAdyenTransactions."Callback Card Summary" := GetString(JObject, 'cardSummary');
                    mPOSAdyenTransactions."Callback PSP Auth Code" := GetString(JObject, 'pspAuthCode');
                    mPOSAdyenTransactions."Callback Amount Value" := GetInt(JObject, 'amountValue');
                    mPOSAdyenTransactions."Callback Issuer Country" := GetString(JObject, 'issuerCountry');
                    mPOSAdyenTransactions."Callback Expiry Month" := GetString(JObject, 'expiryMonth');
                    mPOSAdyenTransactions."Callback Card Holder Verificat" := GetString(JObject, 'cardHolderVerificationMethodResults');
                    mPOSAdyenTransactions."Callback Card Scheme" := GetString(JObject, 'cardScheme');
                    mPOSAdyenTransactions."Callback Card Bin" := GetString(JObject, 'cardBin');
                    mPOSAdyenTransactions."Callback Application Label" := GetString(JObject, 'applicationLabel');
                    mPOSAdyenTransactions."Callback Payment Meth Variant" := GetString(JObject, 'paymentMethodVariant');
                    mPOSAdyenTransactions."Callback Tender Reference" := GetString(JObject, 'tenderReference');
                    mPOSAdyenTransactions."Callback App Preferred Name" := GetString(JObject, 'applicationPreferredName');
                    mPOSAdyenTransactions."Callback Aid Code" := GetString(JObject, 'aidCode');
                    mPOSAdyenTransactions."Callback Org Amount Value" := GetInt(JObject, 'originalAmountValue');
                    mPOSAdyenTransactions."Callback Tx Time" := GetString(JObject, 'txtime');
                    mPOSAdyenTransactions."Callback Tx Date" := GetString(JObject, 'txdate');
                    mPOSAdyenTransactions."Callback Terminal Id" := GetString(JObject, 'terminalId');
                    mPOSAdyenTransactions."Callback Payment Method" := GetString(JObject, 'paymentMethod');
                    mPOSAdyenTransactions."Callback PSP Reference" := GetString(JObject, 'pspReference');
                    mPOSAdyenTransactions."Callback Mid" := GetInt(JObject, 'mid');
                    mPOSAdyenTransactions."Callback Expiry Year" := GetInt(JObject, 'expiryYear');
                    mPOSAdyenTransactions."Callback Card Type" := GetString(JObject, 'cardType');
                    mPOSAdyenTransactions."Callback Org Amount Currency" := GetString(JObject, 'originalAmountCurrency');
                    mPOSAdyenTransactions."Callback Card Holder Name" := GetString(JObject, 'cardHolderName');
                    mPOSAdyenTransactions."Callback Amount Currency" := GetString(JObject, 'amountCurrency');
                    mPOSAdyenTransactions."Callback Transaction Type" := GetString(JObject, 'transactionType');
                    mPOSAdyenTransactions.Handled := true;
                end;
        end;
        mPOSAdyenTransactions.Modify(true);
    end;

    local procedure ParseNetsJson(var mPOSNetsTransactions: Record "MPOS Nets Transactions")
    var
        JObject: JsonObject;
        ResponsData: Text;
        IStream: InStream;
        BigTextVar: BigText;
        Ostream: OutStream;
    begin
        mPOSNetsTransactions.CalcFields("Response Json");

        if not mPOSNetsTransactions."Response Json".HasValue then
            exit
        else begin
            mPOSNetsTransactions."Response Json".CreateInStream(IStream);
            IStream.Read(ResponsData, MaxStrLen(ResponsData));
        end;

        if ResponsData = EmptyJasonResult then
            exit;

        JObject.ReadFrom(ResponsData);

        mPOSNetsTransactions."Callback Result" := GetInt(JObject, 'result');
        mPOSNetsTransactions."Callback AccumulatorUpdate" := GetInt(JObject, 'accumulatorUpdate');
        mPOSNetsTransactions."Callback IssuerId" := GetInt(JObject, 'issuerId');
        mPOSNetsTransactions."Callback TruncatedPan" := GetString(JObject, 'truncatedPan');
        mPOSNetsTransactions."Callback EncryptedPan" := GetString(JObject, 'encryptedPan');
        mPOSNetsTransactions."Callback Timestamp" := GetString(JObject, 'timestamp');
        mPOSNetsTransactions."Callback VerificationMethod" := GetInt(JObject, 'verificationMethod');
        mPOSNetsTransactions."Callback SessionNumber" := GetString(JObject, 'sessionNumber');
        mPOSNetsTransactions."Callback StanAuth" := GetString(JObject, 'stanAuth');
        mPOSNetsTransactions."Callback SequenceNumber" := GetString(JObject, 'sequenceNumber');
        mPOSNetsTransactions."Callback TotalAmount" := GetInt(JObject, 'totalAmount');
        mPOSNetsTransactions."Callback TipAmount" := GetInt(JObject, 'tipAmount');
        mPOSNetsTransactions."Callback SurchargeAmount" := GetInt(JObject, 'surchargeAmount');
        mPOSNetsTransactions."Callback AcquiereMerchantID" := GetString(JObject, 'acquiereMerchantID');
        mPOSNetsTransactions."Callback CardIssuerName" := GetString(JObject, 'cardIssuerName');
        mPOSNetsTransactions."Callback TCC" := GetString(JObject, 'TCC');
        mPOSNetsTransactions."Callback AID" := GetString(JObject, 'AID');
        mPOSNetsTransactions."Callback TVR" := GetString(JObject, 'TVR');
        mPOSNetsTransactions."Callback TSI" := GetString(JObject, 'TSI');
        mPOSNetsTransactions."Callback ATC" := GetString(JObject, 'ATC');
        mPOSNetsTransactions."Callback AED" := GetString(JObject, 'AED');
        mPOSNetsTransactions."Callback IAC" := GetString(JObject, 'IAC');

        mPOSNetsTransactions."Callback OrganisationNumber" := GetString(JObject, 'organisationNumber');
        mPOSNetsTransactions."Callback BankAgent" := GetString(JObject, 'bankAgent');
        mPOSNetsTransactions."Callback AccountType" := GetString(JObject, 'accountType');
        mPOSNetsTransactions."Callback OptionalData" := GetString(JObject, 'optionalData');
        mPOSNetsTransactions."Callback ResponseCode" := GetString(JObject, 'responseCode');
        mPOSNetsTransactions."Callback RejectionSource" := GetInt(JObject, 'rejectionSource');
        mPOSNetsTransactions."Callback RejectionReason" := GetString(JObject, 'rejectionReason');
        mPOSNetsTransactions."Callback MerchantReference" := GetString(JObject, 'merchantReference');
        mPOSNetsTransactions."Callback StatusDescription" := GetString(JObject, 'statusDescription');

        mPOSNetsTransactions.Handled := true;

        BigTextVar.AddText(GetString(JObject, 'receipt1'));
        mPOSNetsTransactions."Callback Receipt 1".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        Clear(BigTextVar);
        BigTextVar.AddText(GetString(JObject, 'receipt2'));
        mPOSNetsTransactions."Callback Receipt 2".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        mPOSNetsTransactions.Modify(true);
    end;

    local procedure GetString(var JObject: JsonObject; JTokenName: Text): Text
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not JObject.Get(JTokenName, JToken) then
            exit('');

        JValue := JToken.AsValue();
        if (JValue.IsNull) then
            exit('');

        exit(JValue.AsText());
    end;

    local procedure GetInt(var JObject: JsonObject; JTokenName: Text): Integer
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not JObject.Get(JTokenName, JToken) then
            exit(0);

        JValue := JToken.AsValue();
        if (JValue.IsNull) then
            exit(0);
        exit(JValue.AsInteger());
    end;

    local procedure GetCurrencyCode(SalesLineCurrencyCode: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if SalesLineCurrencyCode <> '' then
            exit(SalesLineCurrencyCode);

        GeneralLedgerSetup.Get;
        if GeneralLedgerSetup."LCY Code" <> '' then
            exit(GeneralLedgerSetup."LCY Code");

        Error(ErrorCurrencyIsNotDefined);
    end;

    procedure CallCancelStart(var SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        mPOSAdyenTransactions: Record "MPOS Adyen Transactions";
        mPOSProxy: Page "MPOS Proxy";
        JSON: Text;
        CallBackUrl: Text;
        DateTimeTick: DotNet npNetDateTime;
        CurrSessionId: Code[20];
        mPOSAdyenTransactionsResponse: Record "MPOS Adyen Transactions";
        BigTextVar: BigText;
        Ostream: OutStream;
        mPosAppSetup: Record "MPOS App Setup";
        mPOSPaymentGateway: Record "MPOS Payment Gateway";
        mPOSNetsTransactions: Record "MPOS Nets Transactions";
        mPOSNetsTransactionsResponse: Record "MPOS Nets Transactions";
    begin
        mPosAppSetup.Get(SaleLinePOS."Register No.");

        if not mPosAppSetup.Enable then
            exit;

        mPosAppSetup.TestField(Enable, true);
        mPosAppSetup.TestField("Payment Gateway");
        mPOSPaymentGateway.Get(mPosAppSetup."Payment Gateway");
        mPOSPaymentGateway.TestField("Merchant Id");

        DateTimeTick := DateTimeTick.Now();
        CurrSessionId := Format(DateTimeTick.Ticks);

        case mPOSPaymentGateway.Provider of
            mPOSPaymentGateway.Provider::ADYEN:
                begin
                    mPOSAdyenTransactions.Init;
                    mPOSAdyenTransactions."Register No." := SaleLinePOS."Register No.";
                    mPOSAdyenTransactions."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                    mPOSAdyenTransactions."Sales Line No." := SaleLinePOS."Line No.";
                    mPOSAdyenTransactions.Amount := SaleLinePOS."Amount Including VAT";
                    mPOSAdyenTransactions."Session Id" := CurrSessionId;
                    mPOSAdyenTransactions."Created Date" := CurrentDateTime;
                    mPOSAdyenTransactions."Currency Code" := GetCurrencyCode(SaleLinePOS."Currency Code");
                    mPOSAdyenTransactions."Merchant Reference" := CurrSessionId;
                    mPOSAdyenTransactions."Payment Amount In Cents" := mPOSAdyenTransactions.Amount * 100;
                    mPOSAdyenTransactions."Payment Gateway" := mPosAppSetup."Payment Gateway";
                    mPOSAdyenTransactions."Merchant Id" := mPOSPaymentGateway."Merchant Id";

                    JSON := '{ "mPosRequest" : [{ "debug":"false" , "amount":"'
                      + Format(mPOSAdyenTransactions."Payment Amount In Cents") + '", "currency":"'
                      + mPOSAdyenTransactions."Currency Code" + '", "reference":"'
                      + mPOSAdyenTransactions."Session Id" + '", "transactionType":"", "paymentGateWay":"' + mPOSAdyenTransactions."Payment Gateway" + '","merchantId":"' + mPOSAdyenTransactions."Merchant Id" + '" }]}';

                    BigTextVar.AddText(JSON);
                    mPOSAdyenTransactions."Request Json".CreateOutStream(Ostream);
                    BigTextVar.Write(Ostream);
                    mPOSAdyenTransactions.Insert;
                    Commit;
                end;
            mPOSPaymentGateway.Provider::NETS:
                begin
                    mPOSNetsTransactions.Init;
                    mPOSNetsTransactions."Register No." := SaleLinePOS."Register No.";
                    mPOSNetsTransactions."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                    mPOSNetsTransactions."Sales Line No." := SaleLinePOS."Line No.";
                    mPOSNetsTransactions.Amount := SaleLinePOS."Amount Including VAT";
                    mPOSNetsTransactions."Session Id" := CurrSessionId;
                    mPOSNetsTransactions."Created Date" := CurrentDateTime;
                    mPOSNetsTransactions."Currency Code" := GetCurrencyCode(SaleLinePOS."Currency Code");
                    mPOSNetsTransactions."Merchant Reference" := CurrSessionId;
                    mPOSNetsTransactions."Payment Amount In Cents" := mPOSNetsTransactions.Amount * 100;
                    mPOSNetsTransactions."Payment Gateway" := mPosAppSetup."Payment Gateway";
                    mPOSNetsTransactions."Merchant Id" := mPOSPaymentGateway."Merchant Id";
                    mPOSNetsTransactions."Transaction Type" := mPOSNetsTransactions."Transaction Type"::CANCEL;
                    mPOSNetsTransactions."Transaction Type Id" := 50;

                    JSON := '{ "mPosRequest" : [{ "debug":"false" , "amount":"'
                      + Format(mPOSNetsTransactions."Payment Amount In Cents") + '", "currency":"'
                      + mPOSNetsTransactions."Currency Code" + '", "reference":"'
                      + mPOSNetsTransactions."Session Id" + '", "transactionType":"' + Format(mPOSNetsTransactions."Transaction Type Id") + '", "paymentGateWay":"' + mPOSNetsTransactions."Payment Gateway" + '","merchantId":"' + mPOSNetsTransactions."Merchant Id" + '" }]}';

                    BigTextVar.AddText(JSON);
                    mPOSNetsTransactions."Request Json".CreateOutStream(Ostream);
                    BigTextVar.Write(Ostream);
                    mPOSNetsTransactions.Insert;
                    Commit;

                end;
        end;

        mPOSProxy.SetProvider(mPOSPaymentGateway.Provider);
        mPOSProxy.SetState(mPOSAdyenTransactions, mPOSNetsTransactions);
        mPOSProxy.RunModal;

        case mPOSPaymentGateway.Provider of
            mPOSPaymentGateway.Provider::ADYEN:
                begin
                    mPOSAdyenTransactionsResponse.Get(mPOSAdyenTransactions."Transaction No.");

                    ParseAdyenJson(mPOSAdyenTransactionsResponse);

                    if mPOSAdyenTransactionsResponse."Callback Result" = 'APPROVED' then begin
              SaleLinePOS."EFT Approved" := true;
                        SaleLinePOS.Description := SaleLinePOS.Description + ' ' + Format(mPOSAdyenTransactionsResponse."Transaction No.");
                    end else
              SaleLinePOS."EFT Approved" := false;
                    SaleLinePOS.Modify;
                    Commit;
                end;
            mPOSPaymentGateway.Provider::NETS:
                begin
                    mPOSNetsTransactionsResponse.Get(mPOSNetsTransactions."Transaction No.");

                    ParseNetsJson(mPOSNetsTransactionsResponse);
                    //-NPR5.36 [291652]
                    HandlePrint(mPOSNetsTransactionsResponse);
                    //+NPR5.36 [291652]

                    Commit;
                    if mPOSNetsTransactionsResponse."Callback Result" = 0 then
                        exit(true)
                    else
                        exit(false);
                end;
        end;
    end;

    local procedure HandlePrint(var mPOSNetsTransactionsResponse: Record "MPOS Nets Transactions")
    var
        CreditCardTransaction: Record "EFT Receipt";
        TempBlob: Record TempBlob temporary;
        MPOSAppSetup: Record "MPOS App Setup";
    begin
        //-NPR5.36 [291652]
        //Quick fix for getting terminal print data into print table before full EFT hook implementation:
        if mPOSNetsTransactionsResponse."Callback Receipt 1".HasValue then begin
            TempBlob.Init;
            TempBlob.Blob := mPOSNetsTransactionsResponse."Callback Receipt 1";
            CreateReceiptData(mPOSNetsTransactionsResponse."Register No.", mPOSNetsTransactionsResponse."Sales Ticket No.", mPOSNetsTransactionsResponse."Sales Line No.", TempBlob);
            TempBlob.Reset;
        end;

        if mPOSNetsTransactionsResponse."Callback Receipt 2".HasValue then begin
            TempBlob.Init;
            TempBlob.Blob := mPOSNetsTransactionsResponse."Callback Receipt 2";
            CreateReceiptData(mPOSNetsTransactionsResponse."Register No.", mPOSNetsTransactionsResponse."Sales Ticket No.", mPOSNetsTransactionsResponse."Sales Line No.", TempBlob);
            TempBlob.Reset;
        end;

        if MPOSAppSetup.Get(mPOSNetsTransactionsResponse."Register No.") then
            if MPOSAppSetup."Handle EFT Print in NAV" then begin
                CreditCardTransaction.SetRange("Register No.", mPOSNetsTransactionsResponse."Register No.");
                CreditCardTransaction.SetRange("Sales Ticket No.", mPOSNetsTransactionsResponse."Sales Ticket No.");
                //-NPR5.37 [291652]
                CreditCardTransaction.SetRange("No. Printed", 0);
                //+NPR5.37 [291652]
                //-NPR5.46 [290734]
                //CreditCardTransaction.PrintTerminalReceipt(FALSE);
                CreditCardTransaction.PrintTerminalReceipt();
                //+NPR5.46 [290734]
            end;
        //+NPR5.36 [291652]
    end;

    local procedure CreateReceiptData(RegisterNo: Code[10]; SalesTicketNo: Code[20]; LineNo: Integer; var TempBlob: Record TempBlob temporary)
    var
        CreditCardTransaction: Record "EFT Receipt";
        ReceiptNo: Integer;
        InStream: InStream;
        Line: Text;
        EntryNo: Integer;
    begin
        //-NPR5.36 [291652]
        CreditCardTransaction.SetRange("Register No.", RegisterNo);
        CreditCardTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        if CreditCardTransaction.FindLast then;
        ReceiptNo := CreditCardTransaction."Receipt No." + 1;
        EntryNo := CreditCardTransaction."Entry No." + 1;

        CreditCardTransaction.Reset;
        CreditCardTransaction.Init;
        CreditCardTransaction."Register No." := RegisterNo;
        CreditCardTransaction."Sales Ticket No." := SalesTicketNo;
        CreditCardTransaction."Line No." := LineNo;
        CreditCardTransaction.Date := Today;
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction.Type := 0;
        CreditCardTransaction."Receipt No." := ReceiptNo;

        TempBlob.Blob.CreateInStream(InStream);
        while (not InStream.EOS) do begin
            InStream.ReadText(Line);

            CreditCardTransaction.Text := Line;
            CreditCardTransaction."Entry No." := EntryNo;
            CreditCardTransaction.Insert;

            EntryNo += 1;
        end;
        //+NPR5.36 [291652]
    end;
}

