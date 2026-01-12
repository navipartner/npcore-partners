codeunit 6184892 "NPR POS Action Sentry Example" implements "NPR IPOS Workflow"
{
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Sentry Telemetry example';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup")
    var
        Sentry: Codeunit "NPR Sentry";
        ParentSpan: Codeunit "NPR Sentry Span";
        ChildSpan: Codeunit "NPR Sentry Span";
        ChildSpan2: Codeunit "NPR Sentry Span";
        Item: Record Item;
        ItemDescription: Text;
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        StatusCode: Integer;
    begin
        // a scope and transaction has automatically been started before your POS action runs
        // so you don't need to do it manually.

        Sentry.StartSpan(ParentSpan, 'workflow_parent');
        Sleep(1000);
        Sentry.StartSpan(ChildSpan, 'workflow_child');
        Sleep(2000);
        ChildSpan.Finish();

        Sentry.StartSpan(ChildSpan2, 'workflow_child2');
        if Sentry.FindSet(Item, false, true) then
            repeat
                ItemDescription += Item.Description;
            until Sentry.Next(Item) = 0;
        ChildSpan2.Finish();

        HttpRequest.SetRequestUri('https://jsonplaceholder.typicode.com/comments');
        HttpRequest.Method := 'GET';
        if Sentry.HttpInvoke(HttpClient, HttpRequest, HttpResponse, true) then begin
            StatusCode := HttpResponse.HttpStatusCode;
        end;

        if Sentry.PageRunModal(Page::"Item List", Item) = Action::LookupOK then;

        if Sentry.Confirm('Are you sure?', true) then;

        Sentry.ReportRun(Report::"NPR Turnover Rate");

        ParentSpan.Finish();

        Message('%1', ItemDescription);
        Message('%1', StatusCode);

        if not FunctionWithError() then
            Sentry.AddLastErrorInEnglish();

        Error('bubble error to workflow error handler. This is a programming bug.')
    end;

    [TryFunction]
    local procedure FunctionWithError()
    begin
        Error('An error occurred in the workflow');
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSentryExample.js###
'let main=async({workflow:n})=>{n.respond()};'
        )
    end;

}
