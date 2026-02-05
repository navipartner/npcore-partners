codeunit 6151519 "NPR Nc Endpoint Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    procedure HasInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint"): Boolean
    var
        EndpointHasInit: Boolean;
    begin
        OnHasInitEndpoint(NcEndpoint, EndpointHasInit);
        exit(EndpointHasInit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHasInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint"; var EndpointHasInit: Boolean)
    begin
    end;

    procedure InitEndpoint(NcEndpoint: Record "NPR Nc Endpoint")
    begin
        OnInitEndpoint(NcEndpoint);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint")
    begin
    end;

    procedure RunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint"; var Response: Text) Success: Boolean
    begin
        if TryRunEndpoint(NcTaskOutput, NcEndpoint, Response) then begin
            Response := NcEndpoint."Setup Summary" + ': ' + NcTaskOutput.Name;
            exit(true);
        end;

        Response := GetLastErrorText;
        exit(false);
    end;

    [TryFunction]
    local procedure TryRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint"; var Response: Text)
    begin
        OnRunEndpoint(NcTaskOutput, NcEndpoint, Response);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint"; var Response: Text)
    begin
    end;
}

