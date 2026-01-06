#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248682 "NPR API System Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        System_v1: Codeunit "NPR API System";
    begin
        case true of
            // Request.ApiVersion() > YYYYMMDD:
            //     exit(System_v2);
            else
                exit(System_v1);
        end;
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API System');
    end;
}
#endif