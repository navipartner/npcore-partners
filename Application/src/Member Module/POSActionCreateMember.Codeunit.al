codeunit 6014660 "NPR POS Action Create Member"
{
    Access = Internal;
    var
        ActionVersion: Label '2.0', Locked = true, MaxLength = 20;
        ActionCode: Label 'MM_CREATE_MEMBER', Locked = true, MaxLength = 20;
        ActionDescription: Label 'This action creates and assigns the membership to current sales.', MaxLength = 250;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    var
    begin
        if (Sender.DiscoverAction20(ActionCode, ActionDescription, ActionVersion)) then begin
            Sender.RegisterWorkflow20('await workflow.respond ("CreateMember");');

            PosActionConfiguration(Sender);

        end;
    end;

    local procedure PosActionConfiguration(var Sender: Record "NPR POS Action")
    begin
        Sender."Blocking UI" := true;
        Sender.RegisterTextParameter('MembershipSalesSetupItemNumber', '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if (not Action.IsThisAction(ActionCode)) then
            exit;

        Handled := true;

        case (WorkflowStep) of
            'CreateMember':
                begin
                    CreateMembershipWrapper(POSSession, Context)
                end;
            else
                exit;
        end;

    end;

    local procedure CreateMembershipWrapper(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management")
    var
        POSSale: Record "NPR POS Sale";
        PosSaleMgr: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(PosSaleMgr);
        PosSaleMgr.GetCurrentSale(POSSale);
        ;
        if (CreateMembershipAndAssignToSales(POSSale, CopyStr(Context.GetStringParameter('MembershipSalesSetupItemNumber'), 1, 20))) then begin
            PosSaleMgr.Refresh(POSSale);
            PosSaleMgr.Modify(false, false);
            POSSession.RequestRefreshData();
        end;
    end;

    procedure CreateMembershipAndAssignToSales(POSSale: Record "NPR POS Sale"; ItemNumber: Code[20]): Boolean
    begin
        exit(AssignToSales(POSSale, CreateMembership(ItemNumber)));
    end;

    local procedure CreateMembership(ItemNumber: Code[20]) MembershipEntryNo: Integer
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        SelectMembershipPage: Page "NPR MM Create Membership";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
    begin

        if (ItemNumber <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', ItemNumber);
        end;
        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);

        if (MembershipSalesSetup.Count() = 1) then begin
            MembershipSalesSetup.FindFirst();
        end else begin
            SelectMembershipPage.SetTableView(MembershipSalesSetup);
            SelectMembershipPage.LookupMode(true);
            PageAction := SelectMembershipPage.RunModal();
            if (not (PageAction = Action::LookupOK)) then
                exit(0);

            SelectMembershipPage.GetRecord(MembershipSalesSetup);
        end;

        MemberInfoCapture.Init();
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);

        Commit();
        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (not (PageAction = Action::LookupOK)) then
            exit(0);

        MemberInfoCapturePage.GetRecord(MemberInfoCapture);
        MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);
    end;

    local procedure AssignToSales(var POSSale: Record "NPR POS Sale"; MembershipEntryNo: Integer): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberMgmt: Codeunit "NPR MM POS Action: MemberMgmt.";
    begin
        if (MembershipEntryNo = 0) then
            exit;

        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MemberCard.FindFirst()) then
            exit(false);

        exit(POSActionMemberMgmt.AssignMembershipToPOSSale(POSSale, MembershipEntryNo, MemberCard."External Card No."));
    end;
}
