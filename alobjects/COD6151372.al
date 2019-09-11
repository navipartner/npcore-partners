codeunit 6151372 "CS WS"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180604 CASE 307239 Added Variant Filter
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181010 CASE 307282 Added Item Seach functionality, GetRfidOfflineData and GetRfidOfflineDataAndJournals
    // NPR5.48/CLVA/20181220 CASE 318296 Added function GetItemPicture
    // NPR5.48/JAVA/20190205  CASE 335191 Transport NPR5.48 - 5 February 2019
    // NPR5.48/CLVA/20190222 CASE 318296 Updated function GetItemPicture
    // NPR5.50/CLVA/20190206 CASE 344466 Added function ProcessData, GetRfidOfflineDataDelta, UpdateRfidDeviceInfo, GetRefillData, GetRfidTagData, SetRfidTagData, GetRfidWhseReceiptData
    //                                                  GetRfidWhseReceiptData, ValidateRfidWhseReceiptData, CloseCounting, CloseRefill, UpdateRefill, ApproveCounting and CloseWarehouseCounting
    //                                   Removed functions GetRfidOfflineData, GetRfidOfflineDataAndJournals, GetRfidMasterData and GetRfidData
    // NPR5.50/CLVA/20190502 CASE 353741 Added functions ResetWarehouseCounting and GetItemObject
    // NPR5.51/CLVA/20190610 CASE 356107 Added function SaveRfidWhseReceiptData
    // NPR5.51/CLVA/20190712 CASE 350696 Added FRID model check
    // NPR5.51/CLVA/20190820 CASE 365659 Changed CloseWarehouseCounting to use Phy. Inv. Journal
    // NPR5.51/CLVA/20190826 CASE 365659 Added GetWarehouseCountingDetails
    // NPR5.51/CLVA/20190701 CASE 350696 Added function GetRfidOfflineDataDeltaV2


    trigger OnRun()
    begin
    end;

    var
        IsInternal: Boolean;
        InternalCallId: Guid;
        headerlabel: Label 'STOCK';
        footerlabel: Label 'DELIVERY';
        Txt001: Label 'There are unknown tags related to Whse. Receipt No. %1\\Please manual handle the conflict in the backend system';
        Txt002: Label 'There are items not related to Whse. Receipt No. %1\\Please manual handle the conflict in the backend system';
        Txt003: Label 'There are no items to handle related to Whse. Receipt No. %1';
        Txt004: Label 'Qty. to Receive exceed Outstanding Qty. for item %1 %2';
        Txt005: Label 'Physical Inventory Journal: %1, do not exist';
        Txt006: Label 'Item Journal Template: %1, field Source Code is blank';
        Txt007: Label 'Physical Inventory Journals: %1, field Reason Code is blank';
        Txt008: Label 'Physical Inventory Journals: %1, field Posting No. Series is blank';
        Txt009: Label 'Physical Inventory Journal: %1, is not empty';
        Txt010: Label 'Capture Service is not configured in company: %1';
        Txt011: Label 'There is nothing to save';

    procedure ProcessDocument(var Document: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InputXmlDocument: DotNet npNetXmlDocument;
        OutputXmlDocument: DotNet npNetXmlDocument;
        CSManagement: Codeunit "CS Management";
        CSHelperFunctions: Codeunit "CS Helper Functions";
        CSCommunicationLog: Record "CS Communication Log";
        IsEnable: Boolean;
        LogCommunication: Boolean;
    begin
        CSHelperFunctions.CreateLogEntry(CSCommunicationLog,Document,IsEnable,LogCommunication);

        XMLDOMManagement.LoadXMLDocumentFromText(Document,InputXmlDocument);
        CSManagement.ProcessDocument(InputXmlDocument);
        CSManagement.GetOutboundDocument(OutputXmlDocument);
        Document := OutputXmlDocument.OuterXml;

        CSHelperFunctions.UpdateLogEntry(CSCommunicationLog,'ProcessDocument',IsInternal,InternalCallId,Document,LogCommunication,'');
    end;

    procedure ProcessData(DeviceId: Code[10];BatchId: Text;BatchNo: Text;PostData: Text;StockTakeConfig: Text;WorksheetName: Text;var Data: Text)
    var
        CSStockTakeHandlingRfid: Record "CS Stock-Take Handling Rfid";
        OK: Boolean;
        SessionID: Integer;
        Ostream: OutStream;
        BigTextData: BigText;
        ValInt: Integer;
        ValBool: Boolean;
        CommaString: DotNet npNetString;
        Separator: DotNet npNetString;
        Value: Text;
        Values: DotNet npNetArray;
    begin
        if (DeviceId = '') or (Data = '') then
          exit;

        BigTextData.AddText(Data);

        CSStockTakeHandlingRfid.Init;
        CSStockTakeHandlingRfid.Id := CreateGuid;
        if BatchId <> '' then
          CSStockTakeHandlingRfid."Batch Id" := BatchId
        else
          CSStockTakeHandlingRfid."Batch Id" := CreateGuid;

        if Evaluate(ValInt,BatchNo) then
          CSStockTakeHandlingRfid."Batch No." := ValInt;
        if Evaluate(ValBool,PostData) then
          CSStockTakeHandlingRfid."Batch Posting" := ValBool;
        CSStockTakeHandlingRfid.Created := CurrentDateTime;
        CSStockTakeHandlingRfid."Created By" := UserId;
        CSStockTakeHandlingRfid."Request Function" := 'StockTakeRfid';
        CSStockTakeHandlingRfid."Stock-Take Config Code" := StockTakeConfig;
        CSStockTakeHandlingRfid."Worksheet Name" := WorksheetName;
        CSStockTakeHandlingRfid."Device Id" := DeviceId;

        CSStockTakeHandlingRfid."Request Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);

        CSStockTakeHandlingRfid.Insert(false);
        Commit;

        CommaString := Data;
        Separator := ',';
        Values := CommaString.Split(Separator.ToCharArray());
        CSStockTakeHandlingRfid.Tags := Values.Length;
        CSStockTakeHandlingRfid.Modify(false);
        Commit;

        Clear(Ostream);
        Clear(BigTextData);

        Data := '';

        if CSStockTakeHandlingRfid."Batch Posting" then begin
          OK := StartSession(SessionID, CODEUNIT::"CS UI Stock-Take Handling Rfid", CompanyName, CSStockTakeHandlingRfid);
          if not OK then begin
            CSStockTakeHandlingRfid."Posting Error" := Format(CODEUNIT::"CS UI Stock-Take Handling Rfid");
            CSStockTakeHandlingRfid."Posting Error Detail" := GetLastErrorText;
          end;
        end;

        BigTextData.AddText(Data);
        CSStockTakeHandlingRfid."Response Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);
        CSStockTakeHandlingRfid.Modify(false);
    end;

    procedure IsInternalCall(LocalIsInternal: Boolean;LocalId: Guid)
    begin
        IsInternal := LocalIsInternal;
        InternalCallId := LocalId;
    end;

    procedure GetItemInfoByBarcode(Barcode: Code[20]): Text
    var
        Item: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        PurchaseLine: Record "Purchase Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchaseLineExpectedReceiptDateTxt: Text;
        ItemLedgerEntryPostingDateTxt: Text;
        ItemInventoryTxt: Text;
        MasterTxt: Text;
        DetailTxt: Text;
    begin
        MasterTxt := 'n/a';
        DetailTxt := 'n/a';

        if Barcode = '' then
          exit(StrSubstNo('%1#%2',MasterTxt,DetailTxt));

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
          exit(StrSubstNo('%1#%2',MasterTxt,DetailTxt));

        if not Item.Get(ItemNo) then
          exit(StrSubstNo('%1#%2',MasterTxt,DetailTxt));

        if VariantCode <> '' then
          Item.SetFilter("Variant Filter",VariantCode);

        Item.CalcFields(Inventory,"Qty. on Purch. Order");

        DetailTxt := Format(Item.Inventory);
        ItemInventoryTxt := StrSubstNo('Stock: %1',Item.Inventory);

        if Item."Qty. on Purch. Order" > 0 then begin
          Clear(PurchaseLine);
          PurchaseLine.SetRange("Document Type",PurchaseLine."Document Type"::Order);
          PurchaseLine.SetRange(Type,PurchaseLine.Type::Item);
          PurchaseLine.SetRange("No.",Item."No.");
          if VariantCode <> '' then
            PurchaseLine.SetRange("Variant Code",VariantCode);
          if PurchaseLine.FindLast then
            PurchaseLineExpectedReceiptDateTxt := StrSubstNo('Exp.: %1',PurchaseLine."Expected Receipt Date")
          else
            PurchaseLineExpectedReceiptDateTxt := StrSubstNo('Exp.: %1','n/a');
        end else
          PurchaseLineExpectedReceiptDateTxt := StrSubstNo('Exp.: %1','n/a');

        Clear(ItemLedgerEntry);
        ItemLedgerEntry.SetRange("Entry Type",ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.",Item."No.");
        if VariantCode <> '' then
          ItemLedgerEntry.SetRange("Variant Code",VariantCode);
        if ItemLedgerEntry.FindLast then
          ItemLedgerEntryPostingDateTxt := StrSubstNo('Last: %1',ItemLedgerEntry."Posting Date")
        else
          ItemLedgerEntryPostingDateTxt := StrSubstNo('Last: %1','n/a');

        MasterTxt := StrSubstNo('%1\n%2\n%3',ItemInventoryTxt,PurchaseLineExpectedReceiptDateTxt,ItemLedgerEntryPostingDateTxt);

        exit(StrSubstNo('%1#%2',DetailTxt,MasterTxt));
    end;

    procedure GetItemPicture(Barcode: Code[20]) PictureBase64: Text
    var
        Item: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TempBlob: Record TempBlob;
        MediaGuid: Guid;
        TenantMedia: Record "Tenant Media";
    begin
        //-NPR5.48 [318296]
        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
          exit('');

        if not Item.Get(ItemNo) then
          exit('');

        if VariantCode <> '' then
          Item.SetFilter("Variant Filter",VariantCode);

        if Item.Picture.Count >= 1 then begin
          Clear(PictureBase64);
          TempBlob.Init;
          MediaGuid := Item.Picture.Item(1);
          TenantMedia.Get(MediaGuid);
          TenantMedia.CalcFields(Content);
          TempBlob.Blob:=TenantMedia.Content;
          PictureBase64 := TempBlob.ToBase64String;
        end;

        exit(PictureBase64);
        //+NPR5.48 [318296]
    end;

    procedure SearchItem(Word: Text): Text
    var
        CSItemSeachHandling: Record "CS Item Seach Handling" temporary;
        Item: Record Item;
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        MaxItems: Integer;
        ItemsCounter: Integer;
        CSSetup: Record "CS Setup";
    begin
        if Word = '' then
          exit;

        if not CSSetup.Get then
          exit;

        if CSSetup."Max Records In Search Result" = 0 then begin
          CSSetup."Max Records In Search Result" := 100;
          CSSetup.Modify;
        end;

        MaxItems := CSSetup."Max Records In Search Result";
        ItemsCounter := 0;

        Clear(CSItemSeachHandling);

        if StrLen(Word) <= MaxStrLen(Item."No.") then begin
          if Item.Get(Word) then begin
            CSItemSeachHandling.Init;
            CSItemSeachHandling."No." := Item."No.";
            CSItemSeachHandling.Description := Item.Description;
            CSItemSeachHandling."Description 2" := Item."Description 2";
            CSItemSeachHandling.Rank := 1;
            CSItemSeachHandling.Insert;
            ItemsCounter += 1;
          end;

          Item.SetFilter("No.",'%1','@*' + Word + '*');
          if Item.FindSet then begin
            repeat
              if not CSItemSeachHandling.Get(Item."No.") then begin
                CSItemSeachHandling.Init;
                CSItemSeachHandling."No." := Item."No.";
                CSItemSeachHandling.Description := Item.Description;
                CSItemSeachHandling."Description 2" := Item."Description 2";
                CSItemSeachHandling.Rank := 2;
                CSItemSeachHandling.Insert;
                ItemsCounter += 1;
              end;
            until (Item.Next = 0) or (ItemsCounter = MaxItems);
          end;
        end;

        if (StrLen(Word) <= MaxStrLen(Item.Description)) then begin
          Clear(Item);
          Item.SetFilter(Description,'%1','@*' + Word + '*');
          if Item.FindSet and  (ItemsCounter < MaxItems) then begin
            repeat
              if not CSItemSeachHandling.Get(Item."No.") then begin
                CSItemSeachHandling.Init;
                CSItemSeachHandling."No." := Item."No.";
                CSItemSeachHandling.Description := Item.Description;
                CSItemSeachHandling."Description 2" := Item."Description 2";
                CSItemSeachHandling.Rank := 3;
                CSItemSeachHandling.Insert;
                ItemsCounter += 1;
              end;
            until (Item.Next = 0) or (ItemsCounter = MaxItems);
          end;

          Clear(Item);
          Item.SetFilter("Description 2",'%1','@*' + Word + '*');
          if Item.FindSet and (ItemsCounter < MaxItems) then begin
            repeat
              if not CSItemSeachHandling.Get(Item."No.") then begin
                CSItemSeachHandling.Init;
                CSItemSeachHandling."No." := Item."No.";
                CSItemSeachHandling.Description := Item.Description;
                CSItemSeachHandling."Description 2" := Item."Description 2";
                CSItemSeachHandling.Rank := 4;
                CSItemSeachHandling.Insert;
                ItemsCounter += 1;
              end;
            until (Item.Next = 0) or (ItemsCounter = MaxItems);
          end;
        end;

        CSItemSeachHandling.SetCurrentKey(Rank,"No.");
        if CSItemSeachHandling.FindSet then begin
          JTokenWriter := JTokenWriter.JTokenWriter;
          with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('items');
            WriteStartArray;
              repeat
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSItemSeachHandling."No.");
                WritePropertyName('description1');
                WriteValue(CSItemSeachHandling.Description);
                WritePropertyName('description2');
                WriteValue(CSItemSeachHandling."Description 2");
                WriteEndObject;
              until CSItemSeachHandling.Next = 0;
            WriteEndArray;
            WriteEndObject;
            JObject := Token;
          end;
          Result := JObject.ToString();
        end;

        exit(Result);
    end;

    procedure GetRfidOfflineDataDelta(DeviceId: Code[20]): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateOfflineRfidDataDelta(DeviceId));
    end;

    procedure GetRfidOfflineDataDeltaV2(DeviceId: Code[20]): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateOfflineRfidDataDeltaV2(DeviceId));
    end;

    procedure UpdateRfidDeviceInfo(DeviceId: Code[20];Lasttimestamp: Text;Location: Code[20]): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        Timestamp: BigInteger;
    begin
        if not Evaluate(Timestamp,Lasttimestamp) then
          exit;

        if Timestamp = 0 then
          exit;

        exit(CSHelperFunctions.UpdateDeviceInfo(DeviceId, Timestamp, Location));
    end;

    procedure GetRefillData(StockTakeId: Text): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateRefillData(StockTakeId));
    end;

    procedure GetRfidTagData(TagId: Text): Text
    var
        CSRfidData: Record "CS Rfid Data";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        TagFamily: Code[10];
        TagModel: Code[10];
        CSRfidItemPlaceholder: Record "CS Rfid Item Handling";
    begin
        //-NPR5.51 [350696]
        if (StrLen(TagId) > MaxStrLen(CSRfidItemPlaceholder."Rfid Id")) or (StrLen(TagId) < MaxStrLen(CSRfidTagModels.Family)) then
          exit('UNKNOWNITEM');

        TagFamily := CopyStr(TagId,1,4);
        TagModel  := CopyStr(TagId,5,4);

        if not CSRfidTagModels.Get(TagFamily,TagModel) then
          exit('UNKNOWNITEM');

        if CSRfidTagModels.Discontinued then
          exit('UNKNOWNITEM');
        //+NPR5.51 [350696]

        if CSRfidData.Get(TagId) then
          exit(CSRfidData."Combined key")
        else
          exit('UNKNOWNITEM');
    end;

    procedure SetRfidTagData(StockTakeId: Text;StockTakeConfigCode: Text;WorksheetName: Text;TagId: Text): Text
    var
        CSStockTakesData: Record "CS Stock-Takes Data";
        CSRfidData: Record "CS Rfid Data";
        Result: Text;
    begin
        CSStockTakesData."Stock-Take Id" := StockTakeId;
        CSStockTakesData."Stock-Take Config Code" := StockTakeConfigCode;
        CSStockTakesData."Worksheet Name" := WorksheetName;
        CSStockTakesData."Tag Id" := TagId;
        CSStockTakesData.Created := CurrentDateTime;
        CSStockTakesData."Created By" := UserId;
        if CSRfidData.Get(TagId) then begin
          CSStockTakesData.Validate("Item No.",CSRfidData."Cross-Reference Item No.");
          CSStockTakesData.Validate("Variant Code",CSRfidData."Cross-Reference Variant Code");
          CSStockTakesData.Validate("Item Group Code",CSRfidData."Item Group Code");
          CSStockTakesData."Combined key" := CSRfidData."Combined key";
          Result := CSRfidData."Combined key";
        end else
          Result := 'UNKNOWNITEM';
        if CSStockTakesData.Insert() then
          exit(Result)
        else
          exit(Result);
    end;

    procedure GetRfidWhseReceiptData(DocNo: Text): Text
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemGroup: Record "Item Group";
        Result: Text;
    begin
        if DocNo = '' then
          exit;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;

          WritePropertyName('item');
          WriteStartArray;

          WhseReceiptLine.SetRange("No.",DocNo);
          if WhseReceiptLine.FindSet then begin
            repeat

              Item.Get(WhseReceiptLine."Item No.");

              WriteStartObject;
              WritePropertyName('key');
              if WhseReceiptLine."Variant Code" <> '' then
                WriteValue(WhseReceiptLine."Item No." + '-' + WhseReceiptLine."Variant Code")
              else
                WriteValue(WhseReceiptLine."Item No.");
              WritePropertyName('title');
              WriteValue(WhseReceiptLine.Description);
              WritePropertyName('itemno');
              WriteValue(WhseReceiptLine."Item No.");
              WritePropertyName('variantcode');
              WriteValue(WhseReceiptLine."Variant Code");
              WritePropertyName('varianttitle');
              if ItemVariant.Get(Item."No.",WhseReceiptLine."Variant Code") then
                WriteValue(ItemVariant.Description)
              else
                WriteValue('');
              WritePropertyName('itemgroup');
              WriteValue(Item."Item Group");
              WritePropertyName('qtytoreceive');
              WriteValue(WhseReceiptLine."Qty. to Receive");
              WritePropertyName('qtyoutstanding');
              WriteValue(WhseReceiptLine."Qty. Outstanding");
              WriteEndObject;
            until WhseReceiptLine.Next = 0;
          end;

          WriteEndArray;

          WriteEndObject;
          JObject := Token;
          Result := JObject.ToString();

        end;

        exit(Result);
    end;

    procedure ValidateRfidWhseReceiptData(DocNo: Text;TagId: Text): Text
    var
        CSRfidData: Record "CS Rfid Data";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        if CSRfidData.Get(TagId) then begin
          WhseReceiptLine.SetRange("No.",DocNo);
          WhseReceiptLine.SetRange("Item No.",CSRfidData."Cross-Reference Item No.");
          if WhseReceiptLine.FindFirst then
            exit(CSRfidData."Combined key"+'#0')
          else
            exit(CSRfidData."Combined key"+'#1');
        end else
          exit('UNKNOWNITEM#2');
    end;

    procedure SaveRfidWhseReceiptData(DocNo: Text): Text
    var
        CSWhseReceiptData: Record "CS Whse. Receipt Data";
        Result: Text;
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Tag Type",CSWhseReceiptData."Tag Type"::Unknown);
        if CSWhseReceiptData.FindSet then
          exit(StrSubstNo(Txt001,DocNo));

        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Tag Type",CSWhseReceiptData."Tag Type"::"Not on Document");
        if CSWhseReceiptData.FindSet then
          exit(StrSubstNo(Txt002,DocNo));

        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Tag Type",CSWhseReceiptData."Tag Type"::Document);
        CSWhseReceiptData.SetRange("Transferred To Doc",false);
        if not CSWhseReceiptData.FindSet then begin
          exit(StrSubstNo(Txt003,DocNo));
        end else begin
          repeat
            Clear(WhseReceiptLine);
            WhseReceiptLine.SetCurrentKey("Source Type","Source Subtype","Source No.","Source Line No.");
            WhseReceiptLine.SetRange("No.",CSWhseReceiptData."Doc. No.");
            WhseReceiptLine.SetRange("Item No.",CSWhseReceiptData."Item No.");
            WhseReceiptLine.SetRange("Variant Code",CSWhseReceiptData."Variant Code");
            if WhseReceiptLine.FindSet then begin
              if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding" then
                exit(StrSubstNo(Txt004,CSWhseReceiptData."Item No.",CSWhseReceiptData."Variant Code"));
              WhseReceiptLine.Validate("Qty. to Receive",WhseReceiptLine."Qty. to Receive" + 1);
              WhseReceiptLine.Modify(true);
            end;

            CSWhseReceiptData.Transferred := CurrentDateTime;
            CSWhseReceiptData."Transferred By" := UserId;
            CSWhseReceiptData."Transferred To Doc" := true;
            CSWhseReceiptData.Modify();

          until CSWhseReceiptData.Next = 0;
        end;
    end;

    procedure CloseCounting(StockTakeId: Text;WorksheetName: Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
    begin
        if not CSStockTakes.Get(StockTakeId) then
          exit('UNKNOWNSTOCKTAKEID');

        case WorksheetName of
          'SALESFLOOR' : begin
                          if CSStockTakes."Salesfloor Closed" = 0DT then begin
                            CSStockTakes."Salesfloor Closed" := CurrentDateTime;
                            CSStockTakes."Salesfloor Closed By" := UserId;
                            CSStockTakes.Modify(true);
                          end;
                         end;
          'STOCKROOM' : begin
                          if CSStockTakes."Stockroom Closed" = 0DT then begin
                            CSStockTakes."Stockroom Closed" := CurrentDateTime;
                            CSStockTakes."Stockroom Closed By" := UserId;
                            CSStockTakes.Modify(true);
                          end;
                        end;
        end;

        Commit;

        OK := StartSession(SessionID, CODEUNIT::"CS UI Store Counting Handling", CompanyName, CSStockTakes);
        if not OK then begin
          //TO DO GETLASTERRORTEXT;
        end;

        exit(StockTakeId);
    end;

    procedure CloseRefill(StockTakeId: Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
    begin
        if not CSStockTakes.Get(StockTakeId) then
          exit('UNKNOWNSTOCKTAKEID');

        if CSStockTakes."Refill Closed" = 0DT then begin
          CSStockTakes."Refill Closed" := CurrentDateTime;
          CSStockTakes."Refill Closed By" := UserId;
          CSStockTakes.Modify(true);
        end;

        exit(StockTakeId);
    end;

    procedure UpdateRefill(StockTakeId: Text;ItemNo: Text;Refilled: Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
        Item: Record Item;
        CSRefillData: Record "CS Refill Data";
        RefillStatus: Boolean;
    begin
        if not CSStockTakes.Get(StockTakeId) then
          exit('UNKNOWNSTOCKTAKEID');

        if not Item.Get(ItemNo) then
          exit('UNKNOWNITEMNO');

        if not ((Refilled = '0') or (Refilled = '1')) then
          exit;

        RefillStatus := (Refilled = '1');

        CSRefillData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
        CSRefillData.SetRange("Item No.",Item."No.");
        if CSRefillData.FindSet then begin
          repeat
            CSRefillData.Refilled := RefillStatus;
            CSRefillData."Refilled By" := UserId;
            CSRefillData."Refilled Date" := CurrentDateTime;
            CSRefillData.Modify;
          until CSRefillData.Next = 0;
        end;

        exit(StockTakeId);
    end;

    procedure ApproveCounting(StockTakeId: Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
        StockTakeWorksheet: Record "Stock-Take Worksheet";
    begin
        if not CSStockTakes.Get(StockTakeId) then
          exit('UNKNOWNSTOCKTAKEID');

        if CSStockTakes.Approved = 0DT then begin
          CSStockTakes.Approved := CurrentDateTime;
          CSStockTakes."Approved By" := UserId;
          CSStockTakes.Modify(true);

          StockTakeWorksheet.Get(CSStockTakes.Location,'STOCKROOM');
          StockTakeWorksheet.Validate(Status,StockTakeWorksheet.Status::READY_TO_TRANSFER);
          if StockTakeWorksheet.Modify(true) then
            StartSession(SessionID, CODEUNIT::"CS UI Store Transfer Handling", CompanyName, StockTakeWorksheet);

          StockTakeWorksheet.Get(CSStockTakes.Location,'SALESFLOOR');
          StockTakeWorksheet.Validate(Status,StockTakeWorksheet.Status::READY_TO_TRANSFER);
          if StockTakeWorksheet.Modify(true) then
            StartSession(SessionID, CODEUNIT::"CS UI Store Transfer Handling", CompanyName, StockTakeWorksheet);
        end;

        exit(StockTakeId);
    end;

    procedure CloseWarehouseCounting(StockTakeConfigCode: Text;WorksheetName: Text): Text
    var
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        OK: Boolean;
        SessionID: Integer;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        BaseItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CSStockTakesDataTb: Record "CS Stock-Takes Data";
        TestItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        NewItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "CS Setup";
        CSStockTakesDataQy: Query "CS Stock-Takes Data";
        ItemJournalLine: Record "Item Journal Line";
        ResetItemJournalLine: Record "Item Journal Line";
    begin
        //-NPR5.51
        // IF NOT StockTakeWorksheet.GET(StockTakeConfigCode,WorksheetName) THEN
        //  EXIT('UNKNOWNSTOCKTAKEWORKSHEET');
        //
        // OK := STARTSESSION(SessionID, CODEUNIT::"CS UI WH Counting Handling", COMPANYNAME, StockTakeWorksheet);
        // IF NOT OK THEN
        //  EXIT(GETLASTERRORTEXT);

        if not CSSetup.Get then
          exit(StrSubstNo(Txt010,CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",StockTakeConfigCode) then
          exit(StrSubstNo(Txt005,StockTakeConfigCode));

        ItemJournalTemplate.Get(ItemJournalBatch."Journal Template Name");

        if ItemJournalTemplate."Source Code" = '' then
          exit(StrSubstNo(Txt006,ItemJournalTemplate.Name));

        if ItemJournalBatch."Reason Code" = '' then
          exit(StrSubstNo(Txt007,ItemJournalBatch.Name));

        Clear(BaseItemJournalLine);
        BaseItemJournalLine.Init;
        BaseItemJournalLine.Validate("Journal Template Name",ItemJournalBatch."Journal Template Name");
        BaseItemJournalLine.Validate("Journal Batch Name",ItemJournalBatch.Name);
        BaseItemJournalLine."Location Code" := ItemJournalBatch.Name;

        Clear(NoSeriesMgt);
        BaseItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",BaseItemJournalLine."Posting Date",false);
        BaseItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
        BaseItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
        BaseItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

        Clear(TestItemJournalLine);
        TestItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        TestItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        if TestItemJournalLine.FindSet then
          exit(StrSubstNo(Txt009,StockTakeConfigCode,WorksheetName));

        LineNo := 1000;

        CSStockTakesDataQy.SetRange(Worksheet_Name,ItemJournalBatch."Journal Template Name");
        CSStockTakesDataQy.SetRange(Stock_Take_Config_Code,ItemJournalBatch.Name);
        CSStockTakesDataQy.Open;
        while CSStockTakesDataQy.Read do
        begin
          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
          ItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
          ItemJournalLine.SetRange("Item No.", CSStockTakesDataQy.ItemNo);
          ItemJournalLine.SetRange("Variant Code", CSStockTakesDataQy.Variant_Code);
          if not ItemJournalLine.FindSet then begin
            Clear(NewItemJournalLine);
            NewItemJournalLine.Validate("Journal Template Name",BaseItemJournalLine."Journal Template Name");
            NewItemJournalLine.Validate("Journal Batch Name",BaseItemJournalLine."Journal Batch Name");
            NewItemJournalLine."Line No." := LineNo;
            NewItemJournalLine.Insert(true);

            NewItemJournalLine.Validate("Entry Type",NewItemJournalLine."Entry Type"::"Positive Adjmt.");
            NewItemJournalLine.Validate("Item No.", CSStockTakesDataQy.ItemNo);
            NewItemJournalLine.Validate("Variant Code",CSStockTakesDataQy.Variant_Code);
            NewItemJournalLine.Validate("Location Code",BaseItemJournalLine."Location Code");
            NewItemJournalLine.Validate("Phys. Inventory",true);
            NewItemJournalLine.Validate("Qty. (Phys. Inventory)",CSStockTakesDataQy.Count_);
            NewItemJournalLine."Posting Date" := WorkDate;
            NewItemJournalLine."Document Date" := WorkDate;
            NewItemJournalLine.Validate("External Document No.",'MOBILE');
            NewItemJournalLine.Validate("Changed by User",true);
            NewItemJournalLine."Document No." := BaseItemJournalLine."Document No.";
            NewItemJournalLine."Source Code" := BaseItemJournalLine."Source Code";
            NewItemJournalLine."Reason Code" := BaseItemJournalLine."Reason Code";
            NewItemJournalLine."Posting No. Series" := BaseItemJournalLine."Posting No. Series";
            NewItemJournalLine.Modify(true);
            LineNo += 1000;
          end else begin
            ItemJournalLine.Validate("Qty. (Phys. Inventory)",CSStockTakesDataQy.Count_);
            ItemJournalLine.Validate("Changed by User",true);
            ItemJournalLine.Modify(true);
          end;
        end;

        CSStockTakesDataQy.Close;

        Clear(ResetItemJournalLine);
        ResetItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        ResetItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        ResetItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
        ResetItemJournalLine.SetRange("Changed by User",false);
        ResetItemJournalLine.ModifyAll("Qty. (Phys. Inventory)",0,true);

        Clear(CSStockTakesDataTb);
        CSStockTakesDataTb.SetRange("Worksheet Name",ItemJournalBatch."Journal Template Name");
        CSStockTakesDataTb.SetRange("Stock-Take Config Code",ItemJournalBatch.Name);
        CSStockTakesDataTb.SetFilter("Item No.", '<>%1', '');
        CSStockTakesDataTb.DeleteAll(false);

        exit(StockTakeConfigCode)
        //+NPR5.51
    end;

    procedure ResetWarehouseCounting(StockTakeConfigCode: Text;WorksheetName: Text): Text
    var
        CSSetup: Record "CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        CSStockTakesData: Record "CS Stock-Takes Data";
    begin
        //-NPR5.51
        //IF NOT StockTakeWorksheet.GET(StockTakeConfigCode,WorksheetName) THEN
        if not CSSetup.Get then
          exit(StrSubstNo(Txt010,CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",StockTakeConfigCode) then
          exit('UNKNOWNSTOCKTAKEWORKSHEET');
        //+NPR5.51

        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        //-NPR5.51
        //CSStockTakesData.SETRANGE("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        //CSStockTakesData.SETRANGE("Worksheet Name",StockTakeWorksheet.Name);
        CSStockTakesData.SetRange("Worksheet Name",ItemJournalBatch."Journal Template Name");
        CSStockTakesData.SetRange("Stock-Take Config Code",ItemJournalBatch.Name);
        //+NPR5.51
        CSStockTakesData.DeleteAll();

        exit(StockTakeConfigCode);
    end;

    procedure GetItemObject(Barcode: Code[20]): Text
    var
        Item: Record Item;
        Item2: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        PurchaseLine: Record "Purchase Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempBlob: Record TempBlob;
        MediaGuid: Guid;
        TenantMedia: Record "Tenant Media";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        Var01: Text;
        Var02: Text;
        Var03: Text;
        Var04: Text;
        Var05: Text;
        Var06: Text;
        Var07: Text;
        Var08: Text;
        Var09: Text;
        Var10: Text;
        Var11: Text;
    begin
        if Barcode = '' then
          exit('');

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
          exit('');

        if not Item.Get(ItemNo) then
          exit('');

        Var01 := '-';
        Var02 := '-';
        Var03 := '0';
        Var04 := '-';
        Var05 := '-';
        Var06 := '-';
        Var07 := '-';
        Var08 := '0';
        Var09 := '0';
        Var10 := '0';
        Var11 := '';

        if VariantCode <> '' then
          Item.SetFilter("Variant Filter",VariantCode);
        Item.CalcFields(Inventory,"Qty. on Purch. Order");

        Var01 := Item."No.";
        Var02 := Item.Description;
        Var03 := Format(Item.Inventory);
        Var04 := Item."Base Unit of Measure";
        Var05 := VariantCode;

        if Item."Qty. on Purch. Order" > 0 then begin
          Clear(PurchaseLine);
          PurchaseLine.SetRange("Document Type",PurchaseLine."Document Type"::Order);
          PurchaseLine.SetRange(Type,PurchaseLine.Type::Item);
          PurchaseLine.SetRange("No.",Item."No.");
          if VariantCode <> '' then
            PurchaseLine.SetRange("Variant Code",VariantCode);
          if PurchaseLine.FindLast then
            Var06 := Format(PurchaseLine."Expected Receipt Date");
        end;

        Clear(ItemLedgerEntry);
        ItemLedgerEntry.SetRange("Entry Type",ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.",Item."No.");
        if VariantCode <> '' then
          ItemLedgerEntry.SetRange("Variant Code",VariantCode);
        if ItemLedgerEntry.FindLast then
          Var07 := Format(ItemLedgerEntry."Posting Date");

        Clear(Item2);
        Item2.Get(Item."No.");
        if VariantCode <> '' then
          Item2.SetFilter("Variant Filter",VariantCode);
        Item2.SetFilter("Date Filter",'%1..%2', 0D, Today);
        Item2.CalcFields("Sales (Qty.)");
        Var08 := Format(Item2."Sales (Qty.)");

        Clear(Item2);
        Item2.Get(Item."No.");
        if VariantCode <> '' then
          Item2.SetFilter("Variant Filter",VariantCode);
        Item2.SetRange("Date Filter", CalcDate('<-CY>', WorkDate), CalcDate('<CY>', WorkDate));
        Item2.CalcFields("Sales (Qty.)");
        Var09 := Format(Item2."Sales (Qty.)");

        Clear(Item2);
        Item2.Get(Item."No.");
        if VariantCode <> '' then
          Item2.SetFilter("Variant Filter",VariantCode);
        Item2.SetRange("Date Filter", CalcDate('<CY-2Y+1D>', WorkDate), CalcDate('<CY-1Y>', WorkDate));
        Item2.CalcFields("Sales (Qty.)");
        Var10 := Format(Item2."Sales (Qty.)");

        if Item.Picture.Count >= 1 then begin
          TempBlob.Init;
          MediaGuid := Item.Picture.Item(1);
          TenantMedia.Get(MediaGuid);
          TenantMedia.CalcFields(Content);
          TempBlob.Blob:=TenantMedia.Content;
          Var11 := TempBlob.ToBase64String;
        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;

          WritePropertyName('item');
          WriteStartArray;

              WriteStartObject;
              WritePropertyName('1');
              WriteValue(Var01);
              WritePropertyName('2');
              WriteValue(Var02);

              WritePropertyName('headerlabel');
              WriteValue(headerlabel);
              WritePropertyName('3');
              WriteValue(Var03);
              WritePropertyName('linelabel1');
              WriteValue(Date2DMY(CalcDate('<CY>', WorkDate),3));
              WritePropertyName('8');
              WriteValue(Var08);
              WritePropertyName('linelabel2');
              WriteValue(Date2DMY(CalcDate('<CY-1Y>', WorkDate),3));
              WritePropertyName('9');
              WriteValue(Var09);
              WritePropertyName('linelabel3');
              WriteValue(Date2DMY(CalcDate('<CY-2Y>', WorkDate),3));
              WritePropertyName('10');
              WriteValue(Var10);
              WritePropertyName('footerlabel');
              WriteValue(footerlabel);
              WritePropertyName('6');
              WriteValue(Var06);

              WritePropertyName('4');
              WriteValue(Var04);
              WritePropertyName('5');
              WriteValue(Var05);
              WritePropertyName('7');
              WriteValue(Var07);
              WritePropertyName('11');
              WriteValue(Var11);
              WriteEndObject;

          WriteEndArray;

          WriteEndObject;
          JObject := Token;
          Result := JObject.ToString();

        end;

        exit(Result);
    end;

    procedure GetWarehouseCountingDetails(BatchName: Text): Text
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        CSItemJournal: Query "CS Item Journal";
        CSSetup: Record "CS Setup";
        PredictedQty: Integer;
    begin
        if not CSSetup.Get then
          exit(StrSubstNo(Txt010,CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",BatchName) then
          exit(StrSubstNo(Txt005,BatchName));


        CSItemJournal.SetRange(CSItemJournal.Journal_Template_Name,CSSetup."Phys. Inv Jour Temp Name");
        CSItemJournal.SetRange(CSItemJournal.Journal_Batch_Name,BatchName);
        CSItemJournal.Open;
        while CSItemJournal.Read do
        begin
          PredictedQty := CSItemJournal.Sum_Qty_Calculated;
        end;

        CSItemJournal.Close;

        exit(Format(PredictedQty));
    end;
}

