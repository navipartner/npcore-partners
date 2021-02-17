codeunit 6151575 "NPR AF Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"NPR AF Notification Hub", 'OnAfterInsertEvent', '', true, true)]
    local procedure T6151574OnAfterInsert(var Rec: Record "NPR AF Notification Hub"; RunTrigger: Boolean)
    var
        AFArgumentsNotificationHub: Record "NPR AF Arguments - Notific.Hub" temporary;
        AFAPINotificationHub: Codeunit "NPR AF API - Notification Hub";
    begin
        if not RunTrigger then
            exit;

        AFArgumentsNotificationHub.Init;
        AFArgumentsNotificationHub."Action Type" := Rec."Action Type";
        AFArgumentsNotificationHub."Action Value" := Rec."Action Value";
        AFArgumentsNotificationHub."Created By" := Rec."Created By";
        AFArgumentsNotificationHub."From POS Unit No." := Rec."From POS Unit No.";
        AFArgumentsNotificationHub."To POS Unit No." := Rec."To POS Unit No.";
        AFArgumentsNotificationHub.Title := Rec.Title;

        if Rec.Body = '' then
            AFArgumentsNotificationHub.Body := Rec.Title
        else
            AFArgumentsNotificationHub.Body := Rec.Body;

        AFArgumentsNotificationHub."Notification Color" := Rec."Notification Color";
        AFArgumentsNotificationHub."Notification Key" := Rec.Id;
        AFArgumentsNotificationHub.Platform := Rec.Platform;
        AFArgumentsNotificationHub.Location := Rec.Location;

        Rec."Notification Delivered to Hub" := false;

        Rec."Request Data" := AFArgumentsNotificationHub."Request Data";
        Rec."Response Data" := AFArgumentsNotificationHub."Response Data";
        Rec.Modify(true);
    end;
}

