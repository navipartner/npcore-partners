table 6151170 "NpGp POS Sales Setup"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/ALST/20190904  CASE 337539 obscured password

    Caption = 'Global POS Sales Setup';
    DrillDownPageID = "NpGp Global POS Sales Setups";
    LookupPageID = "NpGp Global POS Sales Setups";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;"Company Name";Text[100])
        {
            Caption = 'Company Name';
            TableRelation = Company;

            trigger OnValidate()
            var
                Company: Record Company;
                NpGpPOSSalesSyncMgt: Codeunit "NpGp POS Sales Sync Mgt.";
                Url: Text;
            begin
                if StrLen("Company Name") > MaxStrLen(Company.Name) then
                  exit;
                if not Company.Get("Company Name") then
                  exit;

                NpGpPOSSalesSyncMgt.InitGlobalPosSalesService();
                Url := GetUrl(CLIENTTYPE::SOAP,Company.Name,OBJECTTYPE::Codeunit,CODEUNIT::"NpGp POS Sales Webservice");
                "Service Url" := CopyStr(Url,1,MaxStrLen("Service Url"));
            end;
        }
        field(10;"Service Url";Text[250])
        {
            Caption = 'Service Url';
        }
        field(15;"Service Username";Text[250])
        {
            Caption = 'Service Username';
        }
        field(20;"Service Password";Guid)
        {
            Caption = 'Service Password';
        }
        field(25;"Sync POS Sales Immediately";Boolean)
        {
            Caption = 'Sync POS Sales Immediately';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure HandlePassword(Password: Text): Text
    var
        ServicePassword: Record "Service Password";
    begin
        //-NPR5.51 [337539]
        ServicePassword.SetRange(Key,"Service Password");
        if Password = '' then begin
          if ServicePassword.FindFirst then
            ServicePassword.Delete;
          exit;
        end;

        if not ServicePassword.FindFirst then begin
          "Service Password" := CreateGuid;
          Modify;
          ServicePassword.Key := "Service Password";
          ServicePassword.Insert;
        end;

        ServicePassword.SavePassword(Password);
        ServicePassword.Modify;
        //+NPR5.51 [337539]
    end;
}

