codeunit 6150796 "NPR POSAction: Delete POS Line"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit('DELETE_POS_LINE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This built in function deletes sales or payment line from the POS';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
                'let saleLines = runtime.getData("BUILTIN_SALELINE");' +
                'if ((!saleLines.length) || (saleLines._invalid)) {' +
                '    await popup.error($labels.notallowed);' +
                '    return;' +
                '};' +

                'if ($parameters.ConfirmDialog) {' +
                '    if (!await popup.confirm({ title: $labels.title, caption: $labels.Prompt.substitute(saleLines._current[10]) })) {' +
                '        return;' +
                '    };' +
                '};' +
                'workflow.respond();'
            );
            Sender.RegisterBooleanParameter('ConfirmDialog', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        DeletePosLine(POSSession);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        TitleLbl: Label 'Delete Line';
        PromptLbl: Label 'Are you sure you want to delete the line %1?';
        NotAllowedLbl: Label 'This line can''t be deleted.';
    begin
        Captions.AddActionCaption(ActionCode(), 'title', TitleLbl);
        Captions.AddActionCaption(ActionCode(), 'notallowed', NotAllowedLbl);
        Captions.AddActionCaption(ActionCode(), 'Prompt', PromptLbl);
    end;

    local procedure DeletePosLine(POSSession: Codeunit "NPR POS Session")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        CurrentView: Codeunit "NPR POS View";
    begin
        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.Type() = CurrentView.Type() ::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            OnBeforeDeleteSaleLinePOS(POSSaleLine);
            DeleteAccessories(POSSaleLine);
            POSSaleLine.DeleteLine();
        end;

        if (CurrentView.Type() = CurrentView.Type() ::Payment) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.RefreshCurrent();
            POSPaymentLine.DeleteLine();
        end;

        POSSession.GetSale(POSSale);
        POSSale.SetModified();
        POSSession.RequestRefreshData();
    end;

    local procedure DeleteAccessories(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;
        if SaleLinePOS."No." in ['', '*'] then
            exit;

        SaleLinePOS2.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOS2.SetFilter("Line No.", '<>%1', SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange("Main Line No.", SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange(Accessory, true);
        SaleLinePOS2.SetRange("Main Item No.", SaleLinePOS."No.");
        if SaleLinePOS2.IsEmpty then
            exit;

        SaleLinePOS2.SetSkipCalcDiscount(true);
        SaleLinePOS2.DeleteAll(false);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
    end;
}
