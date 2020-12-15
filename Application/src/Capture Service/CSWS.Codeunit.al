codeunit 6151372 "NPR CS WS"
{
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
        Txt023: Label 'RFID Document: %1, do not exist';
        Txt024: Label 'Document can''t be closed when there is no tags collected';
        NoRfidModelsInDBErr: Label 'There are no Rfid models set up in "%1" please make sure that either values are available or the "%2" check in %3 is switched off';

    procedure ProcessDocument(var Document: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InputXmlDocument: XmlDocument;
        OutputXmlDocument: XmlDocument;
        CSManagement: Codeunit "NPR CS Management";
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        CSCommunicationLog: Record "NPR CS Comm. Log";
        IsEnable: Boolean;
        LogCommunication: Boolean;
    begin
        CSHelperFunctions.CreateLogEntry(CSCommunicationLog, Document, IsEnable, LogCommunication);

        XmlDocument.ReadFrom(Document, InputXmlDocument);

        CSManagement.ProcessDocument(InputXmlDocument);
        CSManagement.GetOutboundDocument(OutputXmlDocument);
        OutputXmlDocument.WriteTo(Document);

        CSHelperFunctions.UpdateLogEntry(CSCommunicationLog, 'ProcessDocument', IsInternal, InternalCallId, Document, LogCommunication, '');
    end;

    procedure ProcessData(DeviceId: Code[10]; BatchId: Text; BatchNo: Text; PostData: Text; StockTakeConfig: Text; WorksheetName: Text; var Data: Text)
    var
        CSStockTakeHandlingRfid: Record "NPR CS Stock-Take Handl. Rfid";
        OK: Boolean;
        SessionID: Integer;
        Ostream: OutStream;
        BigTextData: BigText;
        ValInt: Integer;
        ValBool: Boolean;
        CommaString: Text;
        Separator: Text;
        Value: Text;
        Values: List of [Text];
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

        if Evaluate(ValInt, BatchNo) then
            CSStockTakeHandlingRfid."Batch No." := ValInt;
        if Evaluate(ValBool, PostData) then
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
        Values := CommaString.Split(Separator);
        CSStockTakeHandlingRfid.Tags := Values.Count;
        CSStockTakeHandlingRfid.Modify(false);
        Commit;

        Clear(Ostream);
        Clear(BigTextData);

        Data := '';

        if CSStockTakeHandlingRfid."Batch Posting" then begin
            OK := StartSession(SessionID, CODEUNIT::"NPR CS UI StockTake Hand. Rfid", CompanyName, CSStockTakeHandlingRfid);
            if not OK then begin
                CSStockTakeHandlingRfid."Posting Error" := Format(CODEUNIT::"NPR CS UI StockTake Hand. Rfid");
                CSStockTakeHandlingRfid."Posting Error Detail" := GetLastErrorText;
            end;
        end;

        BigTextData.AddText(Data);
        CSStockTakeHandlingRfid."Response Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);
        CSStockTakeHandlingRfid.Modify(false);
    end;

    procedure IsInternalCall(LocalIsInternal: Boolean; LocalId: Guid)
    begin
        IsInternal := LocalIsInternal;
        InternalCallId := LocalId;
    end;

    procedure GetItemInfoByBarcode(Barcode: Code[20]): Text
    var
        Item: Record Item;
        BarcodeLibrary: Codeunit "NPR Barcode Library";
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
            exit(StrSubstNo('%1#%2', MasterTxt, DetailTxt));

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
            exit(StrSubstNo('%1#%2', MasterTxt, DetailTxt));

        if not Item.Get(ItemNo) then
            exit(StrSubstNo('%1#%2', MasterTxt, DetailTxt));

        if VariantCode <> '' then
            Item.SetFilter("Variant Filter", VariantCode);

        Item.CalcFields(Inventory, "Qty. on Purch. Order");

        DetailTxt := Format(Item.Inventory);
        ItemInventoryTxt := StrSubstNo('Stock: %1', Item.Inventory);

        if Item."Qty. on Purch. Order" > 0 then begin
            Clear(PurchaseLine);
            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetRange("No.", Item."No.");
            if VariantCode <> '' then
                PurchaseLine.SetRange("Variant Code", VariantCode);
            if PurchaseLine.FindLast then
                PurchaseLineExpectedReceiptDateTxt := StrSubstNo('Exp.: %1', PurchaseLine."Expected Receipt Date")
            else
                PurchaseLineExpectedReceiptDateTxt := StrSubstNo('Exp.: %1', 'n/a');
        end else
            PurchaseLineExpectedReceiptDateTxt := StrSubstNo('Exp.: %1', 'n/a');

        Clear(ItemLedgerEntry);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        if VariantCode <> '' then
            ItemLedgerEntry.SetRange("Variant Code", VariantCode);
        if ItemLedgerEntry.FindLast then
            ItemLedgerEntryPostingDateTxt := StrSubstNo('Last: %1', ItemLedgerEntry."Posting Date")
        else
            ItemLedgerEntryPostingDateTxt := StrSubstNo('Last: %1', 'n/a');

        MasterTxt := StrSubstNo('%1\n%2\n%3', ItemInventoryTxt, PurchaseLineExpectedReceiptDateTxt, ItemLedgerEntryPostingDateTxt);

        exit(StrSubstNo('%1#%2', DetailTxt, MasterTxt));
    end;

    procedure GetItemPicture(Barcode: Code[20]) PictureBase64: Text
    var
        CSWrapperFunctions: Codeunit "NPR CS Wrapper Functions";
    begin
        exit(CSWrapperFunctions.GetItemPicture(Barcode));
    end;

    procedure SearchItem(Word: Text): Text
    var
        CSItemSeachHandling: Record "NPR CS Item Search Handl." temporary;
        Item: Record Item;
        JObject: JsonObject;
        Result: Text;
        MaxItems: Integer;
        ItemsCounter: Integer;
        CSSetup: Record "NPR CS Setup";
        ItemsArray: JsonArray;
        ItemsObject: JsonObject;
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

            Item.SetFilter("No.", '%1', '@*' + Word + '*');
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
            Item.SetFilter(Description, '%1', '@*' + Word + '*');
            if Item.FindSet and (ItemsCounter < MaxItems) then begin
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
            Item.SetFilter("Description 2", '%1', '@*' + Word + '*');
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

        CSItemSeachHandling.SetCurrentKey(Rank, "No.");
        if CSItemSeachHandling.FindSet then begin
            repeat
                Clear(ItemsObject);
                ItemsObject.Add('key', CSItemSeachHandling."No.");
                ItemsObject.Add('description1', CSItemSeachHandling.Description);
                ItemsObject.Add('description2', CSItemSeachHandling."Description 2");
                ItemsArray.Add(ItemsObject);
            until CSItemSeachHandling.Next = 0;
            JObject.Add('items', ItemsArray);
            JObject.WriteTo(Result);
        end;

        exit(Result);
    end;

    procedure GetRfidOfflineDataDelta(DeviceId: Code[20]): Text
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateOfflineRfidDataDelta(DeviceId));
    end;

    procedure UpdateRfidDeviceInfo(DeviceId: Code[20]; Lasttimestamp: Text; Location: Code[20]): Text
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        Timestamp: BigInteger;
    begin
        if not Evaluate(Timestamp, Lasttimestamp) then
            exit;

        if Timestamp = 0 then
            exit;

        exit(CSHelperFunctions.UpdateDeviceInfo(DeviceId, Timestamp, Location));
    end;

    procedure GetRefillData(StockTakeId: Text): Text
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
    begin
        exit(CSHelperFunctions.CreateRefillData(StockTakeId));
    end;

    procedure GetRfidTagData(TagId: Text): Text
    var
        CSRfidData: Record "NPR CS Rfid Data";
        CSRfidTagModels: Record "NPR CS Rfid Tag Models";
        TagFamily: Code[10];
        TagModel: Code[10];
        CSRfidItemPlaceholder: Record "NPR CS Rfid Item Handl.";
    begin
        if (StrLen(TagId) > MaxStrLen(CSRfidItemPlaceholder."Rfid Id")) or (StrLen(TagId) < MaxStrLen(CSRfidTagModels.Family)) then
            exit('UNKNOWNITEM');

        TagFamily := CopyStr(TagId, 1, 4);
        TagModel := CopyStr(TagId, 5, 4);

        if not CSRfidTagModels.Get(TagFamily, TagModel) then
            exit('UNKNOWNITEM');

        if CSRfidTagModels.Discontinued then
            exit('UNKNOWNITEM');

        if CSRfidData.Get(TagId) then
            exit(CSRfidData."Combined key")
        else
            exit('UNKNOWNITEM');
    end;

    procedure SetRfidTagData(StockTakeId: Text; StockTakeConfigCode: Text; WorksheetName: Text; TagId: Text): Text
    var
        CSStockTakesData: Record "NPR CS Stock-Takes Data";
        CSRfidData: Record "NPR CS Rfid Data";
        Result: Text;
    begin
        CSStockTakesData."Stock-Take Id" := StockTakeId;
        CSStockTakesData."Stock-Take Config Code" := StockTakeConfigCode;
        CSStockTakesData."Worksheet Name" := WorksheetName;
        CSStockTakesData."Tag Id" := TagId;
        CSStockTakesData.Created := CurrentDateTime;
        CSStockTakesData."Created By" := UserId;
        if CSRfidData.Get(TagId) then begin
            CSStockTakesData.Validate("Item No.", CSRfidData."Cross-Reference Item No.");
            CSStockTakesData.Validate("Variant Code", CSRfidData."Cross-Reference Variant Code");
            CSStockTakesData.Validate("Item Group Code", CSRfidData."Item Group Code");
            CSStockTakesData."Combined key" := CSRfidData."Combined key";
            Result := CSRfidData."Combined key";
        end else
            Result := 'UNKNOWNITEM';
        if CSStockTakesData.Insert() then
            exit(Result)
        else
            exit(Result);
    end;

    procedure SetRfidTagDataByType(StockTakeId: Text; StockTakeConfigCode: Text; WorksheetName: Text; TagId: Text; "Area": Text): Text
    var
        CSStockTakesData: Record "NPR CS Stock-Takes Data";
        CSRfidData: Record "NPR CS Rfid Data";
        Result: Text;
    begin
        CSStockTakesData."Stock-Take Id" := StockTakeId;
        CSStockTakesData."Stock-Take Config Code" := StockTakeConfigCode;
        CSStockTakesData."Worksheet Name" := WorksheetName;
        CSStockTakesData."Tag Id" := TagId;
        CSStockTakesData.Created := CurrentDateTime;
        CSStockTakesData."Created By" := UserId;
        case Area of
            '0':
                CSStockTakesData.Area := CSStockTakesData.Area::Warehouse;
            '1':
                CSStockTakesData.Area := CSStockTakesData.Area::Salesfloor;
            '2':
                CSStockTakesData.Area := CSStockTakesData.Area::Stockroom;
        end;
        if CSRfidData.Get(TagId) then begin
            CSStockTakesData.Validate("Item No.", CSRfidData."Cross-Reference Item No.");
            CSStockTakesData.Validate("Variant Code", CSRfidData."Cross-Reference Variant Code");
            CSStockTakesData.Validate("Item Group Code", CSRfidData."Item Group Code");
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
        JObject: JsonObject;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemGroup: Record "NPR Item Group";
        Result: Text;
        ItemArray: JsonArray;
        ItemObject: JsonObject;
    begin
        if DocNo = '' then
            exit;

        WhseReceiptLine.SetRange("No.", DocNo);
        if WhseReceiptLine.FindSet then begin
            repeat
                Item.Get(WhseReceiptLine."Item No.");
                if WhseReceiptLine."Variant Code" <> '' then
                    ItemObject.Add('key', WhseReceiptLine."Item No." + '-' + WhseReceiptLine."Variant Code")
                else
                    ItemObject.Add('key', WhseReceiptLine."Item No.");
                ItemObject.Add('title', WhseReceiptLine.Description);
                ItemObject.Add('itemno', WhseReceiptLine."Item No.");
                ItemObject.Add('variantcode', WhseReceiptLine."Variant Code");
                if ItemVariant.Get(Item."No.", WhseReceiptLine."Variant Code") then
                    ItemObject.Add('varianttitle', ItemVariant.Description)
                else
                    ItemObject.Add('varianttitle', '');
                ItemObject.Add('itemgroup', Item."NPR Item Group");
                ItemObject.Add('qtytoreceive', WhseReceiptLine."Qty. to Receive");
                ItemObject.Add('qtyoutstanding', WhseReceiptLine."Qty. Outstanding");

                ItemArray.Add(ItemObject);
            until WhseReceiptLine.Next = 0;
        end;

        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);

        exit(Result);
    end;

    procedure ValidateRfidWhseReceiptData(DocNo: Text; TagId: Text): Text
    var
        CSRfidData: Record "NPR CS Rfid Data";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        if CSRfidData.Get(TagId) then begin
            WhseReceiptLine.SetRange("No.", DocNo);
            WhseReceiptLine.SetRange("Item No.", CSRfidData."Cross-Reference Item No.");
            if WhseReceiptLine.FindFirst then
                exit(CSRfidData."Combined key" + '#0')
            else
                exit(CSRfidData."Combined key" + '#1');
        end else
            exit('UNKNOWNITEM#2');
    end;

    procedure SaveRfidWhseReceiptData(DocNo: Text): Text
    var
        CSWhseReceiptData: Record "NPR CS Whse. Receipt Data";
        Result: Text;
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Tag Type", CSWhseReceiptData."Tag Type"::Unknown);
        if CSWhseReceiptData.FindSet then
            exit(StrSubstNo(Txt001, DocNo));

        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Tag Type", CSWhseReceiptData."Tag Type"::"Not on Document");
        if CSWhseReceiptData.FindSet then
            exit(StrSubstNo(Txt002, DocNo));

        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Tag Type", CSWhseReceiptData."Tag Type"::Document);
        CSWhseReceiptData.SetRange("Transferred To Doc", false);
        if not CSWhseReceiptData.FindSet then begin
            exit(StrSubstNo(Txt003, DocNo));
        end else begin
            repeat
                Clear(WhseReceiptLine);
                WhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                WhseReceiptLine.SetRange("No.", CSWhseReceiptData."Doc. No.");
                WhseReceiptLine.SetRange("Item No.", CSWhseReceiptData."Item No.");
                WhseReceiptLine.SetRange("Variant Code", CSWhseReceiptData."Variant Code");
                if WhseReceiptLine.FindSet then begin
                    if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding" then
                        exit(StrSubstNo(Txt004, CSWhseReceiptData."Item No.", CSWhseReceiptData."Variant Code"));
                    WhseReceiptLine.Validate("Qty. to Receive", WhseReceiptLine."Qty. to Receive" + 1);
                    WhseReceiptLine.Modify(true);
                end;

                CSWhseReceiptData.Transferred := CurrentDateTime;
                CSWhseReceiptData."Transferred By" := UserId;
                CSWhseReceiptData."Transferred To Doc" := true;
                CSWhseReceiptData.Modify();

            until CSWhseReceiptData.Next = 0;
        end;
    end;

    procedure CloseCounting(StockTakeId: Text; WorksheetName: Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
    begin
        if not CSStockTakes.Get(StockTakeId) then
            exit('UNKNOWNSTOCKTAKEID');

        case WorksheetName of
            'SALESFLOOR':
                begin
                    if CSStockTakes."Salesfloor Closed" = 0DT then begin
                        CSStockTakes."Salesfloor Closed" := CurrentDateTime;
                        CSStockTakes."Salesfloor Closed By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
            'STOCKROOM':
                begin
                    if CSStockTakes."Stockroom Closed" = 0DT then begin
                        CSStockTakes."Stockroom Closed" := CurrentDateTime;
                        CSStockTakes."Stockroom Closed By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
        end;

        Commit;

        OK := StartSession(SessionID, CODEUNIT::"NPR CS UI Store Count. Handl.", CompanyName, CSStockTakes);
        if not OK then begin
            //TO DO GETLASTERRORTEXT;
        end;

        exit(StockTakeId);
    end;

    procedure CloseRefill(StockTakeId: Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
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

    procedure UpdateRefill(StockTakeId: Text; ItemNo: Text; Refilled: Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
        Item: Record Item;
        CSRefillData: Record "NPR CS Refill Data";
        RefillStatus: Boolean;
    begin
        if not CSStockTakes.Get(StockTakeId) then
            exit('UNKNOWNSTOCKTAKEID');

        if not Item.Get(ItemNo) then
            exit('UNKNOWNITEMNO');

        if not ((Refilled = '0') or (Refilled = '1')) then
            exit;

        RefillStatus := (Refilled = '1');

        CSRefillData.SetRange("Stock-Take Id", CSStockTakes."Stock-Take Id");
        CSRefillData.SetRange("Item No.", Item."No.");
        if CSRefillData.FindSet then begin
            repeat
                CSRefillData.Refilled := RefillStatus;
                CSRefillData."Refilled By" := UserId;
                CSRefillData."Refilled Date" := CurrentDateTime;
                CSRefillData.Modify;
            until CSRefillData.Next = 0;
        end else begin
            CSRefillData.Init;
            CSRefillData."Item No." := Item."No.";
            CSRefillData.Location := CSStockTakes.Location;
            CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
            CSRefillData.Refilled := RefillStatus;
            CSRefillData."Refilled By" := UserId;
            CSRefillData."Refilled Date" := CurrentDateTime;
            CSRefillData.Insert;
        end;

        exit(StockTakeId);
    end;

    procedure ApproveCounting(StockTakeId: Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
    begin
        if not CSStockTakes.Get(StockTakeId) then
            exit('UNKNOWNSTOCKTAKEID');

        if CSStockTakes.Approved = 0DT then begin
            CSStockTakes.Approved := CurrentDateTime;
            CSStockTakes."Approved By" := UserId;
            CSStockTakes.Modify(true);

            StockTakeWorksheet.Get(CSStockTakes.Location, 'STOCKROOM');
            StockTakeWorksheet.Validate(Status, StockTakeWorksheet.Status::READY_TO_TRANSFER);
            if StockTakeWorksheet.Modify(true) then
                StartSession(SessionID, CODEUNIT::"NPR CS UI Store Transf. Handl.", CompanyName, StockTakeWorksheet);

            StockTakeWorksheet.Get(CSStockTakes.Location, 'SALESFLOOR');
            StockTakeWorksheet.Validate(Status, StockTakeWorksheet.Status::READY_TO_TRANSFER);
            if StockTakeWorksheet.Modify(true) then
                StartSession(SessionID, CODEUNIT::"NPR CS UI Store Transf. Handl.", CompanyName, StockTakeWorksheet);
        end;

        exit(StockTakeId);
    end;

    procedure CloseWarehouseCounting(StockTakeConfigCode: Text; WorksheetName: Text): Text
    var
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        OK: Boolean;
        SessionID: Integer;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        BaseItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CSStockTakesDataTb: Record "NPR CS Stock-Takes Data";
        TestItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        NewItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "NPR CS Setup";
        CSStockTakesDataQy: Query "NPR CS Stock-Takes Data";
        ItemJournalLine: Record "Item Journal Line";
        ResetItemJournalLine: Record "Item Journal Line";
    begin
        if not CSSetup.Get then
            exit(StrSubstNo(Txt010, CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", StockTakeConfigCode) then
            exit(StrSubstNo(Txt005, StockTakeConfigCode));

        ItemJournalTemplate.Get(ItemJournalBatch."Journal Template Name");

        if ItemJournalTemplate."Source Code" = '' then
            exit(StrSubstNo(Txt006, ItemJournalTemplate.Name));

        Clear(BaseItemJournalLine);
        BaseItemJournalLine.Init;
        BaseItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        BaseItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
        BaseItemJournalLine."Location Code" := ItemJournalBatch.Name;

        BaseItemJournalLine."Document No." := Format(WorkDate);
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

        CSStockTakesDataQy.SetRange(Worksheet_Name, ItemJournalBatch."Journal Template Name");
        CSStockTakesDataQy.SetRange(Stock_Take_Config_Code, ItemJournalBatch.Name);
        CSStockTakesDataQy.SetRange(Transferred_To_Worksheet, false);
        CSStockTakesDataQy.Open;
        while CSStockTakesDataQy.Read do begin
            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
            ItemJournalLine.SetRange("Item No.", CSStockTakesDataQy.ItemNo);
            ItemJournalLine.SetRange("Variant Code", CSStockTakesDataQy.Variant_Code);
            if not ItemJournalLine.FindSet then begin
                Clear(NewItemJournalLine);
                NewItemJournalLine.Validate("Journal Template Name", BaseItemJournalLine."Journal Template Name");
                NewItemJournalLine.Validate("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
                NewItemJournalLine."Line No." := LineNo;
                NewItemJournalLine.Insert(true);

                NewItemJournalLine.Validate("Entry Type", NewItemJournalLine."Entry Type"::"Positive Adjmt.");
                NewItemJournalLine.Validate("Item No.", CSStockTakesDataQy.ItemNo);
                NewItemJournalLine.Validate("Variant Code", CSStockTakesDataQy.Variant_Code);
                NewItemJournalLine.Validate("Location Code", BaseItemJournalLine."Location Code");
                NewItemJournalLine.Validate("Phys. Inventory", true);
                NewItemJournalLine.Validate("Qty. (Phys. Inventory)", CSStockTakesDataQy.Count_);
                NewItemJournalLine."Posting Date" := WorkDate;
                NewItemJournalLine."Document Date" := WorkDate;
                NewItemJournalLine.Validate("External Document No.", 'MOBILE');
                NewItemJournalLine.Validate("Changed by User", true);
                NewItemJournalLine."Document No." := BaseItemJournalLine."Document No.";
                NewItemJournalLine."Source Code" := BaseItemJournalLine."Source Code";
                NewItemJournalLine."Reason Code" := BaseItemJournalLine."Reason Code";
                NewItemJournalLine."Posting No. Series" := BaseItemJournalLine."Posting No. Series";
                NewItemJournalLine.Modify(true);
                LineNo += 1000;
            end else begin
                ItemJournalLine.Validate("Qty. (Phys. Inventory)", CSStockTakesDataQy.Count_);
                ItemJournalLine.Validate("Changed by User", true);
                ItemJournalLine.Modify(true);
            end;
        end;

        CSStockTakesDataQy.Close;

        Clear(ResetItemJournalLine);
        ResetItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        ResetItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        ResetItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
        ResetItemJournalLine.SetRange("Changed by User", false);
        if ResetItemJournalLine.FindSet then begin
            repeat
                ResetItemJournalLine.Validate("Qty. (Phys. Inventory)", 0);
                ResetItemJournalLine.Modify(true);
            until ResetItemJournalLine.Next = 0;
        end;

        Clear(CSStockTakesDataTb);
        CSStockTakesDataTb.SetRange("Worksheet Name", ItemJournalBatch."Journal Template Name");
        CSStockTakesDataTb.SetRange("Stock-Take Config Code", ItemJournalBatch.Name);
        CSStockTakesDataTb.ModifyAll("Transferred To Worksheet", true);

        exit(StockTakeConfigCode)
    end;

    procedure ResetWarehouseCounting(StockTakeConfigCode: Text; WorksheetName: Text): Text
    var
        CSSetup: Record "NPR CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        CSStockTakesData: Record "NPR CS Stock-Takes Data";
        CSStockTakeHandlingRfid: Record "NPR CS Stock-Take Handl. Rfid";
    begin
        if not CSSetup.Get then
            exit(StrSubstNo(Txt010, CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", StockTakeConfigCode) then
            exit('UNKNOWNSTOCKTAKEWORKSHEET');

        CSStockTakesData.SetRange("Transferred To Worksheet", false);
        CSStockTakesData.SetRange(Area, CSStockTakesData.Area::Warehouse);
        CSStockTakesData.SetRange("Worksheet Name", ItemJournalBatch."Journal Template Name");
        CSStockTakesData.SetRange("Stock-Take Config Code", ItemJournalBatch.Name);
        CSStockTakesData.DeleteAll();

        Clear(CSStockTakeHandlingRfid);
        CSStockTakeHandlingRfid.SetRange("Stock-Take Config Code", StockTakeConfigCode);
        CSStockTakeHandlingRfid.SetRange("Worksheet Name", ItemJournalBatch."Journal Template Name");
        CSStockTakeHandlingRfid.SetRange(Area, CSStockTakeHandlingRfid.Area::Warehouse);
        CSStockTakeHandlingRfid.DeleteAll();

        exit(StockTakeConfigCode);
    end;

    procedure GetItemObject(Barcode: Code[20]): Text
    var
        CSWrapperFunctions: Codeunit "NPR CS Wrapper Functions";
    begin
        exit(CSWrapperFunctions.GetItemObject(Barcode));
    end;

    procedure GetWarehouseCountingDetails(BatchName: Text): Text
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        CSItemJournal: Query "NPR CS Item Journal";
        CSSetup: Record "NPR CS Setup";
        PredictedQty: Integer;
    begin
        if not CSSetup.Get then
            exit(StrSubstNo(Txt010, CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", BatchName) then
            exit(StrSubstNo(Txt005, BatchName));


        CSItemJournal.SetRange(CSItemJournal.Journal_Template_Name, CSSetup."Phys. Inv Jour Temp Name");
        CSItemJournal.SetRange(CSItemJournal.Journal_Batch_Name, BatchName);
        CSItemJournal.Open;
        while CSItemJournal.Read do begin
            PredictedQty := CSItemJournal.Sum_Qty_Calculated;
        end;

        CSItemJournal.Close;

        exit(Format(PredictedQty));
    end;

    procedure GetStoreData(CurrUser: Text): Text
    var
        CSStoreUsers: Record "NPR CS Store Users";
        CSStockTakes: Record "NPR CS Stock-Takes";
        POSStore: Record "NPR POS Store";
        JObject: JsonObject;
        Result: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        CSSetup: Record "NPR CS Setup";
        Item: Record Item;
        CalculateInventory: Report "Calculate Inventory";
        QtyCalculated: Decimal;
        ItemObject: JsonObject;
        ItemArray: JsonArray;
    begin
        if CurrUser = '' then
            Error(Txt012);

        if StrLen(CurrUser) > MaxStrLen(CSStoreUsers."User ID") then
            Error(Txt012);

        CSStoreUsers.SetRange("User ID", CurrUser);
        if not CSStoreUsers.FindFirst then
            Error(Txt013);

        CSStoreUsers.TestField("POS Store");
        CSStoreUsers.TestField(Supervisor);
        POSStore.Get(CSStoreUsers."POS Store");
        POSStore.TestField("Location Code");
        SalespersonPurchaser.Get(CSStoreUsers.Supervisor);
        SalespersonPurchaser.TestField("NPR Register Password");

        if StrLen(SalespersonPurchaser."NPR Register Password") <> 6 then
            Error(Txt018);

        Location.Get(POSStore."Location Code");
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location, POSStore."Location Code");
        CSStockTakes.SetRange(Closed, 0DT);
        CSStockTakes.SetRange("Journal Posted", false);
        if CSStockTakes.FindFirst then begin
            CSStockTakes.TestField("Journal Template Name");
            CSStockTakes.TestField("Journal Batch Name");

            if not CSStockTakes."Inventory Calculated" then begin
                CSSetup.Get;
                CSSetup.TestField("Phys. Inv Jour Temp Name");
                ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
                ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", Location.Code);

                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
                if ItemJournalLine.Count > 0 then
                    Error(Txt020, CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");

                Clear(ItemJournalLine);
                ItemJournalLine.Init;
                ItemJournalLine.Validate("Journal Template Name", CSStockTakes."Journal Template Name");
                ItemJournalLine.Validate("Journal Batch Name", CSStockTakes."Journal Batch Name");
                ItemJournalLine."Location Code" := CSStockTakes.Location;

                Clear(NoSeriesMgt);
                ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", ItemJournalLine."Posting Date", false);
                ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
                ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
                ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

                Clear(Item);
                Item.SetFilter("Location Filter", CSStockTakes.Location);
                if not Item.FindSet then
                    Error(Txt021, Location);

                Clear(CalculateInventory);
                CalculateInventory.UseRequestPage(false);
                CalculateInventory.SetTableView(Item);
                CalculateInventory.SetItemJnlLine(ItemJournalLine);
                CalculateInventory.InitializeRequest(WorkDate, ItemJournalLine."Document No.", false, false);
                CalculateInventory.RunModal;

                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
                ItemJournalLine.SetRange("Location Code", CSStockTakes.Location);
                if ItemJournalLine.FindSet then begin
                    repeat
                        QtyCalculated += ItemJournalLine."Qty. (Calculated)"
                    until ItemJournalLine.Next = 0;
                end;

                CSStockTakes."Predicted Qty." := QtyCalculated;
                CSStockTakes."Inventory Calculated" := true;
                CSStockTakes.Modify(true);

            end;
        end;

        ItemObject.Add('StoreId', POSStore.Code);
        ItemObject.Add('StoreName', POSStore.Name);
        ItemObject.Add('StoreLocationCode', POSStore."Location Code");
        ItemObject.Add('StoreLocationName', Location.Name);
        ItemObject.Add('StoreAddress', POSStore.Address);
        ItemObject.Add('StoreAddress2', POSStore."Address 2");
        ItemObject.Add('StorePostCode', POSStore."Post Code");
        ItemObject.Add('StoreCountryRegionCode', POSStore."Country/Region Code");
        ItemObject.Add('StoreCity', POSStore.City);
        ItemObject.Add('StoreSupervisorId', SalespersonPurchaser.Code);
        ItemObject.Add('StoreSupervisorName', SalespersonPurchaser.Name);
        ItemObject.Add('StoreSupervisorPassword', SalespersonPurchaser."NPR Register Password");
        ItemObject.Add('StockTakeId', Format(CSStockTakes."Stock-Take Id"));
        ItemObject.Add('JournalTemplateName', CSStockTakes."Journal Template Name");
        ItemObject.Add('JournalBatchName', CSStockTakes."Journal Batch Name");
        ItemObject.Add('PredictedQty', Format(CSStockTakes."Predicted Qty."));
        if CSStockTakes."Stockroom Closed" = 0DT then
            ItemObject.Add('StockroomClosed', '0')
        else
            ItemObject.Add('StockroomClosed', '1');

        if CSStockTakes."Salesfloor Closed" = 0DT then
            ItemObject.Add('SalesfloorClosed', '0')
        else
            ItemObject.Add('SalesfloorClosed', '1');

        if CSStockTakes."Refill Closed" = 0DT then
            ItemObject.Add('RefillClosed', '0')
        else
            ItemObject.Add('RefillClosed', '1');

        if CSStockTakes.Approved = 0DT then
            ItemObject.Add('Approved', '0')
        else
            ItemObject.Add('Approved', '1');

        CSSetup.Get;
        if (CSSetup."Batch Size" > 10) and (CSSetup."Batch Size" < 1000) then
            ItemObject.Add('BatchSize', CSSetup."Batch Size")
        else
            ItemObject.Add('BatchSize', '10');

        ItemArray.Add(ItemObject);
        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    procedure StartStoreCounting(StockTakeId: Text; "Area": Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
    begin
        if not CSStockTakes.Get(StockTakeId) then
            exit(StrSubstNo(Txt017, StockTakeId));

        case Area of
            '0':
                begin
                    Error(Txt019);
                end;
            '1':
                begin
                    if CSStockTakes."Salesfloor Started" = 0DT then begin
                        CSStockTakes."Salesfloor Started" := CurrentDateTime;
                        CSStockTakes."Salesfloor Started By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
            '2':
                begin
                    if CSStockTakes."Stockroom Started" = 0DT then begin
                        CSStockTakes."Stockroom Started" := CurrentDateTime;
                        CSStockTakes."Stockroom Started By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
            '3':
                begin
                    if CSStockTakes."Refill Started" = 0DT then begin
                        CSStockTakes."Refill Started" := CurrentDateTime;
                        CSStockTakes."Refill Started By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
        end;

        exit(StockTakeId);
    end;

    procedure CloseStoreCounting(StockTakeId: Text; "Area": Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
        OK: Boolean;
        SessionID: Integer;
    begin
        if not CSStockTakes.Get(StockTakeId) then
            exit('UNKNOWNSTOCKTAKEID');

        case Area of
            '0':
                begin
                    Error(Txt019);
                end;
            '1':
                begin
                    if CSStockTakes."Salesfloor Closed" = 0DT then begin
                        CSStockTakes."Salesfloor Closed" := CurrentDateTime;
                        CSStockTakes."Salesfloor Closed By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
            '2':
                begin
                    if CSStockTakes."Stockroom Closed" = 0DT then begin
                        CSStockTakes."Stockroom Closed" := CurrentDateTime;
                        CSStockTakes."Stockroom Closed By" := UserId;
                        CSStockTakes.Modify(true);
                    end;
                end;
        end;

        exit(StockTakeId);
    end;

    procedure ApproveStoreCounting(StockTakeId: Text): Text
    var
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        OK: Boolean;
        SessionID: Integer;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        BaseItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CSStockTakesDataTb: Record "NPR CS Stock-Takes Data";
        TestItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        NewItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "NPR CS Setup";
        CSStockTakesDataQy: Query "NPR CS Stock-Takes Data";
        ItemJournalLine: Record "Item Journal Line";
        ResetItemJournalLine: Record "Item Journal Line";
        CSStockTakes: Record "NPR CS Stock-Takes";
        PostingRecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        DocumentNo: Code[20];
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        if not CSStockTakes.Get(StockTakeId) then
            exit(StrSubstNo(Txt017, StockTakeId));

        if CSStockTakes."Adjust Inventory" then begin
            CSSetup.Get;
            if CSSetup."Post with Job Queue" then begin
                PostingRecRef.GetTable(CSStockTakes);
                CSPostingBuffer.Init;
                CSPostingBuffer."Table No." := PostingRecRef.Number;
                CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
                CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Approve Counting";
                CSPostingBuffer."Job Queue Priority for Post" := 2000;
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

            if not ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name") then
                exit(StrSubstNo(Txt005, CSStockTakes."Journal Batch Name"));

            ItemJournalTemplate.Get(ItemJournalBatch."Journal Template Name");

            if ItemJournalTemplate."Source Code" = '' then
                exit(StrSubstNo(Txt006, ItemJournalTemplate.Name));

            Clear(BaseItemJournalLine);
            BaseItemJournalLine.Init;
            BaseItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
            BaseItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
            BaseItemJournalLine."Location Code" := ItemJournalBatch.Name;

            BaseItemJournalLine."Document No." := Format(WorkDate);
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

            CSStockTakesDataQy.SetRange(Stock_Take_Id, StockTakeId);
            CSStockTakesDataQy.SetRange(Stock_Take_Config_Code, ItemJournalBatch."Journal Template Name");
            CSStockTakesDataQy.SetRange(Worksheet_Name, ItemJournalBatch.Name);
            CSStockTakesDataQy.SetRange(Transferred_To_Worksheet, false);
            CSStockTakesDataQy.Open;
            while CSStockTakesDataQy.Read do begin
                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
                ItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
                ItemJournalLine.SetRange("Item No.", CSStockTakesDataQy.ItemNo);
                ItemJournalLine.SetRange("Variant Code", CSStockTakesDataQy.Variant_Code);
                if not ItemJournalLine.FindSet then begin
                    Clear(NewItemJournalLine);
                    NewItemJournalLine.Validate("Journal Template Name", BaseItemJournalLine."Journal Template Name");
                    NewItemJournalLine.Validate("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
                    NewItemJournalLine."Line No." := LineNo;
                    NewItemJournalLine.Insert(true);

                    NewItemJournalLine.Validate("Entry Type", NewItemJournalLine."Entry Type"::"Positive Adjmt.");
                    NewItemJournalLine.Validate("Item No.", CSStockTakesDataQy.ItemNo);
                    NewItemJournalLine.Validate("Variant Code", CSStockTakesDataQy.Variant_Code);
                    NewItemJournalLine.Validate("Location Code", BaseItemJournalLine."Location Code");
                    NewItemJournalLine.Validate("Phys. Inventory", true);
                    NewItemJournalLine.Validate("Qty. (Phys. Inventory)", CSStockTakesDataQy.Count_);
                    NewItemJournalLine."Posting Date" := WorkDate;
                    NewItemJournalLine."Document Date" := WorkDate;
                    NewItemJournalLine.Validate("External Document No.", 'MOBILE');
                    NewItemJournalLine.Validate("Changed by User", true);
                    NewItemJournalLine."Document No." := BaseItemJournalLine."Document No.";
                    NewItemJournalLine."Source Code" := BaseItemJournalLine."Source Code";
                    NewItemJournalLine."Reason Code" := BaseItemJournalLine."Reason Code";
                    NewItemJournalLine."Posting No. Series" := BaseItemJournalLine."Posting No. Series";
                    NewItemJournalLine.Modify(true);
                    LineNo += 1000;
                end else begin
                    ItemJournalLine.Validate("Qty. (Phys. Inventory)", CSStockTakesDataQy.Count_);
                    ItemJournalLine.Validate("Changed by User", true);
                    ItemJournalLine.Modify(true);
                end;
            end;

            CSStockTakesDataQy.Close;

            Clear(ResetItemJournalLine);
            ResetItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
            ResetItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
            ResetItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
            ResetItemJournalLine.SetRange("Changed by User", false);
            if ResetItemJournalLine.FindSet then begin
                repeat
                    ResetItemJournalLine.Validate("Qty. (Phys. Inventory)", 0);
                    ResetItemJournalLine.Modify(true);
                until ResetItemJournalLine.Next = 0;
            end;
        end;

        Clear(CSStockTakesDataTb);
        CSStockTakesDataTb.SetRange("Stock-Take Id", StockTakeId);
        CSStockTakesDataTb.SetRange("Stock-Take Config Code", ItemJournalBatch."Journal Template Name");
        CSStockTakesDataTb.SetRange("Worksheet Name", ItemJournalBatch.Name);
        CSStockTakesDataTb.ModifyAll("Transferred To Worksheet", true);

        if CSStockTakes.Approved = 0DT then begin
            CSStockTakes.Approved := CurrentDateTime;
            CSStockTakes."Approved By" := UserId;
            CSStockTakes.Modify(true);
        end;

        if CSStockTakes."Adjust Inventory" then begin
            if (ItemJournalBatch."No. Series" <> '') then begin
                DocumentNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", WorkDate, false);
                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                ItemJournalLine.ModifyAll("Document No.", DocumentNo, false);
            end;

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
            if ItemJournalLine.FindSet then begin
                repeat
                    ItemJnlPostBatch.Run(ItemJournalLine);
                until ItemJournalLine.Next = 0;
            end;
        end;

        if CSStockTakes.Closed = 0DT then begin
            CSStockTakes.Closed := CurrentDateTime;
            CSStockTakes."Closed By" := UserId;
        end;

        CSStockTakes."Journal Posted" := CSStockTakes."Adjust Inventory";
        CSStockTakes.Modify(true);

        exit(StockTakeId)
    end;

    procedure ResetCounting(StockTakeConfigCode: Text; WorksheetName: Text; "Area": Text): Text
    var
        CSSetup: Record "NPR CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        CSStockTakesData: Record "NPR CS Stock-Takes Data";
        CSStockTakeHandlingRfid: Record "NPR CS Stock-Take Handl. Rfid";
    begin
        Clear(CSStockTakesData);
        CSStockTakesData.SetRange("Transferred To Worksheet", false);
        CSStockTakesData.SetRange("Stock-Take Config Code", StockTakeConfigCode);
        CSStockTakesData.SetRange("Worksheet Name", WorksheetName);
        case Area of
            '0':
                CSStockTakesData.SetRange(Area, CSStockTakesData.Area::Warehouse);
            '1':
                CSStockTakesData.SetRange(Area, CSStockTakesData.Area::Salesfloor);
            '2':
                CSStockTakesData.SetRange(Area, CSStockTakesData.Area::Stockroom);
        end;
        CSStockTakesData.DeleteAll();

        Clear(CSStockTakeHandlingRfid);
        CSStockTakeHandlingRfid.SetRange("Stock-Take Config Code", StockTakeConfigCode);
        CSStockTakeHandlingRfid.SetRange("Worksheet Name", WorksheetName);
        case Area of
            '0':
                CSStockTakeHandlingRfid.SetRange(Area, CSStockTakeHandlingRfid.Area::Warehouse);
            '1':
                CSStockTakeHandlingRfid.SetRange(Area, CSStockTakeHandlingRfid.Area::Salesfloor);
            '2':
                CSStockTakeHandlingRfid.SetRange(Area, CSStockTakeHandlingRfid.Area::Stockroom);
        end;
        CSStockTakeHandlingRfid.DeleteAll();

        exit(StockTakeConfigCode);
    end;

    procedure CreateStoreRefillData(StockTakeId: Text) Result: Text
    begin
        exit(CreateStoreRefillDataV2(StockTakeId));
    end;

    procedure CreateStoreCounting(Location: Code[10]): Text
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        LocationRec: Record Location;
    begin
        LocationRec.Get(Location);
        CSHelperFunctions.CreateNewCounting(LocationRec);
        exit('');
    end;

    procedure CreateStoreCountingV2(Location: Code[10]): Text
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        LocationRec: Record Location;
    begin
        LocationRec.Get(Location);
        CSHelperFunctions.CreateNewCountingV2(LocationRec);
        exit('');
    end;

    procedure SearchPOSStore(Word: Text): Text
    var
        CSItemSeachHandling: Record "NPR CS Item Search Handl." temporary;
        POSStore: Record "NPR POS Store";
        JObject: JsonObject;
        Result: Text;
        CSSetup: Record "NPR CS Setup";
        MaxItems: Integer;
        ItemsCounter: Integer;
        ItemsObject: JsonObject;
        ItemsArray: JsonArray;
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
            POSStore.SetFilter(Code, '%1', '@*' + Word + '*');
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
            POSStore.SetFilter(Name, '%1', '@*' + Word + '*');
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
            POSStore.SetFilter(City, '%1', '@*' + Word + '*');
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

        CSItemSeachHandling.SetCurrentKey(Rank, "No.");
        if CSItemSeachHandling.FindSet then begin
            repeat
                ItemsObject.Add('key', CSItemSeachHandling."No.");
                ItemsObject.Add('description1', CSItemSeachHandling.Description);
                ItemsObject.Add('description2', CSItemSeachHandling."Description 2");
                ItemsArray.Add(ItemsObject);
            until CSItemSeachHandling.Next = 0;
            JObject.Add('items', ItemsArray);
            JObject.WriteTo(Result);
        end;

        exit(Result);
    end;

    procedure GetStoreDataV2(CurrUser: Text; POSStoreCode: Text): Text
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
        POSStore: Record "NPR POS Store";
        JObject: JsonObject;
        Result: Text;
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        CSSetup: Record "NPR CS Setup";
        Item: Record Item;
        CalculateInventory: Report "Calculate Inventory";
        QtyCalculated: Decimal;
        CSCountingSupervisor: Record "NPR CS Counting Supervisor";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CSStoreUsers: Record "NPR CS Store Users";
        ItemObject: JsonObject;
        ItemArray: JsonArray;
    begin
        if CurrUser = '' then
            Error(Txt012);

        if StrLen(CurrUser) > MaxStrLen(CSCountingSupervisor."User ID") then
            Error(Txt012);

        if StrLen(POSStoreCode) > MaxStrLen(POSStore.Code) then
            Error(Txt022, POSStoreCode);

        if not CSCountingSupervisor.Get(CurrUser) then begin
            exit(GetStoreDataByStoreUser(CurrUser));
        end else begin

            if POSStoreCode <> '' then
                if not POSStore.Get(POSStoreCode) then
                    Error(Txt022, POSStoreCode);

            CSCountingSupervisor.TestField(Pin);
            CSCountingSupervisor.CalcFields("Full Name");

            if POSStoreCode <> '' then begin

                CSStoreUsers.SetRange("POS Store", POSStore.Code);
                if CSStoreUsers.FindFirst then
                    if CSStoreUsers.Supervisor <> '' then
                        SalespersonPurchaser.Get(CSStoreUsers.Supervisor);

                POSStore.TestField("Location Code");
                Location.Get(POSStore."Location Code");
                Clear(CSStockTakes);
                CSStockTakes.SetRange(Location, Location.Code);
                CSStockTakes.SetRange(Closed, 0DT);
                CSStockTakes.SetRange("Journal Posted", false);
                CSStockTakes.SetRange("Adjust Inventory", true);
                if CSStockTakes.FindFirst then begin
                    CSStockTakes.TestField("Journal Template Name");
                    CSStockTakes.TestField("Journal Batch Name");

                    if not CSStockTakes."Inventory Calculated" then begin
                        CSSetup.Get;
                        CSSetup.TestField("Phys. Inv Jour Temp Name");
                        ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
                        ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", Location.Code);

                        Clear(ItemJournalLine);
                        ItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
                        ItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
                        if ItemJournalLine.Count > 0 then
                            Error(Txt020, CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");

                        Clear(ItemJournalLine);
                        ItemJournalLine.Init;
                        ItemJournalLine.Validate("Journal Template Name", CSStockTakes."Journal Template Name");
                        ItemJournalLine.Validate("Journal Batch Name", CSStockTakes."Journal Batch Name");
                        ItemJournalLine."Location Code" := CSStockTakes.Location;

                        Clear(NoSeriesMgt);
                        ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", ItemJournalLine."Posting Date", false);
                        ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
                        ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
                        ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

                        Clear(Item);
                        Item.SetFilter("Location Filter", CSStockTakes.Location);
                        if not Item.FindSet then
                            Error(Txt021, Location);

                        Clear(CalculateInventory);
                        CalculateInventory.UseRequestPage(false);
                        CalculateInventory.SetTableView(Item);
                        CalculateInventory.SetItemJnlLine(ItemJournalLine);
                        CalculateInventory.InitializeRequest(WorkDate, ItemJournalLine."Document No.", false, false);
                        CalculateInventory.RunModal;

                        Clear(ItemJournalLine);
                        ItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
                        ItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
                        ItemJournalLine.SetRange("Location Code", CSStockTakes.Location);
                        if ItemJournalLine.FindSet then begin
                            repeat
                                QtyCalculated += ItemJournalLine."Qty. (Calculated)"
                            until ItemJournalLine.Next = 0;
                        end;

                        CSStockTakes."Predicted Qty." := QtyCalculated;
                        CSStockTakes."Inventory Calculated" := true;
                        CSStockTakes.Modify(true);

                    end;
                end;
            end;
        end;

        ItemObject.Add('StoreId', POSStore.Code);
        ItemObject.Add('StoreName', POSStore.Name);
        ItemObject.Add('StoreLocationCode', POSStore."Location Code");
        ItemObject.Add('StoreLocationName', Location.Name);
        ItemObject.Add('StoreAddress', POSStore.Address);
        ItemObject.Add('StoreAddress2', POSStore."Address 2");
        ItemObject.Add('StorePostCode', POSStore."Post Code");
        ItemObject.Add('StoreCountryRegionCode', POSStore."Country/Region Code");
        ItemObject.Add('StoreCity', POSStore.City);
        ItemObject.Add('CountingSupervisor', '1');
        ItemObject.Add('StoreSupervisorId', CSCountingSupervisor."User ID");
        ItemObject.Add('StoreSupervisorName', CSCountingSupervisor."Full Name");
        ItemObject.Add('StoreSupervisorPassword', CSCountingSupervisor.Pin);
        ItemObject.Add('StockTakeId', Format(CSStockTakes."Stock-Take Id"));
        ItemObject.Add('JournalTemplateName', CSStockTakes."Journal Template Name");
        ItemObject.Add('JournalBatchName', CSStockTakes."Journal Batch Name");
        ItemObject.Add('PredictedQty', Format(CSStockTakes."Predicted Qty."));
        if CSStockTakes."Stockroom Closed" = 0DT then
            ItemObject.Add('StockroomClosed', '0')
        else
            ItemObject.Add('StockroomClosed', '1');

        if CSStockTakes."Salesfloor Closed" = 0DT then
            ItemObject.Add('SalesfloorClosed', '0')
        else
            ItemObject.Add('SalesfloorClosed', '1');

        if CSStockTakes."Refill Closed" = 0DT then
            ItemObject.Add('RefillClosed', '0')
        else
            ItemObject.Add('RefillClosed', '1');

        if CSStockTakes.Approved = 0DT then
            ItemObject.Add('Approved', '0')
        else
            ItemObject.Add('Approved', '1');

        CSSetup.Get;
        if (CSSetup."Batch Size" > 10) and (CSSetup."Batch Size" < 1000) then
            ItemObject.Add('BatchSize', CSSetup."Batch Size")
        else
            ItemObject.Add('BatchSize', '10');

        ItemArray.Add(ItemObject);

        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);

        exit(Result);
    end;

    procedure GetStoreDataByStoreUser(CurrUser: Text): Text
    var
        CSStoreUsers: Record "NPR CS Store Users";
        CSStockTakes: Record "NPR CS Stock-Takes";
        POSStore: Record "NPR POS Store";
        JObject: JsonObject;
        Result: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        CSSetup: Record "NPR CS Setup";
        Item: Record Item;
        CalculateInventory: Report "Calculate Inventory";
        QtyCalculated: Decimal;
        ItemObject: JsonObject;
        ItemArray: JsonArray;
    begin
        if CurrUser = '' then
            Error(Txt012);

        if StrLen(CurrUser) > MaxStrLen(CSStoreUsers."User ID") then
            Error(Txt012);

        CSStoreUsers.SetRange("User ID", CurrUser);
        if not CSStoreUsers.FindFirst then
            Error(Txt013);

        CSStoreUsers.TestField("POS Store");
        CSStoreUsers.TestField(Supervisor);
        POSStore.Get(CSStoreUsers."POS Store");
        POSStore.TestField("Location Code");
        SalespersonPurchaser.Get(CSStoreUsers.Supervisor);
        SalespersonPurchaser.TestField("NPR Register Password");

        if StrLen(SalespersonPurchaser."NPR Register Password") <> 6 then
            Error(Txt018);

        Location.Get(POSStore."Location Code");
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location, POSStore."Location Code");
        CSStockTakes.SetRange(Closed, 0DT);
        CSStockTakes.SetRange("Journal Posted", false);
        if CSStoreUsers."Adjust Inventory" then
            CSStockTakes.SetRange("Adjust Inventory", true)
        else
            CSStockTakes.SetRange("Adjust Inventory", false);
        if CSStockTakes.FindFirst then begin
            if CSStockTakes."Adjust Inventory" then begin
                CSStockTakes.TestField("Journal Template Name");
                CSStockTakes.TestField("Journal Batch Name");

                if not CSStockTakes."Inventory Calculated" then begin
                    CSSetup.Get;
                    CSSetup.TestField("Phys. Inv Jour Temp Name");
                    ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
                    ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", Location.Code);

                    Clear(ItemJournalLine);
                    ItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
                    if ItemJournalLine.Count > 0 then
                        Error(Txt020, CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");

                    Clear(ItemJournalLine);
                    ItemJournalLine.Init;
                    ItemJournalLine.Validate("Journal Template Name", CSStockTakes."Journal Template Name");
                    ItemJournalLine.Validate("Journal Batch Name", CSStockTakes."Journal Batch Name");
                    ItemJournalLine."Location Code" := CSStockTakes.Location;

                    Clear(NoSeriesMgt);
                    ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", ItemJournalLine."Posting Date", false);
                    ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
                    ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
                    ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

                    Clear(Item);
                    Item.SetFilter("Location Filter", CSStockTakes.Location);
                    if not Item.FindSet then
                        Error(Txt021, Location);

                    Clear(CalculateInventory);
                    CalculateInventory.UseRequestPage(false);
                    CalculateInventory.SetTableView(Item);
                    CalculateInventory.SetItemJnlLine(ItemJournalLine);
                    CalculateInventory.InitializeRequest(WorkDate, ItemJournalLine."Document No.", false, false);
                    CalculateInventory.RunModal;

                    Clear(ItemJournalLine);
                    ItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
                    ItemJournalLine.SetRange("Location Code", CSStockTakes.Location);
                    if ItemJournalLine.FindSet then begin
                        repeat
                            QtyCalculated += ItemJournalLine."Qty. (Calculated)"
                        until ItemJournalLine.Next = 0;
                    end;

                    CSStockTakes."Predicted Qty." := QtyCalculated;
                    CSStockTakes."Inventory Calculated" := true;
                    CSStockTakes.Modify(true);
                end;
            end;
        end;

        ItemObject.Add('StoreId', POSStore.Code);
        ItemObject.Add('StoreName', POSStore.Name);
        ItemObject.Add('StoreLocationCode', POSStore."Location Code");
        ItemObject.Add('StoreLocationName', Location.Name);
        ItemObject.Add('StoreAddress', POSStore.Address);
        ItemObject.Add('StoreAddress2', POSStore."Address 2");
        ItemObject.Add('StorePostCode', POSStore."Post Code");
        ItemObject.Add('StoreCountryRegionCode', POSStore."Country/Region Code");
        ItemObject.Add('StoreCity', POSStore.City);
        ItemObject.Add('CountingSupervisor', '0');
        ItemObject.Add('StoreSupervisorId', SalespersonPurchaser.Code);
        ItemObject.Add('StoreSupervisorName', SalespersonPurchaser.Name);
        ItemObject.Add('StoreSupervisorPassword', SalespersonPurchaser."NPR Register Password");
        ItemObject.Add('StockTakeId', Format(CSStockTakes."Stock-Take Id"));
        ItemObject.Add('JournalTemplateName', CSStockTakes."Journal Template Name");
        ItemObject.Add('JournalBatchName', CSStockTakes."Journal Batch Name");
        ItemObject.Add('PredictedQty', Format(CSStockTakes."Predicted Qty."));
        if CSStockTakes."Stockroom Closed" = 0DT then
            ItemObject.Add('StockroomClosed', '0')
        else
            ItemObject.Add('StockroomClosed', '1');
        if CSStockTakes."Salesfloor Closed" = 0DT then
            ItemObject.Add('SalesfloorClosed', '0')
        else
            ItemObject.Add('SalesfloorClosed', '1');
        if CSStockTakes."Refill Closed" = 0DT then
            ItemObject.Add('RefillClosed', '0')
        else
            ItemObject.Add('RefillClosed', '1');
        if CSStockTakes.Approved = 0DT then
            ItemObject.Add('Approved', '0')
        else
            ItemObject.Add('Approved', '1');
        CSSetup.Get;
        if (CSSetup."Batch Size" > 10) and (CSSetup."Batch Size" < 1000) then
            ItemObject.Add('BatchSize', CSSetup."Batch Size")
        else
            ItemObject.Add('BatchSize', '10');

        ItemArray.Add(ItemObject);
        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    procedure SetRfidTagDataByTypeBatch(StockTakeId: Text; StockTakeConfigCode: Text; WorksheetName: Text; TagIds: Text; "Area": Text; DeviceId: Code[10]; BatchId: Text) ResultData: Text
    var
        CSStockTakeHandlingRfid: Record "NPR CS Stock-Take Handl. Rfid";
        CSSetup: Record "NPR CS Setup";
        OK: Boolean;
        SessionID: Integer;
        Ostream: OutStream;
        BigTextData: BigText;
        ValInt: Integer;
        ValBool: Boolean;
        CommaString: Text;
        Separator: Text;
        Value: Text;
        Values: List of [Text];
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
            '0':
                CSStockTakeHandlingRfid.Area := CSStockTakeHandlingRfid.Area::Warehouse;
            '1':
                CSStockTakeHandlingRfid.Area := CSStockTakeHandlingRfid.Area::Salesfloor;
            '2':
                CSStockTakeHandlingRfid.Area := CSStockTakeHandlingRfid.Area::Stockroom;
        end;
        CSStockTakeHandlingRfid."Device Id" := DeviceId;
        CSStockTakeHandlingRfid."Posting Started" := CurrentDateTime;
        CSStockTakeHandlingRfid."Request Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);

        CSStockTakeHandlingRfid.Insert(false);
        Commit;

        CommaString := TagIds;
        Separator := ',';
        Values := CommaString.Split(Separator);
        CSSetup.SetRange("Disregard Unknown RFID Tags", true);
        if not CSSetup.IsEmpty then
            CleanTagEntries(Values);
        CSStockTakeHandlingRfid.Tags := Values.Count;
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

    procedure CreateStoreRefillDataV2(StockTakeId: Text) Result: Text
    var
        CSRefillDataTmp: Record "NPR CS Refill Data" temporary;
        Item: Record Item;
        ItemGroup: Record "NPR Item Group";
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        JObject: JsonObject;
        CSSetup: Record "NPR CS Setup";
        CSStockTakes: Record "NPR CS Stock-Takes";
        CSStockTakesData: Record "NPR CS Stock-Takes Data";
        CSRefillSectionDataTmp: Record "NPR CS Refill Section Data" temporary;
        CSRefillData: Record "NPR CS Refill Data";
        SectionObject: JsonObject;
        SectionArray: JsonArray;
        ItemObject: JsonObject;
        ItemArray: JsonArray;
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if not CSStockTakes.Get(StockTakeId) then
            exit;

        Clear(CSRefillDataTmp);
        Clear(CSRefillSectionDataTmp);

        CSStockTakes."Create Refill Data Started" := CurrentDateTime;
        CSStockTakesData.SetRange("Stock-Take Id", CSStockTakes."Stock-Take Id");
        CSStockTakesData.SetRange(Area, CSStockTakesData.Area::Salesfloor);
        if CSStockTakesData.FindSet then begin
            repeat
                if CSStockTakesData."Item No." <> '' then begin
                    if not CSRefillDataTmp.Get(CSStockTakesData."Item No.", CSStockTakesData."Variant Code", CSStockTakes.Location, CSStockTakes."Stock-Take Id") then begin
                        CSStockTakesData.CalcFields("Item Description", "Variant Description");
                        CSRefillDataTmp.Init;
                        CSRefillDataTmp.Validate("Item No.", CSStockTakesData."Item No.");
                        CSRefillDataTmp.Validate("Variant Code", CSStockTakesData."Variant Code");
                        CSRefillDataTmp.Validate(Location, CSStockTakes.Location);
                        CSRefillDataTmp."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                        CSRefillDataTmp."Item Description" := CSStockTakesData."Item Description";
                        CSRefillDataTmp."Variant Description" := CSStockTakesData."Variant Description";
                        CSRefillDataTmp.Insert(true);
                    end;

                    if CSRefillDataTmp."Variant Code" <> '' then
                        CSRefillDataTmp."Combined key" := CSRefillDataTmp."Item No." + '-' + CSRefillDataTmp."Variant Code"
                    else
                        CSRefillDataTmp."Combined key" := CSRefillDataTmp."Item No.";

                    CSRefillDataTmp."Qty. in Store" += 1;

                    CSRefillDataTmp.Modify(true);
                end;
            until CSStockTakesData.Next = 0;
        end;

        Clear(CSStockTakesData);
        CSStockTakesData.SetRange("Stock-Take Id", CSStockTakes."Stock-Take Id");
        CSStockTakesData.SetRange(Area, CSStockTakesData.Area::Stockroom);
        if CSStockTakesData.FindSet then begin
            repeat
                if CSStockTakesData."Item No." <> '' then begin
                    if not CSRefillDataTmp.Get(CSStockTakesData."Item No.", CSStockTakesData."Variant Code", CSStockTakes.Location, CSStockTakes."Stock-Take Id") then begin
                        CSStockTakesData.CalcFields("Item Description", "Variant Description");
                        CSRefillDataTmp.Init;
                        CSRefillDataTmp.Validate("Item No.", CSStockTakesData."Item No.");
                        CSRefillDataTmp.Validate("Variant Code", CSStockTakesData."Variant Code");
                        CSRefillDataTmp.Validate(Location, CSStockTakes.Location);
                        CSRefillDataTmp."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                        CSRefillDataTmp."Item Description" := CSStockTakesData."Item Description";
                        CSRefillDataTmp."Variant Description" := CSStockTakesData."Variant Description";
                        CSRefillDataTmp.Insert(true);
                    end;

                    if CSRefillDataTmp."Variant Code" <> '' then
                        CSRefillDataTmp."Combined key" := CSRefillDataTmp."Item No." + '-' + CSRefillDataTmp."Variant Code"
                    else
                        CSRefillDataTmp."Combined key" := CSRefillDataTmp."Item No.";

                    CSRefillDataTmp."Qty. in Stock" += 1;

                    CSRefillDataTmp.Modify(true);
                end;
            until CSStockTakesData.Next = 0;
        end;

        CSRefillDataTmp.SetFilter("Qty. in Store", '>0');
        CSRefillDataTmp.DeleteAll(false);
        CSRefillDataTmp.Reset;

        if CSRefillDataTmp.FindFirst then begin
            repeat
                CSRefillSectionDataTmp.Init;
                CSRefillSectionDataTmp.Validate("Item No.", CSRefillDataTmp."Item No.");
                CSRefillSectionDataTmp."Item Description" := CSRefillDataTmp."Item Description";
                CSRefillSectionDataTmp.Refilled := CSRefillDataTmp.Refilled;
                if CSRefillSectionDataTmp.Insert(true) then;
            until CSRefillDataTmp.Next = 0;
        end;

        CSStockTakes."Create Refill Data Ended" := CurrentDateTime;
        CSStockTakes.Modify;

        if CSRefillSectionDataTmp.FindFirst then begin
            repeat
                SectionObject.Add('key', CSRefillSectionDataTmp."Item No.");
                SectionObject.Add('title', CSRefillSectionDataTmp."Item Description");
                SectionObject.Add('itemgroup', '');
                Clear(CSRefillData);
                CSRefillData.SetRange("Stock-Take Id", CSStockTakes."Stock-Take Id");
                CSRefillData.SetRange("Item No.", CSRefillSectionDataTmp."Item No.");
                if CSRefillData.FindFirst then
                    SectionObject.Add('marked', CSRefillData.Refilled)
                else
                    SectionObject.Add('marked', CSRefillSectionDataTmp.Refilled);
                SectionArray.Add(SectionObject);
            until CSRefillSectionDataTmp.Next = 0;
        end;
        JObject.Add('section', SectionArray);

        if CSRefillDataTmp.FindFirst then begin
            repeat
                ItemObject.Add('key', CSRefillDataTmp."Combined key");
                ItemObject.Add('title', CSRefillDataTmp."Item Description");
                ItemObject.Add('itemno', CSRefillDataTmp."Item No.");
                ItemObject.Add('variantcode', CSRefillDataTmp."Variant Code");
                ItemObject.Add('varianttitle', CSRefillDataTmp."Variant Description");
                ItemObject.Add('itemgroup', CSRefillDataTmp."Item Group Code");
                ItemObject.Add('imageurl', CSRefillDataTmp."Image Url");
                ItemObject.Add('qtystock', CSRefillDataTmp."Qty. in Stock");
                ItemObject.Add('qtystore', CSRefillDataTmp."Qty. in Store");
                ItemObject.Add('marked', CSRefillDataTmp.Refilled);
                ItemArray.Add(ItemObject);
            until CSRefillDataTmp.Next = 0;
        end;
        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);
    end;

    procedure SetRfidTagDataTransferBatch(DocId: Text; TagIds: Text; ToDocNo: Text; DeviceId: Code[10]; BatchId: Text) ResultData: Text
    var
        CSTransferHandlingRfid: Record "NPR CS Transf. Handl. Rfid";
        OK: Boolean;
        SessionID: Integer;
        Ostream: OutStream;
        BigTextData: BigText;
        ValInt: Integer;
        ValBool: Boolean;
        CommaString: Text;
        Separator: Text;
        Value: Text;
        Values: List of [Text];
        TagData: Text;
    begin
        BigTextData.AddText(TagIds);

        CSTransferHandlingRfid.Init;
        CSTransferHandlingRfid.Id := CreateGuid;
        CSTransferHandlingRfid."Batch Id" := BatchId;
        CSTransferHandlingRfid.Created := CurrentDateTime;
        CSTransferHandlingRfid."Created By" := UserId;
        CSTransferHandlingRfid."Rfid Header Id" := DocId;
        if ToDocNo = '' then
            CSTransferHandlingRfid.Area := CSTransferHandlingRfid.Area::Shipping
        else
            CSTransferHandlingRfid.Area := CSTransferHandlingRfid.Area::Receiving;
        CSTransferHandlingRfid."Device Id" := DeviceId;
        CSTransferHandlingRfid."Posting Started" := CurrentDateTime;
        CSTransferHandlingRfid."Request Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);

        CSTransferHandlingRfid.Insert(false);
        Commit;

        CommaString := TagIds;
        Separator := ',';
        Values := CommaString.Split(Separator);
        CSTransferHandlingRfid.Tags := Values.Count;
        CSTransferHandlingRfid.Modify(false);
        Commit;

        Clear(Ostream);
        Clear(BigTextData);

        ResultData := '';
        TagData := '';

        foreach Value in Values do begin
            if Value <> '' then begin
                TagData := Value + '|' + SetRfidTagDataTransfer(CSTransferHandlingRfid."Rfid Header Id", Value, ToDocNo);
                if ResultData = '' then
                    ResultData := TagData
                else
                    ResultData := ResultData + ',' + TagData;
            end;
        end;

        CSTransferHandlingRfid."Posting Ended" := CurrentDateTime;
        CSTransferHandlingRfid.Handled := true;
        CSTransferHandlingRfid.Modify(true);

        BigTextData.AddText(ResultData);
        CSTransferHandlingRfid."Response Data".CreateOutStream(Ostream);
        BigTextData.Write(Ostream);
        CSTransferHandlingRfid.Modify(false);
        exit(ResultData);
    end;

    procedure SetRfidTagDataTransfer(DocId: Text; TagId: Text; ToDocNo: Text): Text
    var
        CSRfidLines: Record "NPR CS Rfid Lines";
        CSRfidData: Record "NPR CS Rfid Data";
        Result: Text;
    begin
        if ToDocNo = '' then begin
            CSRfidLines.Init;
            CSRfidLines.Id := DocId;
            CSRfidLines."Tag Id" := TagId;
            CSRfidLines.Created := CurrentDateTime;
            CSRfidLines."Created By" := UserId;
            CSRfidLines."Tag Shipped" := true;
            if CSRfidData.Get(TagId) then begin
                CSRfidLines.Validate("Item No.", CSRfidData."Cross-Reference Item No.");
                CSRfidLines.Validate("Variant Code", CSRfidData."Cross-Reference Variant Code");
                CSRfidLines.Validate("Item Group Code", CSRfidData."Item Group Code");
                CSRfidLines."Combined key" := CSRfidData."Combined key";
                Result := CSRfidData."Combined key" + '|1';
            end else
                Result := 'UNKNOWNITEM|0';
            CSRfidLines.Insert();
        end else begin
            if CSRfidLines.Get(DocId, TagId) then begin
                CSRfidLines.Match := true;
                CSRfidLines."Tag Received" := true;
                CSRfidLines.Modify(true);
                if CSRfidLines."Combined key" <> '' then
                    Result := CSRfidLines."Combined key" + '|1'
                else
                    Result := 'UNKNOWNITEM|1';
            end else begin
                CSRfidLines.Init;
                CSRfidLines.Id := DocId;
                CSRfidLines."Tag Id" := TagId;
                CSRfidLines.Created := CurrentDateTime;
                CSRfidLines."Created By" := UserId;
                CSRfidLines."Tag Received" := true;
                if CSRfidData.Get(TagId) then begin
                    CSRfidLines.Validate("Item No.", CSRfidData."Cross-Reference Item No.");
                    CSRfidLines.Validate("Variant Code", CSRfidData."Cross-Reference Variant Code");
                    CSRfidLines.Validate("Item Group Code", CSRfidData."Item Group Code");
                    CSRfidLines."Combined key" := CSRfidData."Combined key";
                    Result := CSRfidData."Combined key" + '|0';
                end else
                    Result := 'UNKNOWNITEM|0';
                CSRfidLines.Insert();
            end;
        end;

        exit(Result)
    end;

    procedure ResetTransfer(DocId: Text; ToDocNo: Text): Text
    var
        CSTransferHandlingRfid: Record "NPR CS Transf. Handl. Rfid";
        CSRfidHeader: Record "NPR CS Rfid Header";
        CSRfidLines: Record "NPR CS Rfid Lines";
    begin
        Clear(CSRfidHeader);
        CSRfidHeader.SetRange(Id, DocId);
        CSRfidHeader.SetRange("To Document No.", ToDocNo);
        if CSRfidHeader.FindSet then begin
            if ToDocNo = '' then begin
                Clear(CSTransferHandlingRfid);
                CSTransferHandlingRfid.SetRange("Rfid Header Id", CSRfidHeader.Id);
                CSTransferHandlingRfid.SetRange(Area, CSTransferHandlingRfid.Area::Shipping);
                CSTransferHandlingRfid.DeleteAll(true);

                Clear(CSRfidLines);
                CSRfidLines.SetRange(Id, CSRfidHeader.Id);
                CSRfidLines.DeleteAll(true);
            end else begin
                Clear(CSTransferHandlingRfid);
                CSTransferHandlingRfid.SetRange("Rfid Header Id", CSRfidHeader.Id);
                CSTransferHandlingRfid.SetRange(Area, CSTransferHandlingRfid.Area::Receiving);
                CSTransferHandlingRfid.DeleteAll(true);

                Clear(CSRfidLines);
                CSRfidLines.SetRange(Id, CSRfidHeader.Id);
                if CSRfidLines.FindSet then begin
                    repeat
                        CSRfidLines.Match := false;
                        CSRfidLines.Modify(true);
                    until CSRfidLines.Next = 0;
                end;

                Clear(CSRfidLines);
                CSRfidLines.SetRange(Id, CSRfidHeader.Id);
                CSRfidLines.SetRange("Tag Shipped", false);
                CSRfidLines.DeleteAll(true);
            end;
        end;

        exit(DocId);
    end;

    procedure CloseTransfer(DocId: Text; ToDocNo: Text): Text
    var
        CSSetup: Record "NPR CS Setup";
        CSRfidHeader: Record "NPR CS Rfid Header";
        CSRfidLines: Record "NPR CS Rfid Lines";
    begin
        if not CSSetup.Get then
            exit(StrSubstNo(Txt010, CompanyName));

        if not CSRfidHeader.Get(DocId) then
            exit(StrSubstNo(Txt023, DocId));

        Clear(CSRfidLines);
        CSRfidLines.SetRange(Id, CSRfidHeader.Id);
        if CSRfidLines.Count = 0 then
            Error(Txt024);

        if ToDocNo <> '' then
            if CSSetup."Use Whse. Receipt" then
                CSRfidHeader.TransferWhseReceiptLines();

        exit(DocId)
    end;

    procedure GetJournalItemCount(StockTakeConfigCode: Text; WorksheetName: Text): Text
    var
        CSSetup: Record "NPR CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        CSItemJournalItems: Query "NPR CS Item Journal Items";
        CombinedKey: Code[30];
        JObject: JsonObject;
        Result: Text;
        ItemObject: JsonObject;
        ItemArray: JsonArray;
    begin
        if not CSSetup.Get then
            exit(StrSubstNo(Txt010, CompanyName));

        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", WorksheetName) then
            exit('UNKNOWNSTOCKTAKEWORKSHEET');

        CSItemJournalItems.SetRange(Journal_Template_Name, CSSetup."Phys. Inv Jour Temp Name");
        CSItemJournalItems.SetRange(Journal_Batch_Name, ItemJournalBatch.Name);
        CSItemJournalItems.Open;
        while CSItemJournalItems.Read do begin
            Clear(ItemObject);
            if CSItemJournalItems.Variant_Code <> '' then
                CombinedKey := CSItemJournalItems.Item_No + '-' + CSItemJournalItems.Variant_Code
            else
                CombinedKey := CSItemJournalItems.Item_No;
            ItemObject.Add('key', CombinedKey);
            ItemObject.Add('predicted', CSItemJournalItems.Sum_Qty_Calculated);
            ItemArray.Add(ItemObject);
        end;
        CSItemJournalItems.Close;
        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    procedure GetDocumentItemCount(DocId: Text): Text
    var
        JObject: JsonObject;
        Result: Text;
        CSRfidHeader: Record "NPR CS Rfid Header";
        CSRfidLines: Record "NPR CS Rfid Lines";
        CSRFIDDocumentItems: Query "NPR CS RFID Document Items";
        CombinedKey: Code[30];
        ItemObject: JsonObject;
        ItemArray: JsonArray;
    begin
        if not CSRfidHeader.Get(DocId) then
            exit('UNKNOWNDOCUMENT');

        CSRFIDDocumentItems.SetRange(Id, CSRfidHeader.Id);
        CSRFIDDocumentItems.SetRange(Tag_Shipped, true);
        CSRFIDDocumentItems.Open;
        while CSRFIDDocumentItems.Read do begin
            Clear(ItemObject);
            if CSRFIDDocumentItems.Variant_Code <> '' then
                CombinedKey := CSRFIDDocumentItems.Item_No + '-' + CSRFIDDocumentItems.Variant_Code
            else
                CombinedKey := CSRFIDDocumentItems.Item_No;

            if CombinedKey = '' then
                CombinedKey := 'UNKNOWNITEM';

            ItemObject.Add('key', CombinedKey);
            ItemObject.Add('predicted', CSRFIDDocumentItems.Count_);
            ItemArray.Add(ItemObject);
        end;
        CSRFIDDocumentItems.Close;
        JObject.Add('item', ItemArray);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    local procedure CleanTagEntries(var Values: List of [Text])
    var
        CSRfidTagModels: Record "NPR CS Rfid Tag Models";
        CSSetup: Record "NPR CS Setup";
        TagIDs: Text;
        Value: Text;
        ValuesString: Text;
        Separator: Text;
        EmptyArray: List of [Text];
    begin
        CSRfidTagModels.SetRange(Discontinued, false);
        if not CSRfidTagModels.FindSet then
            Error(NoRfidModelsInDBErr, CSRfidTagModels.TableCaption, CSSetup.FieldCaption("Disregard Unknown RFID Tags"), CSSetup.TableCaption);

        Separator := ',';
        ValuesString := '';
        foreach Value in Values do begin
            CSRfidTagModels.SetRange(Family, Value.Substring(0, 4));
            CSRfidTagModels.SetRange(Model, Value.Substring(3, 4));

            if not CSRfidTagModels.IsEmpty then begin
                if ValuesString = '' then
                    ValuesString := Value
                else
                    ValuesString := ValuesString + Separator + Value;
            end;
        end;

        if ValuesString = '' then
            Values := EmptyArray
        else
            Values := ValuesString.Split(Separator);
    end;
}

