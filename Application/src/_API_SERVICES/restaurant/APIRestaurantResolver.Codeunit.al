#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248642 "NPR API Restaurant Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        APIRestaurantHandler: Codeunit "NPR API Restaurant Handler";
    begin
        exit(APIRestaurantHandler);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Restaurant');
    end;
}

#endif
