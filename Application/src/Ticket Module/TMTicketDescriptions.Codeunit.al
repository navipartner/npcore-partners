codeunit 6151000 "NPR TMTicketDescriptions"
{
    Access = Internal;

    var
        _TicketSetup: Record "NPR TM Ticket Setup";
        _TicketBOM: Record "NPR TM Ticket Admission BOM";
        _TicketType: Record "NPR TM Ticket Type";
        _Admission: Record "NPR TM Admission";
        _Item: Record Item;
        _Variant: Record "Item Variant";
        _MagentoStoreItem: Record "NPR Magento Store Item";
        _ItemTranslation: Record "Item Translation";

    internal procedure Initialize(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; StoreCode: Code[32]; LanguageCode: Code[10])
    begin
        if (not _TicketSetup.Get()) then
            _TicketSetup.Init();

        _TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
        _TicketBOM.SetFilter("Variant Code", '=%1', VariantCode);

        if (AdmissionCode <> '') then
            _TicketBOM.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (AdmissionCode = '') then
            _TicketBOM.SetFilter(Default, '=%1', true);

        if (not _TicketBOM.FindFirst()) then
            _TicketBOM.SetFilter(Default, '=%1', false);

        if (not _TicketBOM.FindFirst()) then
            Clear(_TicketBOM);

        // Item 
        if (not _Item.Get(ItemNo)) then
            Clear(_Item);

        if (_ItemTranslation.Get(ItemNo, '', LanguageCode)) then
            _Item.Description := _ItemTranslation.Description;

        if (_Item."NPR Ticket Type" <> '') then
            if (not _TicketType.Get(_Item."NPR Ticket Type")) then
                Clear(_TicketType);

        // Variant
        if (not _Variant.Get(ItemNo, VariantCode)) then
            Clear(_Variant);

        if (_ItemTranslation.Get(ItemNo, VariantCode, LanguageCode)) then
            _Variant.Description := _ItemTranslation."Description";

        // Admission
        if (not _Admission.Get(AdmissionCode)) then
            if (not _Admission.Get(_TicketBOM."Admission Code")) then
                Clear(_Admission);

        if (StoreCode <> '') then
            if (not _MagentoStoreItem.Get(_Item."No.", StoreCode)) then
                _MagentoStoreItem.Init();

        if (StoreCode = '') then
            if (not _MagentoStoreItem.Get(_Item."No.", _TicketSetup."Store Code")) then
                _MagentoStoreItem.Init();

    end;

    internal procedure GetDescription(FieldNo: Integer) Description: Text
    var
        TempBlob: Codeunit "Temp Blob";
        DescriptionSelector: Option ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        InStr: InStream;
        OutStr: OutStream;
    begin
        case FieldNo of
            _TicketSetup.FieldNo("Ticket Title"):
                DescriptionSelector := _TicketSetup."Ticket Title";
            _TicketSetup.FieldNo("Ticket Sub Title"):
                DescriptionSelector := _TicketSetup."Ticket Sub Title";
            _TicketSetup.FieldNo("Ticket Name"):
                DescriptionSelector := _TicketSetup."Ticket Name";
            _TicketSetup.FieldNo("Ticket Description"):
                DescriptionSelector := _TicketSetup."Ticket Description";
            _TicketSetup.FieldNo("Ticket Full Description"):
                DescriptionSelector := _TicketSetup."Ticket Full Description";
            else
                DescriptionSelector := DescriptionSelector::BLANK;
        end;

        case DescriptionSelector of
            DescriptionSelector::ITEM_DESC:
                exit(_Item.Description);
            DescriptionSelector::VARIANT_DESC:
                exit(_Variant.Description);
            DescriptionSelector::ADM_DESC:
                exit(_Admission.Description);
            DescriptionSelector::BOM_DESC:
                exit(_TicketBOM.Description);
            DescriptionSelector::TYPE_DESC:
                exit(_TicketType.Description);
            DescriptionSelector::WEBSHOP_SHORT:
                if (_MagentoStoreItem."Webshop Short Desc. Enabled") then begin
                    if (_MagentoStoreItem."Webshop Short Desc.".HasValue()) then begin
                        _MagentoStoreItem.CalcFields("Webshop Short Desc.");
                        _MagentoStoreItem."Webshop Short Desc.".CreateInStream(InStr);
                        InStr.Read(Description);
                        exit(Description);
                    end;
                end else begin
                    if (_Item."NPR Magento Short Desc.".HasValue()) then begin
                        TempBlob.CreateOutStream(OutStr);
                        _Item."NPR Magento Short Desc.".ExportStream(OutStr);
                        TempBlob.CreateInStream(InStr);
                        InStr.Read(Description);
                        exit(Description);
                    end;
                end;
            DescriptionSelector::WEBSHOP_FULL:
                if (_MagentoStoreItem."Webshop Description Enabled") then begin
                    if (_MagentoStoreItem."Webshop Description".HasValue()) then begin
                        _MagentoStoreItem.CalcFields("Webshop Description");
                        _MagentoStoreItem."Webshop Description".CreateInStream(InStr);
                        InStr.Read(Description);
                        exit(Description);
                    end;
                end else begin
                    if (_Item."NPR Magento Desc.".HasValue()) then begin
                        TempBlob.CreateOutStream(OutStr);
                        _Item."NPR Magento Desc.".ExportStream(OutStr);
                        TempBlob.CreateInStream(InStr);
                        InStr.Read(Description);
                        exit(Description);
                    end;
                end;
            DescriptionSelector::WEBSHOP_NAME:
                begin
                    if (_MagentoStoreItem."Webshop Name Enabled") then
                        exit(_MagentoStoreItem."Webshop Name");

                    if (not _MagentoStoreItem."Webshop Name Enabled") then
                        exit(_Item."NPR Magento Name");
                end;
        end;

        exit('');

    end;
}