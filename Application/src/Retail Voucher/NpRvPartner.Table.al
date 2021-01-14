table 6151024 "NPR NpRv Partner"
{
    Caption = 'Retail Voucher Partner';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Partners";
    LookupPageID = "NPR NpRv Partners";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
            begin
                NpRvPartnerMgt.InitLocalPartner(Rec);
            end;
        }
        field(5; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Company: Record Company;
                NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
            begin
                if StrLen(Name) <= MaxStrLen(Company.Name) then begin
                    if Company.Get(Name) then
                        "Service Url" := NpRvPartnerMgt.GetGlobalVoucherWSUrl(Company.Name);
                end;
            end;
        }
        field(10; "Service Url"; Text[250])
        {
            Caption = 'Service Url';
            DataClassification = CustomerContent;
        }
        field(15; "Service Username"; Code[50])
        {
            Caption = 'Service Username';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Service Username");
            end;
        }
        field(20; "Service Password"; Text[100])
        {
            Caption = 'Service Password';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

