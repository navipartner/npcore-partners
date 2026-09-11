#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248745 "NPR ApiCompany" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        if (Request.Match('GET', '/company')) then
            exit(GetCompany());
    end;
    local procedure GetCompany() Response: Codeunit "NPR API Response"
    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Json: Codeunit "NPR Json Builder";
        CurrencyCode: Code[10];
        CountryISOCode: Code[2];
    begin
        GeneralLedgerSetup.SetLoadFields("LCY Code");
        GeneralLedgerSetup.Get();
        CompanyInformation.SetLoadFields(Name, "Country/Region Code");
        CompanyInformation.Get();
        
        CurrencyCode := GeneralLedgerSetup."LCY Code";
        CountryISOCode := GetCountryISOCode(CompanyInformation."Country/Region Code");

        Json.StartObject()
            .AddProperty('name', CompanyInformation.Name);

        if CurrencyCode <> '' then
            Json.AddProperty('currencyCode', CurrencyCode)
        else
            Json.AddProperty('currencyCode');

        if CountryISOCode <> '' then
            Json.AddProperty('countryCode', CountryISOCode)
        else
            Json.AddProperty('countryCode');

        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    local procedure GetCountryISOCode(CountryRegionCode: Code[10]): Code[2]
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegionCode = '' then
            exit('');
        CountryRegion.SetLoadFields("ISO Code");
        if not CountryRegion.Get(CountryRegionCode) then
            exit('');
        exit(CountryRegion."ISO Code");
    end;
}
#endif
