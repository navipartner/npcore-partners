table 6151020 "NPR NpRv Global Vouch. Setup"
{
    Caption = 'Global Voucher Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRv Voucher Type";
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
                if not Company.Get("Service Company Name") then
                    exit;

                Url := GetUrl(CLIENTTYPE::SOAP, Company.Name, OBJECTTYPE::Codeunit, CODEUNIT::"NPR NpRv Global Voucher WS");
                "Service Url" := CopyStr(Url, 1, MaxStrLen("Service Url"));
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
}

