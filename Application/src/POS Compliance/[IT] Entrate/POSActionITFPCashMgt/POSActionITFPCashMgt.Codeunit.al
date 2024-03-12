codeunit 6184745 "NPR POS Action: IT FP Cash Mgt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ITPrinterMgt: Codeunit "NPR IT Printer Mgt.";
        ProcessResponse: Boolean;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage cash in fiscal printer.';
        ParamDirectionCaptionLbl: Label 'Direction';
        ParamDirectionDescrLbl: Label 'Specifies the Direction used.';
        ParamDirectionOptionsCaptionLbl: Label 'In,Out';
        ParamDirectionOptionsLbl: Label 'in,out', Locked = true;
        ParamMgtFormCaptionLbl: Label 'Form';
        ParamMgtFormDescrLbl: Label 'Specifies the Form of cash handling used.';
        ParamMgtFormOptionsCaptionLbl: Label 'Cash,Cheque';
        ParamMgtFormOptionsLbl: Label 'cash,cheque', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Direction', ParamDirectionOptionsLbl, '', ParamDirectionCaptionLbl, ParamDirectionDescrLbl, ParamDirectionOptionsCaptionLbl);
        WorkflowConfig.AddOptionParameter('Form', ParamMgtFormOptionsLbl, '', ParamMgtFormCaptionLbl, ParamMgtFormDescrLbl, ParamMgtFormOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'CreateHTTPRequestBody':
                FrontEnd.WorkflowResponse(CreateHTTPRequestBody(Context, Sale));
            'HandleResponse':
                HandleResponse(Context);
        end;
    end;

    local procedure CreateHTTPRequestBody(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Request: JsonObject;
    var
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
        POSSale: Record "NPR POS Sale";
        InputDialog: Page "NPR Input Dialog";
        AmountToHandle: Decimal;
        AmountToHandleLbl: Label 'Amount to Handle';
        AmountToHandleErr: Label 'Amount to Handle must be positive.';
        Direction: Option in,out;
        Form: Option cash,cheque;
    begin
        Sale.GetCurrentSale(POSSale);
        ITPOSUnitMapping.Get(POSSale."Register No.");
        ITPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Direction := Context.GetIntegerParameter('Direction');
        Form := Context.GetIntegerParameter('Form');

        Clear(InputDialog);
        InputDialog.SetInput(1, AmountToHandle, AmountToHandleLbl);
        InputDialog.LookupMode(true);
        if InputDialog.RunModal() <> Action::LookupOK then
            exit;
        InputDialog.InputDecimal(1, AmountToHandle);

        ProcessResponse := true;

        if AmountToHandle <= 0 then
            Error(AmountToHandleErr);

        AddParametersToRequest(Request, ITPOSUnitMapping, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreatePrinterCashHandlingRequestMessage(AmountToHandle, Direction, Form)));
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        ResponseToken: JsonToken;
    begin
        if not ProcessResponse then
            exit;

        ResponseToken := Context.GetJToken('result');

        ITPrinterMgt.ProcessFPrinterCashHandlingResponse(ResponseToken);
    end;

    local procedure AddParametersToRequest(var Request: JsonObject; ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; RequestMessage: Text)
    begin
        Request.Remove('requestBody');
        Request.Add('url', ITPrinterMgt.FormatHTTPRequestUrl(ITPOSUnitMapping."Fiscal Printer IP Address"));
        Request.Add('requestBody', RequestMessage);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionITFPCashMgt.js###
        'let main = async ({ workflow, context }) => { let request = await workflow.respond("CreateHTTPRequestBody"); const response = await fetch(request["url"], { method: "POST", headers: { "Content-Type": "application/xml", }, body: request["requestBody"] }); const result = await response.text(); await workflow.respond("HandleResponse", { result: result }); };'
        );
    end;
}