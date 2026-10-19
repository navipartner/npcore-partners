codeunit 6248743 "NPR NP Passes Impl"
{
    Access = Internal;
    SingleInstance = true;

    var
        _Notifier: Interface "NPR INPPasses Notifier";
        _NotifierSet: Boolean;
        _Setup: Record "NPR NP Passes Setup";
        _SetupLoaded: Boolean;
        _SetupCompany: Text;

    internal procedure IsConfigured(): Boolean
    begin
        LoadSetup();
        exit(_Setup.Enabled and (_Setup."Base URL" <> ''));
    end;

    // Per session: the change subscribers check it on every modify. The secret itself is not cached.
    local procedure LoadSetup()
    begin
        if (_SetupLoaded and (_SetupCompany = CompanyName())) then
            exit;

        if (not _Setup.Get()) then
            Clear(_Setup);
        _SetupLoaded := true;
        _SetupCompany := CompanyName();
    end;

    local procedure ClearSetupCache()
    begin
        _SetupLoaded := false;
    end;

    internal procedure HasSigningSecret(): Boolean
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        if (not Setup.Get()) then
            exit(false);
        exit(Setup.HasSigningSecret());
    end;

    internal procedure NotifyPassUpdated(SerialNumber: Guid): Boolean
    begin
        if (not IsConfigured()) then
            exit(false);
        if (IsNullGuid(SerialNumber)) then
            exit(false);

        GetNotifier().NotifyPassUpdated(FormatSerialNumber(SerialNumber));
        exit(true);
    end;

    internal procedure SetNotifier(Notifier: Interface "NPR INPPasses Notifier")
    begin
        _Notifier := Notifier;
        _NotifierSet := true;
    end;

    internal procedure ClearNotifier()
    var
        WebHooks: Codeunit "NPR NP Passes WebHooks";
    begin
        _Notifier := WebHooks;
        _NotifierSet := false;
    end;

    local procedure GetNotifier(): Interface "NPR INPPasses Notifier"
    var
        WebHooks: Codeunit "NPR NP Passes WebHooks";
    begin
        if (_NotifierSet) then
            exit(_Notifier);
        exit(WebHooks);
    end;

    internal procedure FormatSerialNumber(Id: Guid): Text[36]
    begin
        exit(CopyStr(LowerCase(DelChr(Format(Id), '=', '{}-')), 1, 36));
    end;

    internal procedure BuildLandingLink(LayoutHandle: Text[40]; SerialNumber: Guid) Link: Text
    var
        Secret: SecretText;
    begin
        if (LayoutHandle = '') then
            exit('');
        if (IsNullGuid(SerialNumber)) then
            exit('');
        if (not IsConfigured()) then
            exit('');
        Secret := _Setup.GetSigningSecret();
        if (Secret.IsEmpty()) then
            exit('');

        Link := StrSubstNo('%1/l/%2/%3?signature=%4', _Setup."Base URL".TrimEnd('/'), LayoutHandle, FormatSerialNumber(SerialNumber),
            SignLink(LayoutHandle, FormatSerialNumber(SerialNumber), Secret));
    end;

    local procedure SignLink(LayoutHandle: Text[40]; SerialNumber: Text[36]; Secret: SecretText): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
    begin
        exit(CryptographyManagement.GenerateHash(LayoutHandle + '/' + SerialNumber, Secret, HashAlgorithmType::HMACSHA256).ToLower());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NP Passes Setup", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertSetup(var Rec: Record "NPR NP Passes Setup"; RunTrigger: Boolean)
    begin
        ClearSetupCache();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NP Passes Setup", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifySetup(var Rec: Record "NPR NP Passes Setup"; var xRec: Record "NPR NP Passes Setup"; RunTrigger: Boolean)
    begin
        ClearSetupCache();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NP Passes Setup", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteSetup(var Rec: Record "NPR NP Passes Setup"; RunTrigger: Boolean)
    begin
        ClearSetupCache();
    end;
}
