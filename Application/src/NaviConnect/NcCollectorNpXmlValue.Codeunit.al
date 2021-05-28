codeunit 6151530 "NPR Nc Collector NpXml Value"
{
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.Get(Rec."Xml Template Code");
        if NpXmlTemplate."Table No." = DATABASE::"NPR Nc Collection" then begin
            SetBufferCollectionToProcessed(Rec);
        end;
    end;

    var
        NcCollection: Record "NPR Nc Collection";

    local procedure SetBufferCollectionToProcessed(var NpXmlCustomValueBuffer: Record "NPR NpXml Custom Val. Buffer")
    var
        RecRef: RecordRef;
    begin
        Clear(RecRef);
        RecRef.Open(NpXmlCustomValueBuffer."Table No.");
        RecRef.SetPosition(NpXmlCustomValueBuffer."Record Position");
        if not RecRef.Find() then
            exit;
        RecRef.SetTable(NcCollection);
        if NcCollection.Find() then begin
            if NcCollection.Status = NcCollection.Status::"Ready to Send" then begin
                NcCollection.Validate(Status, NcCollection.Status::Sent);
                NcCollection.Modify(true);
                Commit();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure OnGetXMLValueMarkAsProcessed(RecRef: RecordRef; NpXmlElement: Record "NPR NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    var
        NcCollection: Record "NPR Nc Collection";
    begin
        if Handled then
            exit;
        if NpXmlElement."Xml Value Codeunit ID" <> CurrCodeunitId() then
            exit;

        Handled := true;

        if RecRef.Number = DATABASE::"NPR Nc Collection" then begin
            RecRef.SetTable(NcCollection);
            if NcCollection.Find() then begin
                if NcCollection.Status = NcCollection.Status::"Ready to Send" then begin
                    NcCollection.Validate(Status, NcCollection.Status::Sent);
                    NcCollection.Modify(true);
                    Commit();
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151551, 'OnSetupGenericChildTable', '', true, true)]
    local procedure CollectionLine2Item(NpXmlElement: Record "NPR NpXml Element"; ParentRecRef: RecordRef; var ChildRecRef: RecordRef; var Handled: Boolean)
    var
        Item: Record Item;
        "Field": Record "Field";
        NcCollectionLine: Record "NPR Nc Collection Line";
        TempItem: Record Item temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if Handled then
            exit;
        if not IsElementSubscriber(NpXmlElement, 'CollectionLine2Item') then
            exit;

        Handled := true;

        ChildRecRef.GetTable(TempItem);
        if ParentRecRef.Number <> DATABASE::"NPR Nc Collection Line" then
            exit;
        ParentRecRef.SetTable(NcCollectionLine);
        if not NcCollectionLine.Find() then
            exit;

        case NcCollectionLine."Table No." of
            DATABASE::Item, DATABASE::"Item Variant", DATABASE::"Item Reference", DATABASE::"Item Unit of Measure":
                begin
                    if Item.Get(NcCollectionLine."PK Code 1") then begin
                        TempItem.Init();
                        TempItem := Item;
                        TempItem.Insert();
                    end;
                end;
            6014555, 6014556:
                begin
                    RecRef.Open(6014556);
                    FieldRef := RecRef.Field(1);
                    FieldRef.SetFilter('%1', NcCollectionLine."PK Line 1");
                    if not RecRef.Find() then
                        exit;
                    if not Field.Get(RecRef.Number, 10) then
                        exit;
                    FieldRef := RecRef.Field(Field."No.");
                    if Format(FieldRef.Value) <> '27' then
                        exit;
                    if not Field.Get(RecRef.Number, 11) then
                        exit;
                    FieldRef := RecRef.Field(Field."No.");
                    if not Item.Get(Format(FieldRef.Value)) then
                        exit;

                    TempItem.Init();
                    TempItem := Item;
                    TempItem.Insert();
                end;
        end;
        ChildRecRef.GetTable(TempItem);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Collector NpXml Value");
    end;

    local procedure IsElementSubscriber(NpXmlElement: Record "NPR NpXml Element"; GenericTableFunction: Text): Boolean
    begin
        if NpXmlElement."Generic Child Codeunit ID" <> CurrCodeunitId() then
            exit(false);
        if NpXmlElement."Generic Child Function" <> GenericTableFunction then
            exit(false);

        exit(true);
    end;
}

