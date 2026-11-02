codeunit 6150728 "NPR POS View Change WF Mgt."
{
    TableNo = "NPR POS Sales Workflow Step";

    trigger OnRun()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsInitialized() then
            Error(SessionNotInitializedErrorMessageLbl);
        OnAfterLogin(Rec, POSSession);
        Commit();
    end;

    var
        Text000: Label 'When POS View is changed to Payment';
        BlockPaymentWFDescriptionLbl: Label 'Block payment if Sale contains Items with insufficient Inventory';
        Text003: Label 'When POS View is changed from Login to Sale';
        SessionNotInitializedErrorMessageLbl: Label 'Session is not initialized.';

    // Discovery
    [Obsolete('Remove after POS Scenario is removed', '2025-09-14')]
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow", 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnPaymentViewCode(), Text000, CurrCodeunitId(), 'OnPaymentView');
        Sender.DiscoverPOSSalesWorkflow(OnAfterLoginCode(), Text003, CurrCodeunitId(), 'OnAfterLogin');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS View Change WF Mgt.");
    end;

    // OnPaymentView Workflow

    local procedure OnPaymentViewCode(): Code[20]
    begin
        exit('PAYMENT_VIEW');
    end;

    [Obsolete('Remove after POS Scenario is removed', '2025-09-14')]
    [IntegrationEvent(false, false)]
    local procedure OnPaymentView(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    begin
    end;


    // OnAfterLogin Workflow

    local procedure OnAfterLoginCode(): Code[20]
    begin
        exit('AFTER_LOGIN');
    end;

    [Obsolete('Use OnAfterLogin in cdu 6151544 "NPR POS Login Events"', '2023-10-28')]
    local procedure OnAfterLogin_OnRun(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    begin
        Commit();
        if not Codeunit.Run(Codeunit::"NPR POS View Change WF Mgt.", POSSalesWorkflowStep) then;
    end;

    [Obsolete('Use OnAfterLogin in cdu 6151544 "NPR POS Login Events"', '2023-10-28')]
    internal procedure InvokeOnAfterLoginWorkflow(var POSSession: Codeunit "NPR POS Session")
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnAfterLoginCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnAfterLoginCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnAfterLogin_OnRun(POSSalesWorkflowStep);
        until POSSalesWorkflowStep.Next() = 0;
    end;

    [Obsolete('Use OnAfterLogin in cdu 6151544 "NPR POS Login Events"', '2023-10-28')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterLogin(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    begin
    end;

    // Test Item Inventory
    [Obsolete('Remove after POS Scenario is removed', '2025-09-14')]
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'TestItemInventory':
                begin
                    Rec.Description := CopyStr(BlockPaymentWFDescriptionLbl, 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := 10;
                    Rec.Enabled := false;
                end;
        end;
    end;

}