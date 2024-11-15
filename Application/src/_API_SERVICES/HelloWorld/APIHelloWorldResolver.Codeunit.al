#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185055 "NPR API Hello World Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        HelloWorld_v1: Codeunit "NPR API Hello World";
    begin
        // This is an example of how you could seperate multiple versions in different codeunits
        // depending on the incoming version header

        case true of
            // Request.ApiVersion() > 20241013D:
            //     exit(HelloWorld_v3);
            // Request.ApiVersion() > 20230101D: 
            //     exit(HelloWorld_v2);
            else
                exit(HelloWorld_v1);
        end;
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API HelloWorld');
    end;
}
#endif