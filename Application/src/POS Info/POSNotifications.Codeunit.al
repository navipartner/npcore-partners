codeunit 6184852 "NPR POS Notifications"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Page, Page::"NPR Activities", 'OnOpenPageEvent', '', false, false)]
    local procedure MissingNotifOnAfterGetCurrRecordEvent()
    begin
        SendOrRecallMissingNotificationPOSUnit();
        SendOrRecallCancelSaleMissingNotification();
        SendDeleteItemNotification();
    end;

    //add notification to my notifications
    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNum(POSUnitNotificationIdLbl,
            POSUnitMissingNotificationMsg,
            POSUnitNotificationDescriptionTxt,
            Database::"NPR POS Unit");

        MyNotifications.InsertDefaultWithTableNum(CancelSalesNotificationIdLbl,
            CancelSaleNotificationMsg,
            CancelSaleNotificationDescriptionTxt,
            Database::"NPR POS Entry");

        MyNotifications.InsertDefaultWithTableNum(DeleteItemNotificationIdLbl,
            DeleteItemNotificationMsg,
            DeleteItemNotificationDescriptionTxt,
            Database::Item);
    end;

    local procedure SendPOSUnitMissingNotification()
    var
        MyNotification: Notification;
        OpenPOSUnitLbl: Label 'OpenPOSUnitPage', Locked = true;
    begin
        MyNotification.ID := POSUnitNotificationIdLbl;
        MyNotification.Message := POSUnitMissingNotificationMsg;
        MyNotification.Scope := NotificationScope::LocalScope;
        MyNotification.AddAction(OpenPOSUnitTxt, Codeunit::"NPR POS Notifications", OpenPOSUnitLbl);
        MyNotification.Send();
    end;

    procedure OpenPOSUnitPage(MyNotification: Notification)
    begin
        Page.Run(Page::"NPR POS Unit List");
    end;

    local procedure SendOrRecallMissingNotificationPOSUnit()
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not IsPOSUnitNotificationEnabled() then
            exit;

        if POSUnit.IsEmpty() then
            SendPOSUnitMissingNotification()
        else
            RecallPOSUnitMissingNotification();
    end;

    local procedure RecallPOSUnitMissingNotification()
    var
        MyNotification: Notification;
    begin
        MyNotification.ID := POSUnitNotificationIdLbl;
        MyNotification.Recall();
    end;

    //add isEnabled function
    local procedure IsPOSUnitNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
        POSUnit: Record "NPR POS Unit";
    begin
        exit(MyNotifications.IsEnabledForRecord(POSUnitNotificationIdLbl, POSUnit));
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


    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteItemSendNotification(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;

        if not IsDeleteItemNotificationEnabled() then
            exit;

        InsertRecordLinkForDeletedItems(Rec."No.");
    end;

    local procedure SendDeleteItemNotification()
    var
        MyNotification: Notification;
        OpenDeleteItemLbl: Label 'OpenDeletedItemPage', Locked = true;
    begin
        MyNotification.ID := DeleteItemNotificationIdLbl;
        MyNotification.Message := DeleteItemNotificationMsg;
        MyNotification.Scope := NotificationScope::LocalScope;
        MyNotification.AddAction(OpenDeleteItemTxt, Codeunit::"NPR POS Notifications", OpenDeleteItemLbl);
        MyNotification.Send();
    end;

    procedure OpenDeletedItemPage(MyNotification: Notification)
    var
        RecordLink: Record "Record Link";
        TempItem: Record Item temporary;
    begin
        RecordLink.SetRange("Record ID", TempItem.RecordId);
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        if RecordLink.IsEmpty() then
            exit;

        if RecordLink.FindSet() then
            repeat
                if not TempItem.Get(CopyStr(RecordLink.Description, 1, MaxStrLen(TempItem."No."))) then begin
                    TempItem.Init();
                    TempItem."No." := RecordLink.Description;
                    TempItem.Insert();
                end;
            until RecordLink.Next() = 0;

        Page.Run(Page::"Item List", TempItem);
    end;

    //add isEnabled function
    local procedure IsDeleteItemNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(DeleteItemNotificationIdLbl));
    end;

    local procedure InsertRecordLinkForDeletedItems(ItemNo: Code[20])
    var
        RecordLink: Record "Record Link";
        Item: Record Item;
    begin
        RecordLink."Link ID" := 0;
        RecordLink.Description := ItemNo;
        RecordLink."Record ID" := Item.RecordID();
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Created := CurrentDateTime();
        RecordLink."User ID" := UserId();
        RecordLink.Company := CompanyName();
        RecordLink.Notify := true;
        RecordLink."To User ID" := UserId;
        RecordLink.Insert();
    end;

    var
        POSUnitNotificationIdLbl: Label '407f8cda-a82f-46d2-967e-85bb9153aca2', Locked = true;
        POSUnitNotificationDescriptionTxt: Label 'Show warning when POS unit list is empty.';
        OpenPOSUnitTxt: Label 'Open POS unit list';
        OpenCancelSalesTxt: Label 'Open cancel sales list';
        POSUnitMissingNotificationMsg: Label 'POS unit list is empty.';

        CancelSalesNotificationIdLbl: Label '4a420aab-74af-4c4b-987d-f3fd1db13c27', Locked = true;
        CancelSaleNotificationDescriptionTxt: Label 'Show warning when a sale is canceled.';
        CancelSaleNotificationMsg: Label 'There are canceled sales.';
        DeleteItemNotificationIdLbl: Label 'd743ea97-8d4d-41c0-b725-2835c30a88f9', Locked = true;
        DeleteItemNotificationDescriptionTxt: Label 'Show warning when an item is deleted.';
        DeleteItemNotificationMsg: Label 'The item has been deleted.';
        OpenDeleteItemTxt: Label 'Open the list of deleted items.';
}