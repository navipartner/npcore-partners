codeunit 6184728 "NPR POS Action: IT EJ Report" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer periodical report printing.';
        StartDateEnterLbl: Label 'Enter Starting Date';
        EndDateEnterLbl: Label 'Enter Ending Date';
        ZReportDateLbl: Label 'Z Report Date';
        ReceiptNoLbl: Label 'Receipt Number (From-To)';
        TitleLbl: Label 'Periodical Report';
        ParamMethodCaptionLbl: Label 'Method';
        ParamMethodDescrLbl: Label 'Specifies the Method used.';
        ParamMethodOptionsCaptionLbl: Label 'Periodical Report By Date,Periodical Report By Receipt Number';
        ParamMethodOptionsLbl: Label 'reportByDate,reportByNumber', Locked = true;
        StatusCodeErr: Label 'Error in communication with the RT printer.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddLabel('startDatePrompt', StartDateEnterLbl);
        WorkflowConfig.AddLabel('endDatePrompt', EndDateEnterLbl);
        WorkflowConfig.AddLabel('receiptNoPrompt', ReceiptNoLbl);
        WorkflowConfig.AddLabel('zReportDatePrompt', ZReportDateLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('statuserror', StatusCodeErr);
        WorkflowConfig.AddOptionParameter('Method',
                        ParamMethodOptionsLbl,
#pragma warning disable AA0139
                                SelectStr(1, ParamMethodOptionsLbl),
#pragma warning restore
                                ParamMethodCaptionLbl,
                        ParamMethodDescrLbl,
                        ParamMethodOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context, POSSession);
            'CreateHTTPRequestBody':
                FrontEnd.WorkflowResponse(CreateHTTPRequestBody(Context, Sale));
            'HandleResponse':
                HandleResponse(Context);
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        POSSetup: Codeunit "NPR POS Setup";
        DefaultValidFromDate: Date;
    begin
        POSSession.GetSetup(POSSetup);
        if not (Evaluate(DefaultValidFromDate, POSSetup.ExchangeLabelDefaultDate()) and (StrLen(POSSetup.ExchangeLabelDefaultDate()) > 0)) then
            DefaultValidFromDate := Today();

        Context.SetContext('defaultdate', Format(DefaultValidFromDate, 0, 9));
    end;

    local procedure CreateHTTPRequestBody(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Request: JsonObject;
    var
        POSActionITEJReportB: Codeunit "NPR POS Action: IT EJ Report B";
        Method: Option reportByDate,reportByNumber;
    begin
        Method := Context.GetIntegerParameter('Method');

        POSActionITEJReportB.CreateHTTPRequestBody(Method, Context, Sale, Request);
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        POSActionITEJReportB: Codeunit "NPR POS Action: IT EJ Report B";
    begin
        POSActionITEJReportB.HandleResponse(Context);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionITFPMgt.js##
        'const main = async ({workflow, context, parameters, captions}) => { await workflow.respond("AddPresetValuesToContext"); var methodNames = [ "reportByDate", "reportByNumber" ]; let methodId = Number(parameters.Method); let Method = methodNames[methodId]; switch(Method) { case "reportByDate":{ workflow.context.startdate = await popup.datepad({ title: captions.title, caption: captions.startDatePrompt, required: true, value: context.defaultdate}); if (workflow.context.startdate === null) { return;} workflow.context.enddate = await popup.datepad({ title: captions.title, caption: captions.endDatePrompt, required: true, value: context.defaultdate}); if (workflow.context.enddate === null) { return;} break; } case "reportByNumber":{ workflow.context.zreportdate = await popup.datepad({ title: captions.title, caption: captions.zReportDatePrompt, required: true, value: context.defaultdate}); if (workflow.context.zreportdate === null) { return;} workflow.context.receiptnumber = await popup.input({ title: captions.title, caption: captions.receiptNoPrompt}); if (workflow.context.receiptnumber === null) { return;} break; } } let request = await workflow.respond("CreateHTTPRequestBody"); let result = await fetchFromPrinter(request); await workflow.respond("HandleResponse", { result: result }); }; async function fetchFromPrinter(request) { const response = await fetch(request["url"], { method: "POST", headers: { "Content-Type": "application/xml", }, body: request["requestBody"] }); return await response.text(); };'
        );
    end;
}