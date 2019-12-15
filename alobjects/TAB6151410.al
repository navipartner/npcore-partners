table 6151410 "Magento Inventory Company"
{
    // MAG1.22/MHA/20160421 CASE 236917 Object created
    // MAG1.22.01/MHA/20160511 CASE 236917 Field 25 Api Domain added and special SSL case removed in SetApiUrl()
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object and field 1

    Caption = 'Magento Inventory Company';

    fields
    {
        field(1;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            NotBlank = true;
            TableRelation = Company;
        }
        field(5;"Location Filter";Text[100])
        {
            Caption = 'Location Filter';

            trigger OnLookup()
            var
                Location: Record Location;
            begin
                if "Company Name" <> CompanyName then
                  if not Location.ChangeCompany("Company Name") then
                    exit;

                if PAGE.RunModal(PAGE::"Location List",Location) <> ACTION::LookupOK then
                  exit;

                "Location Filter" := Location.Code;
            end;

            trigger OnValidate()
            begin
                "Location Filter" := UpperCase("Location Filter");
            end;
        }
        field(10;"Api Url";Text[250])
        {
            Caption = 'Api Url';
        }
        field(15;"Api Username";Text[100])
        {
            Caption = 'Api Username';
        }
        field(20;"Api Password";Text[100])
        {
            Caption = 'Api Password';
        }
        field(25;"Api Domain";Text[100])
        {
            Caption = 'Api Domain';
            Description = 'MAG1.22.01';
        }
    }

    keys
    {
        key(Key1;"Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        SetApiUrl();
    end;

    trigger OnModify()
    begin
        SetApiUrl();
    end;

    procedure SetApiUrl()
    var
        MagentoWebservice: Codeunit "Magento Webservice";
        Position: Integer;
    begin
        if "Api Url" = '' then begin
          "Api Url" := GetUrl(CLIENTTYPE::SOAP,"Company Name",OBJECTTYPE::Codeunit,CODEUNIT::"Magento Webservice");
          if StrPos(LowerCase("Api Url"),'https://') = 1 then begin
            Position := StrPos(CopyStr("Api Url",StrLen('https://')),':');
            "Api Url" := 'https://localhost.dynamics-retail.com:' + CopyStr("Api Url",StrLen('https://') + Position);
          end;
        end;
    end;
}

