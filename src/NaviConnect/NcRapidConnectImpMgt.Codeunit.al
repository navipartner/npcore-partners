codeunit 6151092 "NPR Nc RapidConnect Imp. Mgt."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.16/MHA /20180906  CASE 313184 Apply Package has COMMIT in RapidStart meaning Import and Apply must be split
    // NC2.17/MHA /20181116  CASE 335927 Removed green code and added Xml Import
    // NC2.22/MHA /20190621  CASE 358239 Added FormatValue() to format from Xml value to native format
    // NC14.00.2.22/MHA /20190715  CASE 361941 Excel support

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        //-NC2.17 [335927]
        //ImportExcel(Rec);
        ImportRapidConnect(Rec);
        //+NC2.17 [335927]
    end;

    local procedure ImportRapidConnect(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup";
        DataLogMgt: Codeunit "NPR Data Log Management";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlLoaded: Boolean;
        TableIdFilter: Text;
    begin
        NcRapidConnectSetup.SetRange("Import Type", NcImportEntry."Import Type");
        NcRapidConnectSetup.SetFilter("Package Code", '<>%1', '');
        if not NcRapidConnectSetup.FindSet then
            exit;

        //-NC2.17 [335927]
        XmlLoaded := TryLoadXml(NcImportEntry, XmlDoc);
        if XmlLoaded then
            TableIdFilter := GetTableIdFilter(XmlDoc);
        //+NC2.17 [335927]

        repeat
            DataLogMgt.DisableDataLog(NcRapidConnectSetup."Disable Data Log on Import");
            //-NC14.00.2.22 [361941]
            if XmlLoaded then
                ImportXmlPackage(NcRapidConnectSetup, XmlDoc);
        //+NC2.17 [335927]
        //+NC14.00.2.22 [361941]

        until NcRapidConnectSetup.Next = 0;

        //-NC2.16 [313184]
        Commit;
        asserterror
        begin
            NcRapidConnectSetup.FindSet;
            repeat
                DataLogMgt.DisableDataLog(NcRapidConnectSetup."Disable Data Log on Import");
                //-NC14.00.2.22 [361941]
                if XmlLoaded then
                    ApplyXmlPackage(NcRapidConnectSetup, TableIdFilter);
            //+NC14.00.2.22 [361941]
            until NcRapidConnectSetup.Next = 0;
            Commit;
            Error('');
        end;
        //+NC2.16 [313184]

        DataLogMgt.DisableDataLog(false);
    end;

    local procedure UseDialog(): Boolean
    begin
        //-NC2.16 [313184]
        exit(false);
        //+NC2.16 [313184]
    end;

    local procedure "--- Xml Import"()
    begin
    end;

    local procedure ImportXmlPackage(NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup"; var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageData: Record "Config. Package Data";
        "Field": Record "Field";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDocElement: DotNet NPRNetXmlElement;
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        PackageNo: Integer;
        TableId: Integer;
    begin
        //-NC2.17 [335927]
        if IsNull(XmlDoc) then
            exit;

        XmlDocElement := XmlDoc.DocumentElement;
        if IsNull(XmlDocElement) then
            exit;

        foreach XmlElement in XmlDocElement.SelectNodes('record') do begin
            Evaluate(TableId, XmlElement.GetAttribute('table_id'), 9);
            ConfigPackageTable.Get(NcRapidConnectSetup."Package Code", TableId);

            Clear(ConfigPackageRecord);
            ConfigPackageRecord.LockTable;
            ConfigPackageRecord.SetRange("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageRecord.SetRange("Table ID", ConfigPackageTable."Table ID");
            if ConfigPackageRecord.FindLast then;
            PackageNo := ConfigPackageRecord."No." + 1;

            ConfigPackageRecord.Init;
            ConfigPackageRecord."Package Code" := ConfigPackageTable."Package Code";
            ConfigPackageRecord."Table ID" := ConfigPackageTable."Table ID";
            ConfigPackageRecord."No." := PackageNo;
            ConfigPackageRecord.Insert(true);

            foreach XmlElement2 in XmlElement.SelectNodes('field') do begin
                ConfigPackageData.Init;
                ConfigPackageData."Package Code" := ConfigPackageRecord."Package Code";
                ConfigPackageData."Table ID" := ConfigPackageRecord."Table ID";
                ConfigPackageData."No." := ConfigPackageRecord."No.";
                Evaluate(ConfigPackageData."Field ID", XmlElement2.GetAttribute('field_no'), 9);
                ConfigPackageData.Value := CopyStr(XmlElement2.InnerText, 1, MaxStrLen(ConfigPackageData.Value));
                //-NC2.22 [358239]
                if Field.Get(ConfigPackageData."Table ID", ConfigPackageData."Field ID") then
                    ConfigPackageData.Value := CopyStr(FormatValue(Field, ConfigPackageData.Value), 1, MaxStrLen(ConfigPackageData.Value));
                //+NC2.22 [358239]
                ConfigPackageData.Insert(true);
            end;
        end;
        //+NC2.17 [335927]
    end;

    local procedure FormatValue("Field": Record "Field"; Value: Text): Text
    var
        TextValue: Text[250];
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
    begin
        //-NC2.22 [358239]
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
        //+NC2.22 [358239]
    end;

    local procedure ApplyXmlPackage(NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup"; TableIdFilter: Text)
    var
        ConfigPackage: Record "Config. Package";
        TempBlob: Codeunit "Temp Blob";
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        //-NC2.17 [335927]
        if NcRapidConnectSetup."Package Code" = '' then
            exit;
        if not NcRapidConnectSetup."Apply Package" then
            exit;

        ConfigPackage.Get(NcRapidConnectSetup."Package Code");
        ConfigPackageTable.SetRange("Package Code", NcRapidConnectSetup."Package Code");
        if ConfigPackage."Exclude Config. Tables" then begin
            ConfigPackageTable.FilterGroup(40);
            ConfigPackageTable.SetFilter("Table ID", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
              DATABASE::"Config. Template Header", DATABASE::"Config. Template Line",
              DATABASE::"Config. Questionnaire", DATABASE::"Config. Question Area", DATABASE::"Config. Question",
              DATABASE::"Config. Line", DATABASE::"Config. Package Filter", DATABASE::"Config. Field Mapping");
        end;

        ConfigPackageTable.FilterGroup(41);
        ConfigPackageTable.SetFilter("Table ID", TableIdFilter);

        ConfigPackageMgt.SetHideDialog(not UseDialog());
        ConfigPackageMgt.ApplyPackage(ConfigPackage, ConfigPackageTable, false);
        //+NC2.17 [335927]
    end;

    local procedure GetTableIdFilter(var XmlDoc: DotNet "NPRNetXmlDocument") TableIdFilter: Text
    var
        TempInteger: Record "Integer" temporary;
        XmlDocElement: DotNet NPRNetXmlElement;
        XmlElement: DotNet NPRNetXmlElement;
        TableId: Integer;
    begin
        //-NC2.17 [335927]
        if IsNull(XmlDoc) then
            exit('=0&<>0');
        XmlDocElement := XmlDoc.DocumentElement;
        if IsNull(XmlDocElement) then
            exit('=0&<>0');

        foreach XmlElement in XmlDocElement.SelectNodes('record') do begin
            Evaluate(TableId, XmlElement.GetAttribute('table_id'), 9);
            if not TempInteger.Get(TableId) then begin
                TempInteger.Init;
                TempInteger.Number := TableId;
                TempInteger.Insert;

                TableIdFilter += '|' + Format(TableId);
            end;
        end;
        if TableIdFilter = '' then
            exit('=0&<>0');

        TableIdFilter := DelStr(TableIdFilter, 1, 1);
        exit(TableIdFilter);
        //+NC2.17 [335927]
    end;

    [TryFunction]
    local procedure TryLoadXml(var NcImportEntry: Record "NPR Nc Import Entry"; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
        //-NC2.17 [335927]
        if not NcImportEntry.LoadXmlDoc(XmlDoc) then
            Error('');
        //+NC2.17 [335927]
    end;
}

