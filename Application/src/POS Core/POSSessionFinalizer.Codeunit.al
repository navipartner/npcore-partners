codeunit 6150745 "NPR POS Session Finalizer"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure OnRoleCenterOpen()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.ClearAll();
    end;
}

