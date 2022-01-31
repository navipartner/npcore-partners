page 6014523 "NPR Customer Mapping WP"
{
    Extensible = False;
    Caption = 'Magento Customer Mapping';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Customer Mapping";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CountryRegion: Record "Country/Region";
                        CountryRegions: Page "Countries/Regions";
                    begin
                        CountryRegions.LookupMode := true;

                        if Rec."Country/Region Code" <> '' then
                            if CountryRegion.Get(Rec."Country/Region Code") then
                                CountryRegions.SetRecord(CountryRegion);

                        if CountryRegions.RunModal() = Action::LookupOK then begin
                            CountryRegions.GetRecord(CountryRegion);
                            Rec."Country/Region Code" := CountryRegion.Code;

                            Rec."Post Code" := '';
                            CityName := '';

                            CountryRegionName := CountryRegion.Name;
                        end;
                    end;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodes: Page "Post Codes";
                    begin
                        PostCodes.LookupMode := true;

                        PostCode.SetRange("Country/Region Code", Rec."Country/Region Code");
                        if PostCode.FindSet() then;

                        if Rec."Post Code" <> '' then begin
                            PostCode.SetRange(Code, Rec."Post Code");
                            PostCode.FindFirst();
                            PostCode.SetRange(Code);
                        end;

                        if Page.RunModal(Page::"Post Codes", PostCode) = Action::LookupOK then begin
                            Rec."Post Code" := PostCode.Code;

                            CityName := PostCode.City;
                        end;
                    end;
                }
                field(CountryRegionName; CountryRegionName)
                {

                    Caption = 'Country/Region';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Country/Region field';
                    ApplicationArea = NPRRetail;
                }
                field(CityName; CityName)
                {

                    Caption = 'City';
                    Editable = false;
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Template Code field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustomerTemplate: Record "Customer Templ.";
                        CustomerTemplates: Page "Customer Templ. List";
                    begin
                        CustomerTemplates.LookupMode := true;

                        if Rec."Customer Template Code" <> '' then
                            if CustomerTemplate.Get(Rec."Customer Template Code") then
                                CustomerTemplates.SetRecord(CustomerTemplate);

                        if CustomerTemplates.RunModal() = Action::LookupOK then begin
                            CustomerTemplates.GetRecord(CustomerTemplate);
                            Rec."Customer Template Code" := CustomerTemplate.Code;
                        end;
                    end;
                }
                field("Config. Template Code"; Rec."Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Config. Template Code field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ConfigTemplateHdr: Record "Config. Template Header";
                        ConfigTemplates: Page "Config Templates";
                    begin
                        ConfigTemplates.LookupMode := true;

                        if Rec."Config. Template Code" <> '' then
                            ConfigTemplateHdr.SetRange("Table ID", 18);
                        if ConfigTemplateHdr.FindSet() then;
                        ConfigTemplates.SetRecord(ConfigTemplateHdr);

                        if Rec."Config. Template Code" <> '' then
                            if ConfigTemplateHdr.Get(Rec."Config. Template Code") then
                                ConfigTemplates.SetRecord(ConfigTemplateHdr);

                        if ConfigTemplates.RunModal() = Action::LookupOK then begin
                            ConfigTemplates.GetRecord(ConfigTemplateHdr);
                            Rec."Config. Template Code" := ConfigTemplateHdr.Code;
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
