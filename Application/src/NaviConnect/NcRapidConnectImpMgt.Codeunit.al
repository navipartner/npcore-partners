codeunit 6151092 "NPR Nc RapidConnect Imp. Mgt."
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        ImportRapidConnect(Rec);
    end;

    local procedure ImportRapidConnect(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        RcApplyPackage: Codeunit "NPR Nc RapidConnect Apply Pckg";
        NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup";
        DataLogMgt: Codeunit "NPR Data Log Management";
        XmlDoc: XmlDocument;
        XmlLoaded: Boolean;
        TableIdFilter: Text;
    begin
        NcRapidConnectSetup.SetRange("Import Type", NcImportEntry."Import Type");
        NcRapidConnectSetup.SetFilter("Package Code", '<>%1', '');
        if not NcRapidConnectSetup.FindSet() then
            exit;

        XmlLoaded := TryLoadXml(NcImportEntry, XmlDoc);
        if not XmlLoaded then
            exit;

        TableIdFilter := GetTableIdFilter(XmlDoc);

        repeat
            DataLogMgt.DisableDataLog(NcRapidConnectSetup."Disable Data Log on Import");
            ImportXmlPackage(NcRapidConnectSetup, XmlDoc);
        until NcRapidConnectSetup.Next() = 0;

        Commit();
        Clear(RcApplyPackage);
        RcApplyPackage.SetProcessingOptions(TableIdFilter, UseDialog());
        if RcApplyPackage.Run(NcRapidConnectSetup) then;

        DataLogMgt.DisableDataLog(false);
    end;

    local procedure UseDialog(): Boolean
    begin
        exit(false);
    end;

    local procedure ImportXmlPackage(NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup"; var Document: XmlDocument)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageData: Record "Config. Package Data";
        "Field": Record "Field";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        DocumentElement: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
        NodeList2: XmlNodeList;
        Node2: XmlNode;
        Attribute: XmlAttribute;
        PackageNo: Integer;
        TableId: Integer;
    begin
        if not Document.GetRoot(DocumentElement) then
            exit;

        if DocumentElement.IsEmpty then
            exit;

        DocumentElement.SelectNodes('//record', NodeList);
        foreach Node in NodeList do begin
            NpXmlDomMgt.GetAttributeFromElement(Node.AsXmlElement(), 'table_id', Attribute, true);
            Evaluate(TableId, Attribute.Value, 9);
            ConfigPackageTable.Get(NcRapidConnectSetup."Package Code", TableId);

            Clear(ConfigPackageRecord);
            ConfigPackageRecord.LockTable();
            ConfigPackageRecord.SetRange("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageRecord.SetRange("Table ID", ConfigPackageTable."Table ID");
            if ConfigPackageRecord.FindLast() then;
            PackageNo := ConfigPackageRecord."No." + 1;

            ConfigPackageRecord.Init();
            ConfigPackageRecord."Package Code" := ConfigPackageTable."Package Code";
            ConfigPackageRecord."Table ID" := ConfigPackageTable."Table ID";
            ConfigPackageRecord."No." := PackageNo;
            ConfigPackageRecord.Insert(true);

            Node.SelectNodes('//field', NodeList2);
            foreach Node2 in NodeList2 do begin
                ConfigPackageData.Init();
                ConfigPackageData."Package Code" := ConfigPackageRecord."Package Code";
                ConfigPackageData."Table ID" := ConfigPackageRecord."Table ID";
                ConfigPackageData."No." := ConfigPackageRecord."No.";
                NpXmlDomMgt.GetAttributeFromElement(Node2.AsXmlElement(), 'field_no', Attribute, true);
                Evaluate(ConfigPackageData."Field ID", Attribute.Value, 9);
                ConfigPackageData.Value := CopyStr(Node2.AsXmlElement().InnerText, 1, MaxStrLen(ConfigPackageData.Value));
                if Field.Get(ConfigPackageData."Table ID", ConfigPackageData."Field ID") then
                    ConfigPackageData.Value := CopyStr(FormatValue(Field, ConfigPackageData.Value), 1, MaxStrLen(ConfigPackageData.Value));
                ConfigPackageData.Insert(true);
            end;
        end;
    end;

    local procedure FormatValue("Field": Record "Field"; Value: Text): Text
    var
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
    begin
        case Field.Type of
            Field.Type::Code, Field.Type::Text:
                begin
                    exit(Value);
                end;
            Field.Type::Decimal:
                begin
                    Evaluate(DecimalValue, Value, 9);
                    exit(Format(DecimalValue));
                end;
            Field.Type::Boolean:
                begin
                    Evaluate(BooleanValue, Value, 9);
                    exit(Format(BooleanValue));
                end;
            Field.Type::DateFormula:
                begin
                    Evaluate(DateFormulaValue, Value, 9);
                    exit(Format(DateFormulaValue));
                end;
            Field.Type::BigInteger:
                begin
                    Evaluate(BigIntegerValue, Value, 9);
                    exit(Format(BigIntegerValue));
                end;
            Field.Type::DateTime:
                begin
                    Evaluate(DateTimeValue, Value, 9);
                    exit(Format(DateTimeValue));
                end;
            Field.Type::Integer:
                begin
                    exit(Value);
                end;
            Field.Type::Option:
                begin
                    if not Evaluate(IntegerValue, Value, 9) then
                        exit(Value);
                    Value := SelectStr(IntegerValue + 1, Field.OptionString);
                    exit(Value);
                end;
            Field.Type::Date:
                begin
                    Evaluate(DateValue, Value, 9);
                    exit(Format(DateValue));
                end;
            Field.Type::Time:
                begin
                    Evaluate(TimeValue, Value, 9);
                    exit(Format(TimeValue));
                end;
        end;
    end;

    local procedure GetTableIdFilter(var Document: XmlDocument) TableIdFilter: Text
    var
        TempInteger: Record "Integer" temporary;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        DocumentElement: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
        Attribute: XmlAttribute;
        TableId: Integer;
    begin
        if not Document.GetRoot(DocumentElement) then
            exit('=0&<>0');

        if DocumentElement.IsEmpty then
            exit('=0&<>0');

        DocumentElement.SelectNodes('//record', NodeList);
        foreach Node in NodeList do begin
            NpXmlDomMgt.GetAttributeFromElement(Node.AsXmlElement(), 'table_id', Attribute, true);
            Evaluate(TableId, Attribute.Value, 9);
            if not TempInteger.Get(TableId) then begin
                TempInteger.Init();
                TempInteger.Number := TableId;
                TempInteger.Insert();

                TableIdFilter += '|' + Format(TableId);
            end;
        end;
        if TableIdFilter = '' then
            exit('=0&<>0');

        TableIdFilter := DelStr(TableIdFilter, 1, 1);
        exit(TableIdFilter);
    end;

    [TryFunction]
    local procedure TryLoadXml(var NcImportEntry: Record "NPR Nc Import Entry"; var XmlDoc: XmlDocument)
    begin
        if not NcImportEntry.LoadXmlDoc(XmlDoc) then
            Error('');
    end;
}