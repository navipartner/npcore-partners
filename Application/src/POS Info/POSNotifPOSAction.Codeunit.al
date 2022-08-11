codeunit 6184854 "NPR POS Notif. POS Action"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Entry Cue", 'OnOpenPageEvent', '', false, false)]
    local procedure NewAppVersionNotificationOnOpenPageEvent()
    begin
        if IsPOSActionNotificationEnabled() then
            SendNotification();
    end;

    //add notification to my notifications
    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNum(NotificationIdLbl,
            NewNotificationMsg,
            NotificationDescriptionTxt,
            Database::"NPR POS Bin Entry");
    end;

    local procedure SendNotification()
    var
        MyNotifications: Record "My Notifications";
        POSBinEntry: Record "NPR POS Bin Entry";
        RecordRef: RecordRef;
        POSStores: Text;
        POSUnits: Text;
        Filters: Text;
    begin
        if not MyNotifications.Get(UserId(), NotificationIdLbl) then
            exit;

        Filters := GetFiltersAsText(MyNotifications);
        if Filters <> '' then begin
            GetFilteredRecord(MyNotifications, RecordRef, Filters);
            POSBinEntry.SetView(RecordRef.GetView());
        end;

        POSBinEntry.SetRange(Type, POSBinEntry.Type::DIFFERENCE);
        POSBinEntry.SetFilter("Created At", '%1..%2', CreateDateTime(WorkDate(), 0T), CreateDateTime(WorkDate(), 235959T));
        if POSBinEntry.IsEmpty() then
            exit;

        //find all stores and units with differences
        POSStores := '';
        POSUnits := '';
        if POSBinEntry.FindSet() then
            repeat
                AddCode(POSStores, POSBinEntry."POS Store Code", 0);
                AddCode(POSUnits, POSBinEntry."POS Unit No.", 1);
            until POSBinEntry.Next() = 0;

        SendNewNotification(POSStores, POSUnits);
    end;

    local procedure GetFiltersAsText(MyNotifications: Record "My Notifications") Filters: Text
    var
        FiltersInStream: InStream;
    begin
        MyNotifications.CalcFields("Apply to Table Filter");
        if not MyNotifications."Apply to Table Filter".HasValue then
            exit;
        MyNotifications."Apply to Table Filter".CreateInStream(FiltersInStream);
        FiltersInStream.Read(Filters);
    end;

    local procedure GetFilteredRecord(MyNotifications: Record "My Notifications"; var RecordRef: RecordRef; Filters: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FiltersOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(FiltersOutStream);
        FiltersOutStream.Write(Filters);

        RecordRef.Open(MyNotifications."Apply to Table Id");
        RequestPageParametersHelper.ConvertParametersToFilters(RecordRef, TempBlob);
    end;

    local procedure SendNewNotification(POSStores: Text; POSUnits: Text)
    var
        MyNotification: Notification;
        NewNotificationLbl: Label 'There are differences at the end of the day for POS stores: %1 and POS units: %2.', Comment = '%1 = POS store, %2 = POS units';
    begin
        POSStores := POSStores.Replace('|', ', ');
        POSUnits := POSUnits.Replace('|', ', ');
        MyNotification.ID := NotificationIdLbl;
        MyNotification.Message := StrSubstNo(NewNotificationLbl, POSStores, POSUnits);
        MyNotification.Scope := NotificationScope::LocalScope;
        MyNotification.Send();
    end;

    local procedure IsPOSActionNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(NotificationIdLbl));
    end;

    local procedure AddCode(var POSTxt: Text; POSCode: Code[10]; Type: Integer)
    begin
        if POSTxt = '' then
            POSTxt := POSCode
        else begin
            case Type of
                0:
                    begin
                        if not CheckPOSStoreExistsInString(POSTxt, POSCode) then
                            POSTxt += '|' + POSCode;
                    end;
                1:
                    begin
                        if not CheckPOSUnitExistsInString(POSTxt, POSCode) then
                            POSTxt += '|' + POSCode;
                    end;
            end;
        end;

    end;

    local procedure CheckPOSStoreExistsInString(POSStores: Text; POSStoreCode: Code[10]): Boolean
    var
        POSStore: Record "NPR POS Store";
        TempPOSStore: Record "NPR POS Store" temporary;
    begin
        POSStore.SetFilter(Code, POSStores);
        if POSStore.FindSet() then
            repeat
                TempPOSStore.Init();
                TempPOSStore.TransferFields(POSStore);
                TempPOSStore.Insert();
            until POSStore.Next() = 0;

        TempPOSStore.SetRange(Code, POSStoreCode);
        exit(not TempPOSStore.IsEmpty);
    end;

    local procedure CheckPOSUnitExistsInString(POSUnits: Text; POSUnitCode: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        TempPOSUnit: Record "NPR POS Unit" temporary;
    begin
        POSUnit.SetFilter("No.", POSUnits);
        if POSUnit.FindSet() then
            repeat
                TempPOSUnit.Init();
                TempPOSUnit.TransferFields(POSUnit);
                TempPOSUnit.Insert();
            until POSUnit.Next() = 0;

        TempPOSUnit.SetRange("No.", POSUnitCode);
        exit(not TempPOSUnit.IsEmpty);
    end;

    var
        NotificationIdLbl: Label 'cc0c0ffc-8edc-4158-920d-a2b66550aab6', Locked = true;
        NotificationDescriptionTxt: Label 'Difference at the end of the day.';
        NewNotificationMsg: Label 'Show warning if there is a difference at the end of the day';
}