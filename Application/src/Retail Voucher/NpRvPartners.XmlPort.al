xmlport 6151013 "NPR NpRv Partners"
{
    Caption = 'Retail Voucher Partners';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/global_voucher_service';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    XMLVersionNo = V11;

    schema
    {
        textelement(retail_voucher_partners)
        {
            tableelement(tempnprvpartner; "NPR NpRv Partner")
            {
                MinOccurs = Zero;
                XmlName = 'retail_voucher_partner';
                UseTemporary = true;
                fieldattribute(partner_code; TempNpRvPartner.Code)
                {
                }
                fieldelement(name; TempNpRvPartner.Name)
                {
                }
                fieldelement(service_url; TempNpRvPartner."Service Url")
                {
                }
                textelement(auth_type)
                {
                }
                fieldelement(service_username; TempNpRvPartner."Service Username")
                {
                }
                textelement(service_password)
                {
                }
                fieldelement(oauth_setup_code; TempNpRvPartner."OAuth2 Setup Code")
                {
                }
                textelement(relations)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempnprvpartnerrelation; "NPR NpRv Partner Relation")
                    {
                        LinkFields = "Partner Code" = FIELD(Code);
                        LinkTable = TempNpRvPartner;
                        MinOccurs = Zero;
                        XmlName = 'relation';
                        UseTemporary = true;
                        fieldattribute(voucher_type; TempNpRvPartnerRelation."Voucher Type")
                        {
                        }

                        trigger OnAfterInitRecord()
                        begin
                            TempNpRvPartnerRelation."Partner Code" := TempNpRvPartner.Code;
                        end;
                    }
                }

                trigger OnAfterInsertRecord()
                var
                    AuthType: Enum "NPR API Auth. Type";
                begin
                    if auth_type <> '' then
                        TempNpRvPartner.AuthType := Enum::"NPR API Auth. Type".FromInteger(AuthType.Ordinals.Get(AuthType.Names.IndexOf(auth_type)));
                end;
            }
        }
    }

    procedure GetSourceTables(var TempNpRvPartner2: Record "NPR NpRv Partner" temporary; var TempNpRvPartnerRelation2: Record "NPR NpRv Partner Relation" temporary; var ServicePassword: Text)
    begin
        TempNpRvPartner2.Copy(TempNpRvPartner, true);
        TempNpRvPartnerRelation2.Copy(TempNpRvPartnerRelation, true);
        ServicePassword := service_password;
    end;
}

