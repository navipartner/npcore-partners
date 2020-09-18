page 6014523 "NPR Customer Mapping WP"
{
    Caption = 'Magento Customer Mapping';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Customer Mapping";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CountryRegion: Record "Country/Region";
                        CountryRegions: Page "Country/Regions Entity";
                    begin
                        CountryRegions.LookupMode := true;

                        if "Country/Region Code" <> '' then
                            if CountryRegion.Get("Country/Region Code") then
                                CountryRegions.SetRecord(CountryRegion);

                        if CountryRegions.RunModal() = Action::LookupOK then begin
                            CountryRegions.GetRecord(CountryRegion);
                            "Country/Region Code" := CountryRegion.Code;

                            "Post Code" := '';
                            CityName := '';

                            CountryRegionName := CountryRegion.Name;
                        end;
                    end;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        TempPostCode: Record "Post Code" temporary;
                        PostCodes: Page "Post Codes";
                    begin
                        PostCodes.LookupMode := true;

                        PostCode.SetRange("Country/Region Code", "Country/Region Code");
                        if PostCode.FindSet() then;

                        if "Post Code" <> '' then begin
                            PostCode.SetRange(Code, "Post Code");
                            PostCode.FindFirst();
                            PostCode.SetRange(Code);
                        end;

                        if Page.RunModal(Page::"Post Codes", PostCode) = Action::LookupOK then begin
                            "Post Code" := PostCode.Code;

                            CityName := PostCode.City;
                        end;
                    end;
                }
                field(CountryRegionName; CountryRegionName)
                {
                    ApplicationArea = All;
                    Caption = 'Country/Region';
                    Editable = false;
                }
                field(CityName; CityName)
                {
                    ApplicationArea = All;
                    Caption = 'City';
                    Editable = false;
                }
                field("Customer Template Code"; "Customer Template Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustomerTemplate: Record "Customer Template";
                        CustomerTemplates: Page "Customer Template List";
                    begin
                        CustomerTemplates.LookupMode := true;

                        if "Customer Template Code" <> '' then
                            if CustomerTemplate.Get("Customer Template Code") then
                                CustomerTemplates.SetRecord(CustomerTemplate);

                        if CustomerTemplates.RunModal() = Action::LookupOK then begin
                            CustomerTemplates.GetRecord(CustomerTemplate);
                            "Customer Template Code" := CustomerTemplate.Code;
                        end;
                    end;
                }
                field("Config. Template Code"; "Config. Template Code")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ConfigTemplateHdr: Record "Config. Template Header";
                        ConfigTemplates: Page "Config Templates";
                    begin
                        ConfigTemplates.LookupMode := true;

                        if "Config. Template Code" <> '' then
                            ConfigTemplateHdr.SetRange("Table ID", 18);
                        if ConfigTemplateHdr.FindSet() then;
                        ConfigTemplates.SetRecord(ConfigTemplateHdr);

                        if "Config. Template Code" <> '' then
                            if ConfigTemplateHdr.Get("Config. Template Code") then
                                ConfigTemplates.SetRecord(ConfigTemplateHdr);

                        if ConfigTemplates.RunModal() = Action::LookupOK then begin
                            ConfigTemplates.GetRecord(ConfigTemplateHdr);
                            "Config. Template Code" := ConfigTemplateHdr.Code;
                        end;
                    end;
                }
            }
        }
    }

    var
        CountryRegionName: Text;
        CityName: Text;

    procedure CreateMagentoCustomerMappingData()
    var
        MagentoCustomerMapping: Record "NPR Magento Customer Mapping";
    begin
        if Rec.FindSet() then
            repeat
                MagentoCustomerMapping := Rec;
                if not MagentoCustomerMapping.Insert() then
                    MagentoCustomerMapping.Modify();
            until Rec.Next() = 0;
    end;

    procedure MagentoCustomerMappingDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;
}