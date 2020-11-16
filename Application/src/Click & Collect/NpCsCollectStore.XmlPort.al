xmlport 6151197 "NPR NpCs Collect Store"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Store';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/collect_store';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(stores)
        {
            MaxOccurs = Once;
            tableelement(tempnpcsstore; "NPR NpCs Store")
            {
                MinOccurs = Zero;
                XmlName = 'store';
                UseTemporary = true;
                fieldattribute(store_code; TempNpCsStore.Code)
                {
                }
                fieldelement(location_code; TempNpCsStore."Location Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_name; TempNpCsStore."Contact Name")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_name_2; TempNpCsStore."Contact Name 2")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_address; TempNpCsStore."Contact Address")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_address_2; TempNpCsStore."Contact Address 2")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_post_code; TempNpCsStore."Contact Post Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_city; TempNpCsStore."Contact City")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_country_code; TempNpCsStore."Contact Country/Region Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_county; TempNpCsStore."Contact County")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_phone_no; TempNpCsStore."Contact Phone No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(contact_email; TempNpCsStore."Contact E-mail")
                {
                    MinOccurs = Zero;
                }

                trigger OnAfterGetRecord()
                begin
                    SetContactInfo();
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    local procedure SetContactInfo()
    begin
        if SetContactInfoPosStore() then
            exit;

        if SetContactInfoLocation() then
            exit;

        SetContactInfoCompanyInfo();
    end;

    local procedure SetContactInfoPosStore(): Boolean
    var
        POSStore: Record "NPR POS Store";
    begin
        if TempNpCsStore."Location Code" = '' then
            exit(false);

        POSStore.SetRange("Location Code", TempNpCsStore."Location Code");
        POSStore.SetFilter(Name, '<>%1', '');
        if not POSStore.FindFirst then
            exit(false);

        TempNpCsStore."Contact Name" := POSStore.Name;
        TempNpCsStore."Contact Name 2" := POSStore."Name 2";
        TempNpCsStore."Contact Address" := POSStore.Address;
        TempNpCsStore."Contact Address 2" := POSStore."Address 2";
        TempNpCsStore."Contact Post Code" := POSStore."Post Code";
        TempNpCsStore."Contact City" := POSStore.City;
        TempNpCsStore."Contact Country/Region Code" := POSStore."Country/Region Code";
        TempNpCsStore."Contact County" := POSStore.County;

        TempNpCsStore."Contact E-mail" := POSStore."E-Mail";
        TempNpCsStore."Contact Phone No." := POSStore."Phone No.";
        exit(true);
    end;

    local procedure SetContactInfoLocation(): Boolean
    var
        Location: Record Location;
    begin
        if TempNpCsStore."Location Code" = '' then
            exit(false);

        if not Location.Get(TempNpCsStore."Location Code") then
            exit(false);
        if Location.Name = '' then
            exit(false);

        TempNpCsStore."Contact Name" := Location.Name;
        TempNpCsStore."Contact Name 2" := Location."Name 2";
        TempNpCsStore."Contact Address" := Location.Address;
        TempNpCsStore."Contact Address 2" := Location."Address 2";
        TempNpCsStore."Contact Post Code" := Location."Post Code";
        TempNpCsStore."Contact City" := Location.City;
        TempNpCsStore."Contact Country/Region Code" := Location."Country/Region Code";
        TempNpCsStore."Contact County" := Location.County;

        TempNpCsStore."Contact E-mail" := Location."E-Mail";
        TempNpCsStore."Contact Phone No." := Location."Phone No.";
        exit(true);
    end;

    local procedure SetContactInfoCompanyInfo()
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get;

        TempNpCsStore."Contact Name" := CompanyInfo.Name;
        TempNpCsStore."Contact Name 2" := CompanyInfo."Name 2";
        TempNpCsStore."Contact Address" := CompanyInfo.Address;
        TempNpCsStore."Contact Address 2" := CompanyInfo."Address 2";
        TempNpCsStore."Contact Post Code" := CompanyInfo."Post Code";
        TempNpCsStore."Contact City" := CompanyInfo.City;
        TempNpCsStore."Contact Country/Region Code" := CompanyInfo."Country/Region Code";
        TempNpCsStore."Contact County" := CompanyInfo.County;

        TempNpCsStore."Contact E-mail" := CompanyInfo."E-Mail";
        TempNpCsStore."Contact Phone No." := CompanyInfo."Phone No.";
    end;
}

