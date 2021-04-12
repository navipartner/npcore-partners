codeunit 6150829 "NPR POS Action: POS Info"
{
    var
        ActionDescription: Label 'This built in function opens a page displaying the POS Information.';
        Title: Label 'Item Card';
        NotAllowed: Label 'Cannot open the Item Inventory Overview for this line.';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('POSINFO');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.6');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterTextParameter('POSInfoCode', '');
                RegisterOptionParameter('ApplicationScope', ' ,Current Line,All Lines,New Lines,Ask', 'All Lines');
                RegisterBooleanParameter('ClearPOSInfo', false);
                RegisterWorkflow(false);
                RegisterDataSourceBinding('BUILTIN_SALE');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        OpenPOSInfoPage(Context, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'notallowed', NotAllowed);
    end;

    local procedure OpenPOSInfoPage(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSInfoManagement: Codeunit "NPR POS Info Management";
        SalePOS: Record "NPR POS Sale";
        LinePOS: Record "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.Type = CurrentView.Type::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(LinePOS);
        end;

        if (CurrentView.Type = CurrentView.Type::Payment) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.GetCurrentPaymentLine(LinePOS);
        end;

        if (LinePOS."Sales Ticket No." = '') then begin
            // No lines in current view
            LinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            LinePOS."Register No." := SalePOS."Register No.";
            LinePOS.Date := SalePOS.Date;
            LinePOS.Type := LinePOS.Type::Item;
        end;

        POSInfoManagement.ProcessPOSInfoMenuFunction(
          LinePOS, JSON.GetStringOrFail('POSInfoCode', StrSubstNo(ReadingErr, ActionCode())), JSON.GetInteger('ApplicationScope'), JSON.GetBoolean('ClearPOSInfo'));
    end;
}
