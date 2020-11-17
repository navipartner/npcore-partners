codeunit 6151373 "NPR CS Helper Functions"
{
    trigger OnRun()
    begin
    end;

    var
        Err_CSStockTakes: Label 'There is already an open Stock-Take with id %1';
        Err_PostingIsScheduled: Label 'Phy. Inventory Journal is scheduled for posting: %1 %2';
        Err_StockTakeWorksheetNotEmpty: Label 'Phy. Inventory Journal is not empty: %1 %2';
        Err_MissingLocation: Label 'Location is missing on POS Store';
        Err_ConfirmForceClose: Label 'This will delete Phy. Inventory Journal: %1 %2';
        Txt_CountingCancelled: Label 'Counting was cancelled';
        Text001: Label 'Location %1';
        Text002: Label 'Calculate Inventory for Location %1';
        Text003: Label 'There is no Items on Location %1';
        Err_PostingNotDone: Label 'The posting of the last counting is not finalised. Try again later.';
        Err_PostingIsPosted: Label 'Phy. Inventory Journal is already posted: %1 %2';
        Txt014: Label 'Only Super User countings can be posted';
        Txt013: Label 'User Id is not setup as Store User';
        Err_ConfirmForceCloseWOPosting: Label 'This will delete Phy. Inventory Journal: %1 %2 and cancel posting';

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

    procedure CreateLogEntry(var CSCommunicationLog: Record "NPR CS Comm. Log"; Document: Text; var IsEnable: Boolean; var LogCommunication: Boolean)
    var
        Ostream: OutStream;
        CSSetup: Record "NPR CS Setup";
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

    procedure UpdateLogEntry(var CSCommunicationLog: Record "NPR CS Comm. Log"; FunctionCalled: Text; IsInternalRequest: Boolean; InternalRequestId: Guid; Document: Text; LogCommunication: Boolean; "Device Id": Code[10])
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
        CSCommunicationLog."Device Id" := "Device Id";
        CSCommunicationLog."Response Data".CreateOutStream(Ostream);

        BigTextDocument.Write(Ostream);

        CSCommunicationLog.Modify(true);
    end;

    local procedure "-- Debug"()
    begin
    end;

    procedure InternalRequest(Request: Text; IsInternal: Boolean; InternalId: Guid)
    var
        CSWS: Codeunit "NPR CS WS";
    begin
        CSWS.IsInternalCall(IsInternal, InternalId);
        CSWS.ProcessDocument(Request);
    end;

    local procedure "-- Helper functions"()
    begin
    end;

    procedure ResetFieldDefaults(CSUIHeader: Record "NPR CS UI Header")
    var
        CSFieldDefaults: Record "NPR CS Field Defaults";
    begin
        Clear(CSFieldDefaults);
        CSFieldDefaults.SetRange("Use Case Code", CSUIHeader.Code);
        CSFieldDefaults.DeleteAll(true);
    end;

    procedure InitOfflineRfidData() Result: Text
    var
        CSRfidOfflineData: Record "NPR CS Rfid Data";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if not Confirm('Re-create the offline datastore?', true) then
            exit;

        CSRfidOfflineData.DeleteAll(true);

        ItemCrossReference.SetRange("NPR Is Retail Serial No.", true);
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
        JObject: DotNet NPRNetJObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        CSRfidItemGroups: Query "NPR CS Rfid Item Groups";
        CSRfidItems: Query "NPR CS Rfid Items";
        CSRfidItemTags: Query "NPR CS Rfid Item Tags";
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
        CSRfidTagModelsQuery: Query "NPR CS Rfid Tag Models";
        CSSetup: Record "NPR CS Setup";
        CSDevices: Record "NPR CS Devices";
        CSRfidData: Record "NPR CS Rfid Data";
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
            WritePropertyName('currenttagcount');
            WriteValue(CSDevices."Current Tag Count");
            WriteEndObject;
            WriteEndArray;

            WriteEndObject;
            JObject := Token;
        end;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices.Modify(true);

        Result := JObject.ToString();
    end;

    procedure CreateOfflineRfidDataDeltaV2(DeviceId: Code[20]) Result: Text
    var
        JObject: DotNet NPRNetJObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        CSRfidItemGroups: Query "NPR CS Rfid Item Groups";
        CSRfidItems: Query "NPR CS Rfid Items";
        CSRfidItemTags: Query "NPR CS Rfid Item Tags";
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
        CSRfidTagModelsQuery: Query "NPR CS Rfid Tag Models";
        CSSetup: Record "NPR CS Setup";
        CSDevices: Record "NPR CS Devices";
        CSRfidData: Record "NPR CS Rfid Data";
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
        CSRefillData: Record "NPR CS Refill Data";
        Item: Record Item;
        ItemGroup: Record "NPR Item Group";
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        JObject: DotNet NPRNetJObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        CSSetup: Record "NPR CS Setup";
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
        CSRefillItems: Query "NPR CS Refill Items";
        CSRefillSections: Query "NPR CS Refill Sections";
        CSStockTakes: Record "NPR CS Stock-Takes";
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
                            CSRefillData.Validate("Item Group Code", Item."NPR Item Group");
                            if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                                MagentoPictureLink.SetRange("Item No.", Item."No.");
                                MagentoPictureLink.SetRange("Base Image", true);
                                if MagentoPictureLink.FindFirst then
                                    if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                                        CSRefillData."Image Url" := MagentoPicture.GetMagentoUrl;
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
                            CSRefillData.Validate("Item Group Code", Item."NPR Item Group");
                            if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                                MagentoPictureLink.SetRange("Item No.", Item."No.");
                                MagentoPictureLink.SetRange("Base Image", true);
                                if MagentoPictureLink.FindFirst then
                                    if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                                        CSRefillData."Image Url" := MagentoPicture.GetMagentoUrl;
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

    procedure ClearDeviceInfo(var CSDevices: Record "NPR CS Devices")
    begin
        CSDevices."Last Download Timestamp" := 0;
        CSDevices."Refresh Item Catalog" := true;
        CSDevices.Modify(true);
    end;

    local procedure CreateCSRfidOfflineDataRecord(ItemCrossReference: Record "Item Cross Reference")
    var
        CSRfidOfflineData: Record "NPR CS Rfid Data";
        CSRfidTagModels: Record "NPR CS Rfid Tag Models";
        TagModel: Code[10];
        TagId: Code[30];
        Item: Record Item;
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoPicture: Record "NPR Magento Picture";
        CSSetup: Record "NPR CS Setup";
    begin
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
                CSRfidOfflineData.Validate("Item Group Code", Item."NPR Item Group");
                if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                    MagentoPictureLink.SetRange("Item No.", Item."No.");
                    MagentoPictureLink.SetRange("Base Image", true);
                    if MagentoPictureLink.FindFirst then
                        if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                            CSRfidOfflineData."Image Url" := MagentoPicture.GetMagentoUrl;
                end;
            end;
            CSRfidOfflineData.Modify(true);
        end;
    end;

    local procedure DeleteCSRfidOfflineDataRecord(ItemCrossReference: Record "Item Cross Reference")
    var
        CSRfidOfflineData: Record "NPR CS Rfid Data";
        CSRfidTagModels: Record "NPR CS Rfid Tag Models";
        TagModel: Code[10];
        TagId: Code[30];
        Item: Record Item;
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoPicture: Record "NPR Magento Picture";
        CSSetup: Record "NPR CS Setup";
    begin
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
    end;

    procedure CreateStockTakeWorksheet(Location: Code[20]; Name: Code[10]; var StockTakeWorksheet: Record "NPR Stock-Take Worksheet")
    var
        CSSetup: Record "NPR CS Setup";
        StockTakeConfiguration: Record "NPR Stock-Take Configuration";
        StockTakeTemplate: Record "NPR Stock-Take Template";
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
        CSDevices: Record "NPR CS Devices";
    begin
        if not CSDevices.Get(DeviceId) then
            exit;

        if CurrentTimestamp = 0 then
            exit;

        CSDevices."Last Download Timestamp" := CurrentTimestamp;
        CSDevices."Refresh Item Catalog" := false;
        CSDevices.Location := Location;
        CSDevices.Modify(true);

        Result := 'updated';
    end;

    procedure CreateNewCounting(Location: Record Location)
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        RecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSSetup: Record "NPR CS Setup";
        ItemJournalTemplate: Record "Item Journal Template";
        CalculateInventory: Report "Calculate Inventory";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        QtyCalculated: Decimal;
        CSStockTakes: Record "NPR CS Stock-Takes";
        NewCSStockTakes: Record "NPR CS Stock-Takes";
    begin
        CreateNewCountingV2(Location);
    end;

    procedure CancelCounting(var CSStockTakes: Record "NPR CS Stock-Takes")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        LocationRec: Record Location;
        RecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
    begin
        if CSStockTakes.Closed <> 0DT then
            exit;

        if not LocationRec.Get(CSStockTakes.Location) then
            Error(Err_MissingLocation);

        if ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name") then begin
            RecRef.GetTable(ItemJournalBatch);
            Clear(CSPostingBuffer);
            CSPostingBuffer.SetRange("Table No.", RecRef.Number);
            CSPostingBuffer.SetRange("Record Id", RecRef.RecordId);
            CSPostingBuffer.SetRange(Executed, false);
            if CSPostingBuffer.FindSet then
                Error(Err_PostingIsScheduled, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

            if not Confirm(StrSubstNo(Err_ConfirmForceClose, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name), true) then
                exit;

            ItemJournalBatch.Delete(true);

        end;

        CSStockTakes."Journal Posted" := CSStockTakes."Adjust Inventory";
        CSStockTakes.Closed := CurrentDateTime;
        CSStockTakes."Closed By" := UserId;
        CSStockTakes.Note := Txt_CountingCancelled;

        CSStockTakes.Modify(true);
    end;

    procedure CreateNewCountingV2(Location: Record Location)
    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        RecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSSetup: Record "NPR CS Setup";
        ItemJournalTemplate: Record "Item Journal Template";
        CalculateInventory: Report "Calculate Inventory";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        QtyCalculated: Decimal;
        CSStockTakes: Record "NPR CS Stock-Takes";
        NewCSStockTakes: Record "NPR CS Stock-Takes";
        CSCountingSupervisor: Record "NPR CS Counting Supervisor";
        AdjustInventory: Boolean;
        CSStoreUsers: Record "NPR CS Store Users";
        ExecuteCalculation: Boolean;
    begin
        if CSCountingSupervisor.Get(UserId) then begin
            AdjustInventory := true;
        end else begin
            Clear(CSStoreUsers);
            CSStoreUsers.SetRange("User ID", UserId);
            CSStoreUsers.SetRange("Adjust Inventory", true);
            if CSStoreUsers.FindFirst then
                AdjustInventory := true;
        end;

        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location, Location.Code);
        CSStockTakes.SetRange(Closed, 0DT);
        if AdjustInventory then
            CSStockTakes.SetRange("Adjust Inventory", true)
        else
            CSStockTakes.SetRange("Adjust Inventory", false);
        if CSStockTakes.FindSet then
            Error(Err_CSStockTakes, CSStockTakes."Stock-Take Id");

        if AdjustInventory then begin
            Clear(CSStockTakes);
            CSStockTakes.SetRange(Location, Location.Code);
            CSStockTakes.SetFilter(Closed, '<>%1', 0DT);
            CSStockTakes.SetRange("Journal Posted", false);
            CSStockTakes.SetRange("Adjust Inventory", true);
            if CSStockTakes.FindSet then
                Error(Err_PostingNotDone);
        end;

        CSSetup.Get;
        if AdjustInventory then begin
            CSSetup.TestField("Phys. Inv Jour Temp Name");
            ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
            if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", Location.Code) then begin
                ItemJournalBatch.Init;
                ItemJournalBatch.Validate("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
                ItemJournalBatch.Validate(Name, Location.Code);
                ItemJournalBatch.Description := StrSubstNo(Text001, Location.Code);
                ItemJournalBatch.Validate("No. Series", CSSetup."Phys. Inv Jour No. Series");
                ItemJournalBatch."Reason Code" := ItemJournalTemplate."Reason Code";
                ItemJournalBatch.Insert(true);
            end else begin
                RecRef.GetTable(ItemJournalBatch);
                Clear(CSPostingBuffer);
                CSPostingBuffer.SetRange("Table No.", RecRef.Number);
                CSPostingBuffer.SetRange("Record Id", RecRef.RecordId);
                CSPostingBuffer.SetRange(Executed, false);
                if CSPostingBuffer.FindSet then
                    Error(Err_PostingIsScheduled, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                if ItemJournalLine.Count > 0 then
                    Error(Err_StockTakeWorksheetNotEmpty, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);
            end;
        end;

        NewCSStockTakes.Init;
        NewCSStockTakes."Stock-Take Id" := CreateGuid;
        NewCSStockTakes.Created := CurrentDateTime;
        NewCSStockTakes."Created By" := UserId;
        NewCSStockTakes.Location := Location.Code;
        if AdjustInventory then begin
            NewCSStockTakes."Adjust Inventory" := true;
            NewCSStockTakes."Journal Template Name" := ItemJournalBatch."Journal Template Name";
            NewCSStockTakes."Journal Batch Name" := ItemJournalBatch.Name;
        end;
        NewCSStockTakes.Insert(true);

        Commit;

        if GuiAllowed then
            ExecuteCalculation := Confirm(StrSubstNo(Text002, Location.Code, true))
        else
            ExecuteCalculation := AdjustInventory;

        if ExecuteCalculation then begin
            Clear(ItemJournalLine);
            ItemJournalLine.Init;
            ItemJournalLine.Validate("Journal Template Name", NewCSStockTakes."Journal Template Name");
            ItemJournalLine.Validate("Journal Batch Name", NewCSStockTakes."Journal Batch Name");
            ItemJournalLine."Location Code" := NewCSStockTakes.Location;

            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", ItemJournalLine."Posting Date", false);
            ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

            Clear(Item);
            Item.SetFilter("Location Filter", NewCSStockTakes.Location);
            if not Item.FindSet then
                Error(Text003, Location);

            if CSSetup."Exclude Invt. Posting Groups" <> '' then
                Item.SetFilter("Inventory Posting Group", ReversedInvtPostingGroupFilter(CSSetup."Exclude Invt. Posting Groups"));

            Clear(CalculateInventory);
            CalculateInventory.UseRequestPage(false);
            CalculateInventory.SetTableView(Item);
            CalculateInventory.SetItemJnlLine(ItemJournalLine);
            CalculateInventory.InitializeRequest(WorkDate, ItemJournalLine."Document No.", false, false);
            CalculateInventory.RunModal;

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", NewCSStockTakes."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", NewCSStockTakes."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code", NewCSStockTakes.Location);
            if ItemJournalLine.FindSet then begin
                repeat
                    QtyCalculated += ItemJournalLine."Qty. (Calculated)"
                until ItemJournalLine.Next = 0;
            end;

            NewCSStockTakes."Predicted Qty." := QtyCalculated;
            NewCSStockTakes."Inventory Calculated" := true;
            NewCSStockTakes.Modify(true);
        end;
    end;

    procedure PostCounting(var CSStockTakes: Record "NPR CS Stock-Takes")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        DocumentNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if CSStockTakes."Journal Posted" then
            Error(Err_PostingIsPosted, CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");

        if not CSStockTakes."Adjust Inventory" then
            Error(Txt014);

        ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");
        ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report", false);

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

        if CSStockTakes.Closed = 0DT then begin
            CSStockTakes.Closed := CurrentDateTime;
            CSStockTakes."Closed By" := UserId;
        end;

        CSStockTakes."Journal Posted" := true;
        CSStockTakes.Modify(true);
    end;

    procedure CancelCountingWOPosting(var CSStockTakes: Record "NPR CS Stock-Takes")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        LocationRec: Record Location;
        RecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
    begin
        if CSStockTakes."Journal Posted" then
            exit;

        if not LocationRec.Get(CSStockTakes.Location) then
            Error(Err_MissingLocation);

        if ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name") then begin

            if not Confirm(StrSubstNo(Err_ConfirmForceCloseWOPosting, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name), true) then
                exit;

            RecRef.GetTable(ItemJournalBatch);
            Clear(CSPostingBuffer);
            CSPostingBuffer.SetRange("Table No.", RecRef.Number);
            CSPostingBuffer.SetRange("Record Id", RecRef.RecordId);
            CSPostingBuffer.SetRange(Executed, false);
            if CSPostingBuffer.FindSet then
                CSPostingBuffer.Delete(true);

            ItemJournalBatch.Delete(true);

        end;

        CSStockTakes."Journal Posted" := CSStockTakes."Adjust Inventory";
        CSStockTakes.Closed := CurrentDateTime;
        CSStockTakes."Closed By" := UserId;
        CSStockTakes.Note := Txt_CountingCancelled;

        CSStockTakes.Modify(true);
    end;

    procedure CaptureServiceStatus(): Boolean
    var
        CSSetup: Record "NPR CS Setup";
    begin
        if not CSSetup.Get then
            exit(false);

        if not CSSetup."Enable Capture Service" then
            exit(false);

        exit(true);
    end;

    procedure UpdateItemCrossRef()
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        Clear(ItemCrossReference);
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("NPR Is Retail Serial No.", true);
        if ItemCrossReference.FindFirst then begin
            repeat
                CreateCSRfidOfflineDataRecord(ItemCrossReference);
            until ItemCrossReference.Next = 0;
        end;
    end;

    procedure UpdateItemCrossRefFromRecord(var ItemCrossReference: Record "Item Cross Reference")
    begin
        ItemCrossReference.TestField("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.TestField("NPR Is Retail Serial No.", true);

        CreateCSRfidOfflineDataRecord(ItemCrossReference);
    end;

    local procedure ReversedInvtPostingGroupFilter(InvtPostingGroupFilterIn: Text): Text
    var
        InvtPostingGr: Record "Inventory Posting Group";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        Clear(InvtPostingGr);
        InvtPostingGr.SetFilter(Code, InvtPostingGroupFilterIn);
        if InvtPostingGr.FindSet() then
            repeat
                InvtPostingGr.Mark(true);
            until InvtPostingGr.Next() = 0;

        InvtPostingGr.SetRange(Code);
        if InvtPostingGr.FindSet() then
            repeat
                InvtPostingGr.Mark(not InvtPostingGr.Mark());
            until InvtPostingGr.Next() = 0;

        InvtPostingGr.MarkedOnly(true);
        if InvtPostingGr.IsEmpty then
            exit('');
        exit(SelectionFilterManagement.GetSelectionFilterForInventoryPostingGroup(InvtPostingGr));
    end;

    local procedure "-- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterInsertEvent', '', true, true)]
    local procedure T5717OnAfterInsert(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    var
        CSSetup: Record "NPR CS Setup";
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
            exit;

        if not Rec."NPR Is Retail Serial No." then
            exit;

        CreateCSRfidOfflineDataRecord(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', true, true)]
    local procedure T5717OnAfterModify(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; RunTrigger: Boolean)
    var
        CSSetup: Record "NPR CS Setup";
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
            exit;

        if not Rec."NPR Is Retail Serial No." then
            exit;

        CreateCSRfidOfflineDataRecord(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterDeleteEvent', '', true, true)]
    local procedure T5717OnAfterDelete(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    var
        CSSetup: Record "NPR CS Setup";
    begin
        if not CSSetup.Get then
            exit;

        if not CSSetup."Enable Capture Service" then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
            exit;

        if not Rec."NPR Is Retail Serial No." then
            exit;

        DeleteCSRfidOfflineDataRecord(Rec);
    end;
}