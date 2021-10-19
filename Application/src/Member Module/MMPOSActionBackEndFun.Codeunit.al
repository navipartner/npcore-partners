codeunit 6060108 "NPR MM POS Action: BackEnd Fun"
{
    // 

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action provides access to backend manangement function for the member module.';

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
        JSON: Codeunit "NPR POS JSON Management";
        ItemNumber: Code[20];
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ItemNumber := CopyStr(JSON.GetStringParameterOrFail('MembershipSalesSetupItemNumber', ActionCode()), 1, MaxStrLen(ItemNumber));
        CreateMembership(ItemNumber);
    end;

    local procedure CreateMembership(MemberSalesSetupItemNumber: Code[20])
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        MembershipPage: Page "NPR MM Membership Card";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
        Membership: Record "NPR MM Membership";
        ResponseMessage: Text;
    begin

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberSalesSetupItemNumber);

        MemberInfoCapture.Init();
        MemberInfoCapture."Item No." := MemberSalesSetupItemNumber;
        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();

        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);

            case MembershipSalesSetup."Business Flow Type" of

                MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                    begin
                        MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);
                        Membership.Get(MembershipEntryNo);
                        MembershipPage.SetRecord(Membership);
                        Commit();
                        MembershipPage.RunModal();
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER:
                    MembershipManagement.AddMemberAndCard(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);

                MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                    MembershipManagement.AddAnonymousMember(MemberInfoCapture, MemberInfoCapture.Quantity);

                MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                    begin
                        MembershipManagement.BlockMemberCard(MembershipManagement.GetCardEntryNoFromExtCardNo(MemberInfoCapture."Replace External Card No."), true);
                        MembershipManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_CARD:
                    MembershipManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
            end;

        end;
    end;
}

