codeunit 85021 "NPR NpXml Tests"
{
    /* Temprorary commenting whole CU until Alen create configuration for BC service inside pipeline container which will enable Azure KeyVault and needed ceritificate 
    //[Feature] NpXml module, download UPD_ITEM.xml from AzureBlob storage and sync with WebShop using FTP and API
    Subtype = Test;

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
        Task: Record "NPR Nc Task";
        XmlTemplate: Record "NPR NpXml Template";
        LibraryInventory: Codeunit "Library - Inventory";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        SyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        Assert: Codeunit Assert;
        Successed: Boolean;
    begin
        // [Scenario] Check that Process Manualy action is handled correctly using UPD_Item XML template

        //[GIVEN] Initialize
        Initialize();

        //[GIVEN] Enable DataLog for table
        EnableDataLog(Database::Item);

        //[GIVEN] Enable DataLogSub
        EnableDataLogSubscriber(Database::Item);

        //[GIVEN] Create Item
        NPRLibraryInventory.CreateItem(Item);

        //[GIVEN] Enable Magento Item 
        Item."NPR Magento Item" := true;
        Item.Description := format(Random(10000));
        Item.Modify();

        //[GIVEN] Download XML Template from Azure Blob Storage
        DownloadXmlTemplateFromAzureBlobStorage('Latest/upd_item.xml', XmlTemplate);

        //[GIVEN] Configure XML Template
        ConfigureXmlTemplateForAPI(XmlTemplate);

        //[GIVEN] Import TaskList Item
        ImportTaskList();

        //[WHEN] TaskList item is processed
        Task.SetRange("Table No.", Database::Item);
        Task.SetRange("Record Value", Item."No.");
        if Task.FindFirst() then
            Successed := SyncMgt.ProcessTask(Task);

        //[THEN] Check if Resposne was Successfull
        Assert.IsTrue(Successed, 'API synchronization failed for XML template: UPD_Item');
    end;

    [Test]
    procedure ProcessTaskWithUpdItemXmlTemplateUsingFTP()
    var
        Item: Record Item;
        Task: Record "NPR Nc Task";
        XmlTemplate: Record "NPR NpXml Template";
        LibraryInventory: Codeunit "Library - Inventory";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        SyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        Assert: Codeunit Assert;
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
        NPRLibraryInventory.CreateItem(Item);

        //[GIVEN] Enable Magento Item 
        Item."NPR Magento Item" := true;
        Item.Modify(true);
        Item.Description := format(Random(10000));
        Item.Modify(true);

        //[GIVEN] Download XML Template from Azure Blob Storage
        DownloadXmlTemplateFromAzureBlobStorage('Latest/upd_item.xml', XmlTemplate);

        //[GIVEN] Configure XML Template
        ConfigureXmlTemplateForFTP(XmlTemplate);

        //[GIVEN] Import TaskList Item
        ImportTaskList();

        //[WHEN] TaskList item is processed
        Task.SetRange("Table No.", Database::Item);
        Task.SetRange("Record Value", Item."No.");
        if Task.FindFirst() then
            Successed := SyncMgt.ProcessTask(Task);

        //[THEN] Check if Resposne was Successfull
        Assert.IsTrue(Successed, 'API synchronization failed for XML template: UPD_Item');
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin
            SetupMagento();
            SetupNaviConnect();
            SetupNpRetailSetup;
            SetupRetailItemSetup;
            SetupNpXml;
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
        NCSetup: Record "NPR Nc Setup";
    begin
        if not NCSetup.Get() then begin
            NCSetup.Init();
            NCSetup.Insert();
        end;

        NCSetup."Task Queue Enabled" := true;
        NCSetup."Task Worker Group" := 'NC';
        NCSetup.Modify();
    end;

    local procedure SetupNpRetailSetup()
    var
        NpRetailSetup: Record "NPR NP Retail Setup";
    begin
        if not NpRetailSetup.Get() then begin
            NpRetailSetup.Init();
            NpRetailSetup.Insert();
        end;
    end;

    local procedure SetupRetailItemSetup()
    var
        RetailItemSetup: Record "NPR Retail Item Setup";
    begin
        if not RetailItemSetup.Get() then begin
            RetailItemSetup.Init();
            RetailItemSetup.Insert();
        end;
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
        NcTaskProcessLine: Record "NPR Nc Task Proces. Line";
    begin
        NcTaskProcessLine.SetRange("Task Processor Code", 'NC');
        if NcTaskProcessLine.IsEmpty then begin
            NcTaskProcessLine.Init();
            NcTaskProcessLine.Type := NcTaskProcessLine.Type::Custom;
            NcTaskProcessLine."Task Processor Code" := 'NC';
            NcTaskProcessLine.Code := 'NC';
            NcTaskProcessLine.Value := 'NC';
            NcTaskProcessLine.Insert();
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
            DataLogSetupTable.Insert();
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

    local procedure DownloadXmlTemplateFromAzureBlobStorage(XmlTemplateFileName: Text; var XmlTemplate: Record "NPR NpXml Template")
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        TemplateCode: Text;
        BaseURL: Text;
    begin
        BaseURL := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl') + '/npxml/' + XmlTemplateFileName.Substring(1, XmlTemplateFileName.LastIndexOf('/'));
        TemplateCode := XmlTemplateFileName.Substring(XmlTemplateFileName.LastIndexOf('/') + 1);
        TemplateCode := TemplateCode.Substring(1, TemplateCode.IndexOf('.xml') - 1);
        if NpXmlTemplateMgt.ImportNpXmlTemplateUrl(TemplateCode, BaseURL) then
            XmlTemplate.Get(TemplateCode);
    end;

    local procedure ConfigureXmlTemplateForAPI(var XmlTemplate: Record "NPR NpXml Template")
    begin
        XmlTemplate."FTP Transfer" := false;
        XmlTemplate."API Transfer" := true;
        XmlTemplate."API Type" := XmlTemplate."API Type"::"REST (Json)";
        XmlTemplate."API Url" := 'http://new.ottosuenson.dk/rest/all/V1/naviconnect/products';
        XmlTemplate."API Method" := XmlTemplate."API Method"::POST;
        XmlTemplate."API Username Type" := XmlTemplate."API Username Type"::Custom;
        XmlTemplate."API Content-Type" := 'naviconnect/json';
        XmlTemplate."API Authorization" := 'bearer tfqlwf5mtq3ny5s2ugtcjydosqrb32k1';
        XmlTemplate."API Accept" := 'naviconnect/xml';
        XmlTemplate.Modify();
    end;

    local procedure ConfigureXmlTemplateForFTP(var XmlTemplate: Record "NPR NpXml Template")
    begin
        XmlTemplate."FTP Transfer" := true;
        XmlTemplate."API Transfer" := false;
        XmlTemplate."FTP Server" := 'ftp://ftp01.dynamics-retail.com';
        XmlTemplate."FTP Username" := 'Case-325323';
        XmlTemplate."FTP Password" := 'tNDs2Bags42B+1';
        XmlTemplate."FTP Port" := 21;
        XmlTemplate."FTP Passive" := true;
        XmlTemplate."FTP Directory" := 'BC/Export';
        XmlTemplate.Modify();
    end;

    local procedure ImportTaskList()
    var
        TaskProcessor: Record "NPR Nc Task Processor";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if not TaskProcessor.FindFirst() then begin
            TaskProcessor.Init;
            TaskProcessor.Code := 'NC';
            TaskProcessor.Description := LibraryRandom.RandText(10);
            TaskProcessor.Insert(true);
        end;

        NcTaskMgt.UpdateTasks(TaskProcessor);
    end;
    */
}