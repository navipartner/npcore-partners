codeunit 6150788 "NPR POS Action: PrintExchLabel"
{
    var
        ReadingErr: Label 'reading in %1 of %2';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_EXCH_LABEL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This is a built-in action for printing exchange labels';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
                'await workflow.respond("AddPresetValuesToContext");' +
                'if (($parameters.Setting == $parameters.Setting["Package"]) || ($parameters.Setting == $parameters.Setting["Selection"])) {' +
                '   var result = await popup.calendarPlusLines({ title: $labels.title, caption: $labels.calendar, date: $context.defaultdate, dataSource: "BUILTIN_SALELINE" });' +
                '} else {' +
                '   var result = await popup.datepad({ title: $labels.title, caption: $labels.validfrom, required: true, value: $context.defaultdate });' +
                '};' +
                'if (result === null) { return };' +
                'workflow.respond("PrintExchangeLabels", { UserSelection: result });'
            );

            Sender.RegisterOptionParameter('Setting', 'Single,Line Quantity,All Lines,Selection,Package', 'Single');
            Sender.RegisterBooleanParameter('PreventNegativeQty', true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        CalendarCaptionLbl: Label 'Select a valid from date and the lines to include';
        TitleLbl: Label 'Print Exchange Label';
        ValidFromLbl: Label 'Valid From Date';
    begin
        Captions.AddActionCaption(ActionCode(), 'title', TitleLbl);
        Captions.AddActionCaption(ActionCode(), 'validfrom', ValidFromLbl);
        Captions.AddActionCaption(ActionCode(), 'calendar', CalendarCaptionLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        CASE WorkflowStep OF
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context, POSSession);
            'PrintExchangeLabels':
                PrintExchangeLabels(Context, POSSession);
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSetup: Codeunit "NPR POS Setup";
        DefaultValidFromDate: Date;
    begin
        POSSession.GetSetup(POSSetup);
        if not (Evaluate(DefaultValidFromDate, POSSetup.ExchangeLabelDefaultDate()) and (StrLen(POSSetup.ExchangeLabelDefaultDate()) > 0)) then
            DefaultValidFromDate := Today();

        Context.SetContext('defaultdate', Format(DefaultValidFromDate, 0, 9));
    end;

    local procedure PrintExchangeLabels(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        PrintLines: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        ExchangeLabelMgt: Codeunit "NPR Exchange Label Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        UserSelectionJToken: JsonToken;
        UserSelectionJObject: JsonObject;
        RowKeys: List of [Text];
        RowKey: Text;
        RowPosition: Text;
        ValidFromDate: Date;
        Setting: Option Single,"Line Quantity","All Lines",Selection,Package;
        PreventNegativeQty: Boolean;
        CannotbeNegErr: Label 'cannot be negative';
    begin
        PreventNegativeQty := Context.GetBooleanParameter('PreventNegativeQty');
        if PreventNegativeQty then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if SaleLinePOS.Quantity < 0 then
                SaleLinePOS.FieldError(Quantity, CannotbeNegErr);
        end;

        Context.SetScopeRoot();
        Setting := Context.GetIntegerParameterOrFail('Setting', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        UserSelectionJToken := Context.GetJTokenOrFail('UserSelection', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        case Setting of
            Setting::Single,
            Setting::"Line Quantity",
            Setting::"All Lines":
                begin
                    ValidFromDate := DT2Date(UserSelectionJToken.AsValue().AsDateTime());
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                    PrintLines := SaleLinePOS;
                    PrintLines.SetRecFilter();
                end;

            Setting::Selection,
            Setting::Package:
                begin
                    UserSelectionJObject := UserSelectionJToken.AsObject();
                    UserSelectionJObject.Get('date', UserSelectionJToken);
                    ValidFromDate := DT2Date(UserSelectionJToken.AsValue().AsDateTime());

                    UserSelectionJObject.Get('rows', UserSelectionJToken);
                    UserSelectionJObject := UserSelectionJToken.AsObject();
                    RowKeys := UserSelectionJObject.Keys();
                    foreach RowKey in RowKeys do
                        if RowKey <> 'count' then begin
                            UserSelectionJObject.Get(RowKey, UserSelectionJToken);
                            RowPosition := UserSelectionJToken.AsValue().AsText();
                            PrintLines.SetPosition(RowPosition);
                            PrintLines.Mark(true);
                        end;
                    PrintLines.MarkedOnly(true);
                end;
        end;

        ExchangeLabelMgt.PrintLabelsFromPOSWithoutPrompts(Setting, PrintLines, ValidFromDate);
    end;
}