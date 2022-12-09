codeunit 6184852 "NPR POS Notifications"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Page, Page::"NPR Activities", 'OnOpenPageEvent', '', false, false)]
    local procedure MissingNotifOnAfterGetCurrRecordEvent()
    begin
        SendOrRecallMissingNotificationPOSUnit();
        SendOrRecallCancelSaleMissingNotification();
        SendDeleteItemNotification();
        SendDeleteItemOnPOSNotification();
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

        MyNotifications.InsertDefaultWithTableNum(DeleteItemOnPOSNotificationIdLbl,
            DeleteItemOnPOSNotificationMsg,
            DeleteItemOnPOSNotificationDescriptionTxt,
            Database::"NPR POS Sale Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"My Notifications", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertNotificationSetDisable(var Rec: Record "My Notifications")
    begin
        if (Rec."Notification Id" = POSUnitNotificationIdLbl) or (Rec."Notification Id" = CancelSalesNotificationIdLbl) or
            (Rec."Notification Id" = DeleteItemNotificationIdLbl) or (Rec."Notification Id" = DeleteItemOnPOSNotificationIdLbl) then begin
            Rec.Enabled := false;
            Rec.Modify();
        end;
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

        InsertRecordLinkForDeletedItems(Rec);
    end;

    local procedure SendDeleteItemNotification()
    var
        MyNotification: Notification;
        OpenDeleteItemLbl: Label 'OpenDeletedItemPage', Locked = true;
    begin
        if not IsDeleteItemNotificationEnabled() then
            exit;

        if not DeletedItemsExist() then
            exit;

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
        TempItem2: Record Item temporary;
        RecID: RecordId;
        RecRef: RecordRef;
    begin
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetRange(Description, TempItem.TableName);
        if RecordLink.IsEmpty() then
            exit;

        if RecordLink.FindSet() then
            repeat
                RecID := RecordLink."Record ID";
                RecRef := RecID.GetRecord();
                RecRef.SetTable(TempItem);
                if not TempItem2.Get(TempItem."No.") then begin
                    TempItem2.Init();
                    TempItem2 := TempItem;
                    TempItem2.Insert();
                end;
            until RecordLink.Next() = 0;

        Page.Run(Page::"Item List", TempItem2);
    end;

    //add isEnabled function
    local procedure IsDeleteItemNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(DeleteItemNotificationIdLbl));
    end;

    local procedure InsertRecordLinkForDeletedItems(Item: Record Item)
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink."Link ID" := 0;
        RecordLink.Description := Item.TableName;
        RecordLink."Record ID" := Item.RecordID();
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Created := CurrentDateTime();
        RecordLink."User ID" := UserId();
        RecordLink.Company := CompanyName();
        RecordLink.Notify := true;
        RecordLink.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterDeletePOSSaleLine', '', false, false)]
    local procedure OnDeleteItemOnPOSSendNotification(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if SaleLinePOS.IsTemporary() then
            exit;

        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit;

        if not IsDeleteItemOnPOSNotificationEnabled() then
            exit;

        InsertRecordLinkForDeletedItemsOnPOS(SaleLinePOS);
    end;

    local procedure SendDeleteItemOnPOSNotification()
    var
        MyNotification: Notification;
        OpenDeleteItemOnPOSLbl: Label 'OpenDeletedItemPOSLinePage', Locked = true;
    begin
        if not IsDeleteItemOnPOSNotificationEnabled() then
            exit;

        if not DeletedItemsOnPOSExist() then
            exit;

        MyNotification.ID := DeleteItemonPOSNotificationIdLbl;
        MyNotification.Message := DeleteItemOnPOSNotificationMsg;
        MyNotification.Scope := NotificationScope::LocalScope;
        MyNotification.AddAction(OpenDeleteItemOnPOSTxt, Codeunit::"NPR POS Notifications", OpenDeleteItemOnPOSLbl);
        MyNotification.Send();
    end;

    procedure OpenDeletedItemPOSLinePage(MyNotification: Notification)
    var
        RecordLink: Record "Record Link";
        TempSalesPOSLine: Record "NPR POS Sale Line" temporary;
        TempSalesPOSLine2: Record "NPR POS Sale Line" temporary;
        RecID: RecordId;
        RecRef: RecordRef;
    begin
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetRange(Description, TempSalesPOSLine.TableName);
        if RecordLink.IsEmpty() then
            exit;

        if RecordLink.FindSet() then
            repeat
                RecID := RecordLink."Record ID";
                RecRef := RecID.GetRecord();
                RecRef.SetTable(TempSalesPOSLine);
                if not TempSalesPOSLine2.Get(TempSalesPOSLine."Register No.", TempSalesPOSLine."Sales Ticket No.",
                TempSalesPOSLine.Date, TempSalesPOSLine."Sale Type", TempSalesPOSLine."Line No.") then begin
                    TempSalesPOSLine2.Init();
                    TempSalesPOSLine2 := TempSalesPOSLine;
                    TempSalesPOSLine2.Insert();
                end;
            until RecordLink.Next() = 0;

        Page.Run(Page::"NPR POS Sale Lines List", TempSalesPOSLine2);
    end;

    //add isEnabled function
    local procedure IsDeleteItemOnPOSNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(DeleteItemOnPOSNotificationIdLbl));
    end;

    local procedure InsertRecordLinkForDeletedItemsOnPOS(SalesPOSLine: Record "NPR POS Sale Line")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink."Link ID" := 0;
        RecordLink.Description := SalesPOSLine.TableName;
        RecordLink."Record ID" := SalesPOSLine.RecordID();
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Created := CurrentDateTime();
        RecordLink."User ID" := UserId();
        RecordLink.Company := CompanyName();
        RecordLink.Notify := true;
        RecordLink.Insert();
    end;

    procedure DeletedItemsExist(): Boolean
    var
        RecordLink: Record "Record Link";
        Item: Record Item;
    begin
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetRange(Description, Item.TableName);
        exit(not RecordLink.IsEmpty());
    end;

    procedure DeletedItemsOnPOSExist(): Boolean
    var
        RecordLink: Record "Record Link";
        SalesPOSLine: Record "NPR POS Sale Line";
    begin
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetRange(Description, SalesPOSLine.TableName);
        exit(not RecordLink.IsEmpty());
    end;

    var
        POSUnitNotificationIdLbl: Label '407f8cda-a82f-46d2-967e-85bb9153aca2', Locked = true;
        POSUnitNotificationDescriptionTxt: Label 'Show warning when POS unit list is empty.';
        OpenPOSUnitTxt: Label 'Open POS unit list';
        OpenCancelSalesTxt: Label 'Open cancel sales list';
        POSUnitMissingNotificationMsg: Label 'NPR POS unit list is empty.';

        CancelSalesNotificationIdLbl: Label '4a420aab-74af-4c4b-987d-f3fd1db13c27', Locked = true;
        CancelSaleNotificationDescriptionTxt: Label 'Show warning when a POS sale is canceled.';
        CancelSaleNotificationMsg: Label 'NPR POS sales has been canceled.';
        DeleteItemNotificationIdLbl: Label 'd743ea97-8d4d-41c0-b725-2835c30a88f9', Locked = true;
        DeleteItemNotificationDescriptionTxt: Label 'Show warning when an item is deleted.';
        DeleteItemNotificationMsg: Label 'NPR item has been deleted from item list.';
        OpenDeleteItemTxt: Label 'Open the list of deleted items.';
        DeleteItemOnPOSNotificationIdLbl: Label '756c3fc5-adc8-4c79-8483-1b8c9fa37a08', Locked = true;
        DeleteItemOnPOSNotificationDescriptionTxt: Label 'Show warning when an item is deleted on POS line.';
        DeleteItemOnPOSNotificationMsg: Label 'NPR POS sale items have been deleted.';
        OpenDeleteItemOnPOSTxt: Label 'Open the list of deleted item POS lines.';
}