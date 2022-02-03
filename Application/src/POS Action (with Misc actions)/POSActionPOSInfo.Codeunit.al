codeunit 6150829 "NPR POS Action: POS Info"
{
    Access = Internal;

    var
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('POSINFO');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This built in function opens assignes a POS info code to POS sale or POS sale line.', MaxLength = 250;
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
                'await workflow.respond("SelectPosInfo");' +
                'while ($context.AskForPosInfoText) {' +
                '  $context.UserInputString = await popup.input({title: $context.PopupTitle, caption: $context.FieldDescription, required: $context.InputMandatory});' +
                '  if (($context.InputMandatory) && (!$context.UserInputString)) { ' +
                '    let DoRetry = await popup.confirm({title: $context.FieldDescription, caption: $captions.ConfirmRetry});' +
                '    if (!DoRetry) {' +
                '      return;' +
                '    };' +
                '  } else {' +
                '    await workflow.respond("ValidateUserInput");' +
                '  };' +
                '};'
                );

            Sender.RegisterTextParameter('POSInfoCode', '');
            Sender.RegisterOptionParameter('ApplicationScope', ' ,Current Line,All Lines,New Lines,Ask', 'All Lines');
            Sender.RegisterBooleanParameter('ClearPOSInfo', false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALE');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        MustBeSpecifiedLbl: Label 'You cannot leave this field blank.';
        ConfirmRetryQst: Label 'Do you want to try again?';
        ConfirmRetryLbl: Label '%1 %2', Locked = true;
    begin
        Captions.AddActionCaption(ActionCode(), 'ConfirmRetry', StrSubstNo(ConfirmRetryLbl, MustBeSpecifiedLbl, ConfirmRetryQst));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        PosInfo: Record "NPR POS Info";
        UserInputString: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        PosInfo.Get(Context.GetStringParameterOrFail('POSInfoCode', StrSubstNo(ReadingErr, ActionCode())));

        case WorkflowStep of
            'SelectPosInfo':
                if AddInfoRequired(PosInfo, Context) then
                    exit;
            'ValidateUserInput':
                UserInputString := ValidateUserInput(PosInfo, Context);
        end;
        OpenPOSInfoPage(PosInfo, Context, POSSession, UserInputString);
    end;

    local procedure AddInfoRequired(PosInfo: Record "NPR POS Info"; Context: Codeunit "NPR POS JSON Management"): Boolean
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

    local procedure ValidateUserInput(PosInfo: Record "NPR POS Info"; Context: Codeunit "NPR POS JSON Management") UserInputString: Text
    begin
        Context.SetScopeRoot();
        UserInputString := Context.GetString('UserInputString');
        if UserInputString = '' then begin
            PosInfo.Get(Context.GetStringParameterOrFail('POSInfoCode', StrSubstNo(ReadingErr, ActionCode())));
            if PosInfo."Input Mandatory" then
                Error('');
        end;
        Context.SetContext('AskForPosInfoText', false);
    end;

    local procedure OpenPOSInfoPage(PosInfo: Record "NPR POS Info"; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; UserInputString: Text)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
        POSInfoManagement: Codeunit "NPR POS Info Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.Type() = CurrentView.Type() ::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        end;

        if (CurrentView.Type() = CurrentView.Type() ::Payment) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        end;

        if (SaleLinePOS."Sales Ticket No." = '') then begin
            // No lines in current view
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
        end;

        POSInfoManagement.ProcessPOSInfoMenuFunction(
            SaleLinePOS, PosInfo.Code, Context.GetIntegerParameter('ApplicationScope'), Context.GetBooleanParameter('ClearPOSInfo'), UserInputString);
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
}
