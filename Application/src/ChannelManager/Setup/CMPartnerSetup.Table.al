table 6059939 "NPR CMPartnerSetup"
{
    Access = Internal;
    Caption = 'Channel Manager Partner Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PartnerId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Partner Id';
            NotBlank = true;
        }

        field(10; Name; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }

        field(40; Active; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Active';
            InitValue = true;
        }

        field(50; NPDesignerTemplateId; Text[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Design Layout Id';
        }

        field(51; NPDesignerTemplateLabel; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Design Layout Label';

            trigger OnLookup()
            var
                Designer: Codeunit "NPR NPDesigner";
            begin
                Designer.LookupDesignLayouts('attractionWallet', Rec.FieldCaption(NPDesignerTemplateLabel), Rec.NPDesignerTemplateId, Rec.NPDesignerTemplateLabel);
            end;

            trigger OnValidate()
            var
                Designer: Codeunit "NPR NPDesigner";
            begin
                Designer.ValidateDesignLayouts('attractionWallet', Rec.NPDesignerTemplateId, Rec.NPDesignerTemplateLabel);
            end;
        }
    }

    keys
    {
        key(Key1; PartnerId)
        {
            Clustered = true;
        }

        key(Key2; Name)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, PartnerId)
        {
        }
    }
}
