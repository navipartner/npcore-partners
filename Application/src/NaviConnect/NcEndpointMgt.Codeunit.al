codeunit 6151519 "NPR Nc Endpoint Mgt."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created
    // NC2.13/MHA /20180613  CASE 318934 Added Init framework


    trigger OnRun()
    begin
    end;

    local procedure "--- Init"()
    begin
    end;

    procedure HasInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint"): Boolean
    var
        EndpointHasInit: Boolean;
    begin
        //-NC2.13 [318934]
        OnHasInitEndpoint(NcEndpoint, EndpointHasInit);
        exit(EndpointHasInit);
        //+NC2.13 [318934]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHasInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint"; var EndpointHasInit: Boolean)
    begin
        //-NC2.13 [318934]
        //+NC2.13 [318934]
    end;

    procedure InitEndpoint(NcEndpoint: Record "NPR Nc Endpoint")
    begin
        //-NC2.13 [318934]
        OnInitEndpoint(NcEndpoint);
        //+NC2.13 [318934]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint")
    begin
        //-NC2.13 [318934]
        //+NC2.13 [318934]
    end;

    local procedure "--- Run"()
    begin
    end;

    procedure RunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint"; var Response: Text) Success: Boolean
    var
        OutStream: OutStream;
    begin
        if TryRunEndpoint(NcTaskOutput, NcEndpoint) then begin
            Response := NcEndpoint."Setup Summary" + ': ' + NcTaskOutput.Name;
            exit(true);
        end;

        Response := GetLastErrorText;
        exit(false);
    end;

    [TryFunction]
    local procedure TryRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    begin
        OnRunEndpoint(NcTaskOutput, NcEndpoint);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    begin
    end;
}

