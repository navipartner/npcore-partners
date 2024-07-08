codeunit 6150829 "NPR POS Action: POS Info" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::POSINFO));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This built in function assigns a POS info code to POS sale or POS sale line.';
        ParamPOSInfoCode_CptLBl: Label 'POS Info Code';
        ParamPOSInfoCode_DescLbl: Label 'Code of POS info record.';
        ParamApplicationScope_OptionLbl: Label ' ,Current Line,All Lines,New Lines,Ask', locked = true;
        ParamApplicationScope_CptLbl: Label 'Application Scope';
        ParamApplicationScope_DescLbl: Label 'Choose application scope.';
        ParamApplicationScope_OptionCptLbl: Label ' ,Current Line,All Lines,New Lines,Ask';
        ParamClearPOSInfo_CptLbl: Label 'Clear POS Info';
        ParamClearPOSInfo_DescLbl: Label 'Clears POS info from';
        MustBeSpecifiedLbl: Label 'You cannot leave this field blank.';
        ConfirmRetryQst: Label 'Do you want to try again?';
        ConfirmRetryLbl: Label '%1 %2', Locked = true;
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('POSInfoCode', '', ParamPOSInfoCode_CptLBl, ParamPOSInfoCode_DescLbl);
        WorkflowConfig.AddOptionParameter('ApplicationScope',
                                        ParamApplicationScope_OptionLbl,
#pragma warning disable AA0139
                                        SelectStr(3, ParamApplicationScope_OptionLbl),
#pragma warning restore 
                                        ParamApplicationScope_CptLbl,
                                        ParamApplicationScope_DescLbl,
                                        ParamApplicationScope_OptionCptLbl);
        WorkflowConfig.AddBooleanParameter('ClearPOSInfo', false, ParamClearPOSInfo_CptLbl, ParamClearPOSInfo_DescLbl);
        WorkflowConfig.AddLabel('ConfirmRetry', StrSubstNo(ConfirmRetryLbl, MustBeSpecifiedLbl, ConfirmRetryQst));
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSale());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSInfo: Record "NPR POS Info";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
        POSsession: Codeunit "NPR POS Session";
        BusinessLogicRun: Codeunit "NPR POS Action: POS Info-B";
        ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask";
        UserInputString: Text;
        ClearPOSInfo: Boolean;
        WrongViewErr: Label 'The POS action can only be run in POS Sale or Payment view.';
    begin
        POSInfo.Get(Context.GetStringParameter('POSInfoCode'));

        case Step of
            'SelectPosInfo':
                begin
                    POSSession.GetCurrentView(CurrentView);
                    if not (CurrentView.GetType() in [CurrentView.GetType() ::Sale, CurrentView.GetType() ::Payment]) then
                        Error(WrongViewErr);
                    if AddInfoRequired(PosInfo, Context) then
                        exit;
                end;
            'ValidateUserInput':
                UserInputString := ValidateUserInput(POSInfo, Context);
        end;

        ApplicationScope := Context.GetIntegerParameter('ApplicationScope');
        ClearPOSInfo := Context.GetBooleanParameter('ClearPOSInfo');

        Sale.GetCurrentSale(SalePOS);

        POSSession.GetCurrentView(CurrentView);
        case CurrentView.GetType() of
            CurrentView.GetType() ::Sale:
                SaleLine.GetCurrentSaleLine(SaleLinePOS);
            CurrentView.GetType() ::Payment:
                PaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        end;

        if BusinessLogicRun.OpenPOSInfoPage(SalePOS, SaleLinePOS, POSInfo, UserInputString, ApplicationScope, ClearPOSInfo) then
            POSsession.RequestFullRefresh();
    end;

    local procedure AddInfoRequired(PosInfo: Record "NPR POS Info"; Context: Codeunit "NPR POS JSON Helper"): Boolean
    var
        POSInfoManagement: Codeunit "NPR POS Info Management";
        IsRequired: Boolean;
    begin
        IsRequired := POSInfoManagement.PosInfoInputTextRequired(PosInfo);
        Context.SetContext('AskForPosInfoText', IsRequired);
        if IsRequired then begin
            Context.SetContext('PopupTitle', PosInfo.Message);
            Context.SetContext('FieldDescription', PosInfo.Description);
            Context.SetContext('InputMandatory', PosInfo."Input Mandatory");
        end;
        exit(IsRequired);
    end;

    local procedure ValidateUserInput(PosInfo: Record "NPR POS Info"; Context: Codeunit "NPR POS JSON Helper") UserInputString: Text
    begin
        Context.SetScopeRoot();
        UserInputString := Context.GetString('UserInputString');
        if UserInputString = '' then
            if PosInfo."Input Mandatory" then
                Error('');
        Context.SetContext('AskForPosInfoText', false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
    var
        PosInfo: Record "NPR POS Info";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'POSInfoCode':
                begin
                    if POSParameterValue.Value <> '' then begin
                        PosInfo.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(PosInfo.Code));
                        if PosInfo.find('=><') then;
                    end;
                    if Page.RunModal(0, PosInfo) = Action::LookupOK then
                        POSParameterValue.Value := PosInfo.Code;
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPOSInfo.js###
'let main=async({workflow:e,context:i,popup:r,parameters:t,captions:a})=>{for(await e.respond("SelectPosInfo");i.AskForPosInfoText;)if(i.UserInputString=await r.input({title:i.PopupTitle,caption:i.FieldDescription,required:i.InputMandatory}),i.InputMandatory&&!i.UserInputString){if(!await r.confirm({title:i.FieldDescription,caption:a.ConfirmRetry}))return}else await e.respond("ValidateUserInput")};'
);
    end;
}
