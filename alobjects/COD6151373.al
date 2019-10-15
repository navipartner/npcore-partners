codeunit 6151373 "CS Helper Functions"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180604 CASE 307239 Updated PublishWebService to cs_service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181019 CASE 307282 Added functions CreateOfflineRfidData and DeleteRfidTagsInItemCrossRef
    // NPR5.48/CLVA/20181119 CASE 335051 Added Tag family and model info
    // NPR5.48/CLVA/20181214 CASE 335051 Added Timestamp filter and UpdateRfidTagsInItemCrossRef
    // NPR5.50/CLVA/20190206 CASE 344466 Added device Id to log functionality
    // NPR5.50/CLVA/20190227 CASE 346068 Added Event subscriber T5717OnAfterInsert, T5717OnAfterModify and T5717OnAfterDelete
    // NPR5.50/CLVA/20190425 CASE 352134 Deleted functions GetRfidMasterData, GetRfidData, CreateOfflineRfidData, DeleteRfidTagsInItemCrossRef, UpdateRfidTagsInItemCrossRef and
    // NPR5.50/CLVA/20190502 CASE 353741 Added elements to DeviceInfo
    // NPR5.51/CLVA/20190820 CASE 365659 Removed ItemTags from export
    //                                   Added missing WritePropertyName
    //                                   Handling empty Item Group Code in export data
    // NPR5.51/CLVA/20190822 CASE 365967 Added function PostTransferOrder and TryPostTransferOrder
    // NPR5.51/CLVA/20190701 CASE 350696 Added function GetRfidOfflineDataDeltaV2


    trigger OnRun()
    begin
    end;

    procedure PublishWebService(Enable: Boolean)
    var
        WebService: Record "Web Service";
    begin
        if Enable then begin
            if not WebService.Get(WebService."Object Type"::Codeunit, 'cs_service') then begin
                WebService.Init;
                WebService."Object Type" := WebService."Object Type"::Codeunit;
                WebService."Service Name" := 'cs_service';
                WebService."Object ID" := 6151372;
                WebService.Published := true;
                WebService.Insert(true);
            end;
        end else begin
            if WebService.Get(WebService."Object Type"::Codeunit, 'cs_service') then
                WebService.Delete(true);
        end;
    end;

    local procedure "-- Log functions"()
    begin
    end;

    procedure CreateLogEntry(var CSCommunicationLog: Record "CS Communication Log"; Document: Text; var IsEnable: Boolean; var LogCommunication: Boolean)
    var
        Ostream: OutStream;
        CSSetup: Record "CS Setup";
        BigTextDocument: BigText;
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        IsEnable := true;

        if not CSSetup."Log Communication" then
            exit;

        LogCommunication := true;

        BigTextDocument.AddText(Document);

        CSCommunicationLog.Init;
        CSCommunicationLog.Id := CreateGuid;
        CSCommunicationLog."Request Start" := CurrentDateTime;
        CSCommunicationLog."Request Data".CreateOutStream(Ostream);

        BigTextDocument.Write(Ostream);

        CSCommunicationLog.Insert;
        Commit;
    end;

    procedure UpdateLogEntry(var CSCommunicationLog: Record "CS Communication Log"; FunctionCalled: Text; IsInternalRequest: Boolean; InternalRequestId: Guid; Document: Text; LogCommunication: Boolean; "Device Id": Code[10])
    var
        Ostream: OutStream;
        BigTextDocument: BigText;
    begin
        if not LogCommunication then
            exit;

        BigTextDocument.AddText(Document);

        CSCommunicationLog."Request End" := CurrentDateTime;
        CSCommunicationLog."Request Function" := FunctionCalled;
        CSCommunicationLog."Internal Request" := IsInternalRequest;
        CSCommunicationLog."Internal Log No." := InternalRequestId;
        CSCommunicationLog.User := UserId;
        //-NPR5.50 [344466]
        CSCommunicationLog."Device Id" := "Device Id";
        //+NPR5.50 [344466]
        CSCommunicationLog."Response Data".CreateOutStream(Ostream);

        BigTextDocument.Write(Ostream);

        CSCommunicationLog.Modify(true);
    end;

    local procedure "-- Debug"()
    begin
    end;

    procedure InternalRequest(Request: Text; IsInternal: Boolean; InternalId: Guid)
    var
        CSWS: Codeunit "CS WS";
    begin
        CSWS.IsInternalCall(IsInternal, InternalId);
        CSWS.ProcessDocument(Request);
    end;

    local procedure "-- Helper functions"()
    begin
    end;

    procedure ResetFieldDefaults(CSUIHeader: Record "CS UI Header")
    var
        CSFieldDefaults: Record "CS Field Defaults";
    begin
        Clear(CSFieldDefaults);
        CSFieldDefaults.SetRange("Use Case Code", CSUIHeader.Code);
        CSFieldDefaults.DeleteAll(true);
    end;

    procedure InitOfflineRfidData() Result: Text
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if not Confirm('Re-create the offline datastore?', true) then
            exit;

        CSRfidOfflineData.DeleteAll(true);

        ItemCrossReference.SetRange("Rfid Tag", true);
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        if ItemCrossReference.FindSet then begin
            repeat
                CreateCSRfidOfflineDataRecord(ItemCrossReference);
            until ItemCrossReference.Next = 0;
        end;

        Clear(CSRfidOfflineData);
        CSRfidOfflineData.FindSet;
        Message('Offline data updated with: ' + Format(CSRfidOfflineData.Count) + ' records');
    end;

    procedure CreateOfflineRfidDataDelta(DeviceId: Code[20]) Result: Text
    var
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSRfidItemGroups: Query "CS Rfid Item Groups";
        CSRfidItems: Query "CS Rfid Items";
        CSRfidItemTags: Query "CS Rfid Item Tags";
        CSRfidItemHandling: Record "CS Rfid Item Handling";
        CSRfidTagModelsQuery: Query "CS Rfid Tag Models";
        CSSetup: Record "CS Setup";
        CSDevices: Record "CS Devices";
        CSRfidData: Record "CS Rfid Data";
        CurrentTimestamp: BigInteger;
    begin
        CSSetup.Get;

        if not CSSetup."Enable Capture Service" then
            exit;

        if not CSDevices.Get(DeviceId) then begin
            CSDevices.Init;
            CSDevices."Device Id" := DeviceId;
            CSDevices.Insert(true);
        end;

        CurrentTimestamp := CSDevices."Last Download Timestamp";

        CSRfidData.SetCurrentKey("Time Stamp");
        if CSDevices."Last Download Timestamp" <> 0 then
            CSRfidData.SetFilter("Time Stamp", StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
        CSRfidData.SetRange("Cross-Reference Discontinue", false);

        // JTokenWriter := JTokenWriter.JTokenWriter;
        // WITH JTokenWriter DO BEGIN
        //  WriteStartObject;
        //  WritePropertyName('itemtag');
        //  WriteStartArray;
        if CSRfidData.FindLast then begin
            CSDevices."Current Tag Count" := CSRfidData.Count;
            CurrentTimestamp := CSRfidData."Time Stamp";
            //      REPEAT
            //        WriteStartObject;
            //        WritePropertyName('key');
            //        WriteValue(CSRfidData.Key);
            //        WritePropertyName('item');
            //        WriteValue(CSRfidData."Combined key");
            //        WritePropertyName('itemgroup');
            //        WriteValue(CSRfidData."Item Group Code");
            //        WriteEndObject;

            //        CurrentTimestamp := CSRfidData."Time Stamp";

            //      UNTIL CSRfidData.NEXT = 0;
        end;
        //  WriteEndArray;
        //  WriteEndObject;
        //  JObject := Token;
        //END;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;

            WritePropertyName('itemgroup');
            WriteStartArray;

            WriteStartObject;
            WritePropertyName('key');
            WriteValue('UNKNOWNTAGS');
            WritePropertyName('title');
            WriteValue('UNKNOWN TAGS');
            WriteEndObject;

            if CSDevices."Last Download Timestamp" <> 0 then
                CSRfidItemGroups.SetFilter(Time_Stamp, StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
            CSRfidItemGroups.Open;
            while CSRfidItemGroups.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidItemGroups.Item_Group_Code);
                WritePropertyName('title');
                WriteValue(CSRfidItemGroups.Item_Group_Description);
                WriteEndObject;
            end;
            CSRfidItemGroups.Close;
            WriteEndArray;

            WritePropertyName('item');
            WriteStartArray;

            WriteStartObject;
            WritePropertyName('key');
            WriteValue('UNKNOWNITEM');
            WritePropertyName('title');
            WriteValue('UNKNOWN ITEM');
            WritePropertyName('itemno');
            WriteValue('UNKNOWNITEMNO');
            WritePropertyName('variantcode');
            WriteValue('');
            WritePropertyName('varianttitle');
            WriteValue('');
            WritePropertyName('itemgroup');
            WriteValue('UNKNOWNTAGS');
            WritePropertyName('imageurl');
            WriteValue('');
            WriteEndObject;

            if CSDevices."Last Download Timestamp" <> 0 then
                CSRfidItems.SetFilter(Time_Stamp, StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
            CSRfidItems.Open;
            while CSRfidItems.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidItems.Combined_key);
                WritePropertyName('title');
                WriteValue(CSRfidItems.Item_Description);
                WritePropertyName('itemno');
                WriteValue(CSRfidItems.Cross_Reference_Item_No);
                WritePropertyName('variantcode');
                WriteValue(CSRfidItems.Cross_Reference_Variant_Code);
                WritePropertyName('varianttitle');
                WriteValue(CSRfidItems.Variant_Description);
                WritePropertyName('itemgroup');
                WriteValue(CSRfidItems.Item_Group_Code);
                WritePropertyName('imageurl');
                WriteValue(CSRfidItems.Image_Url);
                WriteEndObject;
            end;
            CSRfidItems.Close;
            WriteEndArray;

            //-NPR5.51
            // WritePropertyName('itemtag');
            // WriteStartArray;
            // IF CSDevices."Last Download Timestamp" <> 0 THEN
            //  CSRfidItemTags.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
            // CSRfidItemTags.OPEN;
            // WHILE CSRfidItemTags.READ DO BEGIN
            //  WriteStartObject;
            //  WritePropertyName('key');
            //  WriteValue(CSRfidItemTags.Key);
            //  WritePropertyName('item');
            //  WriteValue(CSRfidItemTags.Combined_key);
            //  WritePropertyName('itemgroup');
            //  WriteValue(CSRfidItemTags.Item_Group_Code);
            //  WriteEndObject;
            // END;
            // CSRfidItemTags.CLOSE;
            // WriteEndArray;
            //+NPR5.51

            //-NPR5.50 [335051]
            WritePropertyName('supportedTagModels');
            WriteStartArray;
            CSRfidTagModelsQuery.Open;
            while CSRfidTagModelsQuery.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidTagModelsQuery.Family + CSRfidTagModelsQuery.Model);
                WritePropertyName('family');
                WriteValue(CSRfidTagModelsQuery.Family);
                WritePropertyName('model');
                WriteValue(CSRfidTagModelsQuery.Model);
                WriteEndObject;
            end;
            CSRfidTagModelsQuery.Close;
            WriteEndArray;
            //+NPR5.50 [335051]

            //-NPR5.50 [335051]
            WritePropertyName('deviceinfo');
            WriteStartArray;
            WriteStartObject;
            WritePropertyName('lasttimestamp');
            WriteValue(CurrentTimestamp);
            WritePropertyName('medialibrary');
            WriteValue(CSSetup."Media Library");
            WritePropertyName('refreshItemCatelog');
            if CSDevices."Refresh Item Catalog" then
                WriteValue('TRUE')
            else
                WriteValue('FALSE');
            //-NPR5.50 [35374]
            //-NPR5.51
            WritePropertyName('currenttagcount');
            //+NPR5.51
            WriteValue(CSDevices."Current Tag Count");
            //+NPR5.50 [35374]
            WriteEndObject;
            WriteEndArray;
            //+NPR5.50 [335051]

            WriteEndObject;
            JObject := Token;
        end;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices.Modify(true);

        Result := JObject.ToString();
    end;

    procedure CreateOfflineRfidDataDeltaV2(DeviceId: Code[20]) Result: Text
    var
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSRfidItemGroups: Query "CS Rfid Item Groups";
        CSRfidItems: Query "CS Rfid Items";
        CSRfidItemTags: Query "CS Rfid Item Tags";
        CSRfidItemHandling: Record "CS Rfid Item Handling";
        CSRfidTagModelsQuery: Query "CS Rfid Tag Models";
        CSSetup: Record "CS Setup";
        CSDevices: Record "CS Devices";
        CSRfidData: Record "CS Rfid Data";
        CurrentTimestamp: BigInteger;
    begin
        CSSetup.Get;

        if not CSSetup."Enable Capture Service" then
            exit;

        if not CSDevices.Get(DeviceId) then begin
            CSDevices.Init;
            CSDevices."Device Id" := DeviceId;
            CSDevices.Insert(true);
        end;

        CurrentTimestamp := CSDevices."Last Download Timestamp";

        CSRfidData.SetCurrentKey("Time Stamp");
        if CSDevices."Last Download Timestamp" <> 0 then
            CSRfidData.SetFilter("Time Stamp", StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
        CSRfidData.SetRange("Cross-Reference Discontinue", false);

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;

            WritePropertyName('itemtag');
            WriteStartArray;
            if CSRfidData.FindSet then begin
                CSDevices."Current Tag Count" := CSRfidData.Count;
                repeat
                    WriteStartObject;
                    WritePropertyName('key');
                    WriteValue(CSRfidData.Key);
                    WritePropertyName('item');
                    WriteValue(CSRfidData."Combined key");
                    WritePropertyName('itemgroup');
                    WriteValue(CSRfidData."Item Group Code");
                    WriteEndObject;

                    CurrentTimestamp := CSRfidData."Time Stamp";

                until CSRfidData.Next = 0;
            end;
            WriteEndArray;

            WritePropertyName('itemgroup');
            WriteStartArray;

            WriteStartObject;
            WritePropertyName('key');
            WriteValue('UNKNOWNTAGS');
            WritePropertyName('title');
            WriteValue('UNKNOWN TAGS');
            WriteEndObject;

            if CSDevices."Last Download Timestamp" <> 0 then
                CSRfidItemGroups.SetFilter(Time_Stamp, StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
            CSRfidItemGroups.Open;
            while CSRfidItemGroups.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidItemGroups.Item_Group_Code);
                WritePropertyName('title');
                WriteValue(CSRfidItemGroups.Item_Group_Description);
                WriteEndObject;
            end;
            CSRfidItemGroups.Close;
            WriteEndArray;

            WritePropertyName('item');
            WriteStartArray;

            WriteStartObject;
            WritePropertyName('key');
            WriteValue('UNKNOWNITEM');
            WritePropertyName('title');
            WriteValue('UNKNOWN ITEM');
            WritePropertyName('itemno');
            WriteValue('UNKNOWNITEMNO');
            WritePropertyName('variantcode');
            WriteValue('');
            WritePropertyName('varianttitle');
            WriteValue('');
            WritePropertyName('itemgroup');
            WriteValue('UNKNOWNTAGS');
            WritePropertyName('imageurl');
            WriteValue('');
            WriteEndObject;

            if CSDevices."Last Download Timestamp" <> 0 then
                CSRfidItems.SetFilter(Time_Stamp, StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
            CSRfidItems.Open;
            while CSRfidItems.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidItems.Combined_key);
                WritePropertyName('title');
                WriteValue(CSRfidItems.Item_Description);
                WritePropertyName('itemno');
                WriteValue(CSRfidItems.Cross_Reference_Item_No);
                WritePropertyName('variantcode');
                WriteValue(CSRfidItems.Cross_Reference_Variant_Code);
                WritePropertyName('varianttitle');
                WriteValue(CSRfidItems.Variant_Description);
                WritePropertyName('itemgroup');
                WriteValue(CSRfidItems.Item_Group_Code);
                WritePropertyName('imageurl');
                WriteValue(CSRfidItems.Image_Url);
                WriteEndObject;
            end;
            CSRfidItems.Close;
            WriteEndArray;

            WritePropertyName('itemtag');
            WriteStartArray;
            if CSDevices."Last Download Timestamp" <> 0 then
                CSRfidItemTags.SetFilter(Time_Stamp, StrSubstNo('>%1', CSDevices."Last Download Timestamp"));
            CSRfidItemTags.Open;
            while CSRfidItemTags.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidItemTags.Key);
                WritePropertyName('item');
                WriteValue(CSRfidItemTags.Combined_key);
                WritePropertyName('itemgroup');
                WriteValue(CSRfidItemTags.Item_Group_Code);
                WriteEndObject;
            end;
            CSRfidItemTags.Close;
            WriteEndArray;

            //-#335051 [335051]
            WritePropertyName('supportedTagModels');
            WriteStartArray;
            CSRfidTagModelsQuery.Open;
            while CSRfidTagModelsQuery.Read do begin
                WriteStartObject;
                WritePropertyName('key');
                WriteValue(CSRfidTagModelsQuery.Family + CSRfidTagModelsQuery.Model);
                WritePropertyName('family');
                WriteValue(CSRfidTagModelsQuery.Family);
                WritePropertyName('model');
                WriteValue(CSRfidTagModelsQuery.Model);
                WriteEndObject;
            end;
            CSRfidTagModelsQuery.Close;
            WriteEndArray;
            //+#335051 [335051]

            //-#335051 [335051]
            WritePropertyName('deviceinfo');
            WriteStartArray;
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSDevices."Device Id");
            WritePropertyName('lasttimestamp');
            WriteValue(CurrentTimestamp);
            WritePropertyName('medialibrary');
            WriteValue(CSSetup."Media Library");
            WritePropertyName('refreshItemCatelog');
            if CSDevices."Refresh Item Catalog" then
                WriteValue('TRUE')
            else
                WriteValue('FALSE');
            WriteEndObject;
            WriteEndArray;
            //+#335051 [335051]

            WriteEndObject;
            JObject := Token;
        end;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices."Refresh Item Catalog" := false;
        CSDevices.Modify(true);

        Result := JObject.ToString();
    end;

    procedure CreateRefillData(StockTakeId: Text) Result: Text
    var
        CSRefillData: Record "CS Refill Data";
        Item: Record Item;
        ItemGroup: Record "Item Group";
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSSetup: Record "CS Setup";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        StockTakeWorkSheetLine: Record "Stock-Take Worksheet Line";
        CSRefillItems: Query "CS Refill Items";
        CSRefillSections: Query "CS Refill Sections";
        CSStockTakes: Record "CS Stock-Takes";
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if not CSStockTakes.Get(StockTakeId) then
            exit;

        if (CSStockTakes."Create Refill Data Started" = 0DT) then begin

            CSStockTakes."Create Refill Data Started" := CurrentDateTime;

            StockTakeWorksheet.Get(CSStockTakes.Location, 'SALESFLOOR');
            StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
            StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
            if StockTakeWorkSheetLine.FindSet then begin
                repeat
                    if StockTakeWorkSheetLine."Item No." <> '' then begin
                        if not CSRefillData.Get(StockTakeWorkSheetLine."Item No.", StockTakeWorkSheetLine."Variant Code", StockTakeWorksheet."Conf Location Code", CSStockTakes."Stock-Take Id") then begin
                            CSRefillData.Init;
                            CSRefillData.Validate("Item No.", StockTakeWorkSheetLine."Item No.");
                            CSRefillData.Validate("Variant Code", StockTakeWorkSheetLine."Variant Code");
                            CSRefillData.Validate(Location, StockTakeWorksheet."Conf Location Code");
                            CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                            CSRefillData.Insert(true);
                        end;

                        if CSRefillData."Variant Code" <> '' then
                            CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                        else
                            CSRefillData."Combined key" := CSRefillData."Item No.";

                        CSRefillData."Qty. in Store" += StockTakeWorkSheetLine."Qty. (Counted)";

                        if Item.Get(CSRefillData."Item No.") then begin
                            CSRefillData.Validate("Item Group Code", Item."Item Group");
                            if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                                MagentoPictureLink.SetRange("Item No.", Item."No.");
                                MagentoPictureLink.SetRange("Base Image", true);
                                if MagentoPictureLink.FindFirst then
                                    if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                                        CSRefillData."Image Url" := MagentoPicture.GetMagentotUrl;
                            end;
                        end;

                        CSRefillData.Modify(true);
                    end;
                until StockTakeWorkSheetLine.Next = 0;
            end;

            Clear(StockTakeWorksheet);
            Clear(StockTakeWorkSheetLine);
            StockTakeWorksheet.Get(CSStockTakes.Location, 'STOCKROOM');
            StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
            StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
            if StockTakeWorkSheetLine.FindSet then begin
                repeat
                    if StockTakeWorkSheetLine."Item No." <> '' then begin
                        if not CSRefillData.Get(StockTakeWorkSheetLine."Item No.", StockTakeWorkSheetLine."Variant Code", StockTakeWorksheet."Conf Location Code", CSStockTakes."Stock-Take Id") then begin
                            CSRefillData.Init;
                            CSRefillData.Validate("Item No.", StockTakeWorkSheetLine."Item No.");
                            CSRefillData.Validate("Variant Code", StockTakeWorkSheetLine."Variant Code");
                            CSRefillData.Validate(Location, StockTakeWorksheet."Conf Location Code");
                            CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                            CSRefillData.Insert(true);
                        end;

                        if CSRefillData."Variant Code" <> '' then
                            CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                        else
                            CSRefillData."Combined key" := CSRefillData."Item No.";

                        CSRefillData."Qty. in Stock" += StockTakeWorkSheetLine."Qty. (Counted)";

                        if Item.Get(CSRefillData."Item No.") then begin
                            CSRefillData.Validate("Item Group Code", Item."Item Group");
                            if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                                MagentoPictureLink.SetRange("Item No.", Item."No.");
                                MagentoPictureLink.SetRange("Base Image", true);
                                if MagentoPictureLink.FindFirst then
                                    if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                                        CSRefillData."Image Url" := MagentoPicture.GetMagentotUrl;
                            end;
                        end;

                        CSRefillData.Modify(true);
                    end;
                until StockTakeWorkSheetLine.Next = 0;
            end;

            CSStockTakes."Create Refill Data Ended" := CurrentDateTime;
            CSStockTakes.Modify;

        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;

            WritePropertyName('section');
            WriteStartArray;
            CSRefillSections.SetFilter(Stock_Take_Id, CSStockTakes."Stock-Take Id");
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
            CSRefillItems.SetFilter(Stock_Take_Id, CSStockTakes."Stock-Take Id");
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

    procedure ClearDeviceInfo(var CSDevices: Record "CS Devices")
    begin
        CSDevices."Last Download Timestamp" := 0;
        CSDevices."Refresh Item Catalog" := true;
        CSDevices.Modify(true);
    end;

    local procedure CreateCSRfidOfflineDataRecord(ItemCrossReference: Record "Item Cross Reference")
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        TagModel: Code[10];
        TagId: Code[30];
        Item: Record Item;
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoPicture: Record "Magento Picture";
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if StrLen(ItemCrossReference."Cross-Reference No.") <> MaxStrLen(ItemCrossReference."Cross-Reference No.") then
            exit;

        TagModel := CopyStr(ItemCrossReference."Cross-Reference No.", 1, 4);

        Clear(CSRfidTagModels);
        CSRfidTagModels.SetRange(Model, TagModel);
        if CSRfidTagModels.FindSet then begin

            TagId := CSRfidTagModels.Family + ItemCrossReference."Cross-Reference No.";

            if not CSRfidOfflineData.Get(TagId) then begin
                CSRfidOfflineData.Init;
                CSRfidOfflineData.Key := TagId;
                CSRfidOfflineData.Insert(true);
            end;

            CSRfidOfflineData.Validate("Cross-Reference Item No.", ItemCrossReference."Item No.");
            CSRfidOfflineData.Validate("Cross-Reference Variant Code", ItemCrossReference."Variant Code");
            CSRfidOfflineData.Validate("Cross-Reference UoM", ItemCrossReference."Unit of Measure");
            CSRfidOfflineData.Validate("Cross-Reference Description", ItemCrossReference.Description);
            CSRfidOfflineData.Validate("Cross-Reference Discontinue", ItemCrossReference."Discontinue Bar Code");
            CSRfidOfflineData.Validate(Heartbeat, CurrentDateTime);
            if Item.Get(CSRfidOfflineData."Cross-Reference Item No.") then begin
                CSRfidOfflineData.Validate("Item Group Code", Item."Item Group");
                if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                    MagentoPictureLink.SetRange("Item No.", Item."No.");
                    MagentoPictureLink.SetRange("Base Image", true);
                    if MagentoPictureLink.FindFirst then
                        if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                            CSRfidOfflineData."Image Url" := MagentoPicture.GetMagentotUrl;
                end;
            end;
            CSRfidOfflineData.Modify(true);
        end;
        //+NPR5.50 [346068]
    end;

    local procedure DeleteCSRfidOfflineDataRecord(ItemCrossReference: Record "Item Cross Reference")
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        TagModel: Code[10];
        TagId: Code[30];
        Item: Record Item;
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoPicture: Record "Magento Picture";
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if StrLen(ItemCrossReference."Cross-Reference No.") <> MaxStrLen(ItemCrossReference."Cross-Reference No.") then
            exit;

        TagModel := CopyStr(ItemCrossReference."Cross-Reference No.", 1, 4);

        Clear(CSRfidTagModels);
        CSRfidTagModels.SetRange(Model, TagModel);
        if CSRfidTagModels.FindSet then begin

            TagId := CSRfidTagModels.Family + ItemCrossReference."Cross-Reference No.";

            if CSRfidOfflineData.Get(TagId) then
                CSRfidOfflineData.Delete(true);

        end;
        //+NPR5.50 [346068]
    end;

    procedure CreateStockTakeWorksheet(Location: Code[20]; Name: Code[10]; var StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        CSSetup: Record "CS Setup";
        StockTakeConfiguration: Record "Stock-Take Configuration";
        StockTakeTemplate: Record "Stock-Take Template";
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if StockTakeWorksheet.Get(Location, Name) then
            exit;

        CSSetup.TestField("Stock-Take Template");
        StockTakeTemplate.Get(CSSetup."Stock-Take Template");

        if not StockTakeConfiguration.Get(Location) then begin
            StockTakeConfiguration.Init;
            StockTakeConfiguration.Code := Location;
            StockTakeConfiguration.TransferFields(StockTakeTemplate, false);
            StockTakeConfiguration.Description := StrSubstNo('%1 Stock-Take', StockTakeConfiguration.Code);
            StockTakeConfiguration."Location Code" := Location;
            StockTakeConfiguration."Inventory Calc. Date" := WorkDate;
            StockTakeConfiguration."Stock-Take Template Code" := StockTakeTemplate.Code;
            StockTakeConfiguration.Insert();
        end;

        StockTakeWorksheet.Init;
        StockTakeWorksheet."Stock-Take Config Code" := StockTakeConfiguration.Code;
        StockTakeWorksheet.Name := Name;
        StockTakeWorksheet.Insert(true);
    end;

    procedure UpdateDeviceInfo(DeviceId: Code[10]; CurrentTimestamp: BigInteger; Location: Code[20]) Result: Text
    var
        CSDevices: Record "CS Devices";
    begin
        if not CSDevices.Get(DeviceId) then
            exit;

        if CurrentTimestamp = 0 then
            exit;

        CSDevices."Last Download Timestamp" := CurrentTimestamp;
        //-NPR5.50 [353741]
        CSDevices."Refresh Item Catalog" := false;
        //+NPR5.50 [353741]
        CSDevices.Location := Location;
        CSDevices.Modify(true);

        Result := 'updated';
    end;

    local procedure "-- Posting Functions"()
    begin
    end;

    procedure PostTransferOrder(var CSPostingBuffer: Record "CS Posting Buffer")
    var
        ErrorTxt: Text;
        TransferHeader: Record "Transfer Header";
        PostingFinished: Boolean;
    begin
        CSPostingBuffer.TestField(Posted, false);
        ClearLastError;

        TransferHeader.Get(CSPostingBuffer."Key 1");

        PostingFinished := CODEUNIT.Run(CODEUNIT::"CS UI Transfer Order Posting", TransferHeader);

        if PostingFinished then begin
            if TransferHeader.Get(CSPostingBuffer."Key 1") then begin
                CSPostingBuffer.Aborted := true;
                ErrorTxt := StrSubstNo('%1 : %2', GetLastErrorCode, GetLastErrorText);
                CSPostingBuffer.Description := CopyStr(ErrorTxt, 1, MaxStrLen(CSPostingBuffer.Description));
            end else
                CSPostingBuffer.Posted := true;
        end else begin
            CSPostingBuffer.Aborted := true;
            ErrorTxt := StrSubstNo('%1 : %2', GetLastErrorCode, GetLastErrorText);
            CSPostingBuffer.Description := CopyStr(ErrorTxt, 1, MaxStrLen(CSPostingBuffer.Description));
        end;
        CSPostingBuffer.Modify(true);

        // IF TryPostTransferOrder(CSPostingBuffer) THEN BEGIN
        //  CSPostingBuffer.Posted := TRUE;
        // END ELSE BEGIN
        //  CSPostingBuffer.Aborted := TRUE;
        //  ErrorTxt := STRSUBSTNO('%1 : %2',GETLASTERRORCODE,GETLASTERRORTEXT);
        //  CSPostingBuffer.Description := COPYSTR(ErrorTxt,1,MAXSTRLEN(CSPostingBuffer.Description));
        // END;
        // CSPostingBuffer.MODIFY(TRUE);
    end;

    [TryFunction]
    procedure TryPostTransferOrder(CSPostingBuffer: Record "CS Posting Buffer")
    var
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
        TransferHeader: Record "Transfer Header";
        PostedTransferHeader: Record "Transfer Header";
    begin
        TransferHeader.Get(CSPostingBuffer."Key 1");
        TransferPostReceipt.SetHideValidationDialog(true);
        if TransferPostReceipt.Run(TransferHeader) then begin
            if PostedTransferHeader.Get(TransferHeader."No.") then begin
                if PostedTransferHeader.Status = PostedTransferHeader.Status::Released then
                    ReleaseTransferDoc.Reopen(PostedTransferHeader);
                PostedTransferHeader.Delete(true);
            end;
        end;
    end;

    local procedure "-- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterInsertEvent', '', true, true)]
    local procedure T5717OnAfterInsert(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
            exit;

        if not Rec."Rfid Tag" then
            exit;

        CreateCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', true, true)]
    local procedure T5717OnAfterModify(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
            exit;

        if not Rec."Rfid Tag" then
            exit;

        CreateCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterDeleteEvent', '', true, true)]
    local procedure T5717OnAfterDelete(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
            exit;

        if not Rec."Rfid Tag" then
            exit;

        DeleteCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;
}

