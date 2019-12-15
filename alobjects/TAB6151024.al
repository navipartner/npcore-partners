table 6151024 "NpRv Partner"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company vouchers

    Caption = 'Retail Voucher Partner';
    DrillDownPageID = "NpRv Partners";
    LookupPageID = "NpRv Partners";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;

            trigger OnValidate()
            var
                NpRvPartnerMgt: Codeunit "NpRv Partner Mgt.";
            begin
                NpRvPartnerMgt.InitLocalPartner(Rec);
            end;
        }
        field(5;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(10;"Service Url";Text[250])
        {
            Caption = 'Service Url';
        }
        field(15;"Service Username";Code[50])
        {
            Caption = 'Service Username';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("Service Username");
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.ValidateUserID("Service Username");
            end;
        }
        field(20;"Service Password";Text[100])
        {
            Caption = 'Service Password';
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
}

