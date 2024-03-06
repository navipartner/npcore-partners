codeunit 6151535 "NPR SS POS Action: Member Arr." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action handles member arrival functions for Self Service.';
        ParamDialogPrompt_CptLbl: Label 'Dialog Prompt';
        ParamDialogPrompt_DescLbl: Label 'Specifies the type of Dialog Prompt';
        ParamDialogPrompt_OptLbl: Label 'Member Number,Member Card Number,Membership Number,Facial Recognition,No Prompt', Locked = true;
        ParamDialogPrompt_OptCptLbl: Label 'Member Number,Member Card Number,Membership Number,Facial Recognition,No Prompt';
        ParamPOSWorkflow_CptLbl: Label 'POS Workflow';
        ParamPOSWorkflow_DescLbl: Label 'Specifies the POS Workflow';
        ParamPOSWorkflow_OptLbl: Label 'POSSales,Automatic,With Guests', Locked = true;
        ParamPOSWorkflow_OptCptLbl: Label 'POSSales,Automatic,With Guests';
        ParamAdmissionCode_CptLbl: Label 'Admission Code';
        ParamAdmissionCode_DescLbl: Label 'Specifies the Admission Code';
        ParamDefaultInputValue_CptLbl: Label 'Default Input Value';
        ParamDefaultInputValue_DescLbl: Label 'Specifies the Default Input Value';
        ParamSuppressWelcomeMessage_CptLbl: Label 'Suppress Welcome Message';
        ParamSuppressWelcomeMessage_DescLbl: Label 'Specifies if welcome message will be shown';
        MemberCardPrompt: Label 'Enter Member Card Number';
        MembershipTitle: Label 'Member Arrival - Membership Management.';
        ParamPOSWorkflow_DefaultValue, ParamDialogPrompt_DefaultValue : Text[250];
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        ParamDialogPrompt_DefaultValue := CopyStr(SelectStr(2, ParamDialogPrompt_OptLbl), 1, 250);
        WorkflowConfig.AddOptionParameter('DialogPrompt',
                                        ParamDialogPrompt_OptLbl,
                                        ParamDialogPrompt_DefaultValue,
                                        ParamDialogPrompt_CptLbl,
                                        ParamDialogPrompt_DescLbl,
                                        ParamDialogPrompt_OptCptLbl);
        ParamPOSWorkflow_DefaultValue := CopyStr(SelectStr(1, ParamPOSWorkflow_OptLbl), 1, 250);
        WorkflowConfig.AddOptionParameter('POSWorkflow',
                                ParamPOSWorkflow_OptLbl,
                                ParamPOSWorkflow_DefaultValue,
                                ParamPOSWorkflow_CptLbl,
                                ParamPOSWorkflow_DescLbl,
                                ParamPOSWorkflow_OptCptLbl);
        WorkflowConfig.AddTextParameter('AdmissionCode', '', ParamAdmissionCode_CptLbl, ParamAdmissionCode_DescLbl);
        WorkflowConfig.AddTextParameter('DefaultInputValue', '', ParamDefaultInputValue_CptLbl, ParamDefaultInputValue_DescLbl);
        WorkflowConfig.AddBooleanParameter('SuppressWelcomeMessage', false, ParamSuppressWelcomeMessage_CptLbl, ParamSuppressWelcomeMessage_DescLbl);
        WorkflowConfig.AddLabel('MemberCardPrompt', MemberCardPrompt);
        WorkflowConfig.AddLabel('MembershipTitle', MembershipTitle);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'MemberArrival':
                SetMemberArrival(Context, Setup);
        end;
    end;

    local procedure SetMemberArrival(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup")
    var
        MemberCardNumber: Text[100];
        DialogPrompt: Integer;
        DialogMethodType: Option;
        POSWorkflowType: Option;
        AdmissionCode: Code[20];
        DefaultInputValue: Text;
        ShowWelcomeMessage: Boolean;
        POSActionSSMemberArrival: Codeunit "NPR POS Action SS: MemberArr.B";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        POSWorkflowMethod: Option POS,Automatic,GuestCheckIn;
    begin
        ShowWelcomeMessage := not (Context.GetBooleanParameter('SuppressWelcomeMessage'));
        DefaultInputValue := Context.GetStringParameter('DefaultInputValue');
        DialogPrompt := Context.GetIntegerParameter('DialogPrompt');

        if (DialogPrompt < 0) then
            DialogPrompt := 1;

        DialogMethodType := DialogMethod::CARD_SCAN;

        case DialogPrompt of
            0:
                MemberCardNumber := '';
            1:
                begin
                    DialogMethodType := DialogMethod::NO_PROMPT;
                    MemberCardNumber := CopyStr(Context.GetString('membercard_number'), 1, MaxStrLen(MemberCardNumber));
                end;
            2:
                MemberCardNumber := '';
            3:
                DialogMethodType := DialogMethod::FACIAL_RECOGNITION;
            4:
                if (DefaultInputValue <> '') then
                    DialogMethodType := DialogMethod::NO_PROMPT;
            else
                Error('POS Action: Dialog Prompt with ID %1 is not implemented.', DialogPrompt);
        end;

        POSWorkflowType := Context.GetIntegerParameter('POSWorkflow');
        if (POSWorkflowType < 0) then
            POSWorkflowType := POSWorkflowMethod::POS;

        AdmissionCode := CopyStr(Context.GetStringParameter('AdmissionCode'), 1, MaxStrLen(AdmissionCode));

        if ((MemberCardNumber = '') and (DialogMethodType <> DialogMethod::FACIAL_RECOGNITION)) then
            Error('Member Card Number is required for Member Arrival.');

        POSActionSSMemberArrival.SetMemberArrival(ShowWelcomeMessage, DefaultInputValue, DialogMethodType, POSWorkflowType, MemberCardNumber, AdmissionCode, Setup);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSSMemberArr.js###
'let main=async({workflow:l,popup:r,captions:t,parameters:e})=>{if(e.DefaultInputValue.length==0&&e.DialogPrompt==1){let a=await r.input({caption:t.MemberCardPrompt,title:t.MembershipTitle,value:e.DefaultInputValue});if(a===null)return" ";await l.respond("MemberArrival",{membercard_number:a})}else await l.respond("MemberArrival")};'
        );
    end;
}
