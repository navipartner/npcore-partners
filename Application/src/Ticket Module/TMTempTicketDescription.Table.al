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
    internal procedure SetKeyAndDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20])
    begin
        Clear(Rec);
        Rec.ItemNo := pItemNo;
        Rec.VariantCode := pVariantCode;
        Rec.AdmissionCode := pAdmissionCode;

        SetDescription(pItemNo, pVariantCode, pAdmissionCode);
    end;

    internal procedure SetDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20])
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        Rec.Title := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Title")), 1, MaxStrLen(Rec.Title));
        Rec.Subtitle := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Sub Title")), 1, MaxStrLen(Rec.Subtitle));
        Rec.Name := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Name")), 1, MaxStrLen(Rec.Name));
        Rec.Description := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Description")), 1, MaxStrLen(Rec.Description));
        Rec.FullDescription := CopyStr(GetDescription(pItemNo, pVariantCode, pAdmissionCode, TicketSetup.FieldNo("Ticket Full Description")), 1, MaxStrLen(Rec.FullDescription));
    end;

    internal procedure GetDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20]; pFieldNo: Integer) rDescription: Text
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        Item: Record Item;
        Variant: Record "Item Variant";
        MagentoStoreItem: Record "NPR Magento Store Item";
        DescriptionSelector: Option ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK;
        InStr: InStream;
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

        if (not MagentoStoreItem.Get(Item."No.", TicketSetup."Store Code")) then
            MagentoStoreItem.Init();

        case DescriptionSelector of
            DescriptionSelector::ITEM_DESC:
                exit(Item.Description);
            DescriptionSelector::VARIANT_DESC:
                exit(Variant.Description);
            DescriptionSelector::ADM_DESC:
                exit(Admission.Description);
            DescriptionSelector::BOM_DESC:
                exit(TicketBOM.Description);
            DescriptionSelector::TYPE_DESC:
                exit(TicketType.Description);
            DescriptionSelector::WEBSHOP_SHORT:
                if (MagentoStoreItem."Webshop Short Desc. Enabled") then
                    if (MagentoStoreItem."Webshop Short Desc.".HasValue()) then begin
                        MagentoStoreItem.CalcFields("Webshop Short Desc.");
                        MagentoStoreItem."Webshop Short Desc.".CreateInStream(InStr);
                        InStr.Read(rDescription);
                        exit(rDescription);
                    end;
            DescriptionSelector::WEBSHOP_FULL:
                if (MagentoStoreItem."Webshop Description Enabled") then
                    if (MagentoStoreItem."Webshop Description".HasValue()) then begin
                        MagentoStoreItem.CalcFields("Webshop Description");
                        MagentoStoreItem."Webshop Description".CreateInStream(InStr);
                        InStr.Read(rDescription);
                        exit(rDescription);
                    end;
        end;

        exit('');
    end;
}