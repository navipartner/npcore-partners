codeunit 6151465 "NPR M2 Brand Mgt."
{
    trigger OnRun()
    begin
        UpdateBrands();
    end;

    local procedure UpdateBrands()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoBrand: Record "NPR Magento Brand";
        TempMagentoBrand: Record "NPR Magento Brand" temporary;
        DataLogMgt: Codeunit "NPR Data Log Management";
        M2SetupMgt: Codeunit "NPR M2 Setup Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XNodeList: XmlNodeList;
        XNode: XmlNode;
        BrandId: Code[20];
        PrevRec: Text;
        TypeHelper: Codeunit "Type Helper";
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;

        M2SetupMgt.MagentoApiGet(MagentoSetup."Api Url", 'brands', XmlDoc);
        DataLogMgt.DisableDataLog(true);
        XmlDoc.SelectNodes('//brand', XNodeList);
        foreach XNode in XNodeList do begin
            BrandId := NpXmlDomMgt.GetAttributeCode(XNode.AsXmlElement(), '', 'id', MaxStrLen(MagentoBrand.Id), true);
            if not MagentoBrand.Get(BrandId) then begin
                MagentoBrand.Init();
                MagentoBrand.Id := BrandId;
                MagentoBrand.Insert(true);
            end;

            PrevRec := Format(MagentoBrand);

            MagentoBrand.Name := NpXmlDomMgt.GetElementText(XNode.AsXmlElement(), 'name', MaxStrLen(MagentoBrand.Name), false);
            MagentoBrand.Name := TypeHelper.HtmlDecode(MagentoBrand.Name);
            MagentoBrand.Sorting := NpXmlDomMgt.GetElementInt(XNode.AsXmlElement(), 'sort_order', false);

            if PrevRec <> Format(MagentoBrand) then
                MagentoBrand.Modify(true);

            if not TempMagentoBrand.Get(MagentoBrand.Id) then begin
                TempMagentoBrand.Init();
                TempMagentoBrand := MagentoBrand;
                TempMagentoBrand.Insert();
            end;
        end;

        MagentoBrand.Reset();
        if MagentoBrand.FindSet() then
            repeat
                if not TempMagentoBrand.Get(MagentoBrand.Id) then
                    RemoveBrand(MagentoBrand);
            until MagentoBrand.Next() = 0;
        DataLogMgt.DisableDataLog(false);
    end;

    local procedure ScheduleUpdateBrands(InActiveSession: Boolean)
    var
        SessionId: Integer;
    begin
        if InActiveSession then
            Codeunit.Run(CurrCodeunitId())
        else
            SESSION.StartSession(SessionId, CurrCodeunitId(), CompanyName);
    end;

    local procedure RemoveBrand(var MagentoBrand: Record "NPR Magento Brand")
    var
        Item: Record Item;
    begin
        if MagentoBrand.Id <> '' then begin
            Item.SetRange("NPR Magento Brand", MagentoBrand.Id);
            if Item.FindFirst() then begin
                Item.ModifyAll("NPR Magento Brand", '', false);
                Commit();
            end;
        end;

        MagentoBrand.LockTable();
        if MagentoBrand.Get(MagentoBrand.Id) then begin
            MagentoBrand.Delete();
            Commit();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupBrands', '', true, true)]
    local procedure SetupM2Brands(var Handled: Boolean; InActiveSession: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Brands", CurrCodeunitId(), 'SetupM2Brands') then
            exit;

        Handled := true;
        ScheduleUpdateBrands(InActiveSession);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR M2 Brand Mgt.");
    end;
}