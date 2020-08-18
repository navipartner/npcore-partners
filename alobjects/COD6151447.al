codeunit 6151447 "Magento NpXml Trigger Mgt."
{
    // MAG2.26/MHA /20200527  CASE 406591 Object created - NpXml Trigger functions


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151553, 'OnSetupGenericParentTable', '', true, true)]
    local procedure MagentoStore(NpXmlTemplateTrigger: Record "NpXml Template Trigger";ChildLinkRecRef: RecordRef;var ParentRecRef: RecordRef;var Handled: Boolean)
    var
        NpCsStore: Record "NpCs Store";
        TempNpCsStore: Record "NpCs Store" temporary;
    begin
        if Handled then
          exit;
        if not IsSubscriber(NpXmlTemplateTrigger,'MagentoStore') then
          exit;

        Handled := true;

        ParentRecRef.GetTable(TempNpCsStore);
        case ChildLinkRecRef.Number of
          DATABASE::"NpCs Store":
            begin
              if NpXmlTemplateTrigger."Parent Table No." <> DATABASE::"NpCs Store" then
                exit;

              ChildLinkRecRef.SetTable(NpCsStore);
              if not NpCsStore.Find then
                exit;
              if not IsMagentoStore(NpCsStore) then
                exit;

              TempNpCsStore.Init;
              TempNpCsStore := NpCsStore;
              TempNpCsStore.Insert;
              ParentRecRef.GetTable(TempNpCsStore);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151553, 'OnSetupGenericParentTable', '', true, true)]
    local procedure NonMagentoStore(NpXmlTemplateTrigger: Record "NpXml Template Trigger";ChildLinkRecRef: RecordRef;var ParentRecRef: RecordRef;var Handled: Boolean)
    var
        NpCsStore: Record "NpCs Store";
        TempNpCsStore: Record "NpCs Store" temporary;
    begin
        if Handled then
          exit;
        if not IsSubscriber(NpXmlTemplateTrigger,'NonMagentoStore') then
          exit;

        Handled := true;

        ParentRecRef.GetTable(TempNpCsStore);
        case ChildLinkRecRef.Number of
          DATABASE::"NpCs Store":
            begin
              if NpXmlTemplateTrigger."Parent Table No." <> DATABASE::"NpCs Store" then
                exit;

              ChildLinkRecRef.SetTable(NpCsStore);
              if not NpCsStore.Find then
                exit;
              if IsMagentoStore(NpCsStore) then
                exit;

              TempNpCsStore.Init;
              TempNpCsStore := NpCsStore;
              TempNpCsStore.Insert;
              ParentRecRef.GetTable(TempNpCsStore);
            end;
        end;
    end;

    local procedure IsMagentoStore(NpCsStore: Record "NpCs Store"): Boolean
    var
        MagentoSetup: Record "Magento Setup";
    begin
        if not MagentoSetup.Get then
          exit;

        exit(NpCsStore.Code = MagentoSetup."NpCs From Store Code");
    end;

    local procedure IsSubscriber(NpXmlTemplateTrigger: Record "NpXml Template Trigger";FunctionName: Text): Boolean
    begin
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> CurrCodeunitId() then
          exit(false);

        exit(NpXmlTemplateTrigger."Generic Parent Function" = FunctionName);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento NpXml Trigger Mgt.");
    end;
}

