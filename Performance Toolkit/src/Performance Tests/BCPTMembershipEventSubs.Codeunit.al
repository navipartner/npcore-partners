codeunit 88100 "NPR BCPT Membership Event Subs"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnBeforeMembInfoCaptureDialog', '', false, false)]
    local procedure HandleOnBeforeMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var ShowStandardUserInterface: Boolean)
    begin
        repeat
            if MemberInfoCapture."E-Mail Address" = '' then begin
                MemberInfoCapture."E-Mail Address" := GenerateRandomEmail();
                MemberInfoCapture.Modify();
            end;
        until MemberInfoCapture.Next() = 0;

        ShowStandardUserInterface := false;
    end;

    local procedure GenerateRandomEmail(): Text[80]
    begin
        exit(Format(CreateGuid()) + '@test.navipartner.com');
    end;
}