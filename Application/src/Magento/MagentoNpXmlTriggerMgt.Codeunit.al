codeunit 6151447 "NPR Magento NpXml Trigger Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Trigger Mgt.", 'OnSetupGenericParentTable', '', true, true)]
    local procedure MagentoStore(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    var
        NpCsStore: Record "NPR NpCs Store";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
    begin
        if Handled then
            exit;
        if not IsSubscriber(NpXmlTemplateTrigger, 'MagentoStore') then
            exit;

        Handled := true;

        ParentRecRef.GetTable(TempNpCsStore);
        case ChildLinkRecRef.Number of
            DATABASE::"NPR NpCs Store":
                begin
                    if NpXmlTemplateTrigger."Parent Table No." <> DATABASE::"NPR NpCs Store" then
                        exit;

                    ChildLinkRecRef.SetTable(NpCsStore);
                    if not NpCsStore.Find() then
                        exit;
                    if not IsMagentoStore(NpCsStore) then
                        exit;

                    TempNpCsStore.Init();
                    TempNpCsStore := NpCsStore;
                    TempNpCsStore.Insert();
                    ParentRecRef.GetTable(TempNpCsStore);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Trigger Mgt.", 'OnSetupGenericParentTable', '', true, true)]
    local procedure NonMagentoStore(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    var
        NpCsStore: Record "NPR NpCs Store";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
    begin
        if Handled then
            exit;
        if not IsSubscriber(NpXmlTemplateTrigger, 'NonMagentoStore') then
            exit;

        Handled := true;

        ParentRecRef.GetTable(TempNpCsStore);
        case ChildLinkRecRef.Number of
            DATABASE::"NPR NpCs Store":
                begin
                    if NpXmlTemplateTrigger."Parent Table No." <> DATABASE::"NPR NpCs Store" then
                        exit;

                    ChildLinkRecRef.SetTable(NpCsStore);
                    if not NpCsStore.Find() then
                        exit;
                    if IsMagentoStore(NpCsStore) then
                        exit;

                    TempNpCsStore.Init();
                    TempNpCsStore := NpCsStore;
                    TempNpCsStore.Insert();
                    ParentRecRef.GetTable(TempNpCsStore);
                end;
        end;
    end;

    local procedure IsMagentoStore(NpCsStore: Record "NPR NpCs Store"): Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then
            exit;

        exit(NpCsStore.Code = MagentoSetup."NpCs From Store Code");
    end;

    local procedure IsSubscriber(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; FunctionName: Text): Boolean
    begin
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> CurrCodeunitId() then
            exit(false);

        exit(NpXmlTemplateTrigger."Generic Parent Function" = FunctionName);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento NpXml Trigger Mgt.");
    end;
}