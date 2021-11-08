codeunit 6060108 "NPR MM POS Action: BackEnd Fun"
{
    var
        ActionDescription: Label 'This action provides access to backend management function for the member module.';

    local procedure ActionCode(): Code[20]
    begin

        exit('MM_MEMBER_BACKEND');
    end;

    local procedure ActionVersion(): Text[30]
    begin

        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)

        then begin
            Sender.RegisterWorkflowStep('', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterTextParameter('MembershipSalesSetupItemNumber', '');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        POSActionMemberMgmt: Codeunit "NPR MM POS Action: MemberMgmt.";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSStore: Record "NPR POS Store";
        ItemNumber: Code[20];
        CardNumber: Text[100];
        AssignToSale: Label 'Assign created membership to sale?';
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ItemNumber := CopyStr(JSON.GetStringParameterOrFail('MembershipSalesSetupItemNumber', ActionCode()), 1, MaxStrLen(ItemNumber));

        POSSession.GetSetup(POSSetup);
        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        POSSetup.GetPOSStore(POSStore);

        CardNumber := CreateMembership(ItemNumber, SalespersonPurchaser.Code, POSStore.Code);

        if (CardNumber <> '') then
            if (Confirm(AssignToSale, true)) then
                POSActionMemberMgmt.SelectMembership(POSSession, 2, CardNumber); //2 == NoPrompt

    end;

    local procedure CreateMembership(MemberSalesSetupItemNumber: Code[20]; SalespersonCode: Code[20]; StoreCode: Code[20]) ExternalCardNumber: Text[100];
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipMgt: Codeunit "NPR MM Membership Mgt.";
    begin

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberSalesSetupItemNumber);

        MemberInfoCapture.Init();
#pragma warning disable AA0139
        MemberInfoCapture."Receipt No." := DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890'));
#pragma warning restore
        MemberInfoCapture."Line No." := 1;
        MemberInfoCapture."Item No." := MemberSalesSetupItemNumber;
        MemberInfoCapture."Document No." := SalespersonCode;
        MemberInfoCapture."Store Code" := StoreCode;
        MemberInfoCapture.Quantity := 1;
        MemberInfoCapture.Insert();

        ExternalCardNumber := MembershipMgt.CreateMembershipInteractive(MemberInfoCapture);

        if (MemberInfoCapture.Get(MemberInfoCapture."Entry No.")) then
            MemberInfoCapture.Delete();

        Commit();

        exit(ExternalCardNumber);
    end;
}


