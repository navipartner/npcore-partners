codeunit 6060023 "NPR UPG My Notifications"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade My Notifications', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG My Notifications")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        DoUpgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG My Notifications"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure DoUpgrade()
    begin
        DeletePOSUnitNotification();
        DeleteDeletedItemNotification();
        DeleteDeletedItemOnPOSNotification();
        ModifyEndOfDayNotification();
    end;

    local procedure DeletePOSUnitNotification()
    var
        MyNotifications: Record "My Notifications";
        POSUnitNotificationIdLbl: Label '407f8cda-a82f-46d2-967e-85bb9153aca2', Locked = true;
    begin
        MyNotifications.SetRange("Notification Id", POSUnitNotificationIdLbl);
        if MyNotifications.IsEmpty then
            exit;

        MyNotifications.DeleteAll();
    end;

    local procedure DeleteDeletedItemNotification()
    var
        MyNotifications: Record "My Notifications";
        RecordLink: Record "Record Link";
        Item: Record Item;
        DeleteItemNotificationIdLbl: Label 'd743ea97-8d4d-41c0-b725-2835c30a88f9', Locked = true;
    begin
        MyNotifications.SetRange("Notification Id", DeleteItemNotificationIdLbl);
        if MyNotifications.IsEmpty then
            exit;

        MyNotifications.DeleteAll();

        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetRange(Description, Item.TableName);
        if RecordLink.IsEmpty() then
            exit;

        RecordLink.DeleteAll();
    end;

    local procedure DeleteDeletedItemOnPOSNotification()
    var
        MyNotifications: Record "My Notifications";
        RecordLink: Record "Record Link";
        SalesPOSLine: Record "NPR POS Sale Line";
        DeleteItemOnPOSNotificationIdLbl: Label '756c3fc5-adc8-4c79-8483-1b8c9fa37a08', Locked = true;
    begin
        MyNotifications.SetRange("Notification Id", DeleteItemOnPOSNotificationIdLbl);
        if MyNotifications.IsEmpty then
            exit;

        MyNotifications.DeleteAll();

        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetRange(Description, SalesPOSLine.TableName);
        if RecordLink.IsEmpty() then
            exit;

        RecordLink.DeleteAll();
    end;

    local procedure ModifyEndOfDayNotification()
    var
        MyNotifications: Record "My Notifications";
        OutStream: OutStream;
        NotificationIdLbl: Label 'cc0c0ffc-8edc-4158-920d-a2b66550aab6', Locked = true;
        NotificationDescriptionTxt: Label 'NPR Difference at the end of the day.';
        NewNotificationMsg: Label 'Display a warning if the difference between the provided filter and the actual end-of-day amount is higher or lower than expected.';
    begin
        MyNotifications.SetRange("Notification Id", NotificationIdLbl);
        if MyNotifications.IsEmpty then
            exit;

        if MyNotifications.FindSet(true, false) then
            repeat
                if MyNotifications.Name <> NotificationDescriptionTxt then begin
                    MyNotifications.Name := NotificationDescriptionTxt;
                    MyNotifications.Description.CreateOutStream(OutStream, TextEncoding::UTF8);
                    MyNotifications.Enabled := false;
                    OutStream.Write(NewNotificationMsg);
                    MyNotifications.Modify(false);
                end;
            until MyNotifications.Next() = 0;
    end;
}