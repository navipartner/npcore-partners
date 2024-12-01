codeunit 6185073 "NPR POSAction: GetText" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Add a description for this label';
        DescPOSPaymentMethodCode: Label 'Select POS Payment Method Code to be used for EFT Get Text';
        CaptionPOSPaymentMethodCode: Label 'POS Payment Method Code';
        TerminalInputTitleCpt: Label 'Terminal Input Title';
        TerminalInputTitleDesc: Label 'Insert Terminal Input Title';
        DefaultInputTxtCpt: Label 'Default Input Text';
        DefaultInputTxtDesc: Label 'Insert Default Input Text';
        MaskChararctersFlagCpt: Label 'Mask user input';
    begin
        WorkflowConfig.AddTextParameter('POSPaymentMethodCode', '', CaptionPOSPaymentMethodCode, DescPOSPaymentMethodCode);
        WorkflowConfig.AddTextParameter('TerminalInputTitle', '', TerminalInputTitleCpt, TerminalInputTitleDesc);
        WorkflowConfig.AddTextParameter('DefaultInputTxt', '', DefaultInputTxtCpt, DefaultInputTxtDesc);
        WorkflowConfig.AddBooleanParameter('MaskChararctersFlag', false, MaskChararctersFlagCpt, MaskChararctersFlagCpt);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    begin
        case Step of
            'GetText':
                GetText(SaleMgr, Context);
        end;
    end;

    local procedure GetText(SaleMgr: Codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper")
    var
        EFTAdyenTextInputReq: Codeunit "NPR EFT Adyen Text Input Req";
        TerminalInputTitle: Text;
        DefaultInputTxt: Text;
        EFTSetup: Record "NPR EFT Setup";
        POSPaymentMethodCode: Code[10];
        SalePOS: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        Request: Text;
        URL: Text;
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        Response: Text;
        StatusCode: Integer;
        JObject: JsonObject;
        JValue: JsonValue;
        ResponseInput: Text;
        MaskChararctersFlag: Boolean;
    begin
        TerminalInputTitle := Context.GetStringParameter('TerminalInputTitle');
#pragma warning disable AA0139
        POSPaymentMethodCode := Context.GetStringParameter('POSPaymentMethodCode');
#pragma warning restore AA0139
        DefaultInputTxt := Context.GetStringParameter('DefaultInputTxt');
        MaskChararctersFlag := Context.GetBooleanParameter('MaskChararctersFlag');

        SaleMgr.GetCurrentSale(SalePOS);

        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethodCode);
        InitEFTRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");

        EFTAdyenTextInputReq.SetTitle(TerminalInputTitle);
        EFTAdyenTextInputReq.SetDefaultInput(DefaultInputTxt);
        EFTAdyenTextInputReq.SetMaskChararctersFlag(MaskChararctersFlag);
        Request := EFTAdyenTextInputReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 60 * 5, Response, StatusCode);
        JObject.ReadFrom(Response);
        if TrySelectValue(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Input.TextInput', JValue, true) then begin
            ResponseInput := JValue.AsText();
            EFTTransactionRequest."Result Description" := CopyStr(ResponseInput, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest.Modify();
        end;
    end;

    local procedure TrySelectValue(JObject: JsonObject; Path: Text; var JValue: JsonValue; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        if WithError then begin
            JObject.SelectToken(Path, JToken);
            JValue := JToken.AsValue();
        end else begin
            if not JObject.SelectToken(Path, JToken) then
                exit(false);
            if not JToken.IsValue then
                exit(false);
            JValue := JToken.AsValue();
        end;
        exit(true);
    end;

    local procedure InitEFTRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; SalesReceiptNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        EFTSetup.TestField("EFT Integration Type");
        EFTSetup.TestField("Payment Type POS");
        EFTTransactionRequest."Integration Type" := EFTSetup."EFT Integration Type";
        EFTTransactionRequest."POS Payment Type Code" := EFTSetup."Payment Type POS"; //This one might be switched later depending on transaction context, ie. card type.
        EFTTransactionRequest."Original POS Payment Type Code" := EFTSetup."Payment Type POS"; //This one will keep pointing to EFTSetup value.
        EFTTransactionRequest."Hardware ID" := EFTAdyenCloudIntegrat.GetPOIID(EFTSetup);
        EFTTransactionRequest."Register No." := POSUnitNo;
        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."User ID" := CopyStr(UserId, 1, MaxStrLen(EFTTransactionRequest."User ID"));
        EFTTransactionRequest."Integration Version Code" := '3.0';
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Token := CreateGuid();
        EFTAdyenPaymTypeSetup.Get(EftTransactionRequest."POS Payment Type Code");
        if EFTAdyenPaymTypeSetup.Environment = EFTAdyenPaymTypeSetup.Environment::PRODUCTION then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::Production
        else
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";
        if POSUnitNo <> '' then begin
            POSUnit.Get(POSUnitNo);
            EFTTransactionRequest."Self Service" := POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED;
        end;

        if (POSUnitNo <> '') and (SalesReceiptNo <> '') then begin
            SalePOS.Get(POSUnitNo, SalesReceiptNo);
            EFTTransactionRequest."Sales ID" := SalePOS.SystemId;
        end;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EFTTransactionRequest.Modify();
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionGetText.js###
'const main=async({workflow:a})=>{await a.respond("GetText")};'
        );
    end;
}