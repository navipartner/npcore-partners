#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248641 "NPR API Restaurant"
{
    Access = Internal;

    procedure GetRestaurants(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Json: Codeunit "NPR JSON Builder";
        LogoHandler: Codeunit "NPR NPRERestaurantLogoHandler";
        LogoUrl: Text;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        Restaurant.ReadIsolation := IsolationLevel::ReadCommitted;

        Json.StartArray();
        if Restaurant.FindSet() then
            repeat
                Json.StartObject('')
                    .AddProperty('id', Format(Restaurant.SystemId, 0, 4).ToLower())
                    .AddProperty('code', Restaurant.Code)
                    .AddProperty('name', Restaurant.Name)
                    .AddProperty('description', Restaurant."Name 2")
                    .AddProperty('primaryColor', Restaurant."Menu Primary Color")
                    .AddProperty('secondaryColor', Restaurant."Menu Secondary Color");

                if LogoHandler.GetLogoUrl(Restaurant.SystemId, Enum::"NPR CloudflareMediaVariants"::MEDIUM, 57600, LogoUrl) then
                    Json.AddProperty('logoUrl', LogoUrl);

                Json.EndObject();
            until Restaurant.Next() = 0;
        Json.EndArray();

        exit(Response.RespondOK(Json.BuildAsArray()));
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR NPRE Restaurant");
    end;
}

#endif
