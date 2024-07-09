codeunit 6060138 "NPR MM POS Action: MemberMgmt."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used any more, please use MM_MEMBERMGMT_WF3 instead.';

    // Code for WF1 deleted, retail events moved to 6060131 "NPR MM Member Retail Integr."
    // https://linear.app/navipartner/issue/ATTR-239/mm-membermgmt-wf2-cleanup

    var

        ActionDescription: Label 'This action handles member management functions.';
        UpdateMembershipMetadataLbl: Label 'Update Membership metadata on Sale Line Insert';

    local procedure ActionCode(): Code[20]
    begin
        exit('MM_MEMBERMGT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.99');
    end;

    [EventSubscriber(ObjectType::Table, Codeunit::"NPR POS JSON Management", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('9', 'respond ();');
            Sender.RegisterWorkflow(false);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if (not Action.IsThisAction(ActionCode())) then
            exit;

        Handled := true;
        Message('This action is obsolete, please use MM_MEMBERMGMT_WF3 instead.');

    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if (Rec."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        case Rec."Subscriber Function" of
            'UpdateMembershipOnSaleLineInsert':
                begin
                    Rec.Description := UpdateMembershipMetadataLbl;
                    Rec."Sequence No." := 30;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR MM POS Action: MemberMgmt.");
    end;
}
