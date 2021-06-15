codeunit 6151464 "NPR M2 Category Mgt."
{
    trigger OnRun()
    begin
        UpdateCategories();
    end;

    local procedure UpdateCategories()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoCategory: Record "NPR Magento Category";
        TempMagentoCategory: Record "NPR Magento Category" temporary;
        DataLogMgt: Codeunit "NPR Data Log Management";
        M2SetupMgt: Codeunit "NPR M2 Setup Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XNodeList: XmlNodeList;
        XNode: XmlNode;
        CategoryId: Code[20];
        PrevRec: Text;
        TypeHelper: Codeunit "Type Helper";
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;

        M2SetupMgt.MagentoApiGet(MagentoSetup."Api Url", 'categories', XmlDoc);
        DataLogMgt.DisableDataLog(true);
        XmlDoc.SelectNodes('//category', XNodeList);
        foreach XNode in XNodeList do begin
            CategoryId := NpXmlDomMgt.GetAttributeCode(XNode.AsXmlElement(), '', 'id', MaxStrLen(MagentoCategory.Id), true);
            MagentoCategory.LockTable();
            if not MagentoCategory.Get(CategoryId) then begin
                MagentoCategory.Init();
                MagentoCategory.Id := CategoryId;
                MagentoCategory.Insert(true);
            end;

            PrevRec := Format(MagentoCategory);

            MagentoCategory.Name := NpXmlDomMgt.GetElementText(XNode.AsXmlElement(), 'name', MaxStrLen(MagentoCategory.Name), false);
            MagentoCategory.Name := TypeHelper.HtmlDecode(MagentoCategory.Name);
            MagentoCategory."Parent Category Id" := NpXmlDomMgt.GetElementCode(XNode.AsXmlElement(), 'parent', MaxStrLen(MagentoCategory."Parent Category Id"), false);
            MagentoCategory.Level := NpXmlDomMgt.GetElementInt(XNode.AsXmlElement(), 'level', false);
            MagentoCategory.Path := NpXmlDomMgt.GetElementText(XNode.AsXmlElement(), 'path', MaxStrLen(MagentoCategory.Path), false);
            MagentoCategory.Sorting := NpXmlDomMgt.GetElementInt(XNode.AsXmlElement(), 'position', false);
            MagentoCategory."Root No." := NpXmlDomMgt.GetElementCode(XNode.AsXmlElement(), 'root', MaxStrLen(MagentoCategory."Root No."), false);
            MagentoCategory.Root := MagentoCategory.Id = MagentoCategory."Root No.";

            if PrevRec <> Format(MagentoCategory) then
                MagentoCategory.Modify(true);

            Commit();

            if not TempMagentoCategory.Get(MagentoCategory.Id) then begin
                TempMagentoCategory.Init();
                TempMagentoCategory := MagentoCategory;
                TempMagentoCategory.Insert();
            end;
        end;

        MagentoCategory.Reset();
        if MagentoCategory.FindSet() then
            repeat
                if not TempMagentoCategory.Get(MagentoCategory.Id) then
                    RemoveCategory(MagentoCategory);
            until MagentoCategory.Next() = 0;
        DataLogMgt.DisableDataLog(false);
    end;

    local procedure ScheduleUpdateCategories()
    var
        SessionId: Integer;
    begin
        SESSION.StartSession(SessionId, CurrCodeunitId(), CompanyName);
    end;

    local procedure RemoveCategory(var MagentoCategory: Record "NPR Magento Category")
    var
        MagentoCategoryLink: Record "NPR Magento Category Link";
    begin
        MagentoCategoryLink.SetRange("Category Id", MagentoCategory.Id);
        if MagentoCategoryLink.FindFirst() then begin
            MagentoCategoryLink.DeleteAll();
            Commit();
        end;

        MagentoCategory.LockTable();
        if MagentoCategory.Get(MagentoCategory.Id) then begin
            MagentoCategory.Delete();
            Commit();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupCategories', '', true, true)]
    local procedure SetupM2Categories(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Categories", CurrCodeunitId(), 'SetupM2Categories') then
            exit;

        Handled := true;
        ScheduleUpdateCategories();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR M2 Category Mgt.");
    end;
}