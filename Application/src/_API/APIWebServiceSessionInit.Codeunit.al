#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151009 "NPR API WS Session Init"
{
    Access = Internal;
    SingleInstance = true;

    var
        _SessionStartTime: DateTime;
        _Initialized: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpenCompleted', '', false, false)]
    local procedure OnCompanyOpenCompleted()
    begin
        if not (CurrentClientType() in [ClientType::Api, ClientType::OData, ClientType::ODataV4, ClientType::SOAP]) then
            exit;

        _SessionStartTime := CurrentDateTime();
        _Initialized := true;
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized);
    end;

    procedure GetSessionStartTime(): DateTime
    begin
        exit(_SessionStartTime);
    end;
}
#endif
