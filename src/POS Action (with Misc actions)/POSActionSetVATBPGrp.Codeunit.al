codeunit 6150824 "NPR POSAction: Set VAT B.P.Grp"
{
    // NPR5.32.10/JC  /20170613 CASE 277093 New POS Action for Setting VAT Bus. Posting Group


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Set VAT Bus. Posting Group';

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
                SetVATBusPostingGroup(Context, POSSession, FrontEnd);
        end;
        Handled := true;
    end;

    local procedure SetVATBusPostingGroup(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        Line: Record "NPR Sale Line POS";
        SaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        VATBusPostingGroupValue: Code[10];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        VATBusPostingGroupValue := List(true, true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("VAT Bus. Posting Group", VATBusPostingGroupValue);
        SalePOS.Modify(true);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit('SETVATBPGRP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    procedure List(Lookup: Boolean; ShowEmpty: Boolean): Code[10]
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
            if VATBusinessPostingGroups.RunModal = ACTION::LookupOK then begin
                VATBusinessPostingGroups.GetRecord(VATBusinessPostingGroup);
                exit(VATBusinessPostingGroup.Code);
            end;
        end else
            VATBusinessPostingGroups.RunModal;
    end;
}

