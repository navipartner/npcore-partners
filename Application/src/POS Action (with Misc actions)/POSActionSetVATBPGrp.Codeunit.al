codeunit 6150824 "NPR POSAction: Set VAT B.P.Grp"
{
    Access = Internal;
    var
        ActionDescription: Label 'Set VAT Bus. Posting Group';

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
                SetVATBusPostingGroup(Context, POSSession, FrontEnd);
        end;
        Handled := true;
    end;

    local procedure SetVATBusPostingGroup(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        VATBusPostingGroupValue: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        VATBusPostingGroupValue := List(true, true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("VAT Bus. Posting Group", VATBusPostingGroupValue);
        SalePOS.Modify(true);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('SETVATBPGRP');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    procedure List(Lookup: Boolean; ShowEmpty: Boolean): Code[20]
    var
        VATBusinessPostingGroups: Page "VAT Business Posting Groups";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if not ShowEmpty then begin
            VATBusinessPostingGroup.SetFilter(Description, '<>%1', '');
            VATBusinessPostingGroups.SetTableView(VATBusinessPostingGroup);
        end;

        if Lookup then begin
            VATBusinessPostingGroups.LookupMode(true);
            if VATBusinessPostingGroups.RunModal() = ACTION::LookupOK then begin
                VATBusinessPostingGroups.GetRecord(VATBusinessPostingGroup);
                exit(VATBusinessPostingGroup.Code);
            end;
        end else
            VATBusinessPostingGroups.RunModal();
    end;
}

