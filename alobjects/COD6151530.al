codeunit 6151530 "Nc Collector NpXml Value"
{
    // NC2.01/BR  /20160912  CASE 250447 NaviConnect: Object created
    // NC2.13/MHA /20180530  CASE 312958 Added functions CollectionLine2Item(),IsElementSubscriber()
    // NC2.14/MHA /20180726  CASE 312958 Removed direct reference to NPR table

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlTemplate: Record "NpXml Template";
        NpXmlElement: Record "NpXml Element";
    begin
        NpXmlTemplate.Get("Xml Template Code");
        if NpXmlTemplate."Table No." = DATABASE::"Nc Collection" then begin
          SetBufferCollectionToProcessed(Rec);
        end;
    end;

    var
        NcCollection: Record "Nc Collection";

    local procedure SetBufferCollectionToProcessed(var NpXmlCustomValueBuffer: Record "NpXml Custom Value Buffer")
    var
        RecRef: RecordRef;
    begin
        Clear(RecRef);
        RecRef.Open(NpXmlCustomValueBuffer."Table No.");
        RecRef.SetPosition(NpXmlCustomValueBuffer."Record Position");
        if not  RecRef.Find then
          exit;
        RecRef.SetTable(NcCollection);
        if NcCollection.Find then begin
          if NcCollection.Status = NcCollection.Status::"Ready to Send" then begin
            NcCollection.Validate(Status,NcCollection.Status::Sent);
            NcCollection.Modify(true);
            Commit;
          end;
        end;
    end;

    local procedure "------- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure OnGetXMLValueMarkAsProcessed(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer;var XmlValue: Text;var Handled: Boolean)
    var
        NpXmlTemplate: Record "NpXml Template";
        NcCollection: Record "Nc Collection";
    begin
        if Handled then
          exit;
        if NpXmlElement."Xml Value Codeunit ID" <> CurrCodeunitId() then
          exit;

        Handled := true;

        if RecRef.Number = DATABASE::"Nc Collection" then begin
          RecRef.SetTable(NcCollection);
          if NcCollection.Find then begin
            if NcCollection.Status = NcCollection.Status::"Ready to Send" then begin
              NcCollection.Validate(Status,NcCollection.Status::Sent);
              NcCollection.Modify(true);
              Commit;
            end;
          end;
        end;
    end;

    local procedure "--- NpXml Element Child Table"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151551, 'OnSetupGenericChildTable', '', true, true)]
    local procedure CollectionLine2Item(NpXmlElement: Record "NpXml Element";ParentRecRef: RecordRef;var ChildRecRef: RecordRef;var Handled: Boolean)
    var
        Item: Record Item;
        "Field": Record "Field";
        NcCollectionLine: Record "Nc Collection Line";
        TempItem: Record Item temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ItemNo: Text;
    begin
        //-NC2.13 [312958]
        if Handled then
          exit;
        if not IsElementSubscriber(NpXmlElement,'CollectionLine2Item') then
          exit;

        Handled := true;

        ChildRecRef.GetTable(TempItem);
        if ParentRecRef.Number <> DATABASE::"Nc Collection Line" then
          exit;
        ParentRecRef.SetTable(NcCollectionLine);
        if not NcCollectionLine.Find then
          exit;

        case NcCollectionLine."Table No." of
          DATABASE::Item,DATABASE::"Item Variant",DATABASE::"Item Cross Reference",DATABASE::"Item Unit of Measure":
            begin
              if Item.Get(NcCollectionLine."PK Code 1") then begin
                TempItem.Init;
                TempItem := Item;
                TempItem.Insert;
              end;
            end;
          //-NC2.14 [312958]
          // DATABASE::"NPR Attribute Key",DATABASE::"NPR Attribute Value Set":
          //  BEGIN
          //
          //    IF NPRAttributeKey.GET(NcCollectionLine."PK Line 1") AND (NPRAttributeKey."Table ID" = DATABASE::Item) AND Item.GET(NPRAttributeKey."MDR Code PK") THEN BEGIN
          //      TempItem.INIT;
          //      TempItem := Item;
          //      TempItem.INSERT;
          //    END;
          //  END;
          6014555,6014556:
            begin
              RecRef.Open(6014556);
              FieldRef := RecRef.Field(1);
              FieldRef.SetFilter('%1',NcCollectionLine."PK Line 1");
              if not RecRef.Find then
                exit;
              if not Field.Get(RecRef.Number,10) then
                exit;
              FieldRef := RecRef.Field(Field."No.");
              if Format(FieldRef.Value) <> '27' then
                exit;
              if not Field.Get(RecRef.Number,11) then
                exit;
              FieldRef := RecRef.Field(Field."No.");
              if not Item.Get(Format(FieldRef.Value)) then
                exit;

              TempItem.Init;
              TempItem := Item;
              TempItem.Insert;
            end;
          //+NC2.14 [312958]
        end;
        ChildRecRef.GetTable(TempItem);
        //+NC2.13 [312958]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Nc Collector NpXml Value");
    end;

    local procedure IsElementSubscriber(NpXmlElement: Record "NpXml Element";GenericTableFunction: Text): Boolean
    begin
        //-NC2.13 [312958]
        if NpXmlElement."Generic Child Codeunit ID" <> CurrCodeunitId() then
          exit(false);
        if NpXmlElement."Generic Child Function" <> GenericTableFunction then
          exit(false);

        exit(true);
        //+NC2.13 [312958]
    end;
}

