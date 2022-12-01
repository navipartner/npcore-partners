codeunit 88000 "NPR BCPT POS Direct Sale Cash" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        CreateDirectSalesWithCash();
    end;

    var
        Item, Item2 : Record Item;
        BarCodeItemReference, BarCodeItemReference2 : Record "Item Reference";
        POSPaymentMethod: Record "NPR POS Payment Method";
        BCPTTestContext: Codeunit "BCPT Test Context";
        POSSession: Codeunit "NPR POS Session";
        LibraryRandom: Codeunit "NPR Library - Random";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        IsInitialized, PostSale, AllowGapsInSaleFiscalNoSeries : Boolean;
        NoOfSales, NoOfLinesPerSale : Integer;
        NoOfSalesParamLbl: Label 'NoOfSales', Locked = true;
        NoOfLinesPerSaleParamLbl: Label 'NoOfLinesPerSale', Locked = true;
        PostSaleParamLbl: Label 'PostSale', Locked = true;
        AllowGapsInSaleFiscalNoSeriesParamLbl: Label 'AllowGapsInSaleFiscalNoSeries', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';


    local procedure InitTest();
    var
        NoSeriesLine: Record "No. Series Line";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        POSPaymentMethod.Get('K');
        Item.Get('100CHIMSTA');
        Item2.Get('100DFTBLK');

        POSUnit.Get('01');
        POSMasterDataLibrary.OpenPOSUnit(POSUnit);
        POSMockLibrary.InitializePOSSession(POSSession, POSUnit);

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

        CreateBarCodeItemReference(BarCodeItemReference, Item);
        CreateBarCodeItemReference(BarCodeItemReference2, Item2);

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sale Fiscal No. Series");
        NoSeriesLine.FindFirst();
        NoSeriesLine.Validate("Allow Gaps in Nos.", AllowGapsInSaleFiscalNoSeries);
        NoSeriesLine.Modify();

        Commit();
    end;

    local procedure CreateBarCodeItemReference(var NewItemReference: Record "Item Reference"; Item: Record Item)
    begin
        NewItemReference.SetCurrentKey("Reference Type", "Reference No.");
        NewItemReference.SetRange("Reference Type", NewItemReference."Reference Type"::"Bar Code");
        NewItemReference.SetRange("Item No.", Item."No.");
        if NewItemReference.Count() > 1 then
            NewItemReference.DeleteAll();

        if not NewItemReference.FindFirst() then begin
            NewItemReference.Init();
            NewItemReference."Item No." := Item."No.";
            NewItemReference."Reference Type" := NewItemReference."Reference Type"::"Bar Code";
            NewItemReference."Reference No." := LibraryRandom.RandText(50);
            NewItemReference.Insert(true);
        end;
    end;

    local procedure CreateDirectSalesWithCash()
    var
        i: Integer;
    begin
        for i := 1 to NoOfSales do
            CreateDirectSaleWithCash();
    end;

    local procedure CreateDirectSaleWithCash()
    var
        AmountToPay: Decimal;
    begin
        StartSale();
        AmountToPay := CreateLinesPerSale();
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

    local procedure CreateLinesPerSale() AmountToPay: Decimal
    var
        i: Integer;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference;
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
            Commit();
            BCPTTestContext.UserWait();
        end;
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
            GetDefaultNoOfSalesParameter() + ',' +
            GetDefaultNoOfLinesPerSaleParameter() + ',' +
            GetDefaultPostSaleParameter() + ',' +
            GetDefaultAllowGapsInSaleFiscalNoSeriesParameter());
    end;

    local procedure GetDefaultNoOfSalesParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfSalesParamLbl + '=' + Format(10), 1, 1000));
    end;

    local procedure GetDefaultNoOfLinesPerSaleParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfLinesPerSaleParamLbl + '=' + Format(5), 1, 1000));
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
        ValidateNoOfSalesParameter(SelectStr(1, Parameters));
        ValidateNoOfLinesPerSaleParameter(SelectStr(2, Parameters));
        ValidatePostSaleParameter(SelectStr(3, Parameters));
        ValidateAllowGapsInSaleFiscalNoSeriesParameter(SelectStr(4, Parameters));
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