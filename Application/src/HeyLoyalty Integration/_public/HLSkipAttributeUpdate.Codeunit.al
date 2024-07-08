codeunit 6059998 "NPR HL Skip Attribute Update"
{
    Access = Public;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HL Attribute Mgt.", 'OnCheckIfIsCascadeUpdate', '', false, false)]
    local procedure SkipProcessing(var IsCascadeUpdate: Boolean)
    begin
        IsCascadeUpdate := true;
    end;
}