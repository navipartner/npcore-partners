codeunit 6059796 "NPR POS Action: Payment WF2" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Payment Workflow Dispatcher';
        HideAmountName: Label 'Hide Amount Dialog';
        HideAmountDesc: Label 'Always hide the amount dialog';
        HideZeroAmountName: Label 'Hide Zero Amount Dialog';
        HideZeroAmountDesc: Label 'Hide the amount dialog when amount is zero';
        PaymentMethodCodeName: Label 'Payment Method Code';
        SwitchToPaymentViewName: Label 'Switch to Payment View';
        SwitchToPaymentViewDesc: Label 'Automatically switch to Payment view, when the POS action is run from Sale view';
        EndSaleName: Label 'Try End Sale';
        EndSaleNameDesc: Label 'Try to end the sale after the payment is processed.';
        MMPaymentMethodAssignedCaption: Label 'A payment method has already been assigned to the membership. Do you want to change it?';
        MembershipSubscPayerEmailTitle: Label 'Enter Payer E-mail';
        MembershipSubscPayerEmailCaption: Label 'Please enter the e-mail address of the person paying for this subscription.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('HideAmountDialog', false, HideAmountName, HideAmountDesc);
        WorkflowConfig.AddBooleanParameter('HideZeroAmountDialog', false, HideZeroAmountName, HideZeroAmountDesc);
        WorkflowConfig.AddBooleanParameter('SwitchToPaymentView', false, SwitchToPaymentViewName, SwitchToPaymentViewDesc);
        WorkflowConfig.AddBooleanParameter('tryEndSale', true, EndSaleName, EndSaleNameDesc);
        WorkflowConfig.AddTextParameter('paymentNo', '', PaymentMethodCodeName, PaymentMethodCodeName);
        WorkflowConfig.AddLabel('paymentMethodAssignedCaption', MMPaymentMethodAssignedCaption);
        WorkflowConfig.AddLabel('MembershipSubscPayerEmailTitle', MembershipSubscPayerEmailTitle);
        WorkflowConfig.AddLabel('MembershipSubscPayerEmailCaption', MembershipSubscPayerEmailCaption);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'preparePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePaymentWithPreprocessing(Sale, PaymentLine, Context));
            'continuePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePaymentAndDetectPostprocessing(Sale, PaymentLine, Context));
            'SetMembershipSubscPayerEmail':
                SetMembershipSubscPayerEmail(Context, Sale);
            'tryEndSale':
                Frontend.WorkflowResponse(AttemptEndSale(Context));
            'doLegacyPaymentWorkflow':
                Frontend.WorkflowResponse(DoLegacyPayment(Context, FrontEnd));
            'preparePostWorkflows':
                Frontend.WorkflowResponse(CollectPostprocessingWorkflows(Context, Sale, PaymentLine));
        end;
    end;

    local procedure PreparePaymentWithPreprocessing(Sale: codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        PreWorkflows: JsonObject;
    begin
        PreWorkflows := AddPreWorkflowsToRun(Context);
        if PreWorkflows.Keys.Count() <> 0 then begin
            Response.ReadFrom('{}');
            Response.Add('preWorkflows', PreWorkflows);
            exit(Response);
        end;

        Response := PreparePaymentAndDetectPostprocessing(Sale, PaymentLine, Context);
    end;

    local procedure PreparePaymentAndDetectPostprocessing(Sale: codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
    begin
        Response := PreparePayment(Sale, PaymentLine, Context);

        if HULAuditMgt.HasPaymentPostprocessingWorkflow(Sale) or HasExternalPostprocessingSubscribers() then
            Response.Add('needsPostprocessingWorkflows', true);
    end;

    local procedure HasExternalPostprocessingSubscribers(): Boolean
    var
        EventSubscription: Record "Event Subscription";
    begin
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Payment Processing Events");
        EventSubscription.SetRange("Published Function", 'OnAddPostWorkflowsToRun');
        EventSubscription.SetRange(Active, true);
        exit(not EventSubscription.IsEmpty());
    end;

    local procedure PreparePayment(Sale: codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        Payments: Codeunit "NPR POS Action: Payment WF2 BL";
        PaymentProcessingEvents: Codeunit "NPR Payment Processing Events";
        PaymentMethodCode: Code[10];
        WorkflowName: Code[20];
        PosPaymentMethod: Record "NPR POS Payment Method";
        RemainingAmount: Decimal;
        TextAmountPrompt: Text;
        TextAmountLabel: Label 'Enter Amount';
        ForceAmount: Boolean;
        CollectReturnInformation: Boolean;
        MembershipEmail: Text;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(Span, 'bc.pos.payment.prepare');
        SwitchToPaymentView(Context);
#pragma warning disable AA0139
        PaymentMethodCode := Context.GetStringParameter('paymentNo');
#pragma warning restore AA0139

        Sale.GetCurrentSale(SalePOS);

        Payments.PrepareForPayment(PaymentLine, PaymentMethodCode, WorkflowName, POSPaymentMethod, RemainingAmount, ForceAmount, CollectReturnInformation);

        Response.ReadFrom('{}');
        Response.Add('dispatchToWorkflow', WorkflowName);
        Response.Add('paymentType', POSPaymentMethod."Code");
        Response.Add('paymentDescription', POSPaymentMethod.Description);
        Response.Add('remainingAmount', RemainingAmount);
        TextAmountPrompt := TextAmountLabel;
        PaymentProcessingEvents.OnBeforeAddAmountPromptLblToResponse(POSPaymentMethod, TextAmountPrompt);
        Response.Add('amountPrompt', TextAmountPrompt);
        Response.Add('forceAmount', ForceAmount);
        Response.Add('mmPaymentMethodAssigned', Payments.CheckMMPaymentMethodAssigned(PaymentMethodCode, SalePOS));
        Response.Add('collectReturnInformation', CollectReturnInformation);
        Response.Add('EnableMemberSubscPayerEmail', Payments.CheckMembershipSubscription(SalePOS, POSPaymentMethod, MembershipEmail));
        Response.Add('membershipEmail', MembershipEmail);
        Span.Finish();
        exit(Response);
    end;

    local procedure AddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper") PreWorkflows: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        PmtProcessingEvents: Codeunit "NPR Payment Processing Events";
        POSSession: Codeunit "NPR POS Session";
    begin
        PreWorkflows.ReadFrom('{}');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        AddSaleDimensionWorkflow(SalePOS, PreWorkflows);
        PmtProcessingEvents.OnAddPreWorkflowsToRun(Context, SalePOS, PreWorkflows);
    end;

    local procedure CollectPostprocessingWorkflows(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line") Response: JsonObject
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
        PmtProcessingEvents: Codeunit "NPR Payment Processing Events";
        PostWorkflows: JsonObject;
    begin
        PostWorkflows.ReadFrom('{}');
        HULAuditMgt.AddPaymentPostprocessingWorkflow(Context, Sale, PaymentLine, PostWorkflows);
        PmtProcessingEvents.OnAddPostWorkflowsToRun(Context, Sale, PaymentLine, PostWorkflows);
        Response.Add('postWorkflows', PostWorkflows);
    end;

    local procedure SwitchToPaymentView(Context: Codeunit "NPR POS JSON Helper")
    var
        CurrentView: Codeunit "NPR POS View";
        POSSession: Codeunit "NPR POS Session";
        IsSwitchToPaymentView: Boolean;
    begin
        if not (Context.GetBooleanParameter('SwitchToPaymentView', IsSwitchToPaymentView) and IsSwitchToPaymentView) then
            exit;
        POSSession.GetCurrentView(CurrentView);
        if CurrentView.GetType() <> Enum::"NPR View Type"::Sale then
            exit;
        POSSession.ChangeViewPayment();
    end;

    procedure AddSaleDimensionWorkflow(SalePOS: Record "NPR POS Sale"; PreWorkflows: JsonObject)
    var
        Dimension: Record Dimension;
        POSPmtViewEventSetup: Record "NPR POS Paym. View Event Setup";
        POSPmtViewEventMgt: Codeunit "NPR POS Paym. View Event Mgt.";
        ActionParameters: JsonObject;
        PopupMode: Integer;
        HeadlineTextLbl: Label 'Please specify %1', Comment = '%1 - ML dimension code caption';
    begin
        if not POSPmtViewEventMgt.DimensionIsRequired(SalePOS, POSPmtViewEventSetup) then
            exit;

        Dimension.Get(POSPmtViewEventSetup."Dimension Code");
        PopupMode := POSPmtViewEventSetup."Popup Mode";
        if POSPmtViewEventSetup."Popup Mode" <> POSPmtViewEventSetup."Popup Mode"::List then
            PopupMode += 1;
        ActionParameters.Add('ValueSelection', PopupMode);
        ActionParameters.Add('ApplyTo', 0);
        ActionParameters.Add('StatisticsFrequency', 1);
        ActionParameters.Add('ShowConfirmMessage', false);
        ActionParameters.Add('DimensionSource', 2);
        ActionParameters.Add('DimensionCode', POSPmtViewEventSetup."Dimension Code");
        ActionParameters.Add('CreateDimValue', POSPmtViewEventSetup."Create New Dimension Values");
        ActionParameters.Add('HeadlineTxt', StrSubstNo(HeadlineTextLbl, Dimension.GetMLCodeCaption(GlobalLanguage())));
        ActionParameters.Add('DimensionMandatory', POSPmtViewEventSetup."Dimension Mandatory on POS");

        PreWorkflows.Add('SALE_DIMENSION', ActionParameters);
    end;


    [Obsolete('Use the new END_SALE workflow instead', '2023-11-28')]
    local procedure AttemptEndSale(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: Payment WF2 BL";
        PaymentMethodCode: Code[10];
        Success: Boolean;
    begin
#pragma warning disable AA0139
        PaymentMethodCode := Context.GetStringParameter('paymentNo');
#pragma warning restore AA0139

        Success := Payments.AttemptEndCurrentSale(PaymentMethodCode);

        Response.ReadFrom('{}');
        Response.Add('success', Success);
        exit(Response);
    end;

    local procedure DoLegacyPayment(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management") Response: JsonObject
    var
        POSAction: Record "NPR POS Action";
    begin
        POSAction.Get('PAYMENT');

        POSAction.SetWorkflowInvocationParameterUnsafe('paymentNo', Context.GetStringParameter('paymentNo'));
        POSAction.SetWorkflowInvocationParameterUnsafe('fallbackAmount', Context.GetString('fallbackAmount'));
        FrontEnd.InvokeWorkflow(POSAction);

        Response.ReadFrom('{}');
        exit(Response);
    end;

    local procedure SetMembershipSubscPayerEmail(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        PaymentUserAccount: Text;
        PayerEmailMustBeSpecifiedErr: Label 'You must specify a payer e-mail address for the membership subscription.';
    begin
        PaymentUserAccount := Context.GetString('membershipPayerEmail');
        if PaymentUserAccount = '' then
            Error(PayerEmailMustBeSpecifiedErr);

        MembershipMgtInternal.POSAssignMembershipPaymentUserAccount(Sale, PaymentUserAccount);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPaymentWF2.Codeunit.js###
'const main=async({workflow:e,popup:r,parameters:n,context:i,captions:m})=>{const{HideAmountDialog:u,HideZeroAmountDialog:c}=n;let s=await e.respond("preparePaymentWorkflow");if(s.preWorkflows){for(const[o,w]of Object.entries(s.preWorkflows))o&&await e.run(o,{parameters:w});s=await e.respond("continuePaymentWorkflow")}const{dispatchToWorkflow:p,paymentType:f,remainingAmount:a,paymentDescription:y,amountPrompt:d,forceAmount:P,mmPaymentMethodAssigned:A,collectReturnInformation:E,EnableMemberSubscPayerEmail:b,membershipEmail:W,needsPostprocessingWorkflows:g}=s;if(A&&!await r.confirm(m.paymentMethodAssignedCaption))return{};if(b){if(i.membershipPayerEmail=await r.input({title:m.MembershipSubscPayerEmailTitle,caption:m.MembershipSubscPayerEmailCaption,value:W}),i.membershipPayerEmail===null)return{};await e.respond("SetMembershipSubscPayerEmail")}let t=a;if(!u&&(!c||a>0)){if(t=await r.numpad({title:y,caption:d,value:a}),t===null)return{};if(t===0&&a>0)return{}}if(E&&a===t&&!(await e.run("DATA_COLLECTION",{parameters:{requestCollectInformation:"ReturnInformation"}})).success)return{};if(g){let{postWorkflows:o}=await e.respond("preparePostWorkflows",{paymentAmount:t});await processWorkflows(o)}if(t===0&&a===0&&!P)return await e.run("END_SALE",{parameters:{calledFromWorkflow:"PAYMENT_2",paymentNo:n.paymentNo}}),{};const l=await e.run(p,{context:{paymentType:f,suggestedAmount:t,remainingAmount:a}});return l.legacy?(i.fallbackAmount=t,await e.respond("doLegacyPaymentWorkflow")):l.tryEndSale&&n.tryEndSale&&await e.run("END_SALE",{parameters:{calledFromWorkflow:"PAYMENT_2",paymentNo:n.paymentNo}}),{success:l.success}};async function processWorkflows(e){if(e)for(const[r,{mainParameters:n,customParameters:i}]of Object.entries(e))await workflow.run(r,{context:{customParameters:i},parameters:n})}'
        );
    end;
}
