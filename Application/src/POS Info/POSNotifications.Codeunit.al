codeunit 6184852 "NPR POS Notifications"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Page, Page::"NPR Activities", 'OnOpenPageEvent', '', false, false)]
    local procedure MissingNotifOnAfterGetCurrRecordEvent()
    begin
        SendOrRecallCancelSaleMissingNotification();
    end;

    //add notification to my notifications
    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNum(CancelSalesNotificationIdLbl,
            CancelSaleNotificationMsg,
            CancelSaleNotificationDescriptionTxt,
            Database::"NPR POS Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"My Notifications", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertNotificationSetDisable(var Rec: Record "My Notifications")
    begin
        if Rec."Notification Id" = CancelSalesNotificationIdLbl then begin
            Rec.Enabled := false;
            Rec.Modify();
        end;
    end;

    local procedure SendOrRecallCancelSaleMissingNotification()
    begin
        if not IsCancelSaleNotificationEnabled() then
            exit;

        if SalesCanceled() then
            SendCancelSaleNotification()
        else
            RecallCancelSaleMissingNotification();
    end;

    local procedure RecallCancelSaleMissingNotification()
    var
        MyNotification: Notification;
    begin
        MyNotification.ID := CancelSalesNotificationIdLbl;
        MyNotification.Recall();
    end;

    local procedure SendCancelSaleNotification()
    var
        MyNotification: Notification;
        OpenCancelEntriesLbl: Label 'OpenCancelSalesPage', Locked = true;
    begin
        MyNotification.ID := CancelSalesNotificationIdLbl;
        MyNotification.Message := StrSubstNo(CancelSaleNotificationMsg);
        MyNotification.Scope := NotificationScope::LocalScope;
        MyNotification.AddAction(OpenCancelSalesTxt, Codeunit::"NPR POS Notifications", OpenCancelEntriesLbl);
        MyNotification.Send();
    end;

    procedure OpenCancelSalesPage(MyNotification: Notification)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Ascending(false);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        Page.Run(Page::"NPR POS Entries", POSEntry);
    end;

    //add isEnabled function
    local procedure IsCancelSaleNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(CancelSalesNotificationIdLbl));
    end;

    local procedure SalesCanceled(): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        exit(not POSEntry.IsEmpty());
    end;
    var
        OpenCancelSalesTxt: Label 'Open cancel sales list';
        CancelSalesNotificationIdLbl: Label '4a420aab-74af-4c4b-987d-f3fd1db13c27', Locked = true;
        CancelSaleNotificationDescriptionTxt: Label 'Show warning when a POS sale is canceled.';
        CancelSaleNotificationMsg: Label 'NPR POS sales has been canceled.';
}