codeunit 6150818 "NPR POSAction: Set TaxAreaCode"
{
    var
        ActionDescription: Label 'Set Tax Area Code';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('do_lookup', 'respond();');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
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
        SalePOS: Record "NPR POS Sale";
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

    local procedure ActionCode(): Code[20]
    begin
        exit('SETTAXAREACODE');
    end;

    local procedure ActionVersion(): Text[30]
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
            if TaxAreaList.RunModal() = ACTION::LookupOK then begin
                TaxAreaList.GetRecord(TaxArea);
                exit(TaxArea.Code);
            end;
        end else
            TaxAreaList.RunModal();
    end;
}

