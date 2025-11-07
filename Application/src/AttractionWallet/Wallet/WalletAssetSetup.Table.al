table 6150936 "NPR WalletAssetSetup"
{
    DataClassification = CustomerContent;
    Access = Internal;
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }

        field(20; ReferencePattern; Code[30])
        {
            Caption = 'Wallet Reference Pattern';
            DataClassification = CustomerContent;
        }
        field(21; ExtReferencePattern; Code[30])
        {
            Caption = 'Wallet External Reference Pattern';
            DataClassification = CustomerContent;
        }

        field(30; EnableEndOfSalePrint; Boolean)
        {
            Caption = 'Enable End Of Sale Print';
            DataClassification = CustomerContent;
        }
        field(41; UpdateAssetPrintedInformation; Boolean)
        {
            Caption = 'Increment Asset Print Information';
            DataClassification = CustomerContent;
        }
        field(210; NPDesignerTemplateId; Text[40])
        {
            Caption = 'Design Layout Id';
            DataClassification = CustomerContent;
        }
        field(211; NPDesignerTemplateLabel; Text[80])
        {
            Caption = 'Design Layout Label';
            DataClassification = CustomerContent;
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
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}