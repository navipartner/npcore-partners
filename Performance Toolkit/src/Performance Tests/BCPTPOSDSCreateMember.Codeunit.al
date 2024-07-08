codeunit 88006 "NPR BCPT POS DS Create Member" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        SelectLatestVersion();

        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        CreateDirectSalesWithCreateMember();
    end;

    var
        Item: Record Item;
        BarCodeItemReference: Record "Item Reference";
        POSPaymentMethod: Record "NPR POS Payment Method";
        BCPTTestContext: Codeunit "BCPT Test Context";
        POSSession: Codeunit "NPR POS Session";
        POSMockLibrary: Codeunit "NPR BCPT Library - POS Mock";
        POSMasterDataLibrary: Codeunit "NPR BCPT Library POSMasterData";
        IsInitialized, PostSale, AllowGapsInSaleFiscalNoSeries : Boolean;
        NoOfSales: Integer;
        NoOfSalesParamLbl: Label 'NoOfSales', Locked = true;
        PostSaleParamLbl: Label 'PostSale', Locked = true;
        AllowGapsInSaleFiscalNoSeriesParamLbl: Label 'AllowGapsInSaleFiscalNoSeries', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';

    local procedure InitTest();
    var
        NoSeriesLine: Record "No. Series Line";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        BCPTInitializeDataSetup: Record "NPR BCPT Initialize Data Setup";
    begin
        POSPaymentMethod.Get('K');
        Item.Get('320102');

        if Evaluate(NoOfSales, BCPTTestContext.GetParameter(NoOfSalesParamLbl)) then;
        if Evaluate(PostSale, BCPTTestContext.GetParameter(PostSaleParamLbl)) then;
        if Evaluate(AllowGapsInSaleFiscalNoSeries, BCPTTestContext.GetParameter(AllowGapsInSaleFiscalNoSeriesParamLbl)) then;

        if NoOfSales < 1 then
            NoOfSales := 1;
        if NoOfSales > 1000 then
            NoOfSales := 1000;

        POSMasterDataLibrary.CreateBarCodeItemReference(BarCodeItemReference, Item);

        POSAuditProfile.Get('DEFAULT');
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sale Fiscal No. Series");
        NoSeriesLine.FindSet(true);
        repeat
            if AllowGapsInSaleFiscalNoSeries <> NoSeriesLine."Allow Gaps in Nos." then begin
                NoSeriesLine.Validate("Allow Gaps in Nos.", AllowGapsInSaleFiscalNoSeries);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;

        Commit();
        BCPTInitializeDataSetup.FindNextPOSUnit(POSUnit);
        Commit();
        POSMasterDataLibrary.OpenPOSUnit(POSUnit);
        POSMockLibrary.InitializePOSSession(POSSession, POSUnit);
        Commit();
    end;

    local procedure CreateDirectSalesWithCreateMember()
    var
        i: Integer;
    begin
        for i := 1 to NoOfSales do
            CreateDirectSaleWithCreateMember();
    end;

    local procedure CreateDirectSaleWithCreateMember()
    var
        AmountToPay: Decimal;
    begin
        StartSale();
        AmountToPay := CreateSaleLine();
        PaySale(AmountToPay);
    end;

    local procedure StartSale()
    begin
        BCPTTestContext.StartScenario('Start Sale');
        POSSession.StartTransaction();
        BCPTTestContext.EndScenario('Start Sale');
        Commit();
        BCPTTestContext.UserWait();
    end;

    local procedure CreateSaleLine() AmountToPay: Decimal
    var
        BCPTMembershipEventSubs: Codeunit "NPR BCPT Membership Event Subs";
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
    begin
        BCPTTestContext.StartScenario('Add Sale Line');
        BindSubscription(BCPTMembershipEventSubs);
        POSMockLibrary.CreateItemLine(POSSession, Item, BarCodeItemReference, ItemIdentifierType::ItemCrossReference, 1);
        AmountToPay := Item."Unit Price";
        UnbindSubscription(BCPTMembershipEventSubs);
        BCPTTestContext.EndScenario('Add Sale Line');
        Commit();
        BCPTTestContext.UserWait();
    end;

    local procedure PaySale(AmountToPay: Decimal)
    begin
        BCPTTestContext.StartScenario('Pay Sale');
        POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '', PostSale);
        BCPTTestContext.EndScenario('Pay Sale');
        Commit();
        BCPTTestContext.UserWait();
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(
            CopyStr(GetDefaultNoOfSalesParameter() + ',' +
            GetDefaultPostSaleParameter() + ',' +
            GetDefaultAllowGapsInSaleFiscalNoSeriesParameter(), 1, 1000));
    end;

    local procedure GetDefaultNoOfSalesParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfSalesParamLbl + '=' + Format(10), 1, 1000));
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
        ValidateNoOfSalesParameter(CopyStr(SelectStr(1, Parameters), 1, 1000));
        ValidatePostSaleParameter(CopyStr(SelectStr(2, Parameters), 1, 1000));
        ValidateAllowGapsInSaleFiscalNoSeriesParameter(CopyStr(SelectStr(3, Parameters), 1, 1000));
    end;

    local procedure ValidateNoOfSalesParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, NoOfSalesParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(NoOfSalesParamLbl + '='));
            if Evaluate(NoOfSales, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultNoOfSalesParameter());
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