table 6059866 "NPR TM TempTicketDescription"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'Ticket Description';
    Access = Internal;

    fields
    {
        field(1; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(2; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(3; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(4; LanguageCode; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
        }
        field(10; Title; Text[2048])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(11; Subtitle; Text[2048])
        {
            Caption = 'Subtitle';
            DataClassification = CustomerContent;
        }
        field(12; Name; Text[2048])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(13; Description; Text[2048])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(14; FullDescription; Text[2048])
        {
            Caption = 'Full Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ItemNo, VariantCode, AdmissionCode)
        {
        }
    }

    // AA0245 enabled on cloud builds, so lets go hungarian ...
    internal procedure SetKeyAndDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20]; StoreCode: Code[32]; pLanguageCode: Code[10])
    begin
        Clear(Rec);
        Rec.ItemNo := pItemNo;
        Rec.VariantCode := pVariantCode;
        Rec.AdmissionCode := pAdmissionCode;

        SetDescription(pItemNo, pVariantCode, pAdmissionCode, StoreCode, pLanguageCode);
    end;

    internal procedure SetDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20]; StoreCode: Code[32]; pLanguageCode: Code[10])
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (Rec.LanguageCode <> pLanguageCode) then begin
            Rec.SetRecFilter();
            if (not Rec.Delete()) then;
        end;

        Rec.Title := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Title"), StoreCode, pLanguageCode), 1, MaxStrLen(Rec.Title));
        Rec.Subtitle := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Sub Title"), StoreCode, pLanguageCode), 1, MaxStrLen(Rec.Subtitle));
        Rec.Name := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Name"), StoreCode, pLanguageCode), 1, MaxStrLen(Rec.Name));
        Rec.Description := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Description"), StoreCode, pLanguageCode), 1, MaxStrLen(Rec.Description));
        Rec.FullDescription := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Full Description"), StoreCode, pLanguageCode), 1, MaxStrLen(Rec.FullDescription));
        Rec.LanguageCode := pLanguageCode;
    end;

    internal procedure GetDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20]; pFieldNo: Integer; StoreCode: Code[32]; pLanguageCode: Code[10]) rDescription: Text
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        Item: Record Item;
        Variant: Record "Item Variant";
        MagentoStoreItem: Record "NPR Magento Store Item";
        ItemTranslation: Record "Item Translation";
        TempBlob: Codeunit "Temp Blob";
        DescriptionSelector: Option ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        case pFieldNo of
            TicketSetup.FieldNo("Ticket Title"):
                DescriptionSelector := TicketSetup."Ticket Title";
            TicketSetup.FieldNo("Ticket Sub Title"):
                DescriptionSelector := TicketSetup."Ticket Sub Title";
            TicketSetup.FieldNo("Ticket Name"):
                DescriptionSelector := TicketSetup."Ticket Name";
            TicketSetup.FieldNo("Ticket Description"):
                DescriptionSelector := TicketSetup."Ticket Description";
            TicketSetup.FieldNo("Ticket Full Description"):
                DescriptionSelector := TicketSetup."Ticket Full Description";
            else
                DescriptionSelector := DescriptionSelector::BLANK;
        end;

        TicketBOM.SetFilter("Item No.", '=%1', pItemNo);
        TicketBOM.SetFilter("Variant Code", '=%1', pVariantCode);

        if (pAdmissionCode <> '') then
            TicketBOM.SetFilter("Admission Code", '=%1', pAdmissionCode);

        if (pAdmissionCode = '') then
            TicketBOM.SetFilter(Default, '=%1', true);

        if (not TicketBOM.FindFirst()) then
            TicketBOM.SetFilter(Default, '=%1', false);

        if (not TicketBOM.FindFirst()) then
            Clear(TicketBOM);

        if (not Item.Get(pItemNo)) then
            Clear(Item);

        if (not Variant.Get(pItemNo, pVariantCode)) then
            Clear(Variant);

        if (not Admission.Get(pAdmissionCode)) then
            if (not Admission.Get(TicketBOM."Admission Code")) then
                Clear(Admission);

        if (StoreCode <> '') then
            if (not MagentoStoreItem.Get(Item."No.", StoreCode)) then
                MagentoStoreItem.Init();

        if (StoreCode = '') then
            if (not MagentoStoreItem.Get(Item."No.", TicketSetup."Store Code")) then
                MagentoStoreItem.Init();

        case DescriptionSelector of
            DescriptionSelector::ITEM_DESC:
                if (not ItemTranslation.Get(pItemNo, pVariantCode, pLanguageCode)) then
                    exit(Item.Description)
                else
                    exit(ItemTranslation.Description);
            DescriptionSelector::VARIANT_DESC:
                if (not ItemTranslation.Get(pItemNo, pVariantCode, pLanguageCode)) then
                    exit(Variant.Description)
                else
                    exit(ItemTranslation.Description);
            DescriptionSelector::ADM_DESC:
                exit(Admission.Description);
            DescriptionSelector::BOM_DESC:
                exit(TicketBOM.Description);
            DescriptionSelector::TYPE_DESC:
                exit(TicketType.Description);
            DescriptionSelector::WEBSHOP_SHORT:
                if (MagentoStoreItem."Webshop Short Desc. Enabled") then begin
                    if (MagentoStoreItem."Webshop Short Desc.".HasValue()) then begin
                        MagentoStoreItem.CalcFields("Webshop Short Desc.");
                        MagentoStoreItem."Webshop Short Desc.".CreateInStream(InStr);
                        InStr.Read(rDescription);
                        exit(rDescription);
                    end;
                end else begin
                    if (Item."NPR Magento Short Desc.".HasValue()) then begin
                        TempBlob.CreateOutStream(OutStr);
                        Item."NPR Magento Short Desc.".ExportStream(OutStr);
                        TempBlob.CreateInStream(InStr);
                        InStr.Read(rDescription);
                        exit(rDescription);
                    end;
                end;
            DescriptionSelector::WEBSHOP_FULL:
                if (MagentoStoreItem."Webshop Description Enabled") then begin
                    if (MagentoStoreItem."Webshop Description".HasValue()) then begin
                        MagentoStoreItem.CalcFields("Webshop Description");
                        MagentoStoreItem."Webshop Description".CreateInStream(InStr);
                        InStr.Read(rDescription);
                        exit(rDescription);
                    end;
                end else begin
                    if (Item."NPR Magento Desc.".HasValue()) then begin
                        TempBlob.CreateOutStream(OutStr);
                        Item."NPR Magento Desc.".ExportStream(OutStr);
                        TempBlob.CreateInStream(InStr);
                        InStr.Read(rDescription);
                        exit(rDescription);
                    end;
                end;
            DescriptionSelector::WEBSHOP_NAME:
                begin
                    if (MagentoStoreItem."Webshop Name Enabled") then
                        exit(MagentoStoreItem."Webshop Name");

                    if (not MagentoStoreItem."Webshop Name Enabled") then
                        exit(Item."NPR Magento Name");
                end;
        end;

        exit('');
    end;
}