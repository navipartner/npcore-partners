codeunit 85041 "NPR French Archive Handler"
{
    EventSubscriberInstance = Manual;

    var
        _tempBlob: Codeunit "Temp Blob";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR FR Audit Mgt.", 'OnBeforeDownloadArchive', '', false, false)]
    local procedure OnBeforeDownloadArchive(TempBlob: Codeunit "Temp Blob"; var Handled: Boolean)
    begin
        Handled := true;
        _tempBlob := TempBlob;

    end;

    procedure GetBlob(var TempBlob: Codeunit "Temp Blob")
    begin
        TempBlob := _tempBlob;
    end;
}