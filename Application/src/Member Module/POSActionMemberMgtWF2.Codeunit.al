codeunit 6014479 "NPR POS Action Member Mgt WF2"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used any more, please use MM_MEMBERMGMT_WF3 instead.';

    // Code removed in https://linear.app/navipartner/issue/ATTR-239/mm-membermgmt-wf2-removable


    local procedure ActionCode(): Code[20]
    begin
        exit('MM_MEMBERMGMT_WF2');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.99');
    end;

    [EventSubscriber(ObjectType::Table, CodeUnit::"NPR POS JSON Management", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    var
        ACTION_DESCRIPTION: Label 'This action handles member management functions for workflow 2.0.';
    begin

        if (Sender.DiscoverAction20(ActionCode(), ACTION_DESCRIPTION, ActionVersion())) then begin
            Sender.RegisterWorkflow20('await workflow.respond ("ShowObsoleteMessage");');
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        Handled := true;

        case (WorkflowStep) of
            'ShowObsoleteMessage':
                Message('This action is obsolete and has been removed, please use MM_MEMBERMGMT_WF3 instead.');
        end;

    end;

}

