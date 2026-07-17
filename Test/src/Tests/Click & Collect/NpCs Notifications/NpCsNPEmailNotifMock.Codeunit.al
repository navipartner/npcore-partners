codeunit 85203 "NPR NpCs NPEmail Notif Mock"
{
    EventSubscriberInstance = Manual;

    var
        _Fired: Boolean;
        _ResolvedTemplateId: Code[20];
        _CustomerEmail: Text[80];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Click & Collect", 'OnNotifyCustomerViaNPEmailOnBeforeSendEmail', '', false, false)]
    local procedure CaptureOnBeforeSendNPEmail(RecRef: RecordRef; CustomerEmail: Text[80]; NPEmailTemplate: Record "NPR NPEmailTemplate"; var CustomerNotified: Boolean)
    begin
        _Fired := true;
        _ResolvedTemplateId := NPEmailTemplate.TemplateId;
        _CustomerEmail := CustomerEmail;
        CustomerNotified := true;
    end;

    procedure Fired(): Boolean
    begin
        exit(_Fired);
    end;

    procedure ResolvedTemplateId(): Code[20]
    begin
        exit(_ResolvedTemplateId);
    end;

    procedure CapturedEmail(): Text[80]
    begin
        exit(_CustomerEmail);
    end;
}
