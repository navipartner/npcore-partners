codeunit 6060049 "Item Wksht. WebService Mgr"
{
    // NPR5.22/BR  /20160324  CASE 182391 Object Created
    // NPR5.22/BR  /20160325  CASE 237658 Implementation of processing
    // NPR5.23/BR  /20160504  CASE 237658 Changed a Attributes to elements, changed case of tags
    // NPR5.23/BR  /20160525  CASE 242498 Call Event Publisher OnAfterImportWorksheet(Variant)Line
    // NPR5.23.03/MHA /20160726  CASE 242557 NaviConnect references updated according to NC2.00
    // NPR5.25/BR  /20160704  CASE 246088 Added new fields to the import
    // NPR5.27/BR  /20161013  CASE 253672 Added fields InternalBarcode and VendorsBarcode
    // NPR5.27/BR  /20161021  CASE 253672 Added cleanup function
    // NPR5.28/BR  /20161123  CASE 259200 Restruture Events to avoid memory leak
    // NPR5.28/BR  /20161206  CASE 260359 Fix field mapping of InternalBarcode  and Vendorsbarcode
    // NPR5.33/BR  /20170607  CASE 279610 Deleted fields: Properties, Item Sales Prize, Program No., Assortment, Auto, Out of Stock Print, Print Quantity, Labels per item, ISBN, Label Date, Open quarry unit cost, Hand Out Item No., Model, Basis Number, It
    // NPR5.38/BR  /20171113  CASE 296276 Added field "Description 2"
    // NPR5.38/BR  /20171124  CASE 297587 Added support for fields Sales Price Start Date and Purchase Price Start Date
    // NPR5.39/BR  /20180206  CASE 304421 Do not delete different Variants, set barcodes to Variants
    // NPR5.39/BR  /20180209  CASE 304980 Added new fields
    // NPR5.43/MHA /20180530  CASE 312958 Added functions to support import of NPR Attributes independent of Shortcut Id's; ReadWkshLineAttributes(),ReadWkshLineAttribute()
    // NPR5.43/MHA /20180619  CASE 318871 Changed import of <RecommendedRetailPrice> from "Direct Unit Cost" to "Recommended Retail Price" in ReadItemWorksheetLine()

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
        ImportType: Record "Nc Import Type";
        FunctionName: Text[100];
    begin

        if LoadXmlDoc (XmlDoc) then begin
          FunctionName := GetWebserviceFunction ("Import Type");
          case FunctionName of
            'CreateItemWorksheetLine' : CreateItemWorksheetLines (XmlDoc,  "Entry No.", "Document ID");
            else
              Error (MISSING_CASE, "Import Type", FunctionName);
          end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        ItemWshtImpExpMgt: Codeunit "Item Wsht. Imp. Exp. Mgt.";
        Initialized: Boolean;
        ITEM_NOT_FOUND: Label 'The sales item specified in external_id %1, was not found.';
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        ImportOption: Option "Replace lines","Add lines";
        CombineVarieties: Boolean;
        ActionIfVariantUnknown: Option Skip,Create;
        ActionIfVarietyUnknown: Option Skip,Create;
        VENDOR_NOT_FOUND: Label 'The Vendor %1 could not be found in the database.';
        LastItemWorksheetLine: Record "Item Worksheet Line";

    local procedure CreateItemWorksheetLines(XmlDoc: DotNet npNetXmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
        Token: Text[50];
    begin
        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        //IF NOT NpXmlDomMgt.FindNodes(XmlElement,'ItemWorksheetLines',XmlNodeList) THEN
        //  EXIT;


        if not NpXmlDomMgt.FindNodes(XmlElement,'createitemworksheetline',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'itemWorksheetlineimport',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'InsertItemWorksheetLine',XmlNodeList) then
          exit;

        //FOR i := 0 TO XmlNodeList.Count - 1 DO BEGIN
        //  XmlElement := XmlNodeList.ItemOf(i);
        //  ImportTicketReservation (XmlElement, Token, DocumentID);
        //END;

        XmlElement := XmlNodeList.ItemOf(0);

        SetImportParameters (XmlElement, Token) ;

        //Token := COPYSTR (NpXmlDomMgt.GetXmlAttributeText(XmlElement,'ticket_token',FALSE), 1, MAXSTRLEN (Token));
        //IF (Token = '') THEN
        //  Token := DocumentID;

        //IF TicketRequestManager.TokenRequestExists (Token) THEN
        //  TicketRequestManager.DeleteReservationRequest (Token, TRUE);

        if not NpXmlDomMgt.FindNodes(XmlElement,'ItemWorksheetLine',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          CreateItemWorksheetLine (XmlElement, Token, DocumentID);
        end;

        //PostProcessing;

        Commit;
    end;

    local procedure CreateItemWorksheetLine(XmlElement: DotNet npNetXmlElement;Token: Text[100];DocumentID: Text[100]) Imported: Boolean
    var
        ItemWorksheetLine: Record "Item Worksheet Line";
    begin

        if IsNull(XmlElement) then
          exit(false);

        ItemWorksheetLine.Init ();

        ReadItemWorksheetLine (XmlElement, Token, ItemWorksheetLine);
        InsertWorksheetline (ItemWorksheetLine);

        exit(true);
    end;

    local procedure "---Database"()
    begin
    end;

    local procedure InsertWorksheetline(var ItemWorksheetLine: Record "Item Worksheet Line"): Boolean
    var
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        ItemWorksheetLine.Init ();
    end;

    local procedure ReadItemWorksheetLine(XmlElement: DotNet npNetXmlElement;Token: Text[100];var ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        VarietyValue: Record "Variety Value";
        ItemWkshCheckLine: Codeunit "Item Wsht.-Check Line";
        XmlElement2: DotNet npNetXmlElement;
        VendorVATRegNo: Text;
        TempText: Text;
        TempDec: Decimal;
        TempBool: Boolean;
        TempInteger: Integer;
        TempDateFormula: DateFormula;
        TempDate: Date;
    begin

        Initialize;

        Clear (ItemWorksheetLine);
        ItemWorksheetLine.Init;
        ItemWorksheetLine."Created Date Time" := CurrentDateTime ();
        ItemWorksheetLine."Vendor No." := NpXmlDomMgt.GetXmlText (XmlElement, 'VendorNo', MaxStrLen (ItemWorksheetLine."Vendor No."),false);

        VendorVATRegNo := NpXmlDomMgt.GetXmlText (XmlElement, 'VATRegno', 0, false);
        ItemWorksheetLine."Item No." := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemNo', MaxStrLen (ItemWorksheetLine."Item No."),false);

        FindWorksheetLine (ItemWorksheetLine."Vendor No.",VendorVATRegNo,ItemWorksheetLine."Item No.",ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No.");

        ItemWorksheetLine.SetUpNewLine(LastItemWorksheetLine);
        ItemWorksheetLine.Insert(true);
        ItemWorksheetLine.Action := ItemWorksheetLine.Action :: CreateNew;

        ItemWorksheetLine.Validate("Item No.",NpXmlDomMgt.GetXmlText (XmlElement, 'ItemNo', MaxStrLen (ItemWorksheetLine."Item No."), false));
        ItemWorksheetLine.Validate("Vendor Item No.", NpXmlDomMgt.GetXmlText (XmlElement, 'VendorItemNo', MaxStrLen (ItemWorksheetLine."Vendor Item No."), true));

        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemGroup', MaxStrLen (ItemWorksheetLine."Item Group") , false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Item Group",TempText);
        ItemWorksheetLine.Validate("Vendor No.",NpXmlDomMgt.GetXmlText (XmlElement, 'VendorNo', MaxStrLen (ItemWorksheetLine."Vendor No."), false));

        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Description', MaxStrLen (ItemWorksheetLine.Description), true);
        if TempText <> '' then
          ItemWorksheetLine.Validate(Description,TempText);

        //-NPR5.38 [296276]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Description2', MaxStrLen (ItemWorksheetLine."Description 2"), true);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Description 2",TempText);
        //+NPR5.38 [296276]

        if Evaluate (TempDec, NpXmlDomMgt.GetXmlText (XmlElement, 'DirectUnitCost', 0, false)) then
          ItemWorksheetLine.Validate("Direct Unit Cost",TempDec);
        if Evaluate (TempDec, NpXmlDomMgt.GetXmlText (XmlElement, 'UnitPrice', 0,  false)) then
          ItemWorksheetLine.Validate("Sales Price",TempDec);

        ItemWorksheetLine."Item Category Code" := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemCategory',MaxStrLen (ItemWorksheetLine."Item Category Code"), false);
        ItemWorksheetLine."Product Group Code" := NpXmlDomMgt.GetXmlText (XmlElement, 'ProductGroup', MaxStrLen (ItemWorksheetLine."Product Group Code"), false);
        //-NPR5.25 [246088]
        //ItemWorksheetLine."Tariff No." := NpXmlDomMgt.GetXmlText (XmlElement, 'TariffNo', MAXSTRLEN (ItemWorksheetLine."Tariff No."), FALSE);
        //+NPR5.25 [246088]

        //-NPR5.23 [NPR5.23]
        //ItemWorksheetLine."Sales Price Currency Code" := NpXmlDomMgt.GetXmlText (XmlElement, 'SalesPriceCurrencyCode', MAXSTRLEN (ItemWorksheetLine."Sales Price Currency Code"), FALSE);
        //ItemWorksheetLine."Purchase Price Currency Code" := NpXmlDomMgt.GetXmlText (XmlElement, 'PurchasePriceCurrencyCode', MAXSTRLEN (ItemWorksheetLine."Purchase Price Currency Code"), FALSE);
        ItemWorksheetLine.Validate("Sales Price Currency Code",NpXmlDomMgt.GetXmlText (XmlElement, 'SalesPriceCurrencyCode', MaxStrLen (ItemWorksheetLine."Sales Price Currency Code"), false));
        ItemWorksheetLine.Validate("Purchase Price Currency Code",NpXmlDomMgt.GetXmlText (XmlElement, 'PurchasePriceCurrencyCode', MaxStrLen (ItemWorksheetLine."Purchase Price Currency Code"), false));
        //+NPR5.23 [NPR5.23]

        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'VarietyGroup', MaxStrLen (ItemWorksheetLine."Variety Group"), false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Variety Group",TempText);

        if Evaluate (TempDec, NpXmlDomMgt.GetXmlText (XmlElement, 'RecommendedRetailPrice', 0, false)) then
          //-NPR5.43 [318871]
          //ItemWorksheetLine.VALIDATE("Direct Unit Cost",TempDec);
          ItemWorksheetLine.Validate("Recommended Retail Price",TempDec);
          //+NPR5.43 [318871]

        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute1', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 1, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute2', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 2, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute3', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 3, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute4', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 4, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute5', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 5, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute6', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 6, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute7', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 7, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute8', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 8, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute9', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 9, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Attribute10', 0, false);
        if TempText <> '' then
          NPRAttrManagement.SetWorksheetLineAttributeValue (DATABASE::"Item Worksheet Line", 10, ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , TempText);

        //-NPR5.43 [312958]
        if NpXmlDomMgt.FindNode(XmlElement,'Attributes',XmlElement2) then
          ReadWkshLineAttributes(ItemWorksheetLine,XmlElement2);
        //+NPR5.43 [312958]

        //-NPR5.25 [246088]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'No2', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("No. 2",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Type', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate(Type,TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ShelfNo', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Shelf No.",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemDiscGroup', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Item Disc. Group",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'AllowInvoiceDisc', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Allow Invoice Disc.",1)
            else
              ItemWorksheetLine.Validate("Allow Invoice Disc.",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'StatisticsGroup', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
            if TempInteger <> 0 then
              ItemWorksheetLine.Validate("Statistics Group",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CommissionGroup', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
            if TempInteger <> 0 then
              ItemWorksheetLine.Validate("Commission Group",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PriceProfitCalculation', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Price/Profit Calculation",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Profit', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Profit %",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'LeadTimeCalculation', 0, false);
        if TempText <> '' then
          if Evaluate(TempDateFormula,TempText) then
            ItemWorksheetLine.Validate("Lead Time Calculation",TempDateFormula);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ReorderPoint', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Reorder Point",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MaximumInventory', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Maximum Inventory",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ReorderQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Reorder Quantity",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'UnitListPrice', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Unit List Price",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DutyDue', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Duty Due %",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DutyCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Duty Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'UnitsperParcel', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Units per Parcel",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'UnitVolume', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Unit Volume",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Durability', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate(Durability,TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'FreightType', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Freight Type",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DutyUnitConversion', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Duty Unit Conversion",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CountryRegionPurchasedCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Country/Region Purchased Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'BudgetQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Budget Quantity",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'BudgetedAmount', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Budgeted Amount",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'BudgetProfit', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Budget Profit",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Blocked', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate(Blocked,1)
            else
              ItemWorksheetLine.Validate(Blocked,0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PriceIncludesVAT', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Price Includes VAT",1)
            else
              ItemWorksheetLine.Validate("Price Includes VAT",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CountryRegionofOriginCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Country/Region of Origin Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'AutomaticExtTexts', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Automatic Ext. Texts",1)
            else
              ItemWorksheetLine.Validate("Automatic Ext. Texts",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Reserve', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate(Reserve,TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'StockoutWarning', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Stockout Warning",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PreventNegativeInventory', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Prevent Negative Inventory",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'AssemblyPolicy', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Assembly Policy",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'GTIN', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate(GTIN,TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'LotSize', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Lot Size",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SerialNos', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Serial Nos.",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Scrap', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Scrap %",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'InventoryValueZero', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Inventory Value Zero",1)
            else
              ItemWorksheetLine.Validate("Inventory Value Zero",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DiscreteOrderQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
            if TempInteger <> 0 then
              ItemWorksheetLine.Validate("Discrete Order Quantity",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MinimumOrderQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Minimum Order Quantity",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MaximumOrderQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Maximum Order Quantity",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SafetyStockQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Safety Stock Quantity",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'OrderMultiple', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Order Multiple",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SafetyLeadTime', 0, false);
        if TempText <> '' then
          if Evaluate(TempDateFormula,TempText) then
            ItemWorksheetLine.Validate("Safety Lead Time",TempDateFormula);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'FlushingMethod', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Flushing Method",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ReplenishmentSystem', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Replenishment System",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ReorderingPolicy', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Reordering Policy",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'IncludeInventory', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Include Inventory",1)
            else
              ItemWorksheetLine.Validate("Include Inventory",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ManufacturingPolicy', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Manufacturing Policy",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ReschedulingPeriod', 0, false);
        if TempText <> '' then
          if Evaluate(TempDateFormula,TempText) then
            ItemWorksheetLine.Validate("Rescheduling Period",TempDateFormula);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'LotAccumulationPeriod', 0, false);
        if TempText <> '' then
          if Evaluate(TempDateFormula,TempText) then
            ItemWorksheetLine.Validate("Lot Accumulation Period",TempDateFormula);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DampenerPeriod', 0, false);
        if TempText <> '' then
          if Evaluate(TempDateFormula,TempText) then
            ItemWorksheetLine.Validate("Dampener Period",TempDateFormula);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DampenerQuantity', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Dampener Quantity",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'OverflowLevel', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Overflow Level",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ServiceItemGroup', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Service Item Group",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemTrackingCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Item Tracking Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'LotNos', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Lot Nos.",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ExpirationCalculation', 0, false);
        if TempText <> '' then
          if Evaluate(TempDateFormula,TempText) then
            ItemWorksheetLine.Validate("Expiration Calculation",TempDateFormula);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SpecialEquipmentCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Special Equipment Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PutawayTemplateCode', 0, false);
        if TempText <> '' then
        ItemWorksheetLine.Validate("Put-away Template Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PutawayUnitofMeasureCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Put-away Unit of Measure Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PhysInvtCountingPeriodCode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Phys Invt Counting Period Code",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'UseCrossDocking', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Use Cross-Docking",1)
            else
              ItemWorksheetLine.Validate("Use Cross-Docking",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Groupsale', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Group sale",1)
            else
              ItemWorksheetLine.Validate("Group sale",0);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Properties', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE(Properties,TempText);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemSalesPrize', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempDec,TempText) THEN
        //    IF TempDec <> 0 THEN
        //      ItemWorksheetLine.VALIDATE("Item Sales Prize",TempDec);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ProgramNo', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE("Program No.",TempText);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Season', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate(Season,TempText);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Assortment', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE(Assortment,TempText);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'LabelBarcode', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Label Barcode",TempText);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Auto', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempBool,TempText) THEN
        //    IF TempBool THEN
        //      ItemWorksheetLine.VALIDATE(Auto,1)
        //    ELSE
        //      ItemWorksheetLine.VALIDATE(Auto,0);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Outofstock', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempInteger,TempText) THEN
        //      ItemWorksheetLine.VALIDATE("Out of stock",TempInteger);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Printquantity', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempInteger,TempText) THEN
        //    IF TempInteger <> 0 THEN
        //      ItemWorksheetLine.VALIDATE("Print quantity",TempInteger);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Labelsperitem', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempInteger,TempText) THEN
        //    IF TempInteger <> 0 THEN
        //      ItemWorksheetLine.VALIDATE("Labels per item",TempInteger);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ExplodeBOMauto', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Explode BOM auto",1)
            else
              ItemWorksheetLine.Validate("Explode BOM auto",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Guaranteevoucher', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Guarantee voucher",1)
            else
              ItemWorksheetLine.Validate("Guarantee voucher",0);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ISBN', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempBool,TempText) THEN
        //    IF TempBool THEN
        //      ItemWorksheetLine.VALIDATE(ISBN,1)
        //    ELSE
        //      ItemWorksheetLine.VALIDATE(ISBN,0);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Cannoteditunitprice', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Cannot edit unit price",1)
            else
              ItemWorksheetLine.Validate("Cannot edit unit price",0);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'LabelDate', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempDate,TempText) THEN
        //    IF TempDate <> 0D THEN
        //      ItemWorksheetLine.VALIDATE("Label Date",TempDate);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Openquarryunitcost', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempDec,TempText) THEN
        //    IF TempDec <> 0 THEN
        //      ItemWorksheetLine.VALIDATE("Open quarry unit cost",TempDec);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Secondhandnumber', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Second-hand number",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Condition', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate(Condition,TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Secondhand', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Second-hand",1)
            else
              ItemWorksheetLine.Validate("Second-hand",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'GuaranteeIndex', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Guarantee Index",TempInteger);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'HandOutItemNo', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE("Hand Out Item No.",TempText);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Insurrancecategory', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Insurrance category",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemBrand', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Item Brand",TempText);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Model', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE(Model,TempText);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'TypeRetail', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Type Retail",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'NoPrintonReciept', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("No Print on Reciept",1)
            else
              ItemWorksheetLine.Validate("No Print on Reciept",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PrintTags', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Print Tags",TempText);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'BasisNumber', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE("Basis Number",TempText);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ChangequantitybyPhotoorder', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Change quantity by Photoorder",1)
            else
              ItemWorksheetLine.Validate("Change quantity by Photoorder",0);
        //-NPR5.33 [279610]
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PictureExtention', 0, FALSE);
        //IF TempText <> '' THEN
        //  ItemWorksheetLine.VALIDATE("Picture Extention",TempText);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemType', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempInteger,TempText) THEN
        //      ItemWorksheetLine.VALIDATE("Item Type",TempInteger);
        //TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ItemWeightitemref', 0, FALSE);
        //IF TempText <> '' THEN
        //  IF EVALUATE(TempInteger,TempText) THEN
        //    IF TempInteger <> 0 THEN
        //      ItemWorksheetLine.VALIDATE("Item - Weight item ref.",TempInteger);
        //+NPR5.33 [279610]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'StdSalesQty', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Std. Sales Qty.",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'BlockedonPos', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Blocked on Pos",1)
            else
              ItemWorksheetLine.Validate("Blocked on Pos",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'TicketType', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Ticket Type",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MagentoStatus', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Magento Status",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Backorder', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate(Backorder,1)
            else
              ItemWorksheetLine.Validate(Backorder,0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ProductNewFrom', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText) then
            if TempDate <> 0D then
              ItemWorksheetLine.Validate("Product New From",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ProductNewTo', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText) then
            if TempDate <> 0D then
              ItemWorksheetLine.Validate("Product New To",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'AttributeSetID', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
            if TempInteger <> 0 then
              ItemWorksheetLine.Validate("Attribute Set ID",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SpecialPrice', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Special Price",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SpecialPriceFrom', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText) then
            if TempDate <> 0D then
              ItemWorksheetLine.Validate("Special Price From",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SpecialPriceTo', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText) then
            if TempDate <> 0D then
              ItemWorksheetLine.Validate("Special Price To",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MagentoBrand', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Magento Brand",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'DisplayOnly', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Display Only",1)
            else
              ItemWorksheetLine.Validate("Display Only",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MagentoItem', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate("Magento Item",1)
            else
              ItemWorksheetLine.Validate("Magento Item",0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MagentoName', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Magento Name",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SeoLink', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Seo Link",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MetaTitle', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Meta Title",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'MetaDescription', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Meta Description",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'FeaturedFrom', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText) then
            if TempDate <> 0D then
              ItemWorksheetLine.Validate("Featured From",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'FeaturedTo', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText) then
            if TempDate <> 0D then
              ItemWorksheetLine.Validate("Featured To",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'RoutingNo', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Routing No.",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'ProductionBOMNo', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Production BOM No.",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'OverheadRate', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText) then
            if TempDec <> 0 then
              ItemWorksheetLine.Validate("Overhead Rate",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'OrderTrackingPolicy', 0, false);
        if TempText <> '' then
          if Evaluate(TempInteger,TempText) then
              ItemWorksheetLine.Validate("Order Tracking Policy",TempInteger);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Critical', 0, false);
        if TempText <> '' then
          if Evaluate(TempBool,TempText) then
            if TempBool then
              ItemWorksheetLine.Validate(Critical,1)
            else
              ItemWorksheetLine.Validate(Critical,0);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CommonItemNo', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Common Item No.",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'TariffNo', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Tariff No.",TempText);
        //-NPR5.25 [246088]

        ItemWshtImpExpMgt.SetImportActionWorksheetLine(ItemWorksheetLine);

        //-NPR5.27 [253672]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'InternalBarcode', 0, false);
        if TempText <> '' then
          //-NPR5.28 [260359]
          //ItemWorksheetLine.VALIDATE("Insurrance category",TempText);
          ItemWorksheetLine.Validate("Internal Bar Code",TempText);
          //+NPR5.28 [260359]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'VendorsBarcode', 0, false);
        if TempText <> '' then
          //-NPR5.28 [260359]
          //ItemWorksheetLine.VALIDATE("Item Brand",TempText);
          ItemWorksheetLine.Validate("Vendors Bar Code",TempText);
          //+NPR5.28 [260359]
        //+NPR5.27 [253672]
        //-NPR5.38 [297587]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SalesPriceStartDate', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText,9) then
            ItemWorksheetLine.Validate("Sales Price Start Date",TempDate);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PurchasePriceStartDate', 0, false);
        if TempText <> '' then
          if Evaluate(TempDate,TempText,9) then
            ItemWorksheetLine.Validate("Purchase Price Start Date",TempDate);
        //+NPR5.38 [297587]


        //-NPR5.39 [304980]
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomText1', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Custom Text 1",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomText2', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Custom Text 2",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomText3', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Custom Text 3",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomText4', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Custom Text 4",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomText5', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Custom Text 5",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomPrice1', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText,9) then
            ItemWorksheetLine.Validate("Custom Price 1",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomPrice2', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText,9) then
            ItemWorksheetLine.Validate("Custom Price 2",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomPrice3', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText,9) then
            ItemWorksheetLine.Validate("Custom Price 3",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomPrice4', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText,9) then
            ItemWorksheetLine.Validate("Custom Price 4",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'CustomPrice5', 0, false);
        if TempText <> '' then
          if Evaluate(TempDec,TempText,9) then
            ItemWorksheetLine.Validate("Custom Price 5",TempDec);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'BaseUnitOfMeasure', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Base Unit of Measure",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'SalesUnitOfMeasure', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Sales Unit of Measure",TempText);
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'PurchUnitOfMeasure', 0, false);
        if TempText <> '' then
          ItemWorksheetLine.Validate("Purch. Unit of Measure",TempText);
        //+NPR5.39 [304980]

        ItemWorksheetLine.Modify(true);

        //-NPR5.27 [253672]
        //-NPR5.39 [304421]
        //ItemWorksheetLine.CleanupObsoleteLines;
        //+NPR5.39 [304421]
        //-NPR5.27 [253672]

        //-NPR5.23 [242498]
        //-NPR5.28 [259200]
        //ItemWshtImpExpMgt.OnAfterImportWorksheetLine(ItemWorksheetLine);
        ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetLine(ItemWorksheetLine);
        //+NPR5.28 [259200]
        //+NPR5.23 [242498]

        with ItemWorksheetVariantLine do begin
          Init;
          Validate("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
          Validate("Worksheet Name",ItemWorksheetLine."Worksheet Name");
          Validate("Worksheet Line No.",ItemWorksheetLine."Line No.");
          Validate("Line No.",10000);
          Insert(true);
          Action := Action :: CreateNew;
          Validate("Item No.",ItemWorksheetLine."Item No.");
          Validate("Sales Price",ItemWorksheetLine."Sales Price");
          Validate("Direct Unit Cost",ItemWorksheetLine."Direct Unit Cost");
          TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Variety1', 0, false);
          if TempText <> '' then
            "Variety 1 Value" := TempText;
          TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Variety2', 0, false);
          if TempText <> '' then
            "Variety 2 Value" := TempText;
          TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Variety3', 0, false);
          if TempText <> '' then
            "Variety 3 Value" := TempText;
          TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'Variety4', 0, false);
          if TempText <> '' then
            "Variety 4 Value" := TempText;
          Validate("Existing Item No.",ItemWorksheetLine."Existing Item No.");
          Validate("Variety 1 Value");
          Validate("Variety 2 Value");
          Validate("Variety 3 Value");
          Validate("Variety 4 Value");
          //-NPR5.39 [304421]
          if (ItemWorksheetLine."Existing Item No." = '') then begin
            if ("Internal Bar Code" = '') then
              "Internal Bar Code" := ItemWorksheetLine."Internal Bar Code";
            if ("Vendors Bar Code" = '') then
              "Vendors Bar Code" := ItemWorksheetLine."Vendors Bar Code";
          end;
          //+NPR5.39 [304421]
          ItemWshtImpExpMgt.SetImportActionWorksheetVariantLine(ItemWorksheetLine,ActionIfVariantUnknown,ActionIfVarietyUnknown,ItemWorksheetVariantLine);
          Modify(true);
          //-NPR5.23 [242498]
          //-NPR5.28 [259200]
          //ItemWshtImpExpMgt.OnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
          ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
          //+NPR5.28 [259200]
          //+NPR5.23 [242498]
        end;

        //-NPR5.39 [304421]
        ItemWorksheetLine.CleanupObsoleteLines;
        //+NPR5.39 [304421]

        //-NPR5.25 [246088]
        TempText :=  UpperCase(NpXmlDomMgt.GetXmlText (XmlElement, 'ValidateLine', MaxStrLen (TempText), false));
        if TempText in ['YES','1','TRUE'] then
          ItemWkshCheckLine.RunCheck(ItemWorksheetLine,false,false);
        //+NPR5.25 [246088]
    end;

    local procedure ReadWkshLineAttributes(ItemWorksheetLine: Record "Item Worksheet Line";XmlElement: DotNet npNetXmlElement)
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        //-NPR5.43 [312958]
        if IsNull(XmlElement) then
          exit;
        if XmlElement.Name <> 'Attributes' then
          exit;

        XmlNodeList := XmlElement.SelectNodes('Attribute[@Code!=""]');
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement2 := XmlNodeList.Item(i);
          ReadWkshLineAttribute(ItemWorksheetLine,XmlElement2);
        end;
        //+NPR5.43 [312958]
    end;

    local procedure ReadWkshLineAttribute(ItemWorksheetLine: Record "Item Worksheet Line";XmlElement: DotNet npNetXmlElement)
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "Code": Code[20];
        Value: Text;
    begin
        //-NPR5.43 [312958]
        if IsNull(XmlElement) then
          exit;
        if XmlElement.Name <> 'Attribute' then
          exit;

        Code := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'Code',true);
        if Code = '' then
          exit;

        Value := XmlElement.InnerText;

        NPRAttrManagement.GetAttributeKey(DATABASE::"Item Worksheet Line",ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Line No.",0,ItemWorksheetLine."Worksheet Name",0,AttributeKey,false);
        if not NPRAttrManagement.SetAttributeValue(AttributeKey."Attribute Set ID",Code,Value,AttributeValue) then
          exit;

        if AttributeValue."Attribute Set ID" <> 0 then begin
          AttributeValue.Modify;
          exit;
        end;

        NPRAttrManagement.GetAttributeKey(DATABASE::"Item Worksheet Line",ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Line No.",0,ItemWorksheetLine."Worksheet Name",0,AttributeKey,true);
        AttributeValue."Attribute Set ID" := AttributeKey."Attribute Set ID";
        AttributeValue.Insert;
        //+NPR5.43 [312958]
    end;

    local procedure SetImportParameters(XmlElement: DotNet npNetXmlElement;Token: Text[100])
    var
        TempText: Text;
    begin
        TempText := NpXmlDomMgt.GetXmlText (XmlElement, 'importoptiontxt', MaxStrLen (TempText), false);

        if not Evaluate(ImportOption,TempText ) then
          ImportOption := ImportOption::"Add lines";

        TempText :=  NpXmlDomMgt.GetXmlText (XmlElement, 'combinevarietiestxt', MaxStrLen (TempText), false);
        if not Evaluate(CombineVarieties,TempText ) then
          CombineVarieties := false;

        TempText :=  NpXmlDomMgt.GetXmlText (XmlElement, 'actionifvariantunknowntxt', MaxStrLen (TempText), false);
        if not Evaluate(ActionIfVariantUnknown,TempText ) then
          ActionIfVariantUnknown := ActionIfVariantUnknown :: Create;

        TempText :=  NpXmlDomMgt.GetXmlText (XmlElement, 'actionifvarietyunknowntxt', MaxStrLen (TempText), false);
        if not Evaluate(ActionIfVarietyUnknown,TempText ) then
          ActionIfVarietyUnknown := ActionIfVarietyUnknown :: Create;
    end;

    local procedure FindWorksheetLine(VendorNo: Code[20];VendorVATRegNo: Text;ItemNo: Code[20];var ItemWorksheetTemplateCode: Code[20];var ItemWorksheetCode: Code[20];var ItemWorksheetLineNo: Integer)
    var
        Vendor: Record Vendor;
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheetTemplate2: Record "Item Worksheet Template";
        ItemWorksheet: Record "Item Worksheet";
        ItemWorksheetLine: Record "Item Worksheet Line";
    begin
        //Find Vendor
        //IF NOT Vendor.GET(VendorNo) THEN BEGIN
        // IF VendorVATRegNo <> '' THEN BEGIN
        //   Vendor.SETRANGE(Vendor."VAT Registration No.",VendorVATRegNo);
        //    IF Vendor.COUNT > 1 THEN
        //      ERROR(VENDOR_NOT_FOUND,VendorNo);
        //    IF NOT Vendor.FINDFIRST THEN
        //      ERROR(VENDOR_NOT_FOUND,VendorNo);
        //  END ELSE
        //    ERROR(VENDOR_NOT_FOUND,VendorNo);
        // END;
        if not Vendor.Get(VendorNo) then begin
         if VendorVATRegNo <> '' then begin
           Vendor.SetRange(Vendor."VAT Registration No.",VendorVATRegNo);
           if not Vendor.FindFirst then begin
             Vendor.Init;
             Vendor."No." := '';
           end;
         end;
        end;

        //Set Template
        ItemWorksheetTemplate.Reset;
        ItemWorksheetTemplate.SetRange("Allow Web Service Update",true);
        if not ItemWorksheetTemplate.FindFirst then begin
          ItemWorksheetTemplate2.Reset;
          if ItemWorksheetTemplate2.FindFirst then begin
            ItemWorksheetTemplate := ItemWorksheetTemplate2;
          end else begin
            ItemWorksheetTemplate.Init;
            ItemWorksheetTemplate.Validate(Name,'WEBSERV');
          end;
          ItemWorksheetTemplate.Validate("Allow Web Service Update",true);
          ItemWorksheetTemplate.Insert(true);
        end;
        ItemWorksheetTemplateCode := ItemWorksheetTemplate.Name;

        //Set Worksheet
        ItemWorksheet.Reset;
        ItemWorksheet.SetRange("Item Template Name",ItemWorksheetTemplate.Name);
        ItemWorksheet.SetRange("Vendor No.",Vendor."No.");
        if not ItemWorksheet.FindFirst then begin
          ItemWorksheet.SetFilter("Vendor No.",'');
          if not ItemWorksheet.FindFirst then begin
             ItemWorksheet.Init;
             ItemWorksheet.Validate(ItemWorksheet."Item Template Name",ItemWorksheetTemplate.Name);
             ItemWorksheet.Validate(Name,'WEBSERV');
             ItemWorksheet.Insert(true);
          end;
        end;
        ItemWorksheetCode := ItemWorksheet.Name;

        //Set Line
        ItemWorksheetLine.Reset;
        ItemWorksheetLine.SetRange("Worksheet Template Name",ItemWorksheetTemplateCode);
        ItemWorksheetLine.SetRange("Worksheet Name",ItemWorksheetCode);
        if ItemWorksheetLine.FindLast then begin
          LastItemWorksheetLine := ItemWorksheetLine;
          ItemWorksheetLineNo := ItemWorksheetLine."Line No." + 10000
        end else begin
          LastItemWorksheetLine.Init;
          ItemWorksheetLineNo := 10000;
        end;
    end;

    local procedure "--Utils"()
    begin
    end;

    [Scope('Personalization')]
    procedure Initialize()
    begin

        if not Initialized then begin
          Initialized := true;
        end;
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear (ImportType);
        ImportType.SetFilter (Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst ()) then ;

        exit (ImportType."Webservice Function");
    end;

    local procedure FindWorksheetVendorNio(VendorNo: Code[20])
    begin
    end;
}

