codeunit 6151454 "NPR Magento NpXml ExclVat"
{
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");
        if not RecRef.Find() then
            exit;

        CustomValue := GetExclVat(RecRef, NpXmlElement."Field No.");
        if (CustomValue = '0') and (NpXmlElement."Blank Zero") then
            CustomValue := '';
        RecRef.Close();

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;

    local procedure GetExclVat(RecRef: RecordRef; FieldNo: Integer) DecimalExclVat: Text
    var
        Item: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
        PriceListLine: Record "Price List Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FieldRef: FieldRef;
        DecimalValue: Decimal;
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
        NotSupportedErr: Label 'Unsupported table: %1 %2 - codeunit 6151454 "NPR Magento NpXml ExclVat" ';
    begin
        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
            FieldRef.CalcField();
        if LowerCase(Format(FieldRef.Type)) <> 'decimal' then
            exit('');

        Evaluate(DecimalValue, Format(FieldRef.Value, 0, 9), 9);
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    if Item.Find() and Item."Price Includes VAT" then begin
                        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;
            Database::"Price List Line":
                begin
                    RecRef.SetTable(PriceListLine);
                    if PriceListLine.Find() and PriceListLine."Price Includes VAT" then begin
                        Item.Get(PriceListLine."Asset No.");
                        VATPostingSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;
            DATABASE::"NPR Magento Item Custom Option":
                begin
                    RecRef.SetTable(MagentoItemCustomOption);
                    if MagentoItemCustomOption.Find() and MagentoItemCustomOption."Price Includes VAT" then begin
                        Item.Get(MagentoItemCustomOption."Item No.");
                        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;

            DATABASE::"NPR Magento Itm Cstm Opt.Value":
                begin
                    RecRef.SetTable(MagentoItemCustomOptValue);
                    if MagentoItemCustomOptValue.Find() and MagentoItemCustomOptValue."Price Includes VAT" then begin
                        Item.Get(MagentoItemCustomOptValue."Item No.");
                        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;
            else
                Error(NotSupportedErr, RecRef.Number, RecRef.Caption);
        end;

        GeneralLedgerSetup.Get();
        DecimalValue := Round(DecimalValue, GeneralLedgerSetup."Unit-Amount Rounding Precision");
        DecimalExclVat := Format(DecimalValue, 0, 9);
        exit(DecimalExclVat);
    end;
}