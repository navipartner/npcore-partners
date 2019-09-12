table 6151173 "Upgrade NpGp POS Sales Setup"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.51/ALST/20190909 CASE 337539 Created object Upgrade table to handle schema change


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
                // IF STRLEN("Company Name") > MAXSTRLEN(Company.Name) THEN
                //  EXIT;
                // IF NOT Company.GET("Company Name") THEN
                //  EXIT;
                //
                // NpGpPOSSalesSyncMgt.InitGlobalPosSalesService();
                // Url := GETURL(CLIENTTYPE::SOAP,Company.Name,OBJECTTYPE::Codeunit,CODEUNIT::"NpGp POS Sales Webservice");
                // "Service Url" := COPYSTR(Url,1,MAXSTRLEN("Service Url"));
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
        field(20;"Service Password";Text[250])
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
        // ServicePassword.SETRANGE(Key,"Service Password");
        // IF Password = '' THEN BEGIN
        //  IF ServicePassword.FINDFIRST THEN
        //    ServicePassword.DELETE;
        //  EXIT;
        // END;
        //
        // IF NOT ServicePassword.FINDFIRST THEN BEGIN
        //  "Service Password" := CREATEGUID;
        //  MODIFY;
        //  ServicePassword.Key := "Service Password";
        //  ServicePassword.INSERT;
        // END;
        //
        // ServicePassword.SavePassword(Password);
        // ServicePassword.MODIFY;
    end;
}

