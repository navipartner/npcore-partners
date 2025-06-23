codeunit 88009 "NPR BCPT POS Balancing EOD" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        CreateSalesAndPerformBalancingEOD();
    end;

    var
        EFTSetup: Record "NPR EFT Setup";
        Item, Item2 : Record Item;
        BarCodeItemReference, BarCodeItemReference2 : Record "Item Reference";
        KronePOSPaymentMethod, EuroPOSPaymentMethod, DollarPOSPaymentMethod, PoundPOSPaymentMethod, TerminalPOSPaymentMethod : Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        BCPTTestContext: Codeunit "BCPT Test Context";
        POSSession: Codeunit "NPR POS Session";
        POSMockLibrary: Codeunit "NPR BCPT Library - POS Mock";
        LibraryEFT: Codeunit "NPR BCPT Library - EFT";
        POSMasterDataLibrary: Codeunit "NPR BCPT Library POSMasterData";
        IsInitialized, PostSale, AllowGapsInSaleFiscalNoSeries : Boolean;
        CreateSalesUntilDateTime: DateTime;
        CreateSalesForNoOfMinutes, NoOfLinesPerSale : Integer;
        CreateSalesForNoOfMinutesParamLbl: Label 'CreateSalesForNoOfMinutes', Locked = true;
        NoOfLinesPerSaleParamLbl: Label 'NoOfLinesPerSale', Locked = true;
        PostSaleParamLbl: Label 'PostSale', Locked = true;
        AllowGapsInSaleFiscalNoSeriesParamLbl: Label 'AllowGapsInSaleFiscalNoSeries', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';


    local procedure InitTest();
    var
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
        MayProduceGaps: Boolean;
#endif
        NoSeriesLine: Record "No. Series Line";
        POSAuditProfile: Record "NPR POS Audit Profile";
        BCPTInitializeDataSetup: Record "NPR BCPT Initialize Data Setup";
    begin
        KronePOSPaymentMethod.Get('K');
        EuroPOSPaymentMethod.Get('EURO');
        DollarPOSPaymentMethod.Get('USD');
        PoundPOSPaymentMethod.Get('GBP');
        TerminalPOSPaymentMethod.Get('T');
        Item.Get('100CHIMSTA');
        Item2.Get('100DFTBLK');

        if Evaluate(CreateSalesForNoOfMinutes, BCPTTestContext.GetParameter(CreateSalesForNoOfMinutesParamLbl)) then;
        if Evaluate(NoOfLinesPerSale, BCPTTestContext.GetParameter(NoOfLinesPerSaleParamLbl)) then;
        if Evaluate(PostSale, BCPTTestContext.GetParameter(PostSaleParamLbl)) then;
        if Evaluate(AllowGapsInSaleFiscalNoSeries, BCPTTestContext.GetParameter(AllowGapsInSaleFiscalNoSeriesParamLbl)) then;

        if CreateSalesForNoOfMinutes < 1 then
            CreateSalesForNoOfMinutes := 1;
        if CreateSalesForNoOfMinutes > 20 then
            CreateSalesForNoOfMinutes := 20;
        if NoOfLinesPerSale < 1 then
            NoOfLinesPerSale := 1;
        if NoOfLinesPerSale > 1000 then
            NoOfLinesPerSale := 1000;

        POSMasterDataLibrary.CreateBarCodeItemReference(BarCodeItemReference, Item);
        POSMasterDataLibrary.CreateBarCodeItemReference(BarCodeItemReference2, Item2);

        POSAuditProfile.Get('DEFAULT');
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sale Fiscal No. Series");
        NoSeriesLine.FindSet(true);
        repeat
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            MayProduceGaps := NoSeriesManagement.MayProduceGaps(NoSeriesLine);
            if AllowGapsInSaleFiscalNoSeries <> MayProduceGaps then begin
                if MayProduceGaps then
                    NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence)
                else
                    NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Normal);
#else
            if AllowGapsInSaleFiscalNoSeries <> NoSeriesLine."Allow Gaps in Nos." then begin
                NoSeriesLine.Validate("Allow Gaps in Nos.", AllowGapsInSaleFiscalNoSeries);
