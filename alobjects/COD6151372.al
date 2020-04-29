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
    // NPR5.52/CLVA/20190917 CASE 368484 Added functions SetRfidTagDataByType,GetStoreData,StartStoreCounting,CloseStoreCounting,ApproveStoreCounting,ResetCounting and CreateStoreRefillData
    // NPR5.52/CLVA/20190926 CASE 365659 Added Updated CloseWarehouseCounting
    // NPR5.52/CLVA/20190925 CASE 370277 Changed "Document No." to Workdate
    // NPR5.52/CLVA/20190930 CASE 370690 Added function CreateStoreCounting
    // NPR5.52/CLVA/20191007 CASE 371453 Added RFID validation to GetItemPicture
    // NPR5.53/CLVA/20191029 CASE 374331 Added Store Counting Approvel to Posting Buffer
    //                                   Moved version specific functions to wrapper codeunit
    // NPR5.53/CLVA/20191029 CASE 377467 Calculating Inventory if Inventory Calculation is missing because of lock error in CreateStoreCounting
    // NPR5.53/CLVA/20191122 CASE 377462 Added Priority for Post for ApproveStoreCounting
    // NPR5.53/CLVA/20191203 CASE 375919 Added Counting Supervisor functionality. Addded function CreateStoreCountingV2, SearchPOSStore and GetStoreDataV2
    // NPR5.53/CLVA/20200207 CASE 389864 Changed code to support version specific changes (NAV 2018+).
    // NPR5.54/CLVA/20202020 CASE 384506 Added Supervisor and POS user filter on GetStoreDataV2 and GetStoreDataByStoreUser;
    // NPR5.54/CLVA/20200227 CASE 389224 Added batch handling
    // NPR5.54/CLVA/20200310 CASE 384506 Added function CreateStoreRefillDataV2


    trigger OnRun()
    begin
        Message(CreateStoreRefillDataV2('{dac13779-be4d-4a13-802b-c419c0a6b2f2}'));
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
        Txt012: Label 'User Id is not valid';
        Txt013: Label 'User Id is not setup as Store User';
        Txt014: Label 'There are no active counting sheets for store %1 %2';
        Txt015: Label 'Inventory Calculation has not been done for journal: %1 %2';
        Txt016: Label 'Stock Take Id is not valid';
        Txt017: Label 'Stock Take Id do not exist: %1';
        Txt018: Label 'Supervisor Password is not valid. Valid password is 6 digits';
        Txt019: Label 'Wrong Area type. Only Salesfloor,Stockroom and Refill is supported';
        Txt020: Label 'Inventory Calculation can''t been done for journal: %1 %2, because the journal is not empty';
        Txt021: Label 'There is no Items on Location %1';
        Txt022: Label 'POS Store Code is not valid: %1';

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
    procedure IsInternalCall(LocalIsInternal: Boolean;LocalId: Guid)
    begin
        IsInternal := LocalIsInternal;
        InternalCallId := LocalId;
    end;

    [Scope('Personalization')]
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

    [Scope('Personalization')]
    procedure GetItemPicture(Barcode: Code[20]) PictureBase64: Text
    var
        Item: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        ItemCrossReference: Record "Item Cross Reference";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        CSRfidData: Record "CS Rfid Data";
        TagFamily: Code[10];
        TagModel: Code[10];
        TagId: Code[20];
        CSWrapperFunctions: Codeunit "CS Wrapper Functions";
    begin
        //-NPR5.53 [374331]
        exit(CSWrapperFunctions.GetItemPicture(Barcode));
        //+NPR5.53 [374331]
    end;

    [Scope('Personalization')]
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

    [Scope('Personalization')]
    procedure GetRfidOfflineDataDelta(DeviceId: Code[20]): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateOfflineRfidDataDelta(DeviceId));
    end;

    [Scope('Personalization')]
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

    [Scope('Personalization')]
    procedure GetRefillData(StockTakeId: Text): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateRefillData(StockTakeId));
    end;

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
    procedure SetRfidTagDataByType(StockTakeId: Text;StockTakeConfigCode: Text;WorksheetName: Text;TagId: Text;"Area": Text): Text
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
        case Area of
          '0' : CSStockTakesData.Area := CSStockTakesData.Area::Warehouse;
          '1' : CSStockTakesData.Area := CSStockTakesData.Area::Salesfloor;
          '2' : CSStockTakesData.Area := CSStockTakesData.Area::Stockroom;
        end;
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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

    [Scope('Personalization')]
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
        //-NPR5.52
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

        //IF ItemJournalBatch."Reason Code" = '' THEN
        //  EXIT(STRSUBSTNO(Txt007,ItemJournalBatch.Name));

        Clear(BaseItemJournalLine);
        BaseItemJournalLine.Init;
        BaseItemJournalLine.Validate("Journal Template Name",ItemJournalBatch."Journal Template Name");
        BaseItemJournalLine.Validate("Journal Batch Name",ItemJournalBatch.Name);
        BaseItemJournalLine."Location Code" := ItemJournalBatch.Name;

        //-NPR5.52 [370277]
        //CLEAR(NoSeriesMgt);
        //BaseItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",BaseItemJournalLine."Posting Date",FALSE);
        BaseItemJournalLine."Document No." := Format(WorkDate);
        //+NPR5.52 [370277]
        BaseItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
        BaseItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
        BaseItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

        Clear(TestItemJournalLine);
        TestItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        TestItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        if TestItemJournalLine.FindLast then
          LineNo := TestItemJournalLine."Line No." + 1000
        else
          LineNo := 1000;

        //EXIT(STRSUBSTNO(Txt009,StockTakeConfigCode,WorksheetName));

        CSStockTakesDataQy.SetRange(Worksheet_Name,ItemJournalBatch."Journal Template Name");
        CSStockTakesDataQy.SetRange(Stock_Take_Config_Code,ItemJournalBatch.Name);
        CSStockTakesDataQy.SetRange(Transferred_To_Worksheet,false);
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
        if ResetItemJournalLine.FindSet then begin
          repeat
            ResetItemJournalLine.Validate("Qty. (Phys. Inventory)",0);
            ResetItemJournalLine.Modify(true);
          until ResetItemJournalLine.Next = 0;
        end;

        Clear(CSStockTakesDataTb);
        CSStockTakesDataTb.SetRange("Worksheet Name",ItemJournalBatch."Journal Template Name");
        CSStockTakesDataTb.SetRange("Stock-Take Config Code",ItemJournalBatch.Name);
        //CSStockTakesDataTb.SETFILTER("Item No.", '<>%1', '');
        // CSStockTakesDataTb.DELETEALL(FALSE);
        CSStockTakesDataTb.ModifyAll("Transferred To Worksheet",true);

        exit(StockTakeConfigCode)
        //+NPR5.52
    end;

    [Scope('Personalization')]
    procedure ResetWarehouseCounting(StockTakeConfigCode: Text;WorksheetName: Text): Text
    var
        CSSetup: Record "CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        CSStockTakesData: Record "CS Stock-Takes Data";
        CSStockTakeHandlingRfid: Record "CS Stock-Take Handling Rfid";
    begin
        //-NPR5.51
        //IF NOT StockTakeWorksheet.GET(StockTakeConfigCode,WorksheetName) THEN
        if not CSSetup.Get then
          exit(StrSubstNo(Txt010,CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",StockTakeConfigCode) then
          exit('UNKNOWNSTOCKTAKEWORKSHEET');
        //+NPR5.51

        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        //-NPR5.54 [389224]
        CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Warehouse);
        //+NPR5.54 [389224]
        //-NPR5.51
        //CSStockTakesData.SETRANGE("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        //CSStockTakesData.SETRANGE("Worksheet Name",StockTakeWorksheet.Name);
        CSStockTakesData.SetRange("Worksheet Name",ItemJournalBatch."Journal Template Name");
        CSStockTakesData.SetRange("Stock-Take Config Code",ItemJournalBatch.Name);
        //+NPR5.51
        CSStockTakesData.DeleteAll();

        //-NPR5.54 [389224]
        Clear(CSStockTakeHandlingRfid);
        CSStockTakeHandlingRfid.SetRange("Stock-Take Config Code",StockTakeConfigCode);
        CSStockTakeHandlingRfid.SetRange("Worksheet Name",ItemJournalBatch."Journal Template Name");
        CSStockTakeHandlingRfid.SetRange(Area,CSStockTakeHandlingRfid.Area::Warehouse);
        CSStockTakeHandlingRfid.DeleteAll();
        //+NPR5.54 [389224]

        exit(StockTakeConfigCode);
    end;

    [Scope('Personalization')]
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
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        CSWrapperFunctions: Codeunit "CS Wrapper Functions";
    begin
        //-NPR5.53 [374331]
        exit(CSWrapperFunctions.GetItemObject(Barcode));
        //+NPR5.53 [374331]
    end;

    [Scope('Personalization')]
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

    [Scope('Personalization')]
    procedure GetStoreData(CurrUser: Text): Text
    var
        CSStoreUsers: Record "CS Store Users";
        CSStockTakes: Record "CS Stock-Takes";
        POSStore: Record "POS Store";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        CSSetup: Record "CS Setup";
        Item: Record Item;
        CalculateInventory: Report "Calculate Inventory";
        QtyCalculated: Decimal;
    begin
        if CurrUser = '' then
          Error(Txt012);

        if StrLen(CurrUser) > MaxStrLen(CSStoreUsers."User ID") then
          Error(Txt012);

        CSStoreUsers.SetRange("User ID",CurrUser);
        if not CSStoreUsers.FindFirst then
          Error(Txt013);

        CSStoreUsers.TestField("POS Store");
        CSStoreUsers.TestField(Supervisor);
        POSStore.Get(CSStoreUsers."POS Store");
        POSStore.TestField("Location Code");
        SalespersonPurchaser.Get(CSStoreUsers.Supervisor);
        SalespersonPurchaser.TestField("Register Password");

        if StrLen(SalespersonPurchaser."Register Password") <> 6 then
          Error(Txt018);

        Location.Get(POSStore."Location Code");
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,POSStore."Location Code");
        CSStockTakes.SetRange(Closed,0DT);
        CSStockTakes.SetRange("Journal Posted",false);
        if CSStockTakes.FindFirst then begin
          CSStockTakes.TestField("Journal Template Name");
          CSStockTakes.TestField("Journal Batch Name");

          //-NPR5.53 [377467]
          //IF NOT CSStockTakes."Inventory Calculated" THEN
          //  ERROR(STRSUBSTNO(Txt015,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name"));
          if not CSStockTakes."Inventory Calculated" then begin
            CSSetup.Get;
            CSSetup.TestField("Phys. Inv Jour Temp Name");
            ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
            ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",Location.Code);

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",CSStockTakes."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",CSStockTakes."Journal Batch Name");
            if ItemJournalLine.Count > 0 then
              Error(Txt020,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name");

            Clear(ItemJournalLine);
            ItemJournalLine.Init;
            ItemJournalLine.Validate("Journal Template Name",CSStockTakes."Journal Template Name");
            ItemJournalLine.Validate("Journal Batch Name",CSStockTakes."Journal Batch Name");
            ItemJournalLine."Location Code" := CSStockTakes.Location;

            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
            ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

            Clear(Item);
            Item.SetFilter("Location Filter",CSStockTakes.Location);
            if not Item.FindSet then
              Error(Txt021,Location);

            Clear(CalculateInventory);
            CalculateInventory.UseRequestPage(false);
            CalculateInventory.SetTableView(Item);
            CalculateInventory.SetItemJnlLine(ItemJournalLine);
            CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
            CalculateInventory.RunModal;

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",CSStockTakes."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",CSStockTakes."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code",CSStockTakes.Location);
            if ItemJournalLine.FindSet then begin
              repeat
                QtyCalculated += ItemJournalLine."Qty. (Calculated)"
              until ItemJournalLine.Next = 0;
            end;

            CSStockTakes."Predicted Qty." := QtyCalculated;
            CSStockTakes."Inventory Calculated" := true;
            CSStockTakes.Modify(true);

          end;
          //+NPR5.53 [377467]

        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;

          WritePropertyName('item');
          WriteStartArray;

              WriteStartObject;

              WritePropertyName('StoreId');
              WriteValue(POSStore.Code);
              WritePropertyName('StoreName');
              WriteValue(POSStore.Name);
              WritePropertyName('StoreLocationCode');
              WriteValue(POSStore."Location Code");
              WritePropertyName('StoreLocationName');
              WriteValue(Location.Name);
              WritePropertyName('StoreAddress');
              WriteValue(POSStore.Address);
              WritePropertyName('StoreAddress2');
              WriteValue(POSStore."Address 2");
              WritePropertyName('StorePostCode');
              WriteValue(POSStore."Post Code");
              WritePropertyName('StoreCountryRegionCode');
              WriteValue(POSStore."Country/Region Code");
              WritePropertyName('StoreCity');
              WriteValue(POSStore.City);

              WritePropertyName('StoreSupervisorId');
              WriteValue(SalespersonPurchaser.Code);
              WritePropertyName('StoreSupervisorName');
              WriteValue(SalespersonPurchaser.Name);
              WritePropertyName('StoreSupervisorPassword');
              WriteValue(SalespersonPurchaser."Register Password");

              WritePropertyName('StockTakeId');
              WriteValue(Format(CSStockTakes."Stock-Take Id"));
              WritePropertyName('JournalTemplateName');
              WriteValue(CSStockTakes."Journal Template Name");
              WritePropertyName('JournalBatchName');
              WriteValue(CSStockTakes."Journal Batch Name");
              WritePropertyName('PredictedQty');
              WriteValue(Format(CSStockTakes."Predicted Qty."));

              WritePropertyName('StockroomClosed');
              if CSStockTakes."Stockroom Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('SalesfloorClosed');
              if CSStockTakes."Salesfloor Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('RefillClosed');
              if CSStockTakes."Refill Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('Approved');
              if CSStockTakes.Approved = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              //-NPR5.54 [389224]
              CSSetup.Get;
              WritePropertyName('BatchSize');
              if (CSSetup."Batch Size" > 10) and (CSSetup."Batch Size" < 1000) then
                WriteValue(CSSetup."Batch Size")
              else
                WriteValue('10');
              //-NPR5.54 [389224]

            WriteEndObject;

          WriteEndArray;

          WriteEndObject;
          JObject := Token;
          Result := JObject.ToString();

        end;

        exit(Result);
    end;

    [Scope('Personalization')]
    procedure StartStoreCounting(StockTakeId: Text;"Area": Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
    begin
        //IF STRLEN(StockTakeId) > MAXSTRLEN(CSStockTakes."Stock-Take Id") THEN
        //  EXIT(Txt016);

        if not CSStockTakes.Get(StockTakeId) then
          exit(StrSubstNo(Txt017,StockTakeId));

        case Area of
          '0' : begin
                  Error(Txt019);
                end;
          '1' : begin
                  if CSStockTakes."Salesfloor Started" = 0DT then begin
                    CSStockTakes."Salesfloor Started" := CurrentDateTime;
                    CSStockTakes."Salesfloor Started By" := UserId;
                    CSStockTakes.Modify(true);
                  end;
                end;
          '2' : begin
                  if CSStockTakes."Stockroom Started" = 0DT then begin
                    CSStockTakes."Stockroom Started" := CurrentDateTime;
                    CSStockTakes."Stockroom Started By" := UserId;
                    CSStockTakes.Modify(true);
                  end;
                end;
          '3' : begin
                  if CSStockTakes."Refill Started" = 0DT then begin
                    CSStockTakes."Refill Started" := CurrentDateTime;
                    CSStockTakes."Refill Started By" := UserId;
                    CSStockTakes.Modify(true);
                  end;
                end;
        end;

        exit(StockTakeId);
    end;

    [Scope('Personalization')]
    procedure CloseStoreCounting(StockTakeId: Text;"Area": Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
    begin
        if not CSStockTakes.Get(StockTakeId) then
          exit('UNKNOWNSTOCKTAKEID');

        case Area of
          '0' : begin
                  Error(Txt019);
                end;
          '1' : begin
                  if CSStockTakes."Salesfloor Closed" = 0DT then begin
                    CSStockTakes."Salesfloor Closed" := CurrentDateTime;
                    CSStockTakes."Salesfloor Closed By" := UserId;
                    CSStockTakes.Modify(true);
                  end;
                end;
          '2' : begin
                  if CSStockTakes."Stockroom Closed" = 0DT then begin
                    CSStockTakes."Stockroom Closed" := CurrentDateTime;
                    CSStockTakes."Stockroom Closed By" := UserId;
                    CSStockTakes.Modify(true);
                  end;
                end;
        end;

        exit(StockTakeId);
    end;

    [Scope('Personalization')]
    procedure ApproveStoreCounting(StockTakeId: Text): Text
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
        CSStockTakes: Record "CS Stock-Takes";
        PostingRecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
        CSPostEnqueue: Codeunit "CS Post - Enqueue";
        DocumentNo: Code[20];
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        if not CSStockTakes.Get(StockTakeId) then
          exit(StrSubstNo(Txt017,StockTakeId));

        //-NPR5.53 [375919]
        if CSStockTakes."Adjust Inventory" then begin
        //+NPR5.53 [375919]
          //-NPR5.53 [374331]
          CSSetup.Get;
          if CSSetup."Post with Job Queue" then begin
            PostingRecRef.GetTable(CSStockTakes);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Approve Counting";
            //-NPR5.53 [377462]
            CSPostingBuffer."Job Queue Priority for Post" := 2000;
            //+NPR5.53 [377462]
            if CSPostingBuffer.Insert(true) then begin
              CSPostEnqueue.Run(CSPostingBuffer);
              if CSStockTakes.Approved = 0DT then begin
                CSStockTakes.Approved := CurrentDateTime;
                CSStockTakes."Approved By" := UserId;
                CSStockTakes.Modify(true);
              end;
              exit(StockTakeId);
            end else
              exit(GetLastErrorText);
          end;
          //+NPR5.53 [374331]

          if not ItemJournalBatch.Get(CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name") then
            exit(StrSubstNo(Txt005,CSStockTakes."Journal Batch Name"));

          ItemJournalTemplate.Get(ItemJournalBatch."Journal Template Name");

          if ItemJournalTemplate."Source Code" = '' then
            exit(StrSubstNo(Txt006,ItemJournalTemplate.Name));

          Clear(BaseItemJournalLine);
          BaseItemJournalLine.Init;
          BaseItemJournalLine.Validate("Journal Template Name",ItemJournalBatch."Journal Template Name");
          BaseItemJournalLine.Validate("Journal Batch Name",ItemJournalBatch.Name);
          BaseItemJournalLine."Location Code" := ItemJournalBatch.Name;

          //-NPR5.52 [370277]
          //CLEAR(NoSeriesMgt);
          //BaseItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",BaseItemJournalLine."Posting Date",FALSE);
          BaseItemJournalLine."Document No." := Format(WorkDate);
          //+NPR5.52 [370277]
          BaseItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
          BaseItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
          BaseItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

          Clear(TestItemJournalLine);
          TestItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
          TestItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
          if TestItemJournalLine.FindLast then
            LineNo := TestItemJournalLine."Line No." + 1000
          else
            LineNo := 1000;

          //EXIT(STRSUBSTNO(Txt009,StockTakeConfigCode,WorksheetName));

          CSStockTakesDataQy.SetRange(Stock_Take_Id,StockTakeId);
          //-NPR5.52 [370277]
          //CSStockTakesDataQy.SETRANGE(Worksheet_Name,ItemJournalBatch."Journal Template Name");
          //CSStockTakesDataQy.SETRANGE(Stock_Take_Config_Code,ItemJournalBatch.Name);
          CSStockTakesDataQy.SetRange(Stock_Take_Config_Code,ItemJournalBatch."Journal Template Name");
          CSStockTakesDataQy.SetRange(Worksheet_Name,ItemJournalBatch.Name);
          //+NPR5.52 [370277]
          CSStockTakesDataQy.SetRange(Transferred_To_Worksheet,false);
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
          if ResetItemJournalLine.FindSet then begin
            repeat
              ResetItemJournalLine.Validate("Qty. (Phys. Inventory)",0);
              ResetItemJournalLine.Modify(true);
            until ResetItemJournalLine.Next = 0;
          end;
        //-NPR5.53 [375919]
        end;
        //+NPR5.53 [375919]

        Clear(CSStockTakesDataTb);
        CSStockTakesDataTb.SetRange("Stock-Take Id",StockTakeId);
        //-NPR5.53 [375919]
        //CSStockTakesDataQy.SETRANGE(Stock_Take_Config_Code,ItemJournalBatch."Journal Template Name");
        //CSStockTakesDataQy.SETRANGE(Worksheet_Name,ItemJournalBatch.Name);
        //+NPR5.53 [375919]
        //CSStockTakesDataTb.SETRANGE("Worksheet Name",ItemJournalBatch."Journal Template Name");
        //CSStockTakesDataTb.SETRANGE("Stock-Take Config Code",ItemJournalBatch.Name);
        CSStockTakesDataTb.SetRange("Stock-Take Config Code",ItemJournalBatch."Journal Template Name");
        CSStockTakesDataTb.SetRange("Worksheet Name",ItemJournalBatch.Name);
        CSStockTakesDataTb.ModifyAll("Transferred To Worksheet",true);

        if CSStockTakes.Approved = 0DT then begin
          CSStockTakes.Approved := CurrentDateTime;
          CSStockTakes."Approved By" := UserId;
          CSStockTakes.Modify(true);
        end;

        //-NPR5.53 [375919]
        if CSStockTakes."Adjust Inventory" then begin
          if (ItemJournalBatch."No. Series" <> '') then begin
            DocumentNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",WorkDate,false);
            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
            ItemJournalLine.ModifyAll("Document No.",DocumentNo,false);
          end;

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
          if ItemJournalLine.FindSet then begin
            repeat
              ItemJnlPostBatch.Run(ItemJournalLine);
            until ItemJournalLine.Next = 0;
          end;
        end;

        if CSStockTakes.Closed = 0DT then begin
          CSStockTakes.Closed := CurrentDateTime;
          CSStockTakes."Closed By" := UserId;
          //-NPR5.54 [384506]
          //CSStockTakes."Journal Posted" := CSStockTakes."Adjust Inventory";
          //CSStockTakes.MODIFY(TRUE);
          //+NPR5.54 [384506]
        end;
        //+NPR5.53 [375919]

        //-NPR5.54 [384506]
        CSStockTakes."Journal Posted" := CSStockTakes."Adjust Inventory";
        CSStockTakes.Modify(true);
        //+NPR5.54 [384506]

        exit(StockTakeId)
    end;

    [Scope('Personalization')]
    procedure ResetCounting(StockTakeConfigCode: Text;WorksheetName: Text;"Area": Text): Text
    var
        CSSetup: Record "CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        CSStockTakesData: Record "CS Stock-Takes Data";
        CSStockTakeHandlingRfid: Record "CS Stock-Take Handling Rfid";
    begin
        Clear(CSStockTakesData);
        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        CSStockTakesData.SetRange("Stock-Take Config Code",StockTakeConfigCode);
        CSStockTakesData.SetRange("Worksheet Name",WorksheetName);
        case Area of
          '0' : CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Warehouse);
          '1' : CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Salesfloor);
          '2' : CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Stockroom);
        end;
        CSStockTakesData.DeleteAll();

        //-NPR5.54 [389224]
        Clear(CSStockTakeHandlingRfid);
        CSStockTakeHandlingRfid.SetRange("Stock-Take Config Code",StockTakeConfigCode);
        CSStockTakeHandlingRfid.SetRange("Worksheet Name",WorksheetName);
        case Area of
          '0' : CSStockTakeHandlingRfid.SetRange(Area,CSStockTakeHandlingRfid.Area::Warehouse);
          '1' : CSStockTakeHandlingRfid.SetRange(Area,CSStockTakeHandlingRfid.Area::Salesfloor);
          '2' : CSStockTakeHandlingRfid.SetRange(Area,CSStockTakeHandlingRfid.Area::Stockroom);
        end;
        CSStockTakeHandlingRfid.DeleteAll();
        //+NPR5.54 [389224]

        exit(StockTakeConfigCode);
    end;

    [Scope('Personalization')]
    procedure CreateStoreRefillData(StockTakeId: Text) Result: Text
    var
        CSRefillData: Record "CS Refill Data";
        Item: Record Item;
        ItemGroup: Record "Item Group";
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSSetup: Record "CS Setup";
        CSRefillItems: Query "CS Refill Items";
        CSRefillSections: Query "CS Refill Sections";
        CSStockTakes: Record "CS Stock-Takes";
        CSStockTakesData: Record "CS Stock-Takes Data";
    begin
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if not CSStockTakes.Get(StockTakeId) then
          exit;

        if (CSStockTakes."Create Refill Data Started" = 0DT) then begin

          CSStockTakes."Create Refill Data Started" := CurrentDateTime;

          CSStockTakesData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
          CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Salesfloor);
          CSStockTakesData.SetRange("Transferred To Worksheet",false);
          if CSStockTakesData.FindSet then begin
            repeat
              if CSStockTakesData."Item No." <> '' then begin
                if not CSRefillData.Get(CSStockTakesData."Item No.",CSStockTakesData."Variant Code",CSStockTakes.Location,CSStockTakes."Stock-Take Id") then begin
                  CSRefillData.Init;
                  CSRefillData.Validate("Item No.",CSStockTakesData."Item No.");
                  CSRefillData.Validate("Variant Code",CSStockTakesData."Variant Code");
                  CSRefillData.Validate(Location,CSStockTakes.Location);
                  CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                  CSRefillData.Insert(true);
                end;

                if CSRefillData."Variant Code" <> '' then
                  CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                else
                  CSRefillData."Combined key" := CSRefillData."Item No.";

                CSRefillData."Qty. in Store" += 1;

                CSRefillData.Modify(true);
              end;
            until CSStockTakesData.Next = 0;
          end;

          Clear(CSStockTakesData);
          CSStockTakesData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
          CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Stockroom);
          CSStockTakesData.SetRange("Transferred To Worksheet",false);
          if CSStockTakesData.FindSet then begin
            repeat
              if CSStockTakesData."Item No." <> '' then begin
                if not CSRefillData.Get(CSStockTakesData."Item No.",CSStockTakesData."Variant Code",CSStockTakes.Location,CSStockTakes."Stock-Take Id") then begin
                  CSRefillData.Init;
                  CSRefillData.Validate("Item No.",CSStockTakesData."Item No.");
                  CSRefillData.Validate("Variant Code",CSStockTakesData."Variant Code");
                  CSRefillData.Validate(Location,CSStockTakes.Location);
                  CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                  CSRefillData.Insert(true);
                end;

                if CSRefillData."Variant Code" <> '' then
                  CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                else
                  CSRefillData."Combined key" := CSRefillData."Item No.";

                CSRefillData."Qty. in Stock" += 1;

                CSRefillData.Modify(true);
              end;
            until CSStockTakesData.Next = 0;
          end;

          CSStockTakes."Create Refill Data Ended" := CurrentDateTime;
          CSStockTakes.Modify;

        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
        WriteStartObject;

        WritePropertyName('section');
        WriteStartArray;
        CSRefillSections.SetFilter(Stock_Take_Id,CSStockTakes."Stock-Take Id");
        CSRefillSections.Open;
        while CSRefillSections.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRefillSections.Item_No);
            WritePropertyName('title');
            WriteValue(CSRefillSections.Item_Description);
            WritePropertyName('itemgroup');
            WriteValue(CSRefillSections.Item_Group_Code);
            WritePropertyName('marked');
            WriteValue(CSRefillSections.Refilled);
            WriteEndObject;
        end;
        CSRefillSections.Close;
        WriteEndArray;

        WritePropertyName('item');
        WriteStartArray;
        CSRefillItems.SetFilter(Stock_Take_Id,CSStockTakes."Stock-Take Id");
        CSRefillItems.Open;
        while CSRefillItems.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRefillItems.Combined_key);
            WritePropertyName('title');
            WriteValue(CSRefillItems.Item_Description);
            WritePropertyName('itemno');
            WriteValue(CSRefillItems.Item_No);
            WritePropertyName('variantcode');
            WriteValue(CSRefillItems.Variant_Code);
            WritePropertyName('varianttitle');
            WriteValue(CSRefillItems.Variant_Description);
            WritePropertyName('itemgroup');
            WriteValue(CSRefillItems.Item_Group_Code);
            WritePropertyName('imageurl');
            WriteValue(CSRefillItems.Image_Url);
            WritePropertyName('qtystock');
            WriteValue(CSRefillItems.Qty_in_Stock);
            WritePropertyName('qtystore');
            WriteValue(CSRefillItems.Qty_in_Store);
            WritePropertyName('marked');
            WriteValue(CSRefillItems.Refilled);
            WriteEndObject;
        end;
        CSRefillItems.Close;
        WriteEndArray;

        WriteEndObject;
        JObject := Token;
        end;

        Result := JObject.ToString();
    end;

    [Scope('Personalization')]
    procedure CreateStoreCounting(Location: Code[10]): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        LocationRec: Record Location;
    begin
        LocationRec.Get(Location);
        CSHelperFunctions.CreateNewCounting(LocationRec);
        exit('');
    end;

    [Scope('Personalization')]
    procedure CreateStoreCountingV2(Location: Code[10]): Text
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        LocationRec: Record Location;
    begin
        LocationRec.Get(Location);
        CSHelperFunctions.CreateNewCountingV2(LocationRec);
        exit('');
    end;

    [Scope('Personalization')]
    procedure SearchPOSStore(Word: Text): Text
    var
        CSItemSeachHandling: Record "CS Item Seach Handling" temporary;
        POSStore: Record "POS Store";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        CSSetup: Record "CS Setup";
        MaxItems: Integer;
        ItemsCounter: Integer;
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

        if StrLen(Word) <= MaxStrLen(POSStore.Code) then begin
          if POSStore.Get(Word) then begin
            CSItemSeachHandling.Init;
            CSItemSeachHandling."No." := POSStore.Code;
            CSItemSeachHandling.Description := POSStore.Name;
            CSItemSeachHandling."Description 2" := POSStore."Post Code";
            CSItemSeachHandling.Rank := 1;
            CSItemSeachHandling.Insert;
            ItemsCounter += 1;
          end;

          Clear(POSStore);
          POSStore.SetFilter(Code,'%1','@*' + Word + '*');
          if POSStore.FindSet then begin
            repeat
              if not CSItemSeachHandling.Get(POSStore.Code) then begin
                CSItemSeachHandling.Init;
                CSItemSeachHandling."No." := POSStore.Code;
                CSItemSeachHandling.Description := POSStore.Name;
                CSItemSeachHandling."Description 2" := POSStore."Post Code";
                CSItemSeachHandling.Rank := 2;
                CSItemSeachHandling.Insert;
                ItemsCounter += 1;
              end;
            until (POSStore.Next = 0) or (ItemsCounter = MaxItems);
          end;
        end;

        if (StrLen(Word) <= MaxStrLen(POSStore.Name)) then begin
          Clear(POSStore);
          POSStore.SetFilter(Name,'%1','@*' + Word + '*');
          if POSStore.FindSet and (ItemsCounter < MaxItems) then begin
            repeat
              if not CSItemSeachHandling.Get(POSStore.Code) then begin
                CSItemSeachHandling.Init;
                CSItemSeachHandling."No." := POSStore.Code;
                CSItemSeachHandling.Description := POSStore.Name;
                CSItemSeachHandling."Description 2" := POSStore."Post Code";
                CSItemSeachHandling.Rank := 3;
                CSItemSeachHandling.Insert;
                ItemsCounter += 1;
              end;
            until (POSStore.Next = 0) or (ItemsCounter = MaxItems);
          end;
        end;

        if (StrLen(Word) <= MaxStrLen(POSStore.City)) then begin
          Clear(POSStore);
          POSStore.SetFilter(City,'%1','@*' + Word + '*');
          if POSStore.FindSet and (ItemsCounter < MaxItems) then begin
            repeat
              if not CSItemSeachHandling.Get(POSStore.Code) then begin
                CSItemSeachHandling.Init;
                CSItemSeachHandling."No." := POSStore.Code;
                CSItemSeachHandling.Description := POSStore.Name;
                CSItemSeachHandling."Description 2" := POSStore."Post Code";
                CSItemSeachHandling.Rank := 5;
                CSItemSeachHandling.Insert;
                ItemsCounter += 1;
              end;
            until (POSStore.Next = 0) or (ItemsCounter = MaxItems);
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

    [Scope('Personalization')]
    procedure GetStoreDataV2(CurrUser: Text;POSStoreCode: Text): Text
    var
        CSStockTakes: Record "CS Stock-Takes";
        POSStore: Record "POS Store";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        CSSetup: Record "CS Setup";
        Item: Record Item;
        CalculateInventory: Report "Calculate Inventory";
        QtyCalculated: Decimal;
        CSCountingSupervisor: Record "CS Counting Supervisor";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CSStoreUsers: Record "CS Store Users";
    begin
        if CurrUser = '' then
          Error(Txt012);

        if StrLen(CurrUser) > MaxStrLen(CSCountingSupervisor."User ID") then
          Error(Txt012);

        if StrLen(POSStoreCode) > MaxStrLen(POSStore.Code) then
          Error(Txt022,POSStoreCode);

        if not CSCountingSupervisor.Get(CurrUser) then begin
          exit(GetStoreDataByStoreUser(CurrUser));
        end else begin

          if POSStoreCode <> '' then
            if not POSStore.Get(POSStoreCode) then
              Error(Txt022,POSStoreCode);

          CSCountingSupervisor.TestField(Pin);
          CSCountingSupervisor.CalcFields("Full Name");

          if POSStoreCode <> '' then begin

            CSStoreUsers.SetRange("POS Store",POSStore.Code);
            if CSStoreUsers.FindFirst then
              if CSStoreUsers.Supervisor <> '' then
                SalespersonPurchaser.Get(CSStoreUsers.Supervisor);

            POSStore.TestField("Location Code");
            Location.Get(POSStore."Location Code");
            Clear(CSStockTakes);
            CSStockTakes.SetRange(Location,Location.Code);
            CSStockTakes.SetRange(Closed,0DT);
            CSStockTakes.SetRange("Journal Posted",false);
            //-NPR5.54 [384506]
            CSStockTakes.SetRange("Adjust Inventory",true);
            //+NPR5.54 [384506]
            if CSStockTakes.FindFirst then begin
              //-NPR5.54 [384506]
              //IF CSStockTakes."Adjust Inventory" THEN BEGIN
              //+NPR5.54 [384506]
                CSStockTakes.TestField("Journal Template Name");
                CSStockTakes.TestField("Journal Batch Name");

                if not CSStockTakes."Inventory Calculated" then begin
                  CSSetup.Get;
                  CSSetup.TestField("Phys. Inv Jour Temp Name");
                  ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
                  ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",Location.Code);

                  Clear(ItemJournalLine);
                  ItemJournalLine.SetRange("Journal Template Name",CSStockTakes."Journal Template Name");
                  ItemJournalLine.SetRange("Journal Batch Name",CSStockTakes."Journal Batch Name");
                  if ItemJournalLine.Count > 0 then
                    Error(Txt020,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name");

                  Clear(ItemJournalLine);
                  ItemJournalLine.Init;
                  ItemJournalLine.Validate("Journal Template Name",CSStockTakes."Journal Template Name");
                  ItemJournalLine.Validate("Journal Batch Name",CSStockTakes."Journal Batch Name");
                  ItemJournalLine."Location Code" := CSStockTakes.Location;

                  Clear(NoSeriesMgt);
                  ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
                  ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
                  ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
                  ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

                  Clear(Item);
                  Item.SetFilter("Location Filter",CSStockTakes.Location);
                  if not Item.FindSet then
                    Error(Txt021,Location);

                  Clear(CalculateInventory);
                  CalculateInventory.UseRequestPage(false);
                  CalculateInventory.SetTableView(Item);
                  CalculateInventory.SetItemJnlLine(ItemJournalLine);
                  //-NPR5.53 [389864]
                  //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
                  CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
                  //+NPR5.53 [389864]
                  CalculateInventory.RunModal;

                  Clear(ItemJournalLine);
                  ItemJournalLine.SetRange("Journal Template Name",CSStockTakes."Journal Template Name");
                  ItemJournalLine.SetRange("Journal Batch Name",CSStockTakes."Journal Batch Name");
                  ItemJournalLine.SetRange("Location Code",CSStockTakes.Location);
                  if ItemJournalLine.FindSet then begin
                    repeat
                      QtyCalculated += ItemJournalLine."Qty. (Calculated)"
                    until ItemJournalLine.Next = 0;
                  end;

                  CSStockTakes."Predicted Qty." := QtyCalculated;
                  CSStockTakes."Inventory Calculated" := true;
                  CSStockTakes.Modify(true);

                end;
              //-NPR5.54 [384506]
              //END;
              //+NPR5.54 [384506]
            end;
          end;
        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;

          WritePropertyName('item');
          WriteStartArray;

              WriteStartObject;

              WritePropertyName('StoreId');
              WriteValue(POSStore.Code);
              WritePropertyName('StoreName');
              WriteValue(POSStore.Name);
              WritePropertyName('StoreLocationCode');
              WriteValue(POSStore."Location Code");
              WritePropertyName('StoreLocationName');
              WriteValue(Location.Name);
              WritePropertyName('StoreAddress');
              WriteValue(POSStore.Address);
              WritePropertyName('StoreAddress2');
              WriteValue(POSStore."Address 2");
              WritePropertyName('StorePostCode');
              WriteValue(POSStore."Post Code");
              WritePropertyName('StoreCountryRegionCode');
              WriteValue(POSStore."Country/Region Code");
              WritePropertyName('StoreCity');
              WriteValue(POSStore.City);

              WritePropertyName('CountingSupervisor');
              WriteValue('1');
              WritePropertyName('StoreSupervisorId');
              WriteValue(CSCountingSupervisor."User ID");
              WritePropertyName('StoreSupervisorName');
              WriteValue(CSCountingSupervisor."Full Name");
              WritePropertyName('StoreSupervisorPassword');
              WriteValue(CSCountingSupervisor.Pin);

              WritePropertyName('StockTakeId');
              WriteValue(Format(CSStockTakes."Stock-Take Id"));
              WritePropertyName('JournalTemplateName');
              WriteValue(CSStockTakes."Journal Template Name");
              WritePropertyName('JournalBatchName');
              WriteValue(CSStockTakes."Journal Batch Name");
              WritePropertyName('PredictedQty');
              WriteValue(Format(CSStockTakes."Predicted Qty."));

              WritePropertyName('StockroomClosed');
              if CSStockTakes."Stockroom Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('SalesfloorClosed');
              if CSStockTakes."Salesfloor Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('RefillClosed');
              if CSStockTakes."Refill Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('Approved');
              if CSStockTakes.Approved = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              //-NPR5.54 [389224]
              CSSetup.Get;
              WritePropertyName('BatchSize');
              if (CSSetup."Batch Size" > 10) and (CSSetup."Batch Size" < 1000) then
                WriteValue(CSSetup."Batch Size")
              else
                WriteValue('10');
              //-NPR5.54 [389224]

            WriteEndObject;

          WriteEndArray;

          WriteEndObject;
          JObject := Token;
          Result := JObject.ToString();

        end;

        exit(Result);
    end;

    [Scope('Personalization')]
    procedure GetStoreDataByStoreUser(CurrUser: Text): Text
    var
        CSStoreUsers: Record "CS Store Users";
        CSStockTakes: Record "CS Stock-Takes";
        POSStore: Record "POS Store";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        CSSetup: Record "CS Setup";
        Item: Record Item;
        CalculateInventory: Report "Calculate Inventory";
        QtyCalculated: Decimal;
    begin
        if CurrUser = '' then
          Error(Txt012);

        if StrLen(CurrUser) > MaxStrLen(CSStoreUsers."User ID") then
          Error(Txt012);

        CSStoreUsers.SetRange("User ID",CurrUser);
        if not CSStoreUsers.FindFirst then
          Error(Txt013);

        CSStoreUsers.TestField("POS Store");
        CSStoreUsers.TestField(Supervisor);
        POSStore.Get(CSStoreUsers."POS Store");
        POSStore.TestField("Location Code");
        SalespersonPurchaser.Get(CSStoreUsers.Supervisor);
        SalespersonPurchaser.TestField("Register Password");

        if StrLen(SalespersonPurchaser."Register Password") <> 6 then
          Error(Txt018);

        Location.Get(POSStore."Location Code");
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,POSStore."Location Code");
        CSStockTakes.SetRange(Closed,0DT);
        CSStockTakes.SetRange("Journal Posted",false);
        //-NPR5.54 [384506]
        if CSStoreUsers."Adjust Inventory" then
          CSStockTakes.SetRange("Adjust Inventory",true)
        else
          CSStockTakes.SetRange("Adjust Inventory",false);
        //+NPR5.54 [384506]
        if CSStockTakes.FindFirst then begin
          //-NPR5.53 [375919]
          if CSStockTakes."Adjust Inventory" then begin
          //+NPR5.53 [375919]
            CSStockTakes.TestField("Journal Template Name");
            CSStockTakes.TestField("Journal Batch Name");

            //-NPR5.53 [377467]
            //IF NOT CSStockTakes."Inventory Calculated" THEN
            //  ERROR(STRSUBSTNO(Txt015,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name"));
            if not CSStockTakes."Inventory Calculated" then begin
              CSSetup.Get;
              CSSetup.TestField("Phys. Inv Jour Temp Name");
              ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
              ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",Location.Code);

              Clear(ItemJournalLine);
              ItemJournalLine.SetRange("Journal Template Name",CSStockTakes."Journal Template Name");
              ItemJournalLine.SetRange("Journal Batch Name",CSStockTakes."Journal Batch Name");
              if ItemJournalLine.Count > 0 then
                Error(Txt020,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name");

              Clear(ItemJournalLine);
              ItemJournalLine.Init;
              ItemJournalLine.Validate("Journal Template Name",CSStockTakes."Journal Template Name");
              ItemJournalLine.Validate("Journal Batch Name",CSStockTakes."Journal Batch Name");
              ItemJournalLine."Location Code" := CSStockTakes.Location;

              Clear(NoSeriesMgt);
              ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
              ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
              ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
              ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

              Clear(Item);
              Item.SetFilter("Location Filter",CSStockTakes.Location);
              if not Item.FindSet then
                Error(Txt021,Location);

              Clear(CalculateInventory);
              CalculateInventory.UseRequestPage(false);
              CalculateInventory.SetTableView(Item);
              CalculateInventory.SetItemJnlLine(ItemJournalLine);
              //-NPR5.53 [389864]
              //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
              CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
              //+NPR5.53 [389864]
              CalculateInventory.RunModal;

              Clear(ItemJournalLine);
              ItemJournalLine.SetRange("Journal Template Name",CSStockTakes."Journal Template Name");
              ItemJournalLine.SetRange("Journal Batch Name",CSStockTakes."Journal Batch Name");
              ItemJournalLine.SetRange("Location Code",CSStockTakes.Location);
              if ItemJournalLine.FindSet then begin
                repeat
                  QtyCalculated += ItemJournalLine."Qty. (Calculated)"
                until ItemJournalLine.Next = 0;
              end;

              CSStockTakes."Predicted Qty." := QtyCalculated;
              CSStockTakes."Inventory Calculated" := true;
              CSStockTakes.Modify(true);

            end;
            //+NPR5.53 [377467]
          //-NPR5.53 [375919]
          end;
          //+NPR5.53 [375919]
        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;

          WritePropertyName('item');
          WriteStartArray;

              WriteStartObject;

              WritePropertyName('StoreId');
              WriteValue(POSStore.Code);
              WritePropertyName('StoreName');
              WriteValue(POSStore.Name);
              WritePropertyName('StoreLocationCode');
              WriteValue(POSStore."Location Code");
              WritePropertyName('StoreLocationName');
              WriteValue(Location.Name);
              WritePropertyName('StoreAddress');
              WriteValue(POSStore.Address);
              WritePropertyName('StoreAddress2');
              WriteValue(POSStore."Address 2");
              WritePropertyName('StorePostCode');
              WriteValue(POSStore."Post Code");
              WritePropertyName('StoreCountryRegionCode');
              WriteValue(POSStore."Country/Region Code");
              WritePropertyName('StoreCity');
              WriteValue(POSStore.City);
              //-NPR5.53 [375919]
              WritePropertyName('CountingSupervisor');
              WriteValue('0');
              //+NPR5.53 [375919]
              WritePropertyName('StoreSupervisorId');
              WriteValue(SalespersonPurchaser.Code);
              WritePropertyName('StoreSupervisorName');
              WriteValue(SalespersonPurchaser.Name);
              WritePropertyName('StoreSupervisorPassword');
              WriteValue(SalespersonPurchaser."Register Password");

              WritePropertyName('StockTakeId');
              WriteValue(Format(CSStockTakes."Stock-Take Id"));
              WritePropertyName('JournalTemplateName');
              WriteValue(CSStockTakes."Journal Template Name");
              WritePropertyName('JournalBatchName');
              WriteValue(CSStockTakes."Journal Batch Name");
              WritePropertyName('PredictedQty');
              WriteValue(Format(CSStockTakes."Predicted Qty."));

              WritePropertyName('StockroomClosed');
              if CSStockTakes."Stockroom Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('SalesfloorClosed');
              if CSStockTakes."Salesfloor Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('RefillClosed');
              if CSStockTakes."Refill Closed" = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              WritePropertyName('Approved');
              if CSStockTakes.Approved = 0DT then
                WriteValue('0')
              else
                WriteValue('1');

              //-NPR5.54 [389224]
              CSSetup.Get;
              WritePropertyName('BatchSize');
              if (CSSetup."Batch Size" > 10) and (CSSetup."Batch Size" < 1000) then
                WriteValue(CSSetup."Batch Size")
              else
                WriteValue('10');
              //-NPR5.54 [389224]

            WriteEndObject;

          WriteEndArray;

          WriteEndObject;
          JObject := Token;
          Result := JObject.ToString();

        end;

        exit(Result);
    end;

    [Scope('Personalization')]
    procedure SetRfidTagDataByTypeBatch(StockTakeId: Text;StockTakeConfigCode: Text;WorksheetName: Text;TagIds: Text;"Area": Text;DeviceId: Code[10];BatchId: Text) ResultData: Text
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
        TagData: Text;
    begin
        BigTextData.AddText(TagIds);

        CSStockTakeHandlingRfid.Init;
        CSStockTakeHandlingRfid.Id := CreateGuid;
        CSStockTakeHandlingRfid."Batch Id" := BatchId;
        CSStockTakeHandlingRfid.Created := CurrentDateTime;
        CSStockTakeHandlingRfid."Created By" := UserId;
        CSStockTakeHandlingRfid."Request Function" := 'StockTakeRfid';
        CSStockTakeHandlingRfid."Stock-Take Id" := StockTakeId;
        CSStockTakeHandlingRfid."Stock-Take Config Code" := StockTakeConfigCode;
        CSStockTakeHandlingRfid."Worksheet Name" := WorksheetName;
        case Area of
          '0' : CSStockTakeHandlingRfid.Area := CSStockTakeHandlingRfid.Area::Warehouse;
          '1' : CSStockTakeHandlingRfid.Area := CSStockTakeHandlingRfid.Area::Salesfloor;
          '2' : CSStockTakeHandlingRfid.Area := CSStockTakeHandlingRfid.Area::Stockroom;
        end;
        CSStockTakeHandlingRfid."Device Id" := DeviceId;
        CSStockTakeHandlingRfid."Posting Started" := CurrentDateTime;
        CSStockTakeHandlingRfid."Request Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);

        CSStockTakeHandlingRfid.Insert(false);
        Commit;

        CommaString := TagIds;
        Separator := ',';
        Values := CommaString.Split(Separator.ToCharArray());
        CSStockTakeHandlingRfid.Tags := Values.Length;
        CSStockTakeHandlingRfid.Modify(false);
        Commit;

        Clear(Ostream);
        Clear(BigTextData);

        ResultData := '';
        TagData := '';

        foreach Value in Values do begin
          if Value <> '' then begin
            TagData := Value + '|' + SetRfidTagDataByType(CSStockTakeHandlingRfid."Stock-Take Id",
                                            CSStockTakeHandlingRfid."Stock-Take Config Code",
                                            CSStockTakeHandlingRfid."Worksheet Name",
                                            Value,
                                            Area);
            if ResultData = '' then
              ResultData := TagData
            else
              ResultData := ResultData + ',' + TagData;
          end;
        end;

        CSStockTakeHandlingRfid."Batch Posting" := true;
        CSStockTakeHandlingRfid."Posting Ended" := CurrentDateTime;
        CSStockTakeHandlingRfid.Handled := true;
        CSStockTakeHandlingRfid.Modify(true);

        BigTextData.AddText(ResultData);
        CSStockTakeHandlingRfid."Response Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);
        CSStockTakeHandlingRfid.Modify(false);
        exit(ResultData);
    end;

    [Scope('Personalization')]
    procedure CreateStoreRefillDataV2(StockTakeId: Text) Result: Text
    var
        CSRefillData: Record "CS Refill Data" temporary;
        Item: Record Item;
        ItemGroup: Record "Item Group";
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSSetup: Record "CS Setup";
        CSStockTakes: Record "CS Stock-Takes";
        CSStockTakesData: Record "CS Stock-Takes Data";
        CSRefillSectionData: Record "CS Refill Section Data" temporary;
    begin
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if not CSStockTakes.Get(StockTakeId) then
          exit;

        Clear(CSRefillData);
        Clear(CSRefillSectionData);

        CSStockTakes."Create Refill Data Started" := CurrentDateTime;

        CSStockTakesData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
        CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Salesfloor);
        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        if CSStockTakesData.FindSet then begin
          repeat
            if CSStockTakesData."Item No." <> '' then begin
              if not CSRefillData.Get(CSStockTakesData."Item No.",CSStockTakesData."Variant Code",CSStockTakes.Location,CSStockTakes."Stock-Take Id") then begin
                CSStockTakesData.CalcFields("Item Description","Variant Description");
                CSRefillData.Init;
                CSRefillData.Validate("Item No.",CSStockTakesData."Item No.");
                CSRefillData.Validate("Variant Code",CSStockTakesData."Variant Code");
                CSRefillData.Validate(Location,CSStockTakes.Location);
                CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                CSRefillData."Item Description" := CSStockTakesData."Item Description";
                CSRefillData."Variant Description" := CSStockTakesData."Variant Description";
                CSRefillData.Insert(true);
              end;

              if CSRefillData."Variant Code" <> '' then
                CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
              else
                CSRefillData."Combined key" := CSRefillData."Item No.";

              CSRefillData."Qty. in Store" += 1;

              CSRefillData.Modify(true);

            end;
          until CSStockTakesData.Next = 0;
        end;

        Clear(CSStockTakesData);
        CSStockTakesData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
        CSStockTakesData.SetRange(Area,CSStockTakesData.Area::Stockroom);
        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        if CSStockTakesData.FindSet then begin
          repeat
            if CSStockTakesData."Item No." <> '' then begin
              if not CSRefillData.Get(CSStockTakesData."Item No.",CSStockTakesData."Variant Code",CSStockTakes.Location,CSStockTakes."Stock-Take Id") then begin
                CSStockTakesData.CalcFields("Item Description","Variant Description");
                CSRefillData.Init;
                CSRefillData.Validate("Item No.",CSStockTakesData."Item No.");
                CSRefillData.Validate("Variant Code",CSStockTakesData."Variant Code");
                CSRefillData.Validate(Location,CSStockTakes.Location);
                CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                CSRefillData."Item Description" := CSStockTakesData."Item Description";
                CSRefillData."Variant Description" := CSStockTakesData."Variant Description";
                CSRefillData.Insert(true);
              end;

              if CSRefillData."Variant Code" <> '' then
                CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
              else
                CSRefillData."Combined key" := CSRefillData."Item No.";

              CSRefillData."Qty. in Stock" += 1;

              CSRefillData.Modify(true);
            end;
          until CSStockTakesData.Next = 0;
        end;

        CSRefillData.SetFilter("Qty. in Store",'>0');
        CSRefillData.DeleteAll(false);
        CSRefillData.Reset;

        if CSRefillData.FindFirst then begin
          repeat
            if not CSRefillSectionData.Get(CSStockTakesData."Item No.") then begin
              CSRefillSectionData.Init;
              CSRefillSectionData.Validate("Item No.",CSRefillData."Item No.");
              CSRefillSectionData."Item Description" := CSRefillData."Item Description";
              CSRefillSectionData.Refilled := CSRefillData.Refilled;
              CSRefillSectionData.Insert(true);
            end;
          until CSRefillData.Next = 0;
        end;

        CSStockTakes."Create Refill Data Ended" := CurrentDateTime;
        CSStockTakes.Modify;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
        WriteStartObject;

        WritePropertyName('section');
        WriteStartArray;
        if CSRefillSectionData.FindFirst then begin
          repeat
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRefillSectionData."Item No.");
            WritePropertyName('title');
            WriteValue(CSRefillSectionData."Item Description");
            WritePropertyName('itemgroup');
            WriteValue('');
            WritePropertyName('marked');
            WriteValue(CSRefillSectionData.Refilled);
            WriteEndObject;
          until CSRefillSectionData.Next = 0;
        end;
        WriteEndArray;

        WritePropertyName('item');
        WriteStartArray;
        if CSRefillData.FindFirst then begin
          repeat
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRefillData."Combined key");
            WritePropertyName('title');
            WriteValue(CSRefillData."Item Description");
            WritePropertyName('itemno');
            WriteValue(CSRefillData."Item No.");
            WritePropertyName('variantcode');
            WriteValue(CSRefillData."Variant Code");
            WritePropertyName('varianttitle');
            WriteValue(CSRefillData."Variant Description");
            WritePropertyName('itemgroup');
            WriteValue(CSRefillData."Item Group Code");
            WritePropertyName('imageurl');
            WriteValue(CSRefillData."Image Url");
            WritePropertyName('qtystock');
            WriteValue(CSRefillData."Qty. in Stock");
            WritePropertyName('qtystore');
            WriteValue(CSRefillData."Qty. in Store");
            WritePropertyName('marked');
            WriteValue(CSRefillData.Refilled);
            WriteEndObject;
          until CSRefillData.Next = 0;
        end;
        WriteEndArray;

        WriteEndObject;
        JObject := Token;
        end;

        Result := JObject.ToString();
    end;
}

