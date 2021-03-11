codeunit 85021 "NPR NpXml Tests"
{
    //[Feature] NpXml module, download UPD_ITEM.xml from AzureBlob storage and sync with WebShop using FTP and API
    Subtype = Test;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        Initialized: Boolean;

    [Test]
    procedure ProcessTaskWithUpdItemXmlTemplateUsingAPI()
    var
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        NpXmlTemplate: Record "NPR NpXml Template";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        Assert: Codeunit Assert;
        NpXmlTests: Codeunit "NPR NpXml Tests";
        Successed: Boolean;
    begin
        // [Scenario] Check that Process Manualy action is handled correctly using UPD_Item XML template

        //[GIVEN] Initialize
        Initialize();

        //[GIVEN] Enable Data Log for table
        EnableDataLog(Database::Item);

        //[GIVEN] Enable Data Log Subscriber
        EnableDataLogSubscriber(Database::Item);

        //[GIVEN] Create Item
        LibraryInventory.CreateItem(Item);

        //[GIVEN] Enable Magento Item 
        Item."NPR Magento Item" := true;
        Item.Description := format(Random(10000));
        BindSubscription(NpXmlTests);
        Item.Modify();
        UnbindSubscription(NpXmlTests);

        //[GIVEN] Download XML Template from Azure Blob Storage
        DownloadXmlTemplateFromAzureBlobStorage('Latest/upd_item.xml', NpXmlTemplate);

        //[GIVEN] Configure XML Template
        ConfigureXmlTemplateForAPI(NpXmlTemplate);

        //[GIVEN] Import TaskList Item
        ImportTaskList();

        //[WHEN] TaskList item is processed
        NcTask.SetRange("Table No.", Database::Item);
        NcTask.SetRange("Record Value", Item."No.");
        if NcTask.FindFirst() then
            Successed := NcSyncMgt.ProcessTask(NcTask);

        //[THEN] Check if Resposne was Successfull
        Assert.IsTrue(Successed, 'API synchronization failed for XML template: UPD_Item');
    end;

    [Test]
    procedure ProcessTaskWithUpdItemXmlTemplateUsingFTP()
    var
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        NpXmlTemplate: Record "NPR NpXml Template";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        Assert: Codeunit Assert;
        NpXmlTests: Codeunit "NPR NpXml Tests";
        Successed: Boolean;
    begin
        // [Scenario] Check that Process Manualy action is handled correctly using UPD_Item XML template

        //[GIVEN] Initialize
        Initialize();

        //[GIVEN] Enable Data Log for table
        EnableDataLog(Database::Item);

        //[GIVEN] Enable Data Log Subscriber
        EnableDataLogSubscriber(Database::Item);

        //[GIVEN] Create Item
        LibraryInventory.CreateItem(Item);

        //[GIVEN] Enable Magento Item 
        Item."NPR Magento Item" := true;
        Item.Description := format(Random(10000));
        BindSubscription(NpXmlTests);
        Item.Modify();
        UnbindSubscription(NpXmlTests);

        //[GIVEN] Download XML Template from Azure Blob Storage
        DownloadXmlTemplateFromAzureBlobStorage('Latest/upd_item.xml', NpXmlTemplate);

        //[GIVEN] Configure XML Template
        ConfigureXmlTemplateForFTP(NpXmlTemplate);

        //[GIVEN] Import TaskList Item
        ImportTaskList();

        //[WHEN] TaskList item is processed
        NcTask.SetRange("Table No.", Database::Item);
        NcTask.SetRange("Record Value", Item."No.");
        if NcTask.FindFirst() then
            Successed := NcSyncMgt.ProcessTask(NcTask);

        //[THEN] Check if Resposne was Successfull
        Assert.IsTrue(Successed, 'API synchronization failed for XML template: UPD_Item');
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin
            SetupMagento();
            SetupNaviConnect();
            SetupNpXml();
            SetupNcTaskProcessLine();
            Initialized := true;
        end;
    end;

    local procedure SetupMagento()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then begin
            MagentoSetup.Init();
            MagentoSetup.Insert();
        end;

        MagentoSetup."Magento Enabled" := true;
        MagentoSetup."Magento Url" := 'http://new.ottosuenson.dk/';
        MagentoSetup."Api Url" := 'http://new.ottosuenson.dk/rest/all/V1/naviconnect/';
        MagentoSetup."Api Username Type" := MagentoSetup."Api Username Type"::Automatic;
        MagentoSetup."Api Authorization" := 'bearer tfqlwf5mtq3ny5s2ugtcjydosqrb32k1';
        MagentoSetup.Modify();
    end;

    local procedure SetupNaviConnect()
    var
        NcSetup: Record "NPR Nc Setup";
    begin
        if not NcSetup.Get() then begin
            NcSetup.Init();
            NcSetup.Insert();
        end;

        NcSetup."Task Queue Enabled" := true;
        NcSetup."Task Worker Group" := 'NC';
        NcSetup.Modify(true);
    end;

    local procedure SetupNpXml()
    var
        NpXmlSetup: Record "NPR NpXml Setup";
    begin
        if not NpXmlSetup.Get() then begin
            NpXmlSetup.Init();
            NpXmlSetup.Insert();
        end;

        if not NpXmlSetup."NpXml Enabled" then begin
            NpXmlSetup."NpXml Enabled" := true;
            NpXmlSetup.Modify();
        end;
    end;

    local procedure SetupNcTaskProcessLine()
    var
        NcTaskProcesLine: Record "NPR Nc Task Proces. Line";
    begin
        NcTaskProcesLine.SetRange("Task Processor Code", 'NC');
        if NcTaskProcesLine.IsEmpty then begin
            NcTaskProcesLine.Init();
            NcTaskProcesLine.Type := NcTaskProcesLine.Type::Custom;
            NcTaskProcesLine."Task Processor Code" := 'NC';
            NcTaskProcesLine.Code := 'NC';
            NcTaskProcesLine.Value := 'NC';
            NcTaskProcesLine.Insert();
        end;
    end;

    local procedure EnableDataLog(TableID: Integer);
    var
        DataLogSetupTable: Record "NPR Data Log Setup (Table)";
    begin
        if not DataLogSetupTable.Get(TableID) then begin
            DataLogSetupTable.Init();
            DataLogSetupTable."Table ID" := TableID;
            DataLogSetupTable."Log Insertion" := DataLogSetupTable."Log Insertion"::Detailed;
            DataLogSetupTable."Log Modification" := DataLogSetupTable."Log Modification"::Detailed;
            DataLogSetupTable."Log Deletion" := DataLogSetupTable."Log Deletion"::Detailed;
            DataLogSetupTable.Insert(true);
        end;
    end;

    local procedure EnableDataLogSubscriber(TableID: Integer);
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
    begin
        DataLogSubscriber.SetRange(Code, 'NC');
        DataLogSubscriber.SetRange("Table ID", TableID);
        if DataLogSubscriber.IsEmpty then begin
            DataLogSubscriber.Init();
            DataLogSubscriber.Code := 'NC';
            DataLogSubscriber."Table ID" := TableID;
            DataLogSubscriber.Insert();
        end;
    end;

    local procedure DownloadXmlTemplateFromAzureBlobStorage(XmlTemplateFileName: Text; var NPRNpXmlTemplate: Record "NPR NpXml Template")
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        TemplateCodeText: Text;
        TemplateCode: Code[20];
        BaseURL: Text;
    begin
        BaseURL := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl') + '/npxml/' + XmlTemplateFileName.Substring(1, XmlTemplateFileName.LastIndexOf('/'));
        TemplateCodeText := XmlTemplateFileName.Substring(XmlTemplateFileName.LastIndexOf('/') + 1);
        TemplateCodeText := TemplateCodeText.Substring(1, TemplateCodeText.IndexOf('.xml') - 1);
        TemplateCode := CopyStr(TemplateCodeText, 1, MaxStrLen(TemplateCode));
        if NpXmlTemplateMgt.ImportNpXmlTemplateUrl(TemplateCode, BaseURL) then
            NPRNpXmlTemplate.Get(TemplateCodeText);
    end;

    local procedure ConfigureXmlTemplateForAPI(var NpXmlTemplate: Record "NPR NpXml Template")
    begin
        NpXmlTemplate."FTP Transfer" := false;
        NpXmlTemplate."API Transfer" := true;
        NpXmlTemplate."API Type" := NpXmlTemplate."API Type"::"REST (Json)";
        NpXmlTemplate."API Url" := 'http://new.ottosuenson.dk/rest/all/V1/naviconnect/products';
        NpXmlTemplate."API Method" := NpXmlTemplate."API Method"::POST;
        NpXmlTemplate."API Username Type" := NpXmlTemplate."API Username Type"::Custom;
        NpXmlTemplate."API Content-Type" := 'naviconnect/json';
        NpXmlTemplate."API Authorization" := 'bearer tfqlwf5mtq3ny5s2ugtcjydosqrb32k1';
        NpXmlTemplate."API Accept" := 'naviconnect/xml';
        NpXmlTemplate.Modify();
    end;

    local procedure ConfigureXmlTemplateForFTP(var NpXmlTemplate: Record "NPR NpXml Template")
    begin
        NpXmlTemplate."FTP Transfer" := true;
        NpXmlTemplate."API Transfer" := false;
        NpXmlTemplate."FTP Server" := 'ftp://ftp01.dynamics-retail.com';
        NpXmlTemplate."FTP Username" := 'Case-325323';
        NpXmlTemplate."FTP Password" := 'tNDs2Bags42B+1';
        NpXmlTemplate."FTP Port" := 21;
        NpXmlTemplate."FTP Passive" := true;
        NpXmlTemplate."FTP Directory" := 'BC/Export';
        NpXmlTemplate.Modify();
    end;

    local procedure ImportTaskList()
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if not NcTaskProcessor.FindFirst() then begin
            NcTaskProcessor.Init();
            NcTaskProcessor.Code := 'NC';
            NcTaskProcessor.Description := CopyStr(LibraryRandom.RandText(10), 1, MaxStrLen(NcTaskProcessor.Description));
            NcTaskProcessor.Insert(true);
        end;

        NcTaskMgt.UpdateTasks(NcTaskProcessor);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Data Log Management", 'OnBeforeDatabaseModify', '', true, true)]
    local procedure DataLogManagementOnBeforeDatabaseModify(RecRef: RecordRef; var DataLogDisabled: Boolean; var MonitoredTablesLoaded: Boolean; var Handled: Boolean)
    begin
        DataLogDisabled := false;
        MonitoredTablesLoaded := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Data Log Management", 'OnBeforeLoadMonTables', '', true, true)]
    local procedure DataLogManagementOnBeforeLoadMonTables(var TempDataLogSetup: Record "NPR Data Log Setup (Table)"; var TempDataLogSubscriber: Record "NPR Data Log Subscriber"; var Handled: Boolean);
    begin
        TempDataLogSubscriber.Reset();
        TempDataLogSubscriber.DeleteAll();
    end;
}