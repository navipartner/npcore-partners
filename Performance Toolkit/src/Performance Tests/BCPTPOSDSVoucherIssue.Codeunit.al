codeunit 88003 "NPR BCPT POS DS Voucher Issue" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        SelectLatestVersion();

        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        CreateDirectSalesWithVoucherIssue();
    end;

    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        VoucherType: Record "NPR NpRv Voucher Type";
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
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        NoSeriesLine: Record "No. Series Line";
        BCPTInitializeDataSetup: Record "NPR BCPT Initialize Data Setup";
    begin
        POSPaymentMethod.Get('K');
        VoucherType.Get('CREDITVOUCHER');

        if Evaluate(NoOfSales, BCPTTestContext.GetParameter(NoOfSalesParamLbl)) then;
        if Evaluate(PostSale, BCPTTestContext.GetParameter(PostSaleParamLbl)) then;
        if Evaluate(AllowGapsInSaleFiscalNoSeries, BCPTTestContext.GetParameter(AllowGapsInSaleFiscalNoSeriesParamLbl)) then;

        if NoOfSales < 1 then
            NoOfSales := 1;
        if NoOfSales > 1000 then
            NoOfSales := 1000;

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

    local procedure CreateDirectSalesWithVoucherIssue()
    var
        i: Integer;
    begin
        for i := 1 to NoOfSales do
            CreateDirectSaleWithVoucherIssue();
    end;

    local procedure CreateDirectSaleWithVoucherIssue()
    var
        AmountToPay: Decimal;
    begin
        StartSale();
        AmountToPay := 10000;
        CreateVoucherLine(AmountToPay);
        PaySale(AmountToPay);
    end;

    local procedure StartSale()
    begin
        BCPTTestContext.StartScenario('Start Sale');
        POSSession.StartTransaction();
        BCPTTestContext.EndScenario('Start Sale');
        BCPTTestContext.UserWait();
    end;

    local procedure CreateVoucherLine(AmountToPay: Decimal)
    begin
        BCPTTestContext.StartScenario('Add Voucher Line');
        POSMockLibrary.CreateVoucherLine(POSSession, VoucherType.Code, 1, AmountToPay, '', 0);
        BCPTTestContext.EndScenario('Add Voucher Line');
        BCPTTestContext.UserWait();
    end;

    local procedure PaySale(AmountToPay: Decimal)
    begin
        BCPTTestContext.StartScenario('Pay Sale');
        POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '', PostSale);
        BCPTTestContext.EndScenario('Pay Sale');
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
        exit(CopyStr(NoOfSalesParamLbl + '=' + Format(1), 1, 1000));
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