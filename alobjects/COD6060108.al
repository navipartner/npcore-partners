codeunit 6060108 "MM POS Action - BackEnd Func."
{
    // 
    // MM1.35/TSA /20181008 CASE 325198 Adding back-end member management functionality to front-end


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action provides access to backend manangement function for the member module.';

    local procedure ActionCode(): Text
    begin

        exit ('MM_MEMBER_BACKEND');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)

        then begin
          Sender.RegisterWorkflowStep ('', 'respond();');
          Sender.RegisterWorkflow (false);

          Sender.RegisterTextParameter ('MembershipSalesSetupItemNumber', '');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ItemNumber: Code[20];
    begin

        if (not Action.IsThisAction (ActionCode ())) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser (Context, FrontEnd);
        ItemNumber := JSON.GetStringParameter ('MembershipSalesSetupItemNumber', true);
        CreateMembership (ItemNumber);
    end;

    local procedure CreateMembership(MemberSalesSetupItemNumber: Code[20])
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        MembershipPage: Page "MM Membership Card";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        Membership: Record "MM Membership";
        ResponseMessage: Text;
    begin

        MembershipSalesSetup.Get (MembershipSalesSetup.Type::ITEM, MemberSalesSetupItemNumber);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Item No." := MemberSalesSetupItemNumber;
        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();

        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);

          case MembershipSalesSetup."Business Flow Type" of

            MembershipSalesSetup."Business Flow Type"::MEMBERSHIP :
              begin
                MembershipEntryNo := MembershipManagement.CreateMembershipAll (MembershipSalesSetup, MemberInfoCapture, true);
                Membership.Get (MembershipEntryNo);
                MembershipPage.SetRecord (Membership);
                Commit;
                MembershipPage.RunModal ();
              end;

            MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER :
              MembershipManagement.AddMemberAndCard (true, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);

            MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER :
              MembershipManagement.AddAnonymousMember (MemberInfoCapture, MemberInfoCapture.Quantity);

            MembershipSalesSetup."Business Flow Type"::REPLACE_CARD :
              begin
                MembershipManagement.BlockMemberCard (MembershipManagement.GetCardEntryNoFromExtCardNo (MemberInfoCapture."Replace External Card No."), true);
                MembershipManagement.IssueMemberCard (true, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
              end;

            MembershipSalesSetup."Business Flow Type"::ADD_CARD :
              MembershipManagement.IssueMemberCard (true, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
          end;

        end;
    end;
}

