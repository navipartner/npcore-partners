codeunit 6248275 "NPR POS Action: HUL Cash Mgt B"
{
    Access = Internal;

    #region HU L Cash Mgt. B - Request Creation
    internal procedure SetRequestValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        HwcRequest: JsonObject;
        Method: Option moneyIn,moneyOut;
    begin
        Setup.GetPOSUnit(POSUnit);
        Method := Context.GetIntegerParameter('Method');
        PrepareHwcRequest(HwcRequest, POSUnit, Method);
        Context.SetContext('hwcRequest', HwcRequest);
        Context.SetContext('showSpinner', true);
    end;

    local procedure PrepareHwcRequest(var HwcRequest: JsonObject; POSUnit: Record "NPR POS Unit"; Method: Option moneyIn,moneyOut)
    var
        RequestText: Text;
    begin
        HULCommunicationMgt.SetBaseHwcRequestValues(HwcRequest, POSUnit."No.");

        if Method = Method::moneyIn then
            RequestText := CreateMoneyInRequest(HwcRequest, POSUnit, Method)
        else
            RequestText := CreateMoneyOutRequest(HwcRequest, POSUnit, Method);

        HwcRequest.Add('Payload', RequestText);
    end;

    procedure CreateMoneyInRequest(var HwcRequest: JsonObject; POSUnit: Record "NPR POS Unit"; Method: Option moneyIn,moneyOut): Text
    var
        HULCashMgtReason: Record "NPR HU L Cash Mgt. Reason";
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
        HULCashMgtReasonsPage: Page "NPR HU L Cash Mgt. Reasons";
        HULPOSPaymMethMappPage: Page "NPR HU L POS Paym. Meth. Mapp.";
        InputDialog: Page "NPR Input Dialog";
        CashInAmount: Decimal;
        RoundingAmount: Decimal;
        RoundingNeeded: Boolean;
        CashInAmountLbl: Label 'Cash In Amount';
        CashInAmountErr: Label 'Cash In Amount must be positive.';
        RequestText: Text;
    begin
        if HULCashMgtReason.IsEmpty() then begin
            HULCashMgtReason.InitCashMgtReasons();
            Commit();
        end;
        HULCashMgtReason.SetRange("Entry No.", 1, 8);
        HULCashMgtReasonsPage.LookupMode(true);
        HULCashMgtReasonsPage.SetTableView(HULCashMgtReason);
        if (HULCashMgtReasonsPage.RunModal() <> Action::LookupOK) then
            Error('');
        HULCashMgtReasonsPage.GetRecord(HULCashMgtReason);

        HULPOSPaymMethMappPage.Editable(false);
        HULPOSPaymMethMappPage.LookupMode(true);
        if (HULPOSPaymMethMappPage.RunModal() <> Action::LookupOK) then
            Error('');
        HULPOSPaymMethMappPage.GetRecord(HULPOSPaymMethMapp);

        Clear(InputDialog);
        InputDialog.SetInput(1, CashInAmount, CashInAmountLbl);
        InputDialog.LookupMode(true);
        if InputDialog.RunModal() <> Action::LookupOK then
            Error('');
        InputDialog.InputDecimal(1, CashInAmount);

        if CashInAmount <= 0 then
            Error(CashInAmountErr);

        CashInAmount := Round(CashInAmount, 1, '=');
        RoundingNeeded := CheckIfMoneyTransactionRoundingNeccessary(CashInAmount);

        if RoundingNeeded then
            RoundingAmount := CalculateMoneyTransactionRounding(CashInAmount);

        RequestText := HULCommunicationMgt.MoneyTransaction(HULCashMgtReason, HULPOSPaymMethMapp, Method, CashInAmount, RoundingAmount);
        InsertMoneyTransactionRecord(POSUnit, HULPOSPaymMethMapp."POS Payment Method Code", Method, CashInAmount, RoundingAmount, RequestText);

        exit(RequestText);
    end;

    procedure CreateMoneyOutRequest(var HwcRequest: JsonObject; POSUnit: Record "NPR POS Unit"; Method: Option moneyIn,moneyOut): Text
    var
        HULCashMgtReason: Record "NPR HU L Cash Mgt. Reason";
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
        HULCashMgtReasonsPage: Page "NPR HU L Cash Mgt. Reasons";
        HULPOSPaymMethMappPage: Page "NPR HU L POS Paym. Meth. Mapp.";
        InputDialog: Page "NPR Input Dialog";
        CashOutAmount: Decimal;
        RoundingAmount: Decimal;
        RoundingNeeded: Boolean;
        CashOutAmountLbl: Label 'Cash Out Amount';
        CashOutAmountErr: Label 'Cash Out Amount must be positive.';
        RequestText: Text;
    begin
        if HULCashMgtReason.IsEmpty() then begin
            HULCashMgtReason.InitCashMgtReasons();
            Commit();
        end;
        HULCashMgtReason.SetRange("Entry No.", 31, 41);
        HULCashMgtReasonsPage.LookupMode(true);
        HULCashMgtReasonsPage.SetTableView(HULCashMgtReason);
        if (HULCashMgtReasonsPage.RunModal() <> Action::LookupOK) then
            Error('');
        HULCashMgtReasonsPage.GetRecord(HULCashMgtReason);

        HULPOSPaymMethMappPage.Editable(false);
        HULPOSPaymMethMappPage.LookupMode(true);
        if (HULPOSPaymMethMappPage.RunModal() <> Action::LookupOK) then
            Error('');
        HULPOSPaymMethMappPage.GetRecord(HULPOSPaymMethMapp);

        Clear(InputDialog);
        InputDialog.SetInput(1, CashOutAmount, CashOutAmountLbl);
        InputDialog.LookupMode(true);
        if InputDialog.RunModal() <> Action::LookupOK then
            Error('');
        InputDialog.InputDecimal(1, CashOutAmount);

        if CashOutAmount <= 0 then
            Error(CashOutAmountErr);

        CashOutAmount := Round(CashOutAmount, 1, '=');
        RoundingNeeded := CheckIfMoneyTransactionRoundingNeccessary(CashOutAmount);

        if RoundingNeeded then
            RoundingAmount := CalculateMoneyTransactionRounding(CashOutAmount);

        RequestText := HULCommunicationMgt.MoneyTransaction(HULCashMgtReason, HULPOSPaymMethMapp, Method, CashOutAmount, RoundingAmount);
        InsertMoneyTransactionRecord(POSUnit, HULPOSPaymMethMapp."POS Payment Method Code", Method, CashOutAmount, RoundingAmount, RequestText);

        exit(RequestText);
    end;

    #endregion HU L Cash Mgt. B - Request Creation

    #region HU L Cash Mgt. B - Response Parsing
    internal procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    begin
        Response := ParseHwcResponse(Context);
        ProcessLaurelMiniPOSResponse(Response);
    end;

    internal procedure ProcessLaurelMiniPOSResponse(Response: JsonObject)
    var
        ResponseMessage: JsonObject;
        ResponseMsgToken: JsonToken;
    begin
        HULCommunicationMgt.ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Response);

        Response.Get('ResponseMessage', ResponseMsgToken);
        ResponseMessage := ResponseMsgToken.AsObject();

        HULCommunicationMgt.ThrowErrorMsgFromResponseMessageIfNotSuccessful(ResponseMessage); //Handles iErrCode and sErrMsg from ResponseMessage

        HULCommunicationMgt.HandleMoneyOutTransactionResponse(ResponseMessage);
    end;

    local procedure ParseHwcResponse(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HwcResponse: JsonObject;
        JsonTok: JsonToken;
    begin
        // HWC data
        Response.Add('ShowSuccessMessage', false);

        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcResponse.Get('Success', JsonTok);
        Response.Add('Success', JsonTok.AsValue().AsBoolean());

        HwcResponse.Get('ResponseMessage', JsonTok);
        JsonTok.ReadFrom(JsonTok.AsValue().AsText().Replace('\"', '"'));
        Response.Add('ResponseMessage', JsonTok);

        HwcResponse.Get('ErrorMessage', JsonTok);
        Response.Add('ErrorMessage', JsonTok);
    end;
    #endregion HU L Cash Mgt. B - Response Parsing

    #region HU L Cash Mgt. B - Helper Procedures
    local procedure CheckIfMoneyTransactionRoundingNeccessary(Amount: Decimal): Boolean
    begin
        exit(Round(Amount, 5, '=') <> Amount);
    end;

    local procedure CalculateMoneyTransactionRounding(Amount: Decimal): Decimal
    begin
        exit(-1 * (Amount - Round(Amount, 5, '=')));
    end;

    internal procedure InsertMoneyTransactionRecord(POSUnit: Record "NPR POS Unit"; POSPaymentMethodCode: Code[10]; EntryType: Option moneyIn,moneyOut; CashMgtAmount: Decimal; RoundingAmount: Decimal; RequestText: Text)
    var
        HULCashTransaction: Record "NPR HU L Cash Transaction";
    begin
        HULCashTransaction.Init();
        HULCashTransaction."POS Store Code" := POSUnit."POS Store Code";
        HULCashTransaction."POS Unit No." := POSUnit."No.";
        HULCashTransaction."POS Payment Method Code" := POSPaymentMethodCode;
        HULCashTransaction."Cash Amount" := CashMgtAmount;
        HULCashTransaction."Rounding Amount" := RoundingAmount;
        HULCashTransaction."Entry Type" := EntryType;
        HULCashTransaction."Entry No." := HULCashTransaction.GetLastEntryNo() + 1;
        HULCashTransaction.SetRequestText(RequestText);
        HULCashTransaction.Insert();
    end;
    #endregion HU L Cash Mgt. B - Helper Procedures
    var
        HULCommunicationMgt: Codeunit "NPR HU L Communication Mgt.";
}