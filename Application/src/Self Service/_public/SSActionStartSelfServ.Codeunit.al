codeunit 6151286 "NPR SS Action: Start SelfServ." implements "NPR IPOS Workflow"
{
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This built in actions starts the POS in SelfService mode';
        ParamSalesPerson_CaptLbl: Label 'Sales Person Code';
        ParamSalesPerson_DescLbl: Label 'Specifies Sales Person Code';
        ParamLanguageCode_CaptLbl: Label 'Language Code';
        ParamLanguageCode_DescLbl: Label 'Specifies Language Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

        WorkflowConfig.AddTextParameter('SalespersonCode', '', ParamSalesPerson_CaptLbl, ParamSalesPerson_DescLbl);
        WorkflowConfig.AddTextParameter('LanguageCode', '', ParamLanguageCode_CaptLbl, ParamLanguageCode_DescLbl);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
        SalespersonCode: Code[20];
        LanguageCode: Code[10];
    begin
        SalesPersonCode := CopyStr(Context.GetStringParameter('SalespersonCode'), 1, MaxStrLen(SalespersonCode));
        LanguageCode := CopyStr(Context.GetStringParameter('LanguageCode'), 1, MaxStrLen(LanguageCode));
        StartSelfService(POSSession, SalesPersonCode, LanguageCode);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
       //###NPR_INJECT_FROM_FILE:POSActionStartSS.js###
       'let main=async({})=>{await workflow.respond()};'
        );
    end;

    procedure StartSelfService(POSSession: Codeunit "NPR POS Session"; SalesPersonCode: Code[20]; LanguageCode: Code[10])
    var
        POSActStartSelfServB: Codeunit "NPR SS Action: Start SelfServB";
    begin
        POSActStartSelfServB.StartSelfService(POSSession, SalesPersonCode, LanguageCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitializationComplete', '', false, false)]
    local procedure OnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        //Invoke POSResume codeunit to check if last exists, with manually bound subscriber?
    end;


}

