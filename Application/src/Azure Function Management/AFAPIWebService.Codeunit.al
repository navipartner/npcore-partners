codeunit 6151572 "NPR AF API WebService"
{
    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit, 'azurefunction_service') then begin
            WebService.Init();
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'azurefunction_service';
            WebService."Object ID" := Codeunit::"NPR AF API WebService";
            WebService.Published := true;
            WebService.Insert();
        end;
    end;

    var
        TaskHandledMsg: Label 'Task is assigned to POS Unit %1 : %2';
        TaskIsHandledMsg: Label 'Task is already assigned to POS Unit %1 : %2';
        TaskCancelled: Label 'Task is cancelled by %1';
        TaskIsCancelled: Label 'Task was cancelled by %1';
        TaskCompleted: Label 'Task is completed by %1';
        TaskIsCompleted: Label 'Task was completed by %1';

    procedure SetNotificationFlag(CurrentUser: Code[50]; PosUnitNo: Code[10]; "Key": Code[10]): Text
    var
        PosUnit: Record "NPR POS Unit";
        AFNotificationHub: Record "NPR AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not PosUnit.Get(PosUnitNo) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Handled = 0DT) and (AFNotificationHub.Cancelled = 0DT) then begin
            AFNotificationHub.Handled := CurrentDateTime;
            AFNotificationHub."Handled By" := CurrentUser;
            AFNotificationHub."Handled Pos Unit No." := PosUnitNo;
            AFNotificationHub.Modify(true);
            exit(StrSubstNo(TaskHandledMsg, AFNotificationHub."Handled Pos Unit No.", AFNotificationHub."Handled By"));
        end else begin
            if AFNotificationHub.Handled <> 0DT then
                exit(StrSubstNo(TaskHandledMsg, AFNotificationHub."Handled Pos Unit No.", AFNotificationHub."Handled By"));
            if AFNotificationHub.Cancelled <> 0DT then
                exit(StrSubstNo(TaskIsCancelled, AFNotificationHub."Handled By"));
        end;
    end;

    procedure SetNotificationHandledFlag(CurrentUser: Code[50]; PosUnitNo: Code[10]; "Key": Code[10]): Text
    var
        PosUnit: Record "NPR POS Unit";
        AFNotificationHub: Record "NPR AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not PosUnit.Get(PosUnitNo) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Handled = 0DT) and (AFNotificationHub.Cancelled = 0DT) then begin
            AFNotificationHub.Handled := CurrentDateTime;
            AFNotificationHub."Handled By" := CurrentUser;
            AFNotificationHub."Handled Pos Unit No." := PosUnitNo;
            AFNotificationHub.Modify(true);
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskHandledMsg, AFNotificationHub."Handled Pos Unit No.", AFNotificationHub."Handled By")));
        end else begin
            if AFNotificationHub.Handled <> 0DT then
                exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsHandledMsg, AFNotificationHub."Handled Pos Unit No.", AFNotificationHub."Handled By")));
            if AFNotificationHub.Cancelled <> 0DT then
                exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsCancelled, AFNotificationHub."Cancelled By")));
        end;
    end;

    procedure SetNotificationCancelledFlag(CurrentUser: Code[50]; PosUnitNo: Code[10]; "Key": Code[10]): Text
    var
        PosUnit: Record "NPR POS Unit";
        AFNotificationHub: Record "NPR AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not PosUnit.Get(PosUnitNo) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Cancelled = 0DT) then begin
            AFNotificationHub.Cancelled := CurrentDateTime;
            AFNotificationHub."Cancelled By" := CurrentUser;
            AFNotificationHub."Cancelled Pos Unit No." := PosUnitNo;
            AFNotificationHub.Modify(true);
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskCancelled, AFNotificationHub."Cancelled By")));
        end;

        exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsCancelled, AFNotificationHub."Cancelled By")));
    end;

    procedure SetNotificationCompletedFlag(CurrentUser: Code[50]; PosUnitNo: Code[10]; "Key": Code[10]): Text
    var
        PosUnit: Record "NPR POS Unit";
        AFNotificationHub: Record "NPR AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not PosUnit.Get(PosUnitNo) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Cancelled = 0DT) and (AFNotificationHub.Completed = 0DT) then begin
            AFNotificationHub.Completed := CurrentDateTime;
            AFNotificationHub."Completed By" := CurrentUser;
            AFNotificationHub."Completed Pos Unit No." := PosUnitNo;
            AFNotificationHub.Modify(true);
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskCompleted, AFNotificationHub."Completed By")));
        end;

        if (AFNotificationHub.Cancelled <> 0DT) then
            exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsCancelled, AFNotificationHub."Cancelled By")));

        if (AFNotificationHub.Completed <> 0DT) then
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskIsCompleted, AFNotificationHub."Completed By")));
    end;

    procedure GetNotificationStatus("Key": Code[10]): Text
    var
        AFNotificationHub: Record "NPR AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        exit(BuildNotificationStatusResponse(AFNotificationHub, true, ''));
    end;

    procedure GetVariantByItem(ItemNo: Code[20]): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        JsonObj: JsonObject;
        JsonObjChld: JsonObject;
        JsonArr: JsonArray;
        JsonText: Text;
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        Base64String: Text;
        PictureFilename: Text;
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        ItemNo2: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin
        if ItemNo = '' then
            exit;

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(ItemNo, ItemNo2, VariantCode, ResolvingTable, true) then
            exit;

        if not Item.Get(ItemNo2) then
            exit;

        Base64String := AFHelperFunctions.GetMagentoItemImage(Item, PictureFilename);

        ItemVariant.SetFilter("Item No.", Item."No.");
        ItemVariant.SetFilter("NPR Blocked", '=%1', false);
        if not ItemVariant.FindSet() then
            exit;

        repeat
            JsonObjChld.Add('ItemNo', ItemVariant."Item No.");
            JsonObjChld.Add('Code', ItemVariant.Code);
            JsonObjChld.Add('Description', ItemVariant.Description);
            JsonObjChld.Add('Variety1', ItemVariant."NPR Variety 1");
            JsonObjChld.Add('Variety1Value', ItemVariant."NPR Variety 1 Value");

            JsonObjChld.Add('Variety2', ItemVariant."NPR Variety 2");
            JsonObjChld.Add('Variety2Value', ItemVariant."NPR Variety 2 Value");

            JsonObjChld.Add('Variety3', ItemVariant."NPR Variety 3");
            JsonObjChld.Add('Variety3Value', ItemVariant."NPR Variety 3 Value");

            JsonObjChld.Add('Variety4', ItemVariant."NPR Variety 4");
            JsonObjChld.Add('Variety4Value', ItemVariant."NPR Variety 4 Value");
            JsonArr.Add(JsonObjChld);
        until ItemVariant.Next() = 0;

        JsonObj.Add('Base64Image', Base64String);
        JsonObj.Add('ImageName', PictureFilename);
        JsonObj.Add('ItemVariants', JsonArr);

        JsonObj.WriteTo(JsonText);

        exit(JsonText);
    end;

    procedure GetVariantByBarcode(Barcode: Code[20]): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        JsonObj: JsonObject;
        JsonObjChld: JsonObject;
        JsonArr: JsonArray;
        JsonText: Text;
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Base64String: Text;
        PictureFilename: Text;
    begin
        if Barcode = '' then
            exit;

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
            exit;

        if not Item.Get(ItemNo) then
            exit;

        Base64String := AFHelperFunctions.GetMagentoItemImage(Item, PictureFilename);

        ItemVariant.SetFilter("Item No.", Item."No.");
        ItemVariant.SetFilter("NPR Blocked", '=%1', false);
        if not ItemVariant.FindSet() then
            exit;

        repeat
            JsonObjChld.Add('ItemNo', ItemVariant."Item No.");
            JsonObjChld.Add('Code', ItemVariant.Code);
            JsonObjChld.Add('Description', ItemVariant.Description);
            JsonObjChld.Add('Variety1', ItemVariant."NPR Variety 1");
            JsonObjChld.Add('Variety1Value', ItemVariant."NPR Variety 1 Value");

            JsonObjChld.Add('Variety2', ItemVariant."NPR Variety 2");
            JsonObjChld.Add('Variety2Value', ItemVariant."NPR Variety 2 Value");

            JsonObjChld.Add('Variety3', ItemVariant."NPR Variety 3");
            JsonObjChld.Add('Variety3Value', ItemVariant."NPR Variety 3 Value");

            JsonObjChld.Add('Variety4', ItemVariant."NPR Variety 4");
            JsonObjChld.Add('Variety4Value', ItemVariant."NPR Variety 4 Value");
            JsonArr.Add(JsonObjChld);
        until ItemVariant.Next() = 0;

        JsonObj.Add('Base64Image', Base64String);
        JsonObj.Add('ImageName', PictureFilename);
        JsonObj.Add('ItemVariants', JsonArr);

        JsonObj.WriteTo(JsonText);

        exit(JsonText);
    end;

    procedure GetReceiptAsPDF(SalesTicketNo: Code[20]; ReportId: Integer): Text
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        OStream: OutStream;
        Istream: InStream;
        POSEntry: Record "NPR POS Entry";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if SalesTicketNo = '' then
            exit;

        if ReportId = 0 then
            exit;

        RecRef.GetTable(POSEntry);
        FRef := RecRef.Field(5);
        FRef.SetRange(SalesTicketNo);
        if RecRef.IsEmpty then
            exit;

        TempBlob.CreateInStream(Istream);
        TempBlob.CreateOutStream(OStream);

        Report.SaveAs(ReportId, '', ReportFormat::Pdf, OStream, RecRef);

        exit(Base64Convert.ToBase64(Istream))
    end;

    procedure GetReportByJObjectAsBase64(JObjectTxt: Text): Text
    var
        Istream: InStream;
        OStream: OutStream;
        ReportID: Integer;
        RecID: RecordID;
        RecRef: RecordRef;
        VarRecRef: Variant;
        JsonObj: JsonObject;
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        AllObjWithCaption: Record AllObjWithCaption;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if JObjectTxt = '' then
            exit;
        JsonObj.ReadFrom(JObjectTxt);

        if not Evaluate(ReportID, AFHelperFunctions.GetValueAsText(JsonObj, 'reportID')) then
            exit;

        if not Evaluate(RecID, AFHelperFunctions.GetValueAsText(JsonObj, 'recordID'), 9) then
            exit;

        if not AllObjWithCaption.Get(OBJECTTYPE::Report, ReportID) then
            exit;

        RecRef := RecID.GetRecord();
        RecRef.SetRecFilter();
        VarRecRef := RecRef;

        TempBlob.CreateInStream(Istream);
        TempBlob.CreateOutStream(OStream);

        Report.SaveAs(ReportId, '', ReportFormat::Pdf, OStream, VarRecRef);

        exit(Base64Convert.ToBase64(Istream))
    end;


    local procedure BuildNotificationStatusResponse(AFNotificationHub: Record "NPR AF Notification Hub"; RequestStatus: Boolean; RequestMessages: Text): Text
    var

        JsonObj: JsonObject;
        JsonObjChld: JsonObject;
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        JsonText: Text;
    begin
        JsonObjChld.Add('Key', AFNotificationHub.Id);
        JsonObjChld.Add('RequestStatus', AFHelperFunctions.GetBooleanAsText(RequestStatus));
        JsonObjChld.Add('RequestMessages', RequestMessages);

        JsonObjChld.Add('Createddatetime', AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Created));
        JsonObjChld.Add('Createdby', AFNotificationHub."Created By");
        JsonObjChld.Add('Createdregister', AFNotificationHub."From POS Unit No.");

        JsonObjChld.Add('Handled', AFHelperFunctions.GetBooleanAsText(AFNotificationHub.Handled <> 0DT));
        JsonObjChld.Add('HandledDatetime', AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Handled));
        JsonObjChld.Add('HandledBy', AFNotificationHub."Handled By");
        JsonObjChld.Add('HandledRegister', AFNotificationHub."Handled Pos Unit No.");

        JsonObjChld.Add('Cancelled', AFHelperFunctions.GetBooleanAsText(AFNotificationHub.Cancelled <> 0DT));
        JsonObjChld.Add('CancelledDatetime', AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Completed));
        JsonObjChld.Add('CancelledBy', AFNotificationHub."Cancelled By");
        JsonObjChld.Add('CancelledRegister', AFNotificationHub."Cancelled Pos Unit No.");

        JsonObjChld.Add('Completed', AFHelperFunctions.GetBooleanAsText(AFNotificationHub.Completed <> 0DT));
        JsonObjChld.Add('CompleteDatetime', AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Completed));
        JsonObjChld.Add('CompletedBy', AFNotificationHub."Completed By");
        JsonObjChld.Add('CompletedRegister', AFNotificationHub."Completed Pos Unit No.");

        JsonObj.Add('Status', JsonObjChld);
        JsonObj.WriteTo(JsonText);
        exit(JsonText);
    end;
}