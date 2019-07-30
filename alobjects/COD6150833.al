codeunit 6150833 "POS Action - Notification List"
{
    // NPR5.38/CLVA/20170918 CASE 269792 Object Created
    // NPR5.38/MMV /20171114  CASE 296478 Moved text constant to in-line constant


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function opens the notification list page';
        Title: Label 'Notification List';

    local procedure ActionCode(): Text
    begin
        exit('NOTIFICATIONLIST');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflow(false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        OpenNotificationPage(Context, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
    end;

    local procedure OpenNotificationPage(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        ViewType: DotNet npNetViewType0;
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        NotificationList: Page "Notification List";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        NotificationList.SetRegister := SalePOS."Register No.";
        NotificationList.Run;
    end;
}

