xmlport 6151400 "Magento Avail. InventoryExport"
{
    // MAG1.22/MHA /20160421  CASE 236917 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG9.00.2.11/MHA /20180319  CASE 308406 Specific value removed from XmlVersionNo in order to be V2 extension compliant
    // MAG2.26/MHA /20200430  CASE 402486 Updated Stock Calculation function

    Caption = 'Magento Avail. InventoryExport';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/item_inventory';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(items)
        {
            MaxOccurs = Once;
            tableelement(tempitemvariant;"Item Variant")
            {
                MinOccurs = Zero;
                XmlName = 'item';
                UseTemporary = true;
                fieldattribute(item_no;TempItemVariant."Item No.")
                {
                }
                fieldattribute(variant_code;TempItemVariant.Code)
                {
                }
                textelement(inventory)
                {
                    MaxOccurs = Once;

                    trigger OnBeforePassVariable()
                    var
                        MagentoInventoryCompany: Record "Magento Inventory Company";
                    begin
                        //-MAG2.26 [402486]
                        MagentoInventoryCompany."Location Filter" := LocationFilter;
                        inventory := Format(MagentoItemMgt.GetStockQty3(TempItemVariant."Item No.",TempItemVariant.Code,MagentoInventoryCompany),0,9);
                        //+MAG2.26 [402486]
                    end;
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    begin
        if ItemFilter = '' then
          currXMLport.Quit;

        SetupTempItemVariants();
    end;

    var
        MagentoItemMgt: Codeunit "Magento Item Mgt.";
        ItemFilter: Text;
        VariantFilter: Text;
        LocationFilter: Text;

    local procedure EmptyString() String: Text
    var
        Lf: Char;
        Space: Char;
        EmptyString: Text;
    begin
        String := '';
        Lf := 10;
        Space := 32;
        String := Format(Lf) + Format(Space) + Format(Space) + Format(Space) + Format(Space) + Format(Space) + Format(Space);
        exit(String);
    end;

    procedure SetFilters(NewItemFilter: Text;NewVariantFilter: Text;NewLocationFilter: Text)
    begin
        if NewItemFilter <> EmptyString() then
          ItemFilter := UpperCase(NewItemFilter);
        if NewVariantFilter <> EmptyString() then
          VariantFilter := UpperCase(NewVariantFilter);
        if NewLocationFilter <> EmptyString() then
          LocationFilter := UpperCase(NewLocationFilter);
    end;

    procedure SetupTempItemVariants()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Ch: Char;
        i: Integer;
        j: Integer;
        String: Text;
    begin
        TempItemVariant.DeleteAll;
        String := '';
        for i := 1 to StrLen(VariantFilter) do begin
          Ch := VariantFilter[i];
          j := Ch;
          String += Format(j);
        end;

        if VariantFilter <> '' then begin
          ItemVariant.SetFilter("Item No.",ItemFilter);
          ItemVariant.SetFilter(Code,VariantFilter);
          if ItemVariant.FindSet then
            repeat
              TempItemVariant.Init;
              TempItemVariant := ItemVariant;
              TempItemVariant.Insert;
            until ItemVariant.Next = 0;
          exit;
        end;

        Item.SetFilter("No.",ItemFilter);
        if not Item.FindSet then
          exit;

        repeat
          TempItemVariant.Init;
          TempItemVariant."Item No." := Item."No.";
          TempItemVariant.Insert;
        until Item.Next = 0;
    end;
}

