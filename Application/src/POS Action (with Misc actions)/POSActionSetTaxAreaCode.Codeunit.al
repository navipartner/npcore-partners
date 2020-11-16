codeunit 6150818 "NPR POSAction: Set TaxAreaCode"
{
    // NPR5.32/JC  /20170522 CASE 277095 New POS Action for Setting Tax Area Code in trial mode


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Set Tax Area Code';

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
                RegisterWorkflowStep('do_lookup', 'respond();');
                RegisterWorkflow(false);
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

        case WorkflowStep of
            'do_lookup':
                SetTaxAreaCode(Context, POSSession, FrontEnd);
        end;
        Handled := true;
    end;

    local procedure SetTaxAreaCode(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        Line: Record "NPR Sale Line POS";
        SaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        TaxAreaValue: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        TaxAreaValue := List(true, true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Tax Area Code", TaxAreaValue);
        SalePOS.Modify(true);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit('SETTAXAREACODE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    procedure List(Lookup: Boolean; ShowEmpty: Boolean): Code[20]
    var
        TaxAreaList: Page "Tax Area List";
        TaxArea: Record "Tax Area";
    begin
        if not ShowEmpty then begin
            TaxArea.SetFilter(Description, '<>%1', '');
            TaxAreaList.SetTableView(TaxArea);
        end;

        if Lookup then begin
            TaxAreaList.LookupMode(true);
            if TaxAreaList.RunModal = ACTION::LookupOK then begin
                TaxAreaList.GetRecord(TaxArea);
                exit(TaxArea.Code);
            end;
        end else
            TaxAreaList.RunModal;
    end;
}

