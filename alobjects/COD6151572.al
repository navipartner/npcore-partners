codeunit 6151572 "AF API WebService"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF API WebService
    // NPR5.38/CLVA/20171009 CASE 292987 Added Item Picture
    // NPR5.38/CLVA/20171117 CASE 292987 Added Variant 4
    // NPR5.39/BR  /20180214 CASE 304312 Added Support for POS Entry
    // NPR5.40/CLVA/20180315 CASE 307195 Added GetReportByJObjectAsBase64
    // NPR5.54/TJ  /20200303 CASE 393290 Refactored function GetReceiptAsPDF and added new parameter ReportId


    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit, 'azurefunction_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'azurefunction_service';
            WebService."Object ID" := 6151572;
            WebService.Published := true;
            WebService.Insert;
        end;
    end;

    var
        TaskHandled: Label 'Task is assigned to register %1 : %2';
        TaskIsHandled: Label 'Task is already assigned to register %1 : %2';
        TaskCancelled: Label 'Task is cancelled by %1';
        TaskIsCancelled: Label 'Task was cancelled by %1';
        TaskCompleted: Label 'Task is completed by %1';
        TaskIsCompleted: Label 'Task was completed by %1';

    [Scope('Personalization')]
    procedure SendDefaultPushNotification(Title: Text[30]; Body: Text[250]; Location: Code[10]): Integer
    var
        AFNotificationHub: Record "AF Notification Hub";
    begin
        if Title = '' then
            exit;

        GetCustomerTag();

        AFNotificationHub.Init;
        AFNotificationHub.Title := Title;
        AFNotificationHub.Body := Body;
        AFNotificationHub.Location := Location;
        AFNotificationHub.Insert(true);
        exit(AFNotificationHub.Id);
    end;

    [Scope('Personalization')]
    procedure SendAlertPushNotification(Title: Text[30]; Body: Text[250]; Location: Code[10]): Integer
    var
        AFNotificationHub: Record "AF Notification Hub";
    begin
        if Title = '' then
            exit;

        GetCustomerTag();

        AFNotificationHub.Init;
        AFNotificationHub.Title := Title;
        AFNotificationHub.Body := Body;
        AFNotificationHub.Location := Location;

        AFNotificationHub."Notification Color" := AFNotificationHub."Notification Color"::Red;

        AFNotificationHub.Insert(true);
        exit(AFNotificationHub.Id);
    end;

    [Scope('Personalization')]
    procedure GetCustomerTag(): Text
    var
        AFSetup: Record "AF Setup";
    begin
        if AFSetup.Get then begin
            if AFSetup."Customer Tag" = '' then begin
                AFSetup."Enable Azure Functions" := true;
                if AFSetup."Notification - API Key" = '' then begin
                    AFSetup."Notification - API Key" := '8cKroaodvzgJQwERKeULaGvyjCY9wOvvekNqfZD/DrHORgFLjj0Yhw==';
                    AFSetup."Notification - API Routing" := '/api/NotificationHubFunction';
                    AFSetup."Notification - Base Url" := 'https://navipartnerfa.azurewebsites.net';
                    AFSetup."Notification - Conn. String" := 'Endpoint=sb://npretailnotificationhublive.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=ZyuNLjqgPvXvstZdqWKeVhpbycP091CfMuUf5Z/GECQ=';
                    AFSetup."Notification - Hub Path" := 'npretailnotificationhublive';
                end;
                AFSetup.Modify(true);
            end;
            AFSetup.TestField("Customer Tag");
            exit(AFSetup."Customer Tag");
        end else begin
            AFSetup.Init;
            AFSetup."Enable Azure Functions" := true;
            AFSetup."Notification - API Key" := '8cKroaodvzgJQwERKeULaGvyjCY9wOvvekNqfZD/DrHORgFLjj0Yhw==';
            AFSetup."Notification - API Routing" := '/api/NotificationHubFunction';
            AFSetup."Notification - Base Url" := 'https://navipartnerfa.azurewebsites.net';
            AFSetup."Notification - Conn. String" := 'Endpoint=sb://npretailnotificationhublive.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=ZyuNLjqgPvXvstZdqWKeVhpbycP091CfMuUf5Z/GECQ=';
            AFSetup."Notification - Hub Path" := 'npretailnotificationhublive';
            AFSetup.Insert(true);
            exit(AFSetup."Customer Tag");
        end;
    end;

    [Scope('Personalization')]
    procedure SetNotificationFlag(CurrentUser: Code[50]; RegisterId: Code[10]; "Key": Code[10]): Text
    var
        Register: Record Register;
        AFNotificationHub: Record "AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not Register.Get(RegisterId) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Handled = 0DT) and (AFNotificationHub.Cancelled = 0DT) then begin
            AFNotificationHub.Handled := CurrentDateTime;
            AFNotificationHub."Handled By" := CurrentUser;
            AFNotificationHub."Handled Register" := RegisterId;
            AFNotificationHub.Modify(true);
            exit(StrSubstNo(TaskHandled, AFNotificationHub."Handled Register", AFNotificationHub."Handled By"));
            //EXIT(BuildNotificationStatusResponse(AFNotificationHub,TRUE,STRSUBSTNO(TaskHandled,AFNotificationHub."Handled Register",AFNotificationHub."Handled By")));
        end else begin
            if AFNotificationHub.Handled <> 0DT then
                exit(StrSubstNo(TaskIsHandled, AFNotificationHub."Handled Register", AFNotificationHub."Handled By"));
            //EXIT(BuildNotificationStatusResponse(AFNotificationHub,FALSE,STRSUBSTNO(TaskIsHandled,AFNotificationHub."Handled Register",AFNotificationHub."Handled By")));
            if AFNotificationHub.Cancelled <> 0DT then
                exit(StrSubstNo(TaskIsCancelled, AFNotificationHub."Handled By"));
            //EXIT(BuildNotificationStatusResponse(AFNotificationHub,FALSE,STRSUBSTNO(TaskIsCancelled,AFNotificationHub."Cancelled By")));
        end;
    end;

    [Scope('Personalization')]
    procedure SetNotificationHandledFlag(CurrentUser: Code[50]; RegisterId: Code[10]; "Key": Code[10]): Text
    var
        Register: Record Register;
        AFNotificationHub: Record "AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not Register.Get(RegisterId) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Handled = 0DT) and (AFNotificationHub.Cancelled = 0DT) then begin
            AFNotificationHub.Handled := CurrentDateTime;
            AFNotificationHub."Handled By" := CurrentUser;
            AFNotificationHub."Handled Register" := RegisterId;
            AFNotificationHub.Modify(true);
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskHandled, AFNotificationHub."Handled Register", AFNotificationHub."Handled By")));
        end else begin
            if AFNotificationHub.Handled <> 0DT then
                exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsHandled, AFNotificationHub."Handled Register", AFNotificationHub."Handled By")));
            if AFNotificationHub.Cancelled <> 0DT then
                exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsCancelled, AFNotificationHub."Cancelled By")));
        end;
    end;

    [Scope('Personalization')]
    procedure SetNotificationCancelledFlag(CurrentUser: Code[50]; RegisterId: Code[10]; "Key": Code[10]): Text
    var
        Register: Record Register;
        AFNotificationHub: Record "AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not Register.Get(RegisterId) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Cancelled = 0DT) then begin
            AFNotificationHub.Cancelled := CurrentDateTime;
            AFNotificationHub."Cancelled By" := CurrentUser;
            AFNotificationHub."Cancelled Register" := RegisterId;
            AFNotificationHub.Modify(true);
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskCancelled, AFNotificationHub."Cancelled By")));
        end;

        exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsCancelled, AFNotificationHub."Cancelled By")));
    end;

    [Scope('Personalization')]
    procedure SetNotificationCompletedFlag(CurrentUser: Code[50]; RegisterId: Code[10]; "Key": Code[10]): Text
    var
        Register: Record Register;
        AFNotificationHub: Record "AF Notification Hub";
        KeyInt: Integer;
    begin
        if Key = '' then
            exit;

        if CurrentUser = '' then
            exit;

        if not Register.Get(RegisterId) then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        if (AFNotificationHub.Cancelled = 0DT) and (AFNotificationHub.Completed = 0DT) then begin
            AFNotificationHub.Completed := CurrentDateTime;
            AFNotificationHub."Completed By" := CurrentUser;
            AFNotificationHub."Completed Register" := RegisterId;
            AFNotificationHub.Modify(true);
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskCompleted, AFNotificationHub."Completed By")));
        end;

        if (AFNotificationHub.Cancelled <> 0DT) then
            exit(BuildNotificationStatusResponse(AFNotificationHub, false, StrSubstNo(TaskIsCancelled, AFNotificationHub."Cancelled By")));

        if (AFNotificationHub.Completed <> 0DT) then
            exit(BuildNotificationStatusResponse(AFNotificationHub, true, StrSubstNo(TaskIsCompleted, AFNotificationHub."Completed By")));
    end;

    [Scope('Personalization')]
    procedure GetNotificationStatus("Key": Code[10]): Text
    var
        Register: Record Register;
        AFNotificationHub: Record "AF Notification Hub";
        KeyInt: Integer;
        JSON: Text;
    begin
        if Key = '' then
            exit;

        if not Evaluate(KeyInt, Key) then
            exit;

        if not AFNotificationHub.Get(KeyInt) then
            exit;

        exit(BuildNotificationStatusResponse(AFNotificationHub, true, ''));
    end;

    [Scope('Personalization')]
    procedure GetVariantByItem(ItemNo: Code[20]): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CodeCommaString: Text;
        Variant1CommaString: Text;
        Variant2CommaString: Text;
        Variant3CommaString: Text;
        AFHelperFunctions: Codeunit "AF Helper Functions";
        Base64String: Text;
        PictureFilename: Text;
        BarcodeLibrary: Codeunit "Barcode Library";
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
        ItemVariant.SetFilter(Blocked, '=%1', false);
        if ItemVariant.IsEmpty then
            exit;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            //NPR5.38 [292987]
            WritePropertyName('Base64Image');
            WriteValue(Base64String);
            WritePropertyName('ImageName');
            WriteValue(PictureFilename);
            //NPR5.38 [292987]
            WritePropertyName('ItemVariants');
            WriteStartArray;
            if ItemVariant.FindSet then begin
                repeat

                    CodeCommaString += ItemVariant.Code + ',';
                    Variant1CommaString += ItemVariant."Variety 1 Value" + ',';

                    WriteStartObject();
                    WritePropertyName('ItemNo');
                    WriteValue(ItemVariant."Item No.");
                    WritePropertyName('Code');
                    WriteValue(ItemVariant.Code);
                    WritePropertyName('Description');
                    WriteValue(ItemVariant.Description);
                    WritePropertyName('Variety1');
                    WriteValue(ItemVariant."Variety 1");
                    WritePropertyName('Variety1Value');
                    WriteValue(ItemVariant."Variety 1 Value");
                    WritePropertyName('Variety2');
                    WriteValue(ItemVariant."Variety 2");
                    WritePropertyName('Variety2Value');
                    WriteValue(ItemVariant."Variety 2 Value");
                    WritePropertyName('Variety3');
                    WriteValue(ItemVariant."Variety 3");
                    WritePropertyName('Variety3Value');
                    WriteValue(ItemVariant."Variety 3 Value");
                    //-NPR5.38 [292987]
                    WritePropertyName('Variety4');
                    WriteValue(ItemVariant."Variety 4");
                    WritePropertyName('Variety4Value');
                    WriteValue(ItemVariant."Variety 4 Value");
                    //+NPR5.38 [292987]
                    WriteEndObject();

                until ItemVariant.Next = 0;
            end;

            WriteEndArray;

            WriteEndObject;

            JObject := Token;
        end;

        exit(JObject.ToString);
    end;

    [Scope('Personalization')]
    procedure GetVariantByBarcode(Barcode: Code[20]): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CodeCommaString: Text;
        Variant1CommaString: Text;
        Variant2CommaString: Text;
        Variant3CommaString: Text;
        AFHelperFunctions: Codeunit "AF Helper Functions";
        BarcodeLibrary: Codeunit "Barcode Library";
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
        ItemVariant.SetFilter(Blocked, '=%1', false);
        if ItemVariant.IsEmpty then
            exit;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            //-NPR5.38 [292987]
            WritePropertyName('Base64Image');
            WriteValue(Base64String);
            WritePropertyName('ImageName');
            WriteValue(PictureFilename);
            //+NPR5.38 [292987]
            WritePropertyName('ItemVariants');
            WriteStartArray;
            if ItemVariant.FindSet then begin
                repeat

                    CodeCommaString += ItemVariant.Code + ',';
                    Variant1CommaString += ItemVariant."Variety 1 Value" + ',';

                    WriteStartObject();
                    WritePropertyName('ItemNo');
                    WriteValue(ItemVariant."Item No.");
                    WritePropertyName('Code');
                    WriteValue(ItemVariant.Code);
                    WritePropertyName('Description');
                    WriteValue(ItemVariant.Description);
                    WritePropertyName('Variety1');
                    WriteValue(ItemVariant."Variety 1");
                    WritePropertyName('Variety1Value');
                    WriteValue(ItemVariant."Variety 1 Value");
                    WritePropertyName('Variety2');
                    WriteValue(ItemVariant."Variety 2");
                    WritePropertyName('Variety2Value');
                    WriteValue(ItemVariant."Variety 2 Value");
                    WritePropertyName('Variety3');
                    WriteValue(ItemVariant."Variety 3");
                    WritePropertyName('Variety3Value');
                    WriteValue(ItemVariant."Variety 3 Value");
                    //-NPR5.38 [292987]
                    WritePropertyName('Variety4');
                    WriteValue(ItemVariant."Variety 4");
                    WritePropertyName('Variety4Value');
                    WriteValue(ItemVariant."Variety 4 Value");
                    //+NPR5.38 [292987]

                    WriteEndObject();

                until ItemVariant.Next = 0;
            end;

            WriteEndArray;

            //  WritePropertyName('ValueKeys');
            //  WriteValue(AFHelperFunctions.RemoveLastIndexOf(CodeCommaString,','));
            //  WritePropertyName('ValueVariant1');
            //  WriteValue(AFHelperFunctions.RemoveLastIndexOf(Variant1CommaString,','));

            WriteEndObject;

            JObject := Token;
        end;

        exit(JObject.ToString);
    end;

    [Scope('Personalization')]
    procedure GetReceiptAsPDF(SalesTicketNo: Code[20];ReportId: Integer): Text
    var
        AuditRoll: Record "Audit Roll";
        TempFile: File;
        Filename: Text[1024];
        Istream: InStream;
        MemoryStream: DotNet npNetMemoryStream;
        Bytes: DotNet npNetArray;
        Convert: DotNet npNetConvert;
        NPRetailSetup: Record "NP Retail Setup";
        POSEntry: Record "POS Entry";
        ReportBasedOn: Option "None",POSEntry,AuditRoll;
    begin
        if SalesTicketNo = '' then
            exit;
        
        //-NPR5.54 [393290]
        /*
        IF NOT MPOSAppSetup.FINDFIRST THEN
          EXIT;
        */
        if ReportId = 0 then
          exit;
        //+NPR5.54 [393290]
        
        //-NPR5.39 [304312]
        ReportBasedOn := ReportBasedOn::None;
        if NPRetailSetup.Get then begin
            if NPRetailSetup."Advanced Posting Activated" then begin
            //-NPR5.54 [393290]
            //CLEAR(POSEntry);
            //+NPR5.54 [393290]
                POSEntry.SetRange("Document No.", SalesTicketNo);
            //-NPR5.54 [393290]
            //IF POSEntry.FINDSET THEN BEGIN
            //  IF MPOSAppSetup."POS Entry Report ID" <> 0 THEN BEGIN
            if not POSEntry.IsEmpty then
            //+NPR5.54 [393290]
                        ReportBasedOn := ReportBasedOn::POSEntry;
            //-NPR5.54 [393290]
            //  END;
            //END;
            //+NPR5.54 [393290]
            end;
        end;
        if ReportBasedOn = ReportBasedOn::None then begin
          //-NPR5.54 [393290]
          //CLEAR(AuditRoll);
          //+NPR5.54 [393290]
            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
            AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
          //-NPR5.54 [393290]
          //IF AuditRoll.FINDSET THEN BEGIN
          //  IF MPOSAppSetup."Audit Roll Report ID" <> 0 THEN BEGIN
          if not AuditRoll.IsEmpty then
          //+NPR5.54 [393290]
                    ReportBasedOn := ReportBasedOn::AuditRoll;
          //-NPR5.54 [393290]
          //  END;
          //END;
          //+NPR5.54 [393290]
        end;
        
        if ReportBasedOn = ReportBasedOn::None then
            exit;
        
        TempFile.CreateTempFile;
        Filename := TempFile.Name;
        TempFile.Close();
        case ReportBasedOn of
          //-NPR5.54 [393290]
          /*
          ReportBasedOn::AuditRoll: REPORT.SAVEASPDF(MPOSAppSetup."Audit Roll Report ID",Filename,AuditRoll);
          ReportBasedOn::POSEntry : REPORT.SAVEASPDF(MPOSAppSetup."POS Entry Report ID",Filename,POSEntry);
          */
          ReportBasedOn::AuditRoll: REPORT.SaveAsPdf(ReportId,Filename,AuditRoll);
          ReportBasedOn::POSEntry : REPORT.SaveAsPdf(ReportId,Filename,POSEntry);
          //+NPR5.54 [393290]
        end;
        // IF MPOSAppSetup."Audit Roll Report ID" = 0 THEN
        //  EXIT;
        //
        // CLEAR(AuditRoll);
        // AuditRoll.SETRANGE("Sale Type",AuditRoll."Sale Type"::Sale);
        // AuditRoll.SETRANGE("Sales Ticket No.",SalesTicketNo);
        // IF NOT AuditRoll.FINDSET THEN
        //  EXIT;
        //
        // TempFile.CREATETEMPFILE;
        // Filename := TempFile.NAME;
        // TempFile.CLOSE();
        //
        // REPORT.SAVEASPDF(MPOSAppSetup."Audit Roll Report ID",Filename,AuditRoll);
        //
        //
        // TempFile.CREATETEMPFILE;
        // Filename := TempFile.NAME;
        // TempFile.CLOSE();
        //+NPR5.39 [304312]
        
        if Exists(Filename) then begin
            TempFile.Open(Filename);
            TempFile.CreateInStream(Istream);
            MemoryStream := MemoryStream.MemoryStream();
            CopyStream(MemoryStream, Istream);
            Bytes := MemoryStream.GetBuffer();
        
            TempFile.Close;
            FILE.Erase(Filename);
        
            exit(Convert.ToBase64String(Bytes));
        end;

    end;

    [Scope('Personalization')]
    procedure GetReportByJObjectAsBase64(JObjectTxt: Text): Text
    var
        TempFile: File;
        Filename: Text[1024];
        Istream: InStream;
        MemoryStream: DotNet npNetMemoryStream;
        Bytes: DotNet npNetArray;
        Convert: DotNet npNetConvert;
        ReportID: Integer;
        RecID: RecordID;
        RecRef: RecordRef;
        VarRecRef: Variant;
        JToken: DotNet JToken;
        JObject: DotNet JObject;
        AFHelperFunctions: Codeunit "AF Helper Functions";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        //-NPR5.40 [307195]
        if JObjectTxt = '' then
            exit;
        JToken := JObject.Parse(JObjectTxt);

        if not Evaluate(ReportID, AFHelperFunctions.GetValueAsText(JToken, 'reportID')) then
            exit;

        if not Evaluate(RecID, AFHelperFunctions.GetValueAsText(JToken, 'recordID'), 9) then
            exit;

        if not AllObjWithCaption.Get(OBJECTTYPE::Report, ReportID) then
            exit;

        RecRef := RecID.GetRecord;
        RecRef.SetRecFilter;
        VarRecRef := RecRef;

        TempFile.CreateTempFile;
        Filename := TempFile.Name;
        TempFile.Close();

        REPORT.SaveAsPdf(ReportID, Filename, VarRecRef);

        if Exists(Filename) then begin
            TempFile.Open(Filename);
            TempFile.CreateInStream(Istream);
            MemoryStream := MemoryStream.MemoryStream();
            CopyStream(MemoryStream, Istream);
            Bytes := MemoryStream.GetBuffer();

            TempFile.Close;
            FILE.Erase(Filename);

            exit(Convert.ToBase64String(Bytes));
        end;
        //+NPR5.40 [307195]
    end;

    local procedure IsAFEnabled(): Boolean
    var
        AFSetup: Record "AF Setup";
    begin
        if AFSetup.Get() then
            exit(AFSetup."Enable Azure Functions");

        exit(false);
    end;

    local procedure BuildNotificationStatusResponse(AFNotificationHub: Record "AF Notification Hub"; RequestStatus: Boolean; RequestMessages: Text): Text
    var
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        AFHelperFunctions: Codeunit "AF Helper Functions";
    begin
        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('Status');
            WriteStartObject();
            WritePropertyName('Key');
            WriteValue(AFNotificationHub.Id);
            WritePropertyName('RequestStatus');
            WriteValue(AFHelperFunctions.GetBooleanAsText(RequestStatus));
            WritePropertyName('RequestMessages');
            WriteValue(RequestMessages);

            WritePropertyName('Createddatetime');
            WriteValue(AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Created));
            WritePropertyName('Createdby');
            WriteValue(AFNotificationHub."Created By");
            WritePropertyName('Createdregister');
            WriteValue(AFNotificationHub."From Register No.");

            WritePropertyName('Handled');
            WriteValue(AFHelperFunctions.GetBooleanAsText(AFNotificationHub.Handled <> 0DT));
            WritePropertyName('HandledDatetime');
            WriteValue(AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Handled));
            WritePropertyName('HandledBy');
            WriteValue(AFNotificationHub."Handled By");
            WritePropertyName('HandledRegister');
            WriteValue(AFNotificationHub."Handled Register");

            WritePropertyName('Cancelled');
            WriteValue(AFHelperFunctions.GetBooleanAsText(AFNotificationHub.Cancelled <> 0DT));
            WritePropertyName('CancelledDatetime');
            WriteValue(AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Cancelled));
            WritePropertyName('CancelledBy');
            WriteValue(AFNotificationHub."Cancelled By");
            WritePropertyName('CancelledRegister');
            WriteValue(AFNotificationHub."Cancelled Register");

            WritePropertyName('Completed');
            WriteValue(AFHelperFunctions.GetBooleanAsText(AFNotificationHub.Completed <> 0DT));
            WritePropertyName('CompleteDatetime');
            WriteValue(AFHelperFunctions.GetDateTimeAsText(AFNotificationHub.Completed));
            WritePropertyName('CompletedBy');
            WriteValue(AFNotificationHub."Completed By");
            WritePropertyName('CompletedRegister');
            WriteValue(AFNotificationHub."Completed Register");
            WriteEndObject();
            WriteEndObject;
            JObject := Token;
        end;

        exit(JObject.ToString);
    end;
}

