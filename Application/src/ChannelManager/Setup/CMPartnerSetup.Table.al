table 6059939 "NPR CMPartnerSetup"
{
    Access = Internal;
    Caption = 'OTA Channel Manager Partner Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PartnerId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Partner Id';
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

        field(60; DocumentNoSeries; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Buy-from Order Reference No. Series';
            TableRelation = "No. Series";
        }

        field(70; PartnerType; Enum "NPR CMPartnerType")
        {
            DataClassification = CustomerContent;
            Caption = 'Partner Type';
        }

        field(80; Distribution; Enum "NPR CMDistribution")
        {
            DataClassification = CustomerContent;
            Caption = 'Distribution';
        }

        field(81; OrderConfirmationTemplateId; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Confirmation Email Template';
            TableRelation = "NPR NPEmailTemplate".TemplateId where(DataProvider = const(CHANNEL_MANAGER_ORDER));
        }

        field(82; WalletEmailTemplateId; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Email Template';
            TableRelation = "NPR NPEmailTemplate".TemplateId where(DataProvider = const(CHANNEL_MANAGER_WALLETS));
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

    internal procedure GetDesignLayoutId(): Text[40]
    var
        WalletSetup: Record "NPR WalletAssetSetup";
    begin
        if (Rec.NPDesignerTemplateId <> '') then
            exit(Rec.NPDesignerTemplateId);
        if (Rec.PartnerType <> Rec.PartnerType::TourBooking) then
            exit('');
        if (WalletSetup.Get()) then
            exit(WalletSetup.NPDesignerTemplateId);
    end;

    trigger OnInsert()
    var
        JobQueueSetup: Codeunit "NPR CMJobQueueSetup";
    begin
        if (IsNullGuid(PartnerId)) then
            PartnerId := CreateGuid();

        JobQueueSetup.ShowMissingJobQueueEntryNotification();
    end;

    trigger OnDelete()
    var
        Order: Record "NPR CMOrder";
        HasOrdersErr: Label 'Cannot delete partner ''%1'': %2 order(s) reference it. Set Active to false to block API access instead.', Comment = '%1 = partner name, %2 = order count';
        OrderCount: Integer;
    begin
        Order.SetFilter(PartnerId, '=%1', PartnerId);
        OrderCount := Order.Count();
        if (OrderCount > 0) then
            Error(HasOrdersErr, Name, OrderCount);
    end;
}