#endif
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;

        Commit();
        BCPTInitializeDataSetup.FindNextPOSUnitAndSetCreateSalesUntilDateTime(POSUnit, CreateSalesUntilDateTime, CreateSalesForNoOfMinutes);
        Commit();
        POSMasterDataLibrary.OpenPOSUnit(POSUnit);
        POSMockLibrary.InitializePOSSession(POSSession, POSUnit);
        if not EFTSetup.Get(TerminalPOSPaymentMethod.Code, POSUnit."No.") then
            LibraryEFT.CreateMockEFTSetup(EFTSetup, POSUnit."No.", TerminalPOSPaymentMethod.Code);
        Commit();
    end;

    local procedure CreateSalesAndPerformBalancingEOD()
    begin
        while CurrentDateTime < CreateSalesUntilDateTime do
            CreateSale();

        // this is done in order to try to run Balancing EOD around the same time for all the sessions
        // if we decide to use this CU to test more than 10 concurent sessions it would probably need to be increased
        while CurrentDateTime - CreateSalesUntilDateTime < 30000 do
            Sleep(500);

        PerformBalancingEOD();
    end;

    local procedure CreateSale()
    var
        AmountToPay: Decimal;
        Seconds: Integer;
    begin
        StartSale();
        AmountToPay := CreateLinesPerSale();

        Seconds := (Time - 000000T) div 1000;
        case Seconds mod 60 of
            0 .. 11:
                PaySaleWithTerminal(AmountToPay);
            12 .. 17:
                PaySaleInCash(EuroPOSPaymentMethod.Code, AmountToPay);
            18 .. 23:
                PaySaleInCash(DollarPOSPaymentMethod.Code, AmountToPay);
            24 .. 29:
                PaySaleInCash(PoundPOSPaymentMethod.Code, AmountToPay);
            else
                PaySaleInCash(KronePOSPaymentMethod.Code, AmountToPay);
        end;
    end;

    local procedure StartSale()
    begin
        BCPTTestContext.StartScenario('Start Sale');
        POSSession.StartTransaction();
        BCPTTestContext.EndScenario('Start Sale');
        BCPTTestContext.UserWait();
    end;

    local procedure CreateLinesPerSale() AmountToPay: Decimal
    var
        i: Integer;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
    begin
        for i := 1 to NoOfLinesPerSale do begin
            if i = 1 then
                BCPTTestContext.StartScenario('Add Sale Line');
            if i mod 2 = 1 then begin
                POSMockLibrary.CreateItemLine(POSSession, Item, BarCodeItemReference, ItemIdentifierType::ItemCrossReference, 1);
                AmountToPay += Item."Unit Price";
            end else begin
                POSMockLibrary.CreateItemLine(POSSession, Item2, BarCodeItemReference2, ItemIdentifierType::ItemCrossReference, 1);
                AmountToPay += Item2."Unit Price";
            end;
            if i = 1 then
                BCPTTestContext.EndScenario('Add Sale Line');
            BCPTTestContext.UserWait();
        end;
    end;

    local procedure PaySaleInCash(POSPaymentMethodCode: Code[10]; AmountToPay: Decimal)
    begin
        BCPTTestContext.StartScenario('Pay Sale');
        POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCode, AmountToPay, '', PostSale);
        BCPTTestContext.EndScenario('Pay Sale');
        BCPTTestContext.UserWait();
    end;

    local procedure PaySaleWithTerminal(AmountToPay: Decimal)
    var
        POSSale: Record "NPR POS Sale";
        SalePOS: Codeunit "NPR POS Sale";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        POSActionPayment: Codeunit "NPR POS Action: Payment";
    begin
        BCPTTestContext.StartScenario('Pay Sale');
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        POSSession.ClearActionState();
        POSSession.BeginAction(POSActionPayment.ActionCode()); // Required for EFT payments as they depend on outer PAYMENT workflow session state.
        POSSession.GetSale(SalePOS);
        SalePOS.GetCurrentSale(POSSale);
        EFTTransactionMgt.StartPayment(EFTSetup, AmountToPay, '', POSSale);
        UnbindSubscription(EFTTestMockIntegration);
        BCPTTestContext.EndScenario('Pay Sale');
        BCPTTestContext.UserWait();
    end;

    local procedure PerformBalancingEOD()
    var
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        DimensionSetId: Integer;
        EODWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;
    begin
        DimensionSetId := 0;
        BCPTTestContext.StartScenario('Balancing EOD');
        POSWorkshiftCheckpoint.EndWorkshift(EODWorkshiftMode::ZREPORT, POSUnit."No.", DimensionSetId);
        BCPTTestContext.EndScenario('Balancing EOD');
        BCPTTestContext.UserWait();
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(
            CopyStr(GetDefaultNoOfSalesParameter() + ',' +
            GetDefaultNoOfLinesPerSaleParameter() + ',' +
            GetDefaultPostSaleParameter() + ',' +
            GetDefaultAllowGapsInSaleFiscalNoSeriesParameter(), 1, 1000));
    end;

    local procedure GetDefaultNoOfSalesParameter(): Text[1000]
    begin
        exit(CopyStr(CreateSalesForNoOfMinutesParamLbl + '=' + Format(5), 1, 1000));
    end;

    local procedure GetDefaultNoOfLinesPerSaleParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfLinesPerSaleParamLbl + '=' + Format(2), 1, 1000));
    end;

    local procedure GetDefaultPostSaleParameter(): Text[1000]
    begin
        exit(CopyStr(PostSaleParamLbl + '=' + Format(false), 1, 1000));
    end;

    local procedure GetDefaultAllowGapsInSaleFiscalNoSeriesParameter(): Text[1000]
    begin
        exit(CopyStr(AllowGapsInSaleFiscalNoSeriesParamLbl + '=' + Format(true), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        ValidateCreateSalesForNoOfMinutesParameter(CopyStr(SelectStr(1, Parameters), 1, 1000));
        ValidateNoOfLinesPerSaleParameter(CopyStr(SelectStr(2, Parameters), 1, 1000));
        ValidatePostSaleParameter(CopyStr(SelectStr(3, Parameters), 1, 1000));
        ValidateAllowGapsInSaleFiscalNoSeriesParameter(CopyStr(SelectStr(4, Parameters), 1, 1000));
    end;

    local procedure ValidateCreateSalesForNoOfMinutesParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, CreateSalesForNoOfMinutesParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(CreateSalesForNoOfMinutesParamLbl + '='));
            if Evaluate(CreateSalesForNoOfMinutes, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultNoOfSalesParameter());
    end;

    local procedure ValidateNoOfLinesPerSaleParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, NoOfLinesPerSaleParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(NoOfLinesPerSaleParamLbl + '='));
            if Evaluate(NoOfLinesPerSale, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultNoOfLinesPerSaleParameter());
    end;

    local procedure ValidatePostSaleParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, PostSaleParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(PostSaleParamLbl + '='));
            if Evaluate(PostSale, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultPostSaleParameter());
    end;

    local procedure ValidateAllowGapsInSaleFiscalNoSeriesParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, AllowGapsInSaleFiscalNoSeriesParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(AllowGapsInSaleFiscalNoSeriesParamLbl + '='));
            if Evaluate(AllowGapsInSaleFiscalNoSeries, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultAllowGapsInSaleFiscalNoSeriesParameter());
    end;
}