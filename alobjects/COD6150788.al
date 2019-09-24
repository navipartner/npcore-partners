codeunit 6150788 "POS Action - Print Exch Label"
{
    // NPR5.34/TSA /20170710 CASE 282999 Added function RegisterDataBinding(); to workflow
    // NPR5.36/MMV /20170913 CASE 289442 Format date for XML
    // NPR5.43/MMV /20180620 CASE 305061 Added use of new calendar dialog
    // NPR5.45/JC  /20180820 CASE 323894 Validate if qty is negative to proceed or not
    // NPR5.51/MMV /20190821 CASE 365704 Rewrote datetime parsing to workaround BC14 EVALUATE difference.


    var
        ActionDescription: Label 'This is a built-in action for printing exchange labels.';
        Title: Label 'Print Exchange Label';
        ValidFrom: Label 'Valid From Date';
        CalendarCaption: Label 'Select a valid from date and the lines to include';
        ErrorTxtQtyCannotbeNeg: Label 'Error! Quantity cannot be negative!';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_EXCH_LABEL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.5');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Button,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'if ((param.Setting != param.Setting["Package"]) && (param.Setting != param.Setting["Selection"]))' +
                                             '{ datepad({ title: labels.title, caption: labels.validfrom, value: context.defaultdate, notBlank: true}, "value").respond(); };');
                RegisterWorkflowStep('2', 'if ((param.Setting == param.Setting["Package"]) || (param.Setting == param.Setting["Selection"]))' +
                                             '{ calendar({caption: labels.calendar, title: labels.title, checkedByDefault: true, date: context.defaultdate, columns: [10, 12, 15] }).respond(); };');
                RegisterWorkflow(true);

                RegisterOptionParameter('Setting', 'Single,Line Quantity,All Lines,Selection,Package', 'Single');
                RegisterBooleanParameter('PreventNegativeQty', true);
                RegisterDataBinding();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        POSSetup: Codeunit "POS Setup";
        DefaultDate: Date;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        POSSession.GetSetup(POSSetup);
        if not (Evaluate(DefaultDate, POSSetup.ExchangeLabelDefaultDate) and (StrLen(POSSetup.ExchangeLabelDefaultDate) > 0)) then
            DefaultDate := Today;

        Context.SetContext('defaultdate', Format(DefaultDate, 0, 9));
        FrontEnd.SetActionContext(ActionCode, Context);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'validfrom', ValidFrom);
        Captions.AddActionCaption(ActionCode, 'calendar', CalendarCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Setting: Integer;
        JSON: Codeunit "POS JSON Management";
        Date: Date;
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        ExchangeLabelMgt: Codeunit "Exchange Label Management";
        PrintLines: Record "Sale Line POS";
        CalendarObject: JsonObject;
        "Count": Integer;
        i: Integer;
        Position: Text;
        PreventNegativeQty: Boolean;
        DateTime: DateTime;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        PreventNegativeQty := JSON.GetBooleanParameter('PreventNegativeQty', false);
        if PreventNegativeQty then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if SaleLinePOS.Quantity < 0 then
                Error(ErrorTxtQtyCannotbeNeg);
        end;


        Setting := JSON.GetIntegerParameter('Setting', true);

        case Setting of
            0, 1, 2:
                begin
                    Date := JSON.GetDate('value', true);
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                    PrintLines := SaleLinePOS;
                    PrintLines.SetRecFilter;
                end;
            3, 4:
                begin
                    JSON.GetJsonObject('value', CalendarObject, true);

                    // TODO: CTRLUPGRADE refactor this to use JsonObject that CalendarObject now is
                    Error('CTRLUPRADE');
                    /*
                    Evaluate(Count, CalendarObject.Item('Rows').Item('count').ToString);
                    if Count < 1 then
                        exit;
        //-NPR5.51 [365704]
        //      EVALUATE(Date, CalendarObject.Item('Date').ToString);
              JSON.SetScope('value', true);
              Date := JSON.GetDate('Date', true);
        //+NPR5.51 [365704]

                    for i := 1 to Count do begin
                        Position := CalendarObject.Item('Rows').Item(Format(i - 1)).ToString;
                        PrintLines.SetPosition(Position);
                        PrintLines.Mark(true);
                    end;
                    */
                    PrintLines.MarkedOnly(true);
                end;
        end;

        ExchangeLabelMgt.PrintLabelsFromPOSWithoutPrompts(Setting, PrintLines, Date);
    end;
}

