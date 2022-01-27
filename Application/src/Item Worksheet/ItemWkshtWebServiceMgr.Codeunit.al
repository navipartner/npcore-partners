codeunit 6060049 "NPR Item Wksht. WebService Mgr"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: XmlDocument;
        FunctionName: Text[100];
    begin
        if LoadDoc(Rec, XmlDoc) then begin
            FunctionName := GetWebserviceFunction(Rec."Import Type");
            case FunctionName of
                'CreateItemWorksheetLine':
                    CreateItemWorksheetLines(XmlDoc);
                else
                    Error(MissingCaseErr, Rec."Import Type", FunctionName);
            end;
        end;
    end;

    procedure Initialize()
    begin
        if not Initialized then
            Initialized := true;
    end;

    local procedure CreateItemWorksheetLine(Element: XmlElement): Boolean
    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if Element.IsEmpty() then
            exit(false);

        ItemWorksheetLine.Init();
        ReadItemWorksheetLine(Element, ItemWorksheetLine);
        InsertWorksheetline(ItemWorksheetLine);

        exit(true);
    end;

    local procedure CreateItemWorksheetLines(XmlDoc: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if not XmlDoc.GetRoot(Element) then
            exit;

        if Element.IsEmpty() then
            exit;

        if not Element.SelectNodes('createitemworksheetline', NodeList) then
            exit;

        if not Element.SelectNodes('itemWorksheetlineimport', NodeList) then
            exit;

        if not Element.SelectNodes('InsertItemWorksheetLine', NodeList) then
            exit;

        SetImportParameters(Element);

        if not Element.SelectNodes('//ItemWorksheetLine', NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            CreateItemWorksheetLine(Element);
        end;
        Commit();
    end;

    local procedure FindWorksheetLine(VendorNo: Code[20]; VendorVATRegNo: Text; var ItemWorksheetTemplateCode: Code[10]; var ItemWorksheetCode: Code[10]; var ItemWorksheetLineNo: Integer)
    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetTemplate2: Record "NPR Item Worksh. Template";
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(VendorNo) then
            if VendorVATRegNo <> '' then begin
                Vendor.SetRange(Vendor."VAT Registration No.", VendorVATRegNo);
                if not Vendor.FindFirst() then begin
                    Vendor.Init();
                    Vendor."No." := '';
                end;
            end;

        //Set Template
        ItemWorksheetTemplate.SetRange("Allow Web Service Update", true);
        if not ItemWorksheetTemplate.FindFirst() then begin
            ItemWorksheetTemplate2.Reset();
            if ItemWorksheetTemplate2.FindFirst() then begin
                ItemWorksheetTemplate := ItemWorksheetTemplate2;
            end else begin
                ItemWorksheetTemplate.Init();
                ItemWorksheetTemplate.Validate(Name, 'WEBSERV');
            end;
            ItemWorksheetTemplate.Validate("Allow Web Service Update", true);
            ItemWorksheetTemplate.Insert(true);
        end;
        ItemWorksheetTemplateCode := ItemWorksheetTemplate.Name;

        //Set Worksheet
        ItemWorksheet.SetRange("Item Template Name", ItemWorksheetTemplate.Name);
        ItemWorksheet.SetRange("Vendor No.", Vendor."No.");
        if not ItemWorksheet.FindFirst() then begin
            ItemWorksheet.SetFilter("Vendor No.", '');
            if not ItemWorksheet.FindFirst() then begin
                ItemWorksheet.Init();
                ItemWorksheet.Validate(ItemWorksheet."Item Template Name", ItemWorksheetTemplate.Name);
                ItemWorksheet.Validate(Name, 'WEBSERV');
                ItemWorksheet.Insert(true);
            end;
        end;
        ItemWorksheetCode := ItemWorksheet.Name;

        //Set Line
        ItemWorksheetLine.SetRange("Worksheet Template Name", ItemWorksheetTemplateCode);
        ItemWorksheetLine.SetRange("Worksheet Name", ItemWorksheetCode);
        if ItemWorksheetLine.FindLast() then begin
            LastItemWorksheetLine := ItemWorksheetLine;
            ItemWorksheetLineNo := ItemWorksheetLine."Line No." + 10000
        end else begin
            LastItemWorksheetLine.Init();
            ItemWorksheetLineNo := 10000;
        end;
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]): Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;

    local procedure InsertWorksheetline(var ItemWorksheetLine: Record "NPR Item Worksheet Line"): Boolean
    begin
        ItemWorksheetLine.Init();
    end;

    local procedure ReadItemWorksheetLine(Element: XmlElement; var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
        TempDateFormula: DateFormula;
        TempBool: Boolean;
        TempDate: Date;
        TempDec: Decimal;
        NodeList: XmlNodeList;
        TempInteger: Integer;
        TempText: Text;
        VendorVATRegNo: Text;
        AttributeValueTxt: Text[250];
        i: Integer;
        AttributeLbl: Label 'Attribute%1', Comment = '%1 - Attribute ordinal';
    begin
        Initialize();

        Clear(ItemWorksheetLine);
        ItemWorksheetLine.Init();
        ItemWorksheetLine."Created Date Time" := CurrentDateTime();
#pragma warning disable AA0139
        ItemWorksheetLine."Vendor No." := GetXmlText(Element, 'VendorNo', MaxStrLen(ItemWorksheetLine."Vendor No."), false);

        VendorVATRegNo := GetXmlText(Element, 'VATRegno', 0, false);
        ItemWorksheetLine."Item No." := GetXmlText(Element, 'ItemNo', MaxStrLen(ItemWorksheetLine."Item No."), false);
#pragma warning restore

        FindWorksheetLine(ItemWorksheetLine."Vendor No.", VendorVATRegNo, ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.");

        ItemWorksheetLine.SetUpNewLine(LastItemWorksheetLine);
        ItemWorksheetLine.Insert(true);
        ItemWorksheetLine.Action := ItemWorksheetLine.Action::CreateNew;
        ItemWorksheetLine.Validate("Item No.", GetXmlText(Element, 'ItemNo', MaxStrLen(ItemWorksheetLine."Item No."), false));
        ItemWorksheetLine.Validate("Vendor Item No.",
            GetXmlText(
                Element, 'VendorItemNo',
                MaxStrLen(ItemWorksheetLine."Vendor Item No."), true));

        ItemWorksheetLine.Validate("Vendor No.",
            GetXmlText(
                Element, 'VendorNo',
                MaxStrLen(ItemWorksheetLine."Vendor No."), false));

        TempText := GetXmlText(Element, 'Description', MaxStrLen(ItemWorksheetLine.Description), true);
        if TempText <> '' then
            ItemWorksheetLine.Validate(Description, TempText);
        TempText := GetXmlText(Element, 'Description2', MaxStrLen(ItemWorksheetLine."Description 2"), true);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Description 2", TempText);
        if Evaluate(TempDec, GetXmlText(Element, 'DirectUnitCost', 0, false)) then
            ItemWorksheetLine.Validate("Direct Unit Cost", TempDec);
        if Evaluate(TempDec, GetXmlText(Element, 'UnitPrice', 0, false)) then
            ItemWorksheetLine.Validate("Sales Price", TempDec);

#pragma warning disable AA0139
        ItemWorksheetLine."Item Category Code" := GetXmlText(Element, 'ItemCategory', MaxStrLen(ItemWorksheetLine."Item Category Code"), false);
        ItemWorksheetLine."Product Group Code" := GetXmlText(Element, 'ProductGroup', MaxStrLen(ItemWorksheetLine."Product Group Code"), false);
#pragma warning restore
        ItemWorksheetLine.Validate("Sales Price Currency Code", GetXmlText(Element, 'SalesPriceCurrencyCode', MaxStrLen(ItemWorksheetLine."Sales Price Currency Code"), false));
        ItemWorksheetLine.Validate("Purchase Price Currency Code", GetXmlText(Element, 'PurchasePriceCurrencyCode', MaxStrLen(ItemWorksheetLine."Purchase Price Currency Code"), false));
        TempText := GetXmlText(Element, 'VarietyGroup', MaxStrLen(ItemWorksheetLine."Variety Group"), false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Variety Group", TempText);

        if Evaluate(TempDec, GetXmlText(Element, 'RecommendedRetailPrice', 0, false)) then
            ItemWorksheetLine.Validate("Recommended Retail Price", TempDec);

        for i := 1 to 10 do begin
            AttributeValueTxt := CopyStr(GetXmlText(Element, StrSubstNo(AttributeLbl, i), 0, false), 1, MaxStrLen(AttributeValueTxt));
            if AttributeValueTxt <> '' then
                NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", i, ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.", AttributeValueTxt);
        end;
        TempText := AttributeValueTxt;

        if Element.SelectNodes('Attributes', NodeList) then
            ReadWkshLineAttributes(ItemWorksheetLine, Element);
        TempText := GetXmlText(Element, 'No2', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("No. 2", TempText);
        TempText := GetXmlText(Element, 'Type', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate(Type, TempInteger);
        TempText := GetXmlText(Element, 'ShelfNo', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Shelf No.", TempText);
        TempText := GetXmlText(Element, 'ItemDiscGroup', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Item Disc. Group", TempText);
        TempText := GetXmlText(Element, 'AllowInvoiceDisc', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Allow Invoice Disc.", 1)
                else
                    ItemWorksheetLine.Validate("Allow Invoice Disc.", 0);
        TempText := GetXmlText(Element, 'StatisticsGroup', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                if TempInteger <> 0 then
                    ItemWorksheetLine.Validate("Statistics Group", TempInteger);
        TempText := GetXmlText(Element, 'CommissionGroup', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                if TempInteger <> 0 then
                    ItemWorksheetLine.Validate("Commission Group", TempInteger);
        TempText := GetXmlText(Element, 'PriceProfitCalculation', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Price/Profit Calculation", TempInteger);
        TempText := GetXmlText(Element, 'Profit', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Profit %", TempDec);
        TempText := GetXmlText(Element, 'LeadTimeCalculation', 0, false);
        if TempText <> '' then
            if Evaluate(TempDateFormula, TempText) then
                ItemWorksheetLine.Validate("Lead Time Calculation", TempDateFormula);
        TempText := GetXmlText(Element, 'ReorderPoint', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Reorder Point", TempDec);
        TempText := GetXmlText(Element, 'MaximumInventory', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Maximum Inventory", TempDec);
        TempText := GetXmlText(Element, 'ReorderQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Reorder Quantity", TempDec);
        TempText := GetXmlText(Element, 'UnitListPrice', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Unit List Price", TempDec);
        TempText := GetXmlText(Element, 'DutyDue', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Duty Due %", TempDec);
        TempText := GetXmlText(Element, 'DutyCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Duty Code", TempText);
        TempText := GetXmlText(Element, 'UnitsperParcel', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Units per Parcel", TempDec);
        TempText := GetXmlText(Element, 'UnitVolume', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Unit Volume", TempDec);
        TempText := GetXmlText(Element, 'Durability', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate(Durability, TempText);
        TempText := GetXmlText(Element, 'FreightType', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Freight Type", TempText);
        TempText := GetXmlText(Element, 'DutyUnitConversion', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Duty Unit Conversion", TempDec);
        TempText := GetXmlText(Element, 'CountryRegionPurchasedCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Country/Region Purchased Code", TempText);
        TempText := GetXmlText(Element, 'BudgetQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Budget Quantity", TempDec);
        TempText := GetXmlText(Element, 'BudgetedAmount', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Budgeted Amount", TempDec);
        TempText := GetXmlText(Element, 'BudgetProfit', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Budget Profit", TempDec);
        TempText := GetXmlText(Element, 'Blocked', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate(Blocked, 1)
                else
                    ItemWorksheetLine.Validate(Blocked, 0);
        TempText := GetXmlText(Element, 'PriceIncludesVAT', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Price Includes VAT", 1)
                else
                    ItemWorksheetLine.Validate("Price Includes VAT", 0);
        TempText := GetXmlText(Element, 'CountryRegionofOriginCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Country/Region of Origin Code", TempText);
        TempText := GetXmlText(Element, 'AutomaticExtTexts', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Automatic Ext. Texts", 1)
                else
                    ItemWorksheetLine.Validate("Automatic Ext. Texts", 0);
        TempText := GetXmlText(Element, 'Reserve', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate(Reserve, TempInteger);
        TempText := GetXmlText(Element, 'StockoutWarning', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Stockout Warning", TempInteger);
        TempText := GetXmlText(Element, 'PreventNegativeInventory', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Prevent Negative Inventory", TempInteger);
        TempText := GetXmlText(Element, 'AssemblyPolicy', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Assembly Policy", TempInteger);
        TempText := GetXmlText(Element, 'GTIN', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate(GTIN, TempText);
        TempText := GetXmlText(Element, 'LotSize', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Lot Size", TempDec);
        TempText := GetXmlText(Element, 'SerialNos', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Serial Nos.", TempText);
        TempText := GetXmlText(Element, 'Scrap', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Scrap %", TempDec);
        TempText := GetXmlText(Element, 'InventoryValueZero', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Inventory Value Zero", 1)
                else
                    ItemWorksheetLine.Validate("Inventory Value Zero", 0);
        TempText := GetXmlText(Element, 'DiscreteOrderQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                if TempInteger <> 0 then
                    ItemWorksheetLine.Validate("Discrete Order Quantity", TempInteger);
        TempText := GetXmlText(Element, 'MinimumOrderQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Minimum Order Quantity", TempDec);
        TempText := GetXmlText(Element, 'MaximumOrderQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Maximum Order Quantity", TempDec);
        TempText := GetXmlText(Element, 'SafetyStockQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Safety Stock Quantity", TempDec);
        TempText := GetXmlText(Element, 'OrderMultiple', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Order Multiple", TempDec);
        TempText := GetXmlText(Element, 'SafetyLeadTime', 0, false);
        if TempText <> '' then
            if Evaluate(TempDateFormula, TempText) then
                ItemWorksheetLine.Validate("Safety Lead Time", TempDateFormula);
        TempText := GetXmlText(Element, 'FlushingMethod', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Flushing Method", TempInteger);
        TempText := GetXmlText(Element, 'ReplenishmentSystem', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Replenishment System", TempInteger);
        TempText := GetXmlText(Element, 'ReorderingPolicy', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Reordering Policy", TempInteger);
        TempText := GetXmlText(Element, 'IncludeInventory', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Include Inventory", 1)
                else
                    ItemWorksheetLine.Validate("Include Inventory", 0);
        TempText := GetXmlText(Element, 'ManufacturingPolicy', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Manufacturing Policy", TempInteger);
        TempText := GetXmlText(Element, 'ReschedulingPeriod', 0, false);
        if TempText <> '' then
            if Evaluate(TempDateFormula, TempText) then
                ItemWorksheetLine.Validate("Rescheduling Period", TempDateFormula);
        TempText := GetXmlText(Element, 'LotAccumulationPeriod', 0, false);
        if TempText <> '' then
            if Evaluate(TempDateFormula, TempText) then
                ItemWorksheetLine.Validate("Lot Accumulation Period", TempDateFormula);
        TempText := GetXmlText(Element, 'DampenerPeriod', 0, false);
        if TempText <> '' then
            if Evaluate(TempDateFormula, TempText) then
                ItemWorksheetLine.Validate("Dampener Period", TempDateFormula);
        TempText := GetXmlText(Element, 'DampenerQuantity', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Dampener Quantity", TempDec);
        TempText := GetXmlText(Element, 'OverflowLevel', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Overflow Level", TempDec);
        TempText := GetXmlText(Element, 'ServiceItemGroup', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Service Item Group", TempText);
        TempText := GetXmlText(Element, 'ItemTrackingCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Item Tracking Code", TempText);
        TempText := GetXmlText(Element, 'LotNos', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Lot Nos.", TempText);
        TempText := GetXmlText(Element, 'ExpirationCalculation', 0, false);
        if TempText <> '' then
            if Evaluate(TempDateFormula, TempText) then
                ItemWorksheetLine.Validate("Expiration Calculation", TempDateFormula);
        TempText := GetXmlText(Element, 'SpecialEquipmentCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Special Equipment Code", TempText);
        TempText := GetXmlText(Element, 'PutawayTemplateCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Put-away Template Code", TempText);
        TempText := GetXmlText(Element, 'PutawayUnitofMeasureCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Put-away Unit of Measure Code", TempText);
        TempText := GetXmlText(Element, 'PhysInvtCountingPeriodCode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Phys Invt Counting Period Code", TempText);
        TempText := GetXmlText(Element, 'UseCrossDocking', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Use Cross-Docking", 1)
                else
                    ItemWorksheetLine.Validate("Use Cross-Docking", 0);
        TempText := GetXmlText(Element, 'Groupsale', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Group sale", 1)
                else
                    ItemWorksheetLine.Validate("Group sale", 0);
        TempText := GetXmlText(Element, 'LabelBarcode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Label Barcode", TempText);
        TempText := GetXmlText(Element, 'ExplodeBOMauto', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Explode BOM auto", 1)
                else
                    ItemWorksheetLine.Validate("Explode BOM auto", 0);
        TempText := GetXmlText(Element, 'Guaranteevoucher', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Guarantee voucher", 1)
                else
                    ItemWorksheetLine.Validate("Guarantee voucher", 0);
        TempText := GetXmlText(Element, 'Cannoteditunitprice', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Cannot edit unit price", 1)
                else
                    ItemWorksheetLine.Validate("Cannot edit unit price", 0);
        TempText := GetXmlText(Element, 'Secondhandnumber', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Second-hand number", TempText);
        TempText := GetXmlText(Element, 'Condition', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate(Condition, TempInteger);
        TempText := GetXmlText(Element, 'Secondhand', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Second-hand", 1)
                else
                    ItemWorksheetLine.Validate("Second-hand", 0);
        TempText := GetXmlText(Element, 'GuaranteeIndex', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Guarantee Index", TempInteger);
        TempText := GetXmlText(Element, 'Insurrancecategory', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Insurrance category", TempText);
        TempText := GetXmlText(Element, 'ItemBrand', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Item Brand", TempText);
        TempText := GetXmlText(Element, 'TypeRetail', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Type Retail", TempText);
        TempText := GetXmlText(Element, 'NoPrintonReciept', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("No Print on Reciept", 1)
                else
                    ItemWorksheetLine.Validate("No Print on Reciept", 0);
        TempText := GetXmlText(Element, 'PrintTags', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Print Tags", TempText);
        TempText := GetXmlText(Element, 'ChangequantitybyPhotoorder', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Change quantity by Photoorder", 1)
                else
                    ItemWorksheetLine.Validate("Change quantity by Photoorder", 0);
        TempText := GetXmlText(Element, 'StdSalesQty', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Std. Sales Qty.", TempDec);
        TempText := GetXmlText(Element, 'BlockedonPos', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Blocked on Pos", 1)
                else
                    ItemWorksheetLine.Validate("Blocked on Pos", 0);
        TempText := GetXmlText(Element, 'TicketType', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Ticket Type", TempText);
        TempText := GetXmlText(Element, 'MagentoStatus', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Magento Status", TempInteger);
        TempText := GetXmlText(Element, 'Backorder', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate(Backorder, 1)
                else
                    ItemWorksheetLine.Validate(Backorder, 0);
        TempText := GetXmlText(Element, 'ProductNewFrom', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText) then
                if TempDate <> 0D then
                    ItemWorksheetLine.Validate("Product New From", TempDate);
        TempText := GetXmlText(Element, 'ProductNewTo', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText) then
                if TempDate <> 0D then
                    ItemWorksheetLine.Validate("Product New To", TempDate);
        TempText := GetXmlText(Element, 'AttributeSetID', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                if TempInteger <> 0 then
                    ItemWorksheetLine.Validate("Attribute Set ID", TempInteger);
        TempText := GetXmlText(Element, 'SpecialPrice', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Special Price", TempDec);
        TempText := GetXmlText(Element, 'SpecialPriceFrom', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText) then
                if TempDate <> 0D then
                    ItemWorksheetLine.Validate("Special Price From", TempDate);
        TempText := GetXmlText(Element, 'SpecialPriceTo', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText) then
                if TempDate <> 0D then
                    ItemWorksheetLine.Validate("Special Price To", TempDate);
        TempText := GetXmlText(Element, 'MagentoBrand', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Magento Brand", TempText);
        TempText := GetXmlText(Element, 'DisplayOnly', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Display Only", 1)
                else
                    ItemWorksheetLine.Validate("Display Only", 0);
        TempText := GetXmlText(Element, 'MagentoItem', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate("Magento Item", 1)
                else
                    ItemWorksheetLine.Validate("Magento Item", 0);
        TempText := GetXmlText(Element, 'MagentoName', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Magento Name", TempText);
        TempText := GetXmlText(Element, 'SeoLink', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Seo Link", TempText);
        TempText := GetXmlText(Element, 'MetaTitle', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Meta Title", TempText);
        TempText := GetXmlText(Element, 'MetaDescription', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Meta Description", TempText);
        TempText := GetXmlText(Element, 'FeaturedFrom', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText) then
                if TempDate <> 0D then
                    ItemWorksheetLine.Validate("Featured From", TempDate);
        TempText := GetXmlText(Element, 'FeaturedTo', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText) then
                if TempDate <> 0D then
                    ItemWorksheetLine.Validate("Featured To", TempDate);
        TempText := GetXmlText(Element, 'RoutingNo', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Routing No.", TempText);
        TempText := GetXmlText(Element, 'ProductionBOMNo', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Production BOM No.", TempText);
        TempText := GetXmlText(Element, 'OverheadRate', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText) then
                if TempDec <> 0 then
                    ItemWorksheetLine.Validate("Overhead Rate", TempDec);
        TempText := GetXmlText(Element, 'OrderTrackingPolicy', 0, false);
        if TempText <> '' then
            if Evaluate(TempInteger, TempText) then
                ItemWorksheetLine.Validate("Order Tracking Policy", TempInteger);
        TempText := GetXmlText(Element, 'Critical', 0, false);
        if TempText <> '' then
            if Evaluate(TempBool, TempText) then
                if TempBool then
                    ItemWorksheetLine.Validate(Critical, 1)
                else
                    ItemWorksheetLine.Validate(Critical, 0);
        TempText := GetXmlText(Element, 'CommonItemNo', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Common Item No.", TempText);
        TempText := GetXmlText(Element, 'TariffNo', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Tariff No.", TempText);
        ItemWshtImpExpMgt.SetImportActionWorksheetLine(ItemWorksheetLine);
        TempText := GetXmlText(Element, 'InternalBarcode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Internal Bar Code", TempText);
        TempText := GetXmlText(Element, 'VendorsBarcode', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Vendors Bar Code", TempText);
        TempText := GetXmlText(Element, 'SalesPriceStartDate', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText, 9) then
                ItemWorksheetLine.Validate("Sales Price Start Date", TempDate);
        TempText := GetXmlText(Element, 'PurchasePriceStartDate', 0, false);
        if TempText <> '' then
            if Evaluate(TempDate, TempText, 9) then
                ItemWorksheetLine.Validate("Purchase Price Start Date", TempDate);
        TempText := GetXmlText(Element, 'CustomText1', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Custom Text 1", TempText);
        TempText := GetXmlText(Element, 'CustomText2', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Custom Text 2", TempText);
        TempText := GetXmlText(Element, 'CustomText3', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Custom Text 3", TempText);
        TempText := GetXmlText(Element, 'CustomText4', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Custom Text 4", TempText);
        TempText := GetXmlText(Element, 'CustomText5', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Custom Text 5", TempText);
        TempText := GetXmlText(Element, 'CustomPrice1', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText, 9) then
                ItemWorksheetLine.Validate("Custom Price 1", TempDec);
        TempText := GetXmlText(Element, 'CustomPrice2', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText, 9) then
                ItemWorksheetLine.Validate("Custom Price 2", TempDec);
        TempText := GetXmlText(Element, 'CustomPrice3', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText, 9) then
                ItemWorksheetLine.Validate("Custom Price 3", TempDec);
        TempText := GetXmlText(Element, 'CustomPrice4', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText, 9) then
                ItemWorksheetLine.Validate("Custom Price 4", TempDec);
        TempText := GetXmlText(Element, 'CustomPrice5', 0, false);
        if TempText <> '' then
            if Evaluate(TempDec, TempText, 9) then
                ItemWorksheetLine.Validate("Custom Price 5", TempDec);
        TempText := GetXmlText(Element, 'BaseUnitOfMeasure', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Base Unit of Measure", TempText);
        TempText := GetXmlText(Element, 'SalesUnitOfMeasure', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Sales Unit of Measure", TempText);
        TempText := GetXmlText(Element, 'PurchUnitOfMeasure', 0, false);
        if TempText <> '' then
            ItemWorksheetLine.Validate("Purch. Unit of Measure", TempText);
        ItemWorksheetLine.Modify(true);
        ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetLine(ItemWorksheetLine);
        ItemWorksheetVariantLine.Init();
        ItemWorksheetVariantLine.Validate("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetVariantLine.Validate("Worksheet Name", ItemWorksheetLine."Worksheet Name");
        ItemWorksheetVariantLine.Validate("Worksheet Line No.", ItemWorksheetLine."Line No.");
        ItemWorksheetVariantLine.Validate("Line No.", 10000);
        ItemWorksheetVariantLine.Insert(true);
        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew;
        ItemWorksheetVariantLine.Validate("Item No.", ItemWorksheetLine."Item No.");
        ItemWorksheetVariantLine.Validate("Sales Price", ItemWorksheetLine."Sales Price");
        ItemWorksheetVariantLine.Validate("Direct Unit Cost", ItemWorksheetLine."Direct Unit Cost");
        TempText := GetXmlText(Element, 'Variety1', 0, false);
        if TempText <> '' then
            ItemWorksheetVariantLine."Variety 1 Value" := CopyStr(TempText, 1, MaxStrLen(ItemWorksheetVariantLine."Variety 1 Value"));
        TempText := GetXmlText(Element, 'Variety2', 0, false);
        if TempText <> '' then
            ItemWorksheetVariantLine."Variety 2 Value" := CopyStr(TempText, 1, MaxStrLen(ItemWorksheetVariantLine."Variety 2 Value"));
        TempText := GetXmlText(Element, 'Variety3', 0, false);
        if TempText <> '' then
            ItemWorksheetVariantLine."Variety 3 Value" := CopyStr(TempText, 1, MaxStrLen(ItemWorksheetVariantLine."Variety 3 Value"));
        TempText := GetXmlText(Element, 'Variety4', 0, false);
        if TempText <> '' then
            ItemWorksheetVariantLine."Variety 4 Value" := CopyStr(TempText, 1, MaxStrLen(ItemWorksheetVariantLine."Variety 4 Value"));
        ItemWorksheetVariantLine.Validate("Existing Item No.", ItemWorksheetLine."Existing Item No.");
        ItemWorksheetVariantLine.Validate("Variety 1 Value");
        ItemWorksheetVariantLine.Validate("Variety 2 Value");
        ItemWorksheetVariantLine.Validate("Variety 3 Value");
        ItemWorksheetVariantLine.Validate("Variety 4 Value");
        if (ItemWorksheetLine."Existing Item No." = '') then begin
            if (ItemWorksheetVariantLine."Internal Bar Code" = '') then
                ItemWorksheetVariantLine."Internal Bar Code" := CopyStr(ItemWorksheetLine."Internal Bar Code", 1, MaxStrLen(ItemWorksheetVariantLine."Internal Bar Code"));
            if (ItemWorksheetVariantLine."Vendors Bar Code" = '') then
                ItemWorksheetVariantLine."Vendors Bar Code" := CopyStr(ItemWorksheetLine."Vendors Bar Code", 1, MaxStrLen(ItemWorksheetVariantLine."Vendors Bar Code"));
        end;
        ItemWshtImpExpMgt.SetImportActionWorksheetVariantLine(ItemWorksheetLine, ActionIfVariantUnknown, ActionIfVarietyUnknown, ItemWorksheetVariantLine);
        ItemWorksheetVariantLine.Modify(true);
        ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
        ItemWorksheetLine.CleanupObsoleteLines();
        TempText := UpperCase(GetXmlText(Element, 'ValidateLine', MaxStrLen(TempText), false));
        if TempText in ['YES', '1', 'TRUE'] then
            ItemWkshCheckLine.RunCheck(ItemWorksheetLine, false, false);
    end;

    local procedure ReadWkshLineAttribute(ItemWorksheetLine: Record "NPR Item Worksheet Line"; Element: XmlElement)
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "Code": Code[20];
        Value: Text[250];
    begin
        if Element.IsEmpty() then
            exit;
        if Element.Name <> 'Attribute' then
            exit;

        Code := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'Code', true), 1, MaxStrLen(Code));
        if Code = '' then
            exit;

        Value := CopyStr(Element.InnerText, 1, MaxStrLen(Value));

        NPRAttrManagement.GetAttributeKey(
            DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine."Worksheet Template Name",
            ItemWorksheetLine."Line No.", 0, ItemWorksheetLine."Worksheet Name",
            0, AttributeKey, false);
        if not NPRAttrManagement.SetAttributeValue(AttributeKey."Attribute Set ID", Code, Value, AttributeValue) then
            exit;

        if AttributeValue."Attribute Set ID" <> 0 then begin
            AttributeValue.Modify();
            exit;
        end;

        NPRAttrManagement.GetAttributeKey(
            DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine."Worksheet Template Name",
            ItemWorksheetLine."Line No.", 0, ItemWorksheetLine."Worksheet Name",
            0, AttributeKey, true);
        AttributeValue."Attribute Set ID" := AttributeKey."Attribute Set ID";
        AttributeValue.Insert();
    end;

    local procedure ReadWkshLineAttributes(ItemWorksheetLine: Record "NPR Item Worksheet Line"; Element: XmlElement)
    var
        Element2: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if Element.IsEmpty() then
            exit;
        if Element.Name <> 'Attributes' then
            exit;

        if not Element.SelectNodes('Attribute[@Code!=""]', NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element2 := Node.AsXmlElement();
            ReadWkshLineAttribute(ItemWorksheetLine, Element2);
        end;
    end;

    local procedure SetImportParameters(Element: XmlElement)
    var
        TempText: Text;
    begin
        TempText := GetXmlText(Element, 'importoptiontxt', MaxStrLen(TempText), false);

        if not Evaluate(ImportOption, TempText) then
            ImportOption := ImportOption::"Add lines";

        TempText := GetXmlText(Element, 'combinevarietiestxt', MaxStrLen(TempText), false);
        if not Evaluate(CombineVarieties, TempText) then
            CombineVarieties := false;

        TempText := GetXmlText(Element, 'actionifvariantunknowntxt', MaxStrLen(TempText), false);
        if not Evaluate(ActionIfVariantUnknown, TempText) then
            ActionIfVariantUnknown := ActionIfVariantUnknown::Create;

        TempText := GetXmlText(Element, 'actionifvarietyunknowntxt', MaxStrLen(TempText), false);
        if not Evaluate(ActionIfVarietyUnknown, TempText) then
            ActionIfVarietyUnknown := ActionIfVarietyUnknown::Create;
    end;

    local procedure LoadDoc(var Rec: Record "NPR Nc Import Entry"; var Document: XmlDocument): Boolean
    var
        XmlDomMgt: Codeunit "XML DOM Management";
        InStr: InStream;
        DocumentSource: Text;
    begin
        Rec.CalcFields("Document Source");
        if not Rec."Document Source".HasValue() then
            exit(false);
        Rec."Document Source".CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, Document);
        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);
        exit(true);
    end;

    procedure GetXmlText(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text
    var
        Element2: XmlElement;
        Node: XmlNode;
    begin
        if Element.IsEmpty() then begin
            if Required then
                Error(MissingXmlElementErr, NodePath, '');
            exit('');
        end;

        if not Element.SelectSingleNode(NodePath, Node) then
            exit('');
        Element2 := Node.AsXmlElement();
        if Element2.IsEmpty then begin
            if Required then
                Error(MissingXmlElementErr, NodePath, Element.Name);
            exit('');
        end;

        if MaxLength > 0 then
            exit(CopyStr(Element2.InnerText, 1, MaxLength));

        exit(Element2.InnerText);
    end;

    var
        LastItemWorksheetLine: Record "NPR Item Worksheet Line";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        CombineVarieties: Boolean;
        Initialized: Boolean;
        ImportOption: Option "Replace lines","Add lines";
        ActionIfVariantUnknown: Option Skip,Create;
        ActionIfVarietyUnknown: Option Skip,Create;
        MissingCaseErr: Label 'No handler for %1 [%2].', Comment = '%1 = Import type, %2 = Function name';
        MissingXmlElementErr: Label 'Xml element %1 is missing in %2', Comment = '%1 = Node path, %2 = Xml element name';


}

