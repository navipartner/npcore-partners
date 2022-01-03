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
        NpXmlMockHandler: Codeunit "NPR NpXml Mock Handler";
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

        //[GIVEN] Download XML Template
        MockDownloadXmlTemplate('upd_item', NpXmlTemplate);

        //[GIVEN] Configure XML Template
        ConfigureXmlTemplateForAPI(NpXmlTemplate);

        //[GIVEN] Import TaskList Item
        ImportTaskList();

        //[WHEN] TaskList item is processed
        NcTask.SetRange("Table No.", Database::Item);
        NcTask.SetRange("Record Value", Item."No.");
        if NcTask.FindFirst() then begin
            BindSubscription(NpXmlMockHandler);
            NpXmlMockHandler.SetItemNo(Item."No.");
            Successed := NcSyncMgt.ProcessTask(NcTask);
            UnbindSubscription(NpXmlMockHandler);
        end;

        //[THEN] Check if Resposne was Successfull
        Assert.IsTrue(Successed, GetLastErrorText());
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin
            SetupMagento();
            SetupNaviConnect();
            SetupTaskSetup();
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

    local procedure SetupTaskSetup()
    var
        TaskSetup: Record "NPR Nc Task Setup";
    begin
        TaskSetup.SetRange("Task Processor Code", 'NC');
        TaskSetup.SetRange("Table No.", 27);
        if not TaskSetup.FindFirst() then begin
            TaskSetup.Init();
            TaskSetup."Task Processor Code" := 'NC';
            TaskSetup."Table No." := 27;
            TaskSetup."Codeunit ID" := 6151550;
            TaskSetup.Insert();
        end else begin
            TaskSetup."Codeunit ID" := 6151550;
            TaskSetup.Modify();
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

    local procedure MockDownloadXmlTemplate(XmlTemplateCode: Code[20]; var NPRNpXmlTemplate: Record "NPR NpXml Template")
    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NpXmlMockHandler: Codeunit "NPR NpXml Mock Handler";
    begin
        BindSubscription(NpXmlMockHandler);
        if NpXmlTemplateMgt.ImportNpXmlTemplateUrl(UpperCase(XmlTemplateCode), 'DummyUrl') then
            NPRNpXmlTemplate.Get(XmlTemplateCode);

        UnbindSubscription(NpXmlMockHandler);
    end;

    local procedure ConfigureXmlTemplateForAPI(var NpXmlTemplate: Record "NPR NpXml Template")
    var
        NpXmlElement: Record "NPR NpXml Element";
    begin
        NpXmlTemplate."FTP Transfer" := false;
        NpXmlTemplate."API Transfer" := true;
        NpXmlTemplate."API Type" := NpXmlTemplate."API Type"::"REST (Json)";
        NpXmlTemplate.Modify();

        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlElement.SetFilter("Element Name", '%1|%2', 'ticket_setup*', 'ticket_type*');
        if NpXmlElement.FindSet() then
            NpXmlElement.ModifyAll(Active, false);
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