#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248681 "NPR API System" implements "NPR API Request Handler"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-23';
    ObsoleteReason = 'Unsused API as the only service GetNodeId() is handled directly via OData.';

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('GET', '/system/node'):
                Exit(GetNodeId());
        end;
    end;

    local procedure GetNodeId() Response: Codeunit "NPR API Response"
    var
        Json: Codeunit "NPR JSON Builder";
    begin
        exit(Response.RespondOK(Json.AddProperty('id', ServiceInstanceId())));
    end;
}
#endif