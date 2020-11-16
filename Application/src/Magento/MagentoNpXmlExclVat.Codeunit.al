codeunit 6151454 "NPR Magento NpXml ExclVat"
{
    // MAG1.16/TS/20150507  CASE 213379 Object created - Custom Values for NpXml
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.05/TS  /20170620  CASE 267258 Should return Blank if CustomeValue is 0
    // MAG2.20/MHA /20190430  CASE 353499 Added rounding to 4 decimals
    // MAG2.21/BHR /20190508  CASE #338087 Calculate correct custom price

    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code", "Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        if not RecRef.Find then
            exit;

        CustomValue := GetExclVat(RecRef, NpXmlElement."Field No.");
        //-MAG2.05
        if (CustomValue = '0') and (NpXmlElement."Blank Zero") then
            CustomValue := '';
        //+MAG2.05
        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    local procedure GetExclVat(RecRef: RecordRef; FieldNo: Integer) DecimalExclVat: Text
    var
        Item: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesPrice: Record "Sales Price";
        VATPostingSetup: Record "VAT Posting Setup";
        FieldRef: FieldRef;
        Option: Integer;
        DecimalValue: Decimal;
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        FieldRef := RecRef.Field(FieldNo);
        //-MAG2.21 [#338087]
        if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
            FieldRef.CalcField;
        //+MAG2.21 [#338087]
        if LowerCase(Format(FieldRef.Type)) <> 'decimal' then
            exit('');

        Evaluate(DecimalValue, Format(FieldRef.Value, 0, 9), 9);
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    if Item.Find and Item."Price Includes VAT" then begin
                        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;
            DATABASE::"Sales Price":
                begin
                    RecRef.SetTable(SalesPrice);
                    if SalesPrice.Find and SalesPrice."Price Includes VAT" then begin
                        Item.Get(SalesPrice."Item No.");
                        VATPostingSetup.Get(SalesPrice."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;
            //-MAG2.21 [338087]

            DATABASE::"NPR Magento Item Custom Option":
                begin
                    RecRef.SetTable(MagentoItemCustomOption);
                    if MagentoItemCustomOption.Find and MagentoItemCustomOption."Price Includes VAT" then begin
                        Item.Get(MagentoItemCustomOption."Item No.");
                        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;

            DATABASE::"NPR Magento Itm Cstm Opt.Value":
                begin
                    RecRef.SetTable(MagentoItemCustomOptValue);
                    if MagentoItemCustomOptValue.Find and MagentoItemCustomOptValue."Price Includes VAT" then begin
                        Item.Get(MagentoItemCustomOptValue."Item No.");
                        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                        DecimalValue := DecimalValue / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                end;
        //+MAG2.21 [338087]
        end;

        //-MAG2.20 [353499]
        GeneralLedgerSetup.Get;
        DecimalValue := Round(DecimalValue, GeneralLedgerSetup."Unit-Amount Rounding Precision");
        //+MAG2.20 [353499]
        DecimalExclVat := Format(DecimalValue, 0, 9);
        exit(DecimalExclVat);
    end;
}

