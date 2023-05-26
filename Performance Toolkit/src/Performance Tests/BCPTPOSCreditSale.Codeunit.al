codeunit 88002 "NPR BCPT POS Credit Sale" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        SelectLatestVersion();

        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        CreateCreditSales();
    end;

    var
        Item, Item2 : Record Item;
        BarCodeItemReference, BarCodeItemReference2 : Record "Item Reference";
        BCPTTestContext: Codeunit "BCPT Test Context";
        POSSession: Codeunit "NPR POS Session";
        POSMockLibrary: Codeunit "NPR BCPT Library - POS Mock";
        POSMasterDataLibrary: Codeunit "NPR BCPT Library POSMasterData";
        IsInitialized, PostSale, AllowGapsInSaleFiscalNoSeries : Boolean;
        NoOfSales, NoOfLinesPerSale : Integer;
        NoOfSalesParamLbl: Label 'NoOfSales', Locked = true;
        NoOfLinesPerSaleParamLbl: Label 'NoOfLinesPerSale', Locked = true;
        PostSaleParamLbl: Label 'PostSale', Locked = true;
        AllowGapsInSaleFiscalNoSeriesParamLbl: Label 'AllowGapsInSaleFiscalNoSeries', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';

    local procedure InitTest();
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Salesperson: Record "Salesperson/Purchaser";
        NoSeriesLine: Record "No. Series Line";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        BCPTInitializeDataSetup: Record "NPR BCPT Initialize Data Setup";
    begin
        Item.Get('100CHIMSTA');
        Item2.Get('100DFTBLK');

        if Evaluate(NoOfSales, BCPTTestContext.GetParameter(NoOfSalesParamLbl)) then;
        if Evaluate(NoOfLinesPerSale, BCPTTestContext.GetParameter(NoOfLinesPerSaleParamLbl)) then;
        if Evaluate(PostSale, BCPTTestContext.GetParameter(PostSaleParamLbl)) then;
        if Evaluate(AllowGapsInSaleFiscalNoSeries, BCPTTestContext.GetParameter(AllowGapsInSaleFiscalNoSeriesParamLbl)) then;

        if NoOfSales < 1 then
            NoOfSales := 1;
        if NoOfSales > 1000 then
            NoOfSales := 1000;
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
            if AllowGapsInSaleFiscalNoSeries <> NoSeriesLine."Allow Gaps in Nos." then begin
                NoSeriesLine.Validate("Allow Gaps in Nos.", AllowGapsInSaleFiscalNoSeries);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;

        SalesSetup.Get();
        SalesSetup.TestField("Order Nos.");
        NoSeriesLine.SetRange("Series Code", SalesSetup."Order Nos.");
        NoSeriesLine.FindSet(true);
        repeat
            if NoSeriesLine."Ending No." <> '' then begin
                NoSeriesLine."Ending No." := '';
                NoSeriesLine.Validate("Allow Gaps in Nos.", true);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;

        Commit();
        BCPTInitializeDataSetup.FindNextPOSUnit(POSUnit);
        Commit();
        POSMasterDataLibrary.OpenPOSUnit(POSUnit);
        Salesperson.Get('1');
        POSMockLibrary.InitializePOSSession(POSSession, POSUnit, Salesperson);
        Commit();
    end;

    local procedure CreateCreditSales()
    var
        i: Integer;
    begin
        for i := 1 to NoOfSales do
            CreateCreditSale();
    end;

    local procedure CreateCreditSale()
    begin
        StartSale();
        CreateLinesPerSale();
        SelectCustomerForSale();
        ExportSale();
    end;

    local procedure StartSale()
    begin
        BCPTTestContext.StartScenario('Start Sale');
        POSSession.StartTransaction();
        BCPTTestContext.EndScenario('Start Sale');
        BCPTTestContext.UserWait();
    end;

    local procedure CreateLinesPerSale()
    var
        i: Integer;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
    begin
        for i := 1 to NoOfLinesPerSale do begin
            if i = 1 then
                BCPTTestContext.StartScenario('Add Sale Line');
            if i mod 2 = 1 then
                POSMockLibrary.CreateItemLine(POSSession, Item, BarCodeItemReference, ItemIdentifierType::ItemCrossReference, 1)
            else
                POSMockLibrary.CreateItemLine(POSSession, Item2, BarCodeItemReference2, ItemIdentifierType::ItemCrossReference, 1);
            if i = 1 then
                BCPTTestContext.EndScenario('Add Sale Line');
            BCPTTestContext.UserWait();
        end;
    end;

    local procedure SelectCustomerForSale()
    var
        Customer: Record Customer;
        POSSale: Record "NPR POS Sale";
        SalePOS: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
    begin
        BCPTTestContext.StartScenario('Select Customer');
        POSSession.GetSale(SalePOS);
        SalePOS.GetCurrentSale(POSSale);
#pragma warning disable AA0181
        Customer.Next((SessionId() mod 4) + 1);
#pragma warning restore AA0181
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);
        BCPTTestContext.EndScenario('Select Customer');
        BCPTTestContext.UserWait();
    end;

    local procedure ExportSale()
    var
        SalePOS: Codeunit "NPR POS Sale";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        BCPTMiscEventSubs: Codeunit "NPR BCPT Misc. Event Subs";
    begin
        BCPTTestContext.StartScenario('Export Sale');
        BindSubscription(BCPTMiscEventSubs);
        POSSession.GetSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetInvoice(true);
        SalesDocumentExportMgt.SetShip(true);
        SalesDocumentExportMgt.ProcessPOSSale(SalePOS);
        UnbindSubscription(BCPTMiscEventSubs);
        BCPTTestContext.EndScenario('Export Sale');
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
        exit(CopyStr(NoOfSalesParamLbl + '=' + Format(1), 1, 1000));
    end;

    local procedure GetDefaultNoOfLinesPerSaleParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfLinesPerSaleParamLbl + '=' + Format(5), 1, 1000));
    end;

    local procedure GetDefaultPostSaleParameter(): Text[1000]
    begin
        exit(CopyStr(PostSaleParamLbl + '=' + Format(true), 1, 1000));
    end;

    local procedure GetDefaultAllowGapsInSaleFiscalNoSeriesParameter(): Text[1000]
    begin
        exit(CopyStr(AllowGapsInSaleFiscalNoSeriesParamLbl + '=' + Format(true), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        ValidateNoOfSalesParameter(CopyStr(SelectStr(1, Parameters), 1, 1000));
        ValidateNoOfLinesPerSaleParameter(CopyStr(SelectStr(2, Parameters), 1, 1000));
        ValidatePostSaleParameter(CopyStr(SelectStr(3, Parameters), 1, 1000));
        ValidateAllowGapsInSaleFiscalNoSeriesParameter(CopyStr(SelectStr(4, Parameters), 1, 1000));
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