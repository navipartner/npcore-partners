table 6151020 "NpRv Global Voucher Setup"
{
    // NPR5.42/MHA /20180525  CASE 307022 Object created - Global Retail Voucher
    // NPR5.49/MHA /20190228  CASE 342811 Added field 3 "Service Company Name" and removed field 55 "Account No.", which is now Retail Voucher Partner

    Caption = 'Global Voucher Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NpRv Voucher Type";
        }
        field(3; "Service Company Name"; Text[30])
        {
            Caption = 'Service Company Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Company: Record Company;
                Url: Text;
            begin
                //-NPR5.49 [342811]
                if not Company.Get("Service Company Name") then
                    exit;

                Url := GetUrl(CLIENTTYPE::SOAP, Company.Name, OBJECTTYPE::Codeunit, CODEUNIT::"NpRv Global Voucher Webservice");
                "Service Url" := CopyStr(Url, 1, MaxStrLen("Service Url"));
                //+NPR5.49 [342811]
            end;
        }
        field(5; "Service Url"; Text[250])
        {
            Caption = 'Service Url';
            DataClassification = CustomerContent;
        }
        field(10; "Service Username"; Text[30])
        {
            Caption = 'Service Username';
            DataClassification = CustomerContent;
        }
        field(15; "Service Password"; Text[100])
        {
            Caption = 'Service Password';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Voucher Type")
        {
        }
    }

    fieldgroups
    {
    }
}

