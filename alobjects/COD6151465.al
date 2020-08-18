codeunit 6151465 "M2 Brand Mgt."
{
    // MAG2.26/MHA /20200601  CASE 404580 Object created


    trigger OnRun()
    begin
        UpdateBrands();
    end;

    var
        Text000: Label 'Root Categoery is missing for Website %1';

    local procedure UpdateBrands()
    var
        MagentoSetup: Record "Magento Setup";
        MagentoBrand: Record "Magento Brand";
        TempMagentoBrand: Record "Magento Brand" temporary;
        DataLogMgt: Codeunit "Data Log Management";
        M2SetupMgt: Codeunit "M2 Setup Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        Element: DotNet npNetXmlElement;
        BrandId: Code[20];
        PrevRec: Text;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
          exit;

        M2SetupMgt.MagentoApiGet(MagentoSetup."Api Url",'brands',XmlDoc);
        DataLogMgt.DisableDataLog(true);
        foreach Element in XmlDoc.DocumentElement.SelectNodes('brand') do begin
          BrandId := NpXmlDomMgt.GetAttributeCode(Element,'','id',MaxStrLen(MagentoBrand.Id),true);
          if not MagentoBrand.Get(BrandId) then begin
            MagentoBrand.Init;
            MagentoBrand.Id := BrandId;
            MagentoBrand.Insert(true);
          end;

          PrevRec := Format(MagentoBrand);

          MagentoBrand.Name := NpXmlDomMgt.GetElementText(Element,'name',MaxStrLen(MagentoBrand.Name),false);
          MagentoBrand.Sorting := NpXmlDomMgt.GetElementInt(Element,'sort_order',false);

          if PrevRec <> Format(MagentoBrand) then
            MagentoBrand.Modify(true);

          if not TempMagentoBrand.Get(MagentoBrand.Id) then begin
            TempMagentoBrand.Init;
            TempMagentoBrand := MagentoBrand;
            TempMagentoBrand.Insert;
          end;
        end;
        DataLogMgt.DisableDataLog(false);

        if TempMagentoBrand.IsEmpty then
          exit;

        DataLogMgt.DisableDataLog(true);
        Clear(MagentoBrand);
        if MagentoBrand.FindSet then
          repeat
            if not TempMagentoBrand.Get(MagentoBrand.Id) then
              RemoveBrand(MagentoBrand);
          until MagentoBrand.Next = 0;
        DataLogMgt.DisableDataLog(false);
    end;

    local procedure ScheduleUpdateBrands()
    var
        SessionId: Integer;
    begin
        SESSION.StartSession(SessionId,CurrCodeunitId(),CompanyName);
    end;

    local procedure RemoveBrand(var MagentoBrand: Record "Magento Brand")
    var
        Item: Record Item;
        MagentoCategoryLink: Record "Magento Category Link";
    begin
        if MagentoBrand.Id <> '' then begin
          Item.SetRange("Magento Brand",MagentoBrand.Id);
          if Item.FindFirst then begin
            Item.ModifyAll("Magento Brand",'',false);
            Commit;
          end;
        end;

        MagentoBrand.LockTable;
        if MagentoBrand.Get(MagentoBrand.Id) then begin
          MagentoBrand.Delete;
          Commit;
        end;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupBrands', '', true, true)]
    local procedure SetupM2Brands(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Brands",CurrCodeunitId(),'SetupM2Brands') then
          exit;

        Handled := true;
        ScheduleUpdateBrands();
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"M2 Brand Mgt.");
    end;
}

