codeunit 6151575 "NPR AF Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"NPR AF Notification Hub", 'OnAfterInsertEvent', '', true, true)]
    local procedure T6151574OnAfterInsert(var Rec: Record "NPR AF Notification Hub"; RunTrigger: Boolean)
    var
        TempAFArgumentsNotificationHub: Record "NPR AF Arguments - Notific.Hub" temporary;
    begin
        if not RunTrigger then
            exit;

        TempAFArgumentsNotificationHub.Init();
        TempAFArgumentsNotificationHub."Action Type" := Rec."Action Type";
        TempAFArgumentsNotificationHub."Action Value" := Rec."Action Value";
        TempAFArgumentsNotificationHub."Created By" := Rec."Created By";
        TempAFArgumentsNotificationHub."From POS Unit No." := Rec."From POS Unit No.";
        TempAFArgumentsNotificationHub."To POS Unit No." := Rec."To POS Unit No.";
        TempAFArgumentsNotificationHub.Title := Rec.Title;

        if Rec.Body = '' then
            TempAFArgumentsNotificationHub.Body := Rec.Title
        else
            TempAFArgumentsNotificationHub.Body := Rec.Body;

        TempAFArgumentsNotificationHub."Notification Color" := Rec."Notification Color";
        TempAFArgumentsNotificationHub."Notification Key" := Rec.Id;
        TempAFArgumentsNotificationHub.Platform := Rec.Platform;
        TempAFArgumentsNotificationHub.Location := Rec.Location;

        Rec."Notification Delivered to Hub" := false;

        Rec."Request Data" := TempAFArgumentsNotificationHub."Request Data";
        Rec."Response Data" := TempAFArgumentsNotificationHub."Response Data";
        Rec.Modify(true);
    end;
}

