codeunit 6151464 "NPR M2 Category Mgt."
{
    // MAG2.26/MHA /20200601  CASE 404580 Object created


    trigger OnRun()
    begin
        UpdateCategories();
    end;

    var
        Text000: Label 'Root Categoery is missing for Website %1';

    local procedure UpdateCategories()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoCategory: Record "NPR Magento Category";
        TempMagentoCategory: Record "NPR Magento Category" temporary;
        DataLogMgt: Codeunit "NPR Data Log Management";
        M2SetupMgt: Codeunit "NPR M2 Setup Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        Element: DotNet NPRNetXmlElement;
        CategoryId: Code[20];
        PrevRec: Text;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;

        M2SetupMgt.MagentoApiGet(MagentoSetup."Api Url", 'categories', XmlDoc);
        DataLogMgt.DisableDataLog(true);
        foreach Element in XmlDoc.DocumentElement.SelectNodes('category') do begin
            CategoryId := NpXmlDomMgt.GetAttributeCode(Element, '', 'id', MaxStrLen(MagentoCategory.Id), true);
            MagentoCategory.LockTable;
            if not MagentoCategory.Get(CategoryId) then begin
                MagentoCategory.Init;
                MagentoCategory.Id := CategoryId;
                MagentoCategory.Insert(true);
            end;

            PrevRec := Format(MagentoCategory);

            MagentoCategory.Name := NpXmlDomMgt.GetElementText(Element, 'name', MaxStrLen(MagentoCategory.Name), false);
            MagentoCategory."Parent Category Id" := NpXmlDomMgt.GetElementCode(Element, 'parent', MaxStrLen(MagentoCategory."Parent Category Id"), false);
            MagentoCategory.Level := NpXmlDomMgt.GetElementInt(Element, 'level', false);
            MagentoCategory.Path := NpXmlDomMgt.GetElementText(Element, 'path', MaxStrLen(MagentoCategory.Path), false);
            MagentoCategory.Sorting := NpXmlDomMgt.GetElementInt(Element, 'position', false);
            MagentoCategory."Root No." := NpXmlDomMgt.GetElementCode(Element, 'root', MaxStrLen(MagentoCategory."Root No."), false);
            MagentoCategory.Root := MagentoCategory.Id = MagentoCategory."Root No.";

            if PrevRec <> Format(MagentoCategory) then
                MagentoCategory.Modify(true);

            Commit;

            if not TempMagentoCategory.Get(MagentoCategory.Id) then begin
                TempMagentoCategory.Init;
                TempMagentoCategory := MagentoCategory;
                TempMagentoCategory.Insert;
            end;
        end;
        DataLogMgt.DisableDataLog(false);

        if TempMagentoCategory.IsEmpty then
            exit;

        DataLogMgt.DisableDataLog(true);
        Clear(MagentoCategory);
        if MagentoCategory.FindSet then
            repeat
                if not TempMagentoCategory.Get(MagentoCategory.Id) then
                    RemoveCategory(MagentoCategory);
            until MagentoCategory.Next = 0;
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
        if MagentoCategoryLink.FindFirst then begin
            MagentoCategoryLink.DeleteAll;
            Commit;
        end;

        MagentoCategory.LockTable;
        if MagentoCategory.Get(MagentoCategory.Id) then begin
            MagentoCategory.Delete;
            Commit;
        end;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupCategories', '', true, true)]
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

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR M2 Category Mgt.");
    end;
}

