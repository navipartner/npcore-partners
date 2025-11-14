codeunit 6014476 "NPR Retail Price Log Mgt."
{
    Access = Internal;
    trigger OnRun()
    begin
        UpdatePriceLog();
    end;

    procedure EnablePriceLog(RetailPriceLogSetup: Record "NPR Retail Price Log Setup")
    begin
        if not RetailPriceLogSetup."Price Log Activated" then
            exit;

        EnableChangeLog();

        if RetailPriceLogSetup."Job Queue Activated" then
            CreatePriceLogJobQueue(RetailPriceLogSetup."Job Queue Category Code");

        if RetailPriceLogSetup."Item Unit Price" then
            EnableItemUnitPriceLog();

        if RetailPriceLogSetup."Sales Price" then
            EnableSalesPriceLog();

        if RetailPriceLogSetup."Sales Line Discount" then
            EnableSalesLineDiscountLog();

        if RetailPriceLogSetup."Period Discount" then
            EnablePeriodDiscountLog();
    end;

    local procedure EnableItemUnitPriceLog()
    var
        Item: Record Item;
    begin
        EnableChangeLogSetupField(DATABASE::Item, Item.FieldNo("Unit Price"));
        EnableChangeLogSetupTable(DATABASE::Item);
    end;

    local procedure EnableSalesPriceLog()
    var
        PriceListLine: Record "Price List Line";
    begin
        EnableChangeLogSetupField(DATABASE::"Price List Line", PriceListLine.FieldNo("Unit Price"));
        EnableChangeLogSetupTable(DATABASE::"Price List Line");
    end;

    local procedure EnableSalesLineDiscountLog()
    var
        PriceListLine: Record "Price List Line";
    begin
        EnableChangeLogSetupField(DATABASE::"Price List Line", PriceListLine.FieldNo("Line Discount %"));
        EnableChangeLogSetupTable(DATABASE::"Price List Line");
    end;

    local procedure EnablePeriodDiscountLog()
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        EnableChangeLogSetupField(DATABASE::"NPR Period Discount Line", PeriodDiscountLine.FieldNo("Campaign Unit Price"));
        EnableChangeLogSetupTable(DATABASE::"NPR Period Discount Line");
    end;

    internal procedure CreatePriceLogJobQueue(JobCategory: Code[10])
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NoOfMinutesBetweenRuns: Integer;
        JobQueueDescrLbl: Label 'Retail Price Log update';
        NotBeforeDateTime: DateTime;
    begin
        if JobCategory = '' then
            JobCategory := GetJobQueueCategoryCode();

        NotBeforeDateTime := NowWithDelayInSeconds(5);
        NoOfMinutesBetweenRuns := 15;

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Retail Price Log Mgt.",
            '',
            JobQueueDescrLbl,
            NotBeforeDateTime,
            NoOfMinutesBetweenRuns,
            JobCategory,
            JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end;
    end;

    local procedure GetJobQueueCategoryCode(): Code[10]
    var
        RetailPriceLogSetup: Record "NPR Retail Price Log Setup";
        JobQueueCategory: Record "Job Queue Category";
        DefMessJobCatLbl: Label 'NPR-PriceL', MaxLength = 10;
        DefMessJobCatDescLbl: Label 'Default Price Log JQ Category';
    begin
        if not RetailPriceLogSetup.Get() then begin
            RetailPriceLogSetup.Init();
            RetailPriceLogSetup.Insert();
        end;

        if RetailPriceLogSetup."Job Queue Category Code" <> '' then
            exit(RetailPriceLogSetup."Job Queue Category Code");

        JobQueueCategory.InsertRec(
            CopyStr(DefMessJobCatLbl, 1, MaxStrLen(JobQueueCategory.Code)),
            CopyStr(DefMessJobCatDescLbl, 1, MaxStrLen(JobQueueCategory.Description)));

        RetailPriceLogSetup."Job Queue Category Code" := DefMessJobCatLbl;
        RetailPriceLogSetup.Modify();
        exit(JobQueueCategory.Code);
    end;

    internal procedure DeletePriceLogJobQueue(JobCategory: Code[10])
    var
        JobQueueEntry: Record "Job Queue Entry";
        PermissionErr: Label 'You do not have right permissions to set up Job Queue.';
    begin
        if not (JobQueueEntry.ReadPermission and JobQueueEntry.WritePermission) then
            Error(PermissionErr);

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Retail Price Log Mgt.");
        JobQueueEntry.Setfilter("Job Queue Category Code", '%1', JobCategory);
        JobQueueEntry.DeleteAll(true);
    end;

    local procedure NowWithDelayInSeconds(NoOfSeconds: Integer): DateTime
    begin
        exit(CurrentDateTime() + NoOfSeconds * 1000);
    end;

    local procedure EnableChangeLog()
    var
        ChangeLogSetup: Record "Change Log Setup";
        PrevRec: Text;
    begin
        if not ChangeLogSetup.Get() then begin
            ChangeLogSetup.Init();
            ChangeLogSetup."Change Log Activated" := true;
            ChangeLogSetup.Insert();
        end;

        PrevRec := Format(ChangeLogSetup);

        ChangeLogSetup."Change Log Activated" := true;

        if PrevRec <> Format(ChangeLogSetup) then
            ChangeLogSetup.Modify();
    end;

    local procedure EnableChangeLogSetupField(TableNo: Integer; FieldNo: Integer)
    var
        ChangeLogSetupField: Record "Change Log Setup (Field)";
        PrevRec: Text;
    begin
        if not ChangeLogSetupField.Get(TableNo, FieldNo) then begin
            ChangeLogSetupField.Init();
            ChangeLogSetupField."Table No." := TableNo;
            ChangeLogSetupField."Field No." := FieldNo;
            ChangeLogSetupField."Log Insertion" := true;
            ChangeLogSetupField."Log Modification" := true;
            ChangeLogSetupField.Insert();
        end;

        PrevRec := Format(ChangeLogSetupField);

        ChangeLogSetupField."Log Insertion" := true;
        ChangeLogSetupField."Log Modification" := true;

        if PrevRec <> Format(ChangeLogSetupField) then
            ChangeLogSetupField.Modify();
    end;

    local procedure EnableChangeLogSetupTable(TableNo: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        PrevRec: Text;
    begin
        if not ChangeLogSetupTable.Get(TableNo) then begin
            ChangeLogSetupTable.Init();
            ChangeLogSetupTable."Table No." := TableNo;
            ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"Some Fields";
            ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"Some Fields";
            ChangeLogSetupTable.Insert();
        end;

        PrevRec := Format(ChangeLogSetupTable);

        if ChangeLogSetupTable."Log Insertion" = ChangeLogSetupTable."Log Insertion"::" " then
            ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"Some Fields";
        if ChangeLogSetupTable."Log Modification" = ChangeLogSetupTable."Log Modification"::" " then
            ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"Some Fields";

        if PrevRec <> Format(ChangeLogSetupTable) then
            ChangeLogSetupTable.Modify();
    end;

    procedure UpdatePriceLog()
    var
        RetailPriceLogEntry: Record "NPR Retail Price Log Entry";
        TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary;
    begin
        CleanPriceLog();

        if not FindNewPriceLogEntries(TempRetailPriceLogEntry) then
            exit;

        RetailPriceLogEntry.SetCurrentKey("Change Log Entry No.");
        repeat
            RetailPriceLogEntry.SetRange("Change Log Entry No.", TempRetailPriceLogEntry."Change Log Entry No.");
            if RetailPriceLogEntry.IsEmpty then begin
                RetailPriceLogEntry.Init();
                RetailPriceLogEntry := TempRetailPriceLogEntry;
                RetailPriceLogEntry."Entry No." := 0;
                RetailPriceLogEntry.Insert();
            end;
        until TempRetailPriceLogEntry.Next() = 0;
    end;

    local procedure CleanPriceLog()
    var
        RetailPriceLogEntry: Record "NPR Retail Price Log Entry";
    begin
        RetailPriceLogEntry.SetCurrentKey("Date and Time");
        RetailPriceLogEntry.SetFilter("Date and Time", '<%1', GetDeleteLogAfter());
        if RetailPriceLogEntry.FindFirst() then
            RetailPriceLogEntry.DeleteAll();
    end;

    local procedure GetDeleteLogAfter() DeleteLogAfter: DateTime
    var
        RetailPriceLogSetup: Record "NPR Retail Price Log Setup";
    begin
        if RetailPriceLogSetup.Get() then;
        if RetailPriceLogSetup."Delete Price Log Entries after" = 0 then
            RetailPriceLogSetup."Delete Price Log Entries after" := CreateDateTime(CalcDate('<+90D>', Today), 0T) - CreateDateTime(Today, 0T);

        DeleteLogAfter := CurrentDateTime - RetailPriceLogSetup."Delete Price Log Entries after";
        exit(DeleteLogAfter);
    end;

    local procedure FindNewPriceLogEntries(var TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary): Boolean
    var
        RetailPriceLogSetup: Record "NPR Retail Price Log Setup";
    begin
        if not RetailPriceLogSetup.Get() then
            exit(false);
        if not RetailPriceLogSetup."Price Log Activated" then
            exit(false);

        if RetailPriceLogSetup."Item Unit Price" then
            FindNewItemUnitPriceLogEntries(TempRetailPriceLogEntry);
        if RetailPriceLogSetup."Sales Price" then
            FindNewSalesPriceLogEntries(TempRetailPriceLogEntry);
        if RetailPriceLogSetup."Sales Line Discount" then
            FindNewSalesLineDiscountLogEntries(TempRetailPriceLogEntry);
        if RetailPriceLogSetup."Period Discount" then
            FindNewPeriodDiscountLogEntries(TempRetailPriceLogEntry);

        exit(TempRetailPriceLogEntry.FindSet());
    end;

    local procedure SetChangeLogEntryFilter(LastChangeLogEntryNo: BigInteger; TableNoFilter: Text; FieldNoFilter: Text; var ChangeLogEntry: Record "Change Log Entry"): Boolean
    begin
        Clear(ChangeLogEntry);
        ChangeLogEntry.SetFilter("Entry No.", '>%1', LastChangeLogEntryNo);
        ChangeLogEntry.SetFilter("Table No.", TableNoFilter);
        ChangeLogEntry.SetFilter("Field No.", FieldNoFilter);
        ChangeLogEntry.SetFilter("Type of Change", '%1|%2', ChangeLogEntry."Type of Change"::Insertion, ChangeLogEntry."Type of Change"::Modification);
        ChangeLogEntry.SetFilter("Date and Time", '>=%1', GetDeleteLogAfter());
        exit(ChangeLogEntry.FindFirst());
    end;

    local procedure FindNewItemUnitPriceLogEntries(var TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        Item: Record Item;
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast() then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::Item);
        FieldNoFilter := Format(Item.FieldNo("Unit Price"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter, FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo, TableNoFilter, FieldNoFilter, ChangeLogEntry) then
            exit;

        ChangeLogEntry.FindSet();
        repeat
            i += 1;

            TempRetailPriceLogEntry.Init();
            TempRetailPriceLogEntry."Entry No." := i;
            ChangeLogEnty2PriceLogEntry(ChangeLogEntry, TempRetailPriceLogEntry);
            TempRetailPriceLogEntry."Item No." := CopyStr(ChangeLogEntry."Primary Key Field 1 Value", 1, MaxStrLen(TempRetailPriceLogEntry."Item No."));
            TempRetailPriceLogEntry."Variant Code" := '';
            if Item.Get(TempRetailPriceLogEntry."Item No.") then
                TempRetailPriceLogEntry."Unit of Measure Code" := Item."Base Unit of Measure";
            if Evaluate(TempRetailPriceLogEntry."Old Value", ChangeLogEntry."Old Value", 9) then;
            if Evaluate(TempRetailPriceLogEntry."New Value", ChangeLogEntry."New Value", 9) then;
            TempRetailPriceLogEntry.Insert();
        until ChangeLogEntry.Next() = 0;
    end;

    local procedure FindNewSalesPriceLogEntries(var TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        PriceListLine: Record "Price List Line";
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast() then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::"Price List Line");
        FieldNoFilter := Format(PriceListLine.FieldNo("Unit Price"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter, FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo, TableNoFilter, FieldNoFilter, ChangeLogEntry) then
            exit;

        ChangeLogEntry.FindSet();
        repeat
            i += 1;

            PriceListLine.SetPosition(ChangeLogEntry."Primary Key");
            if PriceListLine.Find() then;
            if ShouldCreateRetailPriceLogEntry(PriceListLine) then begin
                TempRetailPriceLogEntry.Init();
                TempRetailPriceLogEntry."Entry No." := i;
                ChangeLogEnty2PriceLogEntry(ChangeLogEntry, TempRetailPriceLogEntry);
                TempRetailPriceLogEntry."Item No." := PriceListLine."Asset No.";
                TempRetailPriceLogEntry."Variant Code" := '';
                TempRetailPriceLogEntry."Unit of Measure Code" := PriceListLine."Unit of Measure Code";
                if Evaluate(TempRetailPriceLogEntry."Old Value", ChangeLogEntry."Old Value", 9) then;
                if Evaluate(TempRetailPriceLogEntry."New Value", ChangeLogEntry."New Value", 9) then;
                TempRetailPriceLogEntry.Insert();
            end;
        until ChangeLogEntry.Next() = 0;
    end;

    local procedure ShouldCreateRetailPriceLogEntry(PriceListLine: Record "Price List Line") ShouldCreate: Boolean
    var
        RetailPricePublicMgt: Codeunit "NPR Retail Price Public Mgt.";
    begin
        ShouldCreate := PriceListLine."Source Type" = PriceListLine."Source Type"::"All Customers";
        RetailPricePublicMgt.OnAfterShouldCreateRetailPriceLogEntry(PriceListLine, ShouldCreate);
    end;

    local procedure FindNewSalesLineDiscountLogEntries(var TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        PriceListLine: Record "Price List Line";
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast() then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::"Price List Line");
        FieldNoFilter := Format(PriceListLine.FieldNo("Line Discount %"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter, FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo, TableNoFilter, FieldNoFilter, ChangeLogEntry) then
            exit;

        ChangeLogEntry.FindSet();
        repeat
            i += 1;

            PriceListLine.SetPosition(ChangeLogEntry."Primary Key");
            if (PriceListLine."Asset Type" = PriceListLine."Asset Type"::Item) and ShouldCreateRetailPriceLogEntry(PriceListLine) then begin
                TempRetailPriceLogEntry.Init();
                TempRetailPriceLogEntry."Entry No." := i;
                ChangeLogEnty2PriceLogEntry(ChangeLogEntry, TempRetailPriceLogEntry);
                TempRetailPriceLogEntry."Item No." := CopyStr(ChangeLogEntry."Primary Key Field 2 Value", 1, MaxStrLen(TempRetailPriceLogEntry."Item No."));
                TempRetailPriceLogEntry."Variant Code" := '';
                if Evaluate(TempRetailPriceLogEntry."Old Value", ChangeLogEntry."Old Value", 9) then;
                if Evaluate(TempRetailPriceLogEntry."New Value", ChangeLogEntry."New Value", 9) then;
                TempRetailPriceLogEntry.Insert();
            end;
        until ChangeLogEntry.Next() = 0;
    end;

    local procedure FindNewPeriodDiscountLogEntries(var TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast() then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::"NPR Period Discount Line");
        FieldNoFilter := Format(PeriodDiscountLine.FieldNo("Campaign Unit Price"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter, FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo, TableNoFilter, FieldNoFilter, ChangeLogEntry) then
            exit;

        ChangeLogEntry.FindSet();
        repeat
            i += 1;

            TempRetailPriceLogEntry.Init();
            TempRetailPriceLogEntry."Entry No." := i;
            ChangeLogEnty2PriceLogEntry(ChangeLogEntry, TempRetailPriceLogEntry);
            TempRetailPriceLogEntry."Item No." := CopyStr(ChangeLogEntry."Primary Key Field 2 Value", 1, MaxStrLen(TempRetailPriceLogEntry."Item No."));
            TempRetailPriceLogEntry."Variant Code" := '';
            if Evaluate(TempRetailPriceLogEntry."Old Value", ChangeLogEntry."Old Value", 9) then;
            if Evaluate(TempRetailPriceLogEntry."New Value", ChangeLogEntry."New Value", 9) then;
            TempRetailPriceLogEntry.Insert();
        until ChangeLogEntry.Next() = 0;
    end;

    local procedure ChangeLogEnty2PriceLogEntry(ChangeLogEntry: Record "Change Log Entry"; var TempRetailPriceLogEntry: Record "NPR Retail Price Log Entry" temporary)
    begin
        TempRetailPriceLogEntry."Date and Time" := ChangeLogEntry."Date and Time";
        TempRetailPriceLogEntry.Date := DT2Date(ChangeLogEntry."Date and Time");
        TempRetailPriceLogEntry.Time := ChangeLogEntry.Time;
        TempRetailPriceLogEntry."User ID" := ChangeLogEntry."User ID";
        TempRetailPriceLogEntry."Change Log Entry No." := ChangeLogEntry."Entry No.";
        TempRetailPriceLogEntry."Table No." := ChangeLogEntry."Table No.";
        TempRetailPriceLogEntry."Field No." := ChangeLogEntry."Field No.";
    end;

    local procedure GetLastChangeLogEntryNo(TableNoFilter: Text; FieldNoFilter: Text): BigInteger
    var
        RetailPriceLogEntry: Record "NPR Retail Price Log Entry";
    begin
        RetailPriceLogEntry.SetCurrentKey("Table No.", "Field No.", "Change Log Entry No.");
        RetailPriceLogEntry.SetFilter("Table No.", TableNoFilter);
        RetailPriceLogEntry.SetFilter("Field No.", FieldNoFilter);
        if RetailPriceLogEntry.FindLast() then;

        exit(RetailPriceLogEntry."Change Log Entry No.");
    end;

    procedure RetailJnlImportFromPriceLog(RetailJnlHeader: Record "NPR Retail Journal Header")
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
        RetailPriceLogEntry: Record "NPR Retail Price Log Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        TempItem: Record Item temporary;
        LineNo: Integer;
    begin
        if not QueryPriceLog(RetailJnlHeader, TempItem) then
            exit;

        RetailJnlLine.SetRange("No.", RetailJnlHeader."No.");
        if RetailJnlLine.FindLast() then;
        LineNo := RetailJnlLine."Line No.";

        TempItem.FindSet();
        repeat
            ItemUnitOfMeasure.Reset();
            ItemUnitOfMeasure.SetRange("Item No.", TempItem."No.");
            if ItemUnitOfMeasure.FindSet() then
                repeat
                    RetailPriceLogEntry.Reset();
                    RetailPriceLogEntry.SetRange("Item No.", TempItem."No.");
                    RetailPriceLogEntry.SetRange("Unit of Measure Code", ItemUnitOfMeasure.Code);
                    if RetailPriceLogEntry.FindLast() then begin
                        LineNo += 10000;
                        RetailJnlLine.Init();
                        RetailJnlLine.Validate("No.", RetailJnlHeader."No.");
                        RetailJnlLine."Line No." := LineNo;
                        CopyAdditionalFieldsFromHeader(RetailJnlHeader, RetailJnlLine);
                        RetailJnlLine.Validate("Item No.", TempItem."No.");
                        RetailJnlLine.validate("Unit of Measure", RetailPriceLogEntry."Unit of Measure Code");
                        RetailJnlLine.Insert(true);
                    end;
                until ItemUnitOfMeasure.Next() = 0;

        until TempItem.Next() = 0;
    end;

    local procedure QueryPriceLog(RetailJnlHeader: Record "NPR Retail Journal Header"; var TempItem: Record Item temporary): Boolean
    var
        Item: Record Item;
        RetailPriceLogEntry: Record "NPR Retail Price Log Entry";
    begin
        if not RunDynamicRequestPage(Item, RetailPriceLogEntry) then
            exit(false);

        Item.FilterGroup(40);
        if RetailJnlHeader."Location Code" <> '' then
            Item.SetFilter("Location Filter", RetailJnlHeader."Location Code");
        if RetailJnlHeader."Date of creation" <> 0D then
            Item.SetFilter("Date Filter", '>=%1', RetailJnlHeader."Date of creation");
        if Item.IsEmpty then
            exit(false);

        if RetailPriceLogEntry.IsEmpty then
            exit(false);

        RetailPriceLogEntry.SetCurrentKey("Item No.", "Variant Code");
        RetailPriceLogEntry.FilterGroup(40);
        Item.FindSet();
        repeat
            RetailPriceLogEntry.SetRange("Item No.", Item."No.");
            RetailPriceLogEntry.SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
            if RetailPriceLogEntry.FindFirst() then begin
                TempItem.Init();
                TempItem := Item;
                TempItem.Insert();
            end;
        until Item.Next() = 0;

        exit(TempItem.FindFirst());
    end;

    local procedure RunDynamicRequestPage(var Item: Record Item; var RetailPriceLogEntry: Record "NPR Retail Price Log Entry"): Boolean
    var
        FilterPageBuilder: FilterPageBuilder;
        FilterName: Text;
        FilterName2: Text;
        FilterView: Text;
        FilterView2: Text;
    begin
        if not GuiAllowed then
            exit(false);

        FilterPageBuilder.PageCaption := RetailPriceLogEntry.TableCaption;

        FilterName := GetTableName(DATABASE::Item);
        FilterPageBuilder.AddTable(FilterName, DATABASE::Item);

        FilterName2 := GetTableName(DATABASE::"NPR Retail Price Log Entry");
        FilterPageBuilder.AddTable(FilterName2, DATABASE::"NPR Retail Price Log Entry");

        if GetQueryPriceLogView(FilterView, FilterView2) then begin
            Item.SetView(FilterView);
            FilterPageBuilder.SetView(FilterName, FilterView);

            RetailPriceLogEntry.SetView(FilterView2);
            FilterPageBuilder.SetView(FilterName2, FilterView2);
        end;

        FilterPageBuilder.AddRecord(FilterName, Item);
        FilterPageBuilder.ADdField(FilterName, Item."No.");
        FilterPageBuilder.ADdField(FilterName, Item."Last Date Modified");
        FilterPageBuilder.ADdField(FilterName, Item."Item Category Code");
        FilterPageBuilder.ADdField(FilterName, Item."Item Disc. Group");
        FilterPageBuilder.ADdField(FilterName, Item.Description);
        FilterPageBuilder.ADdField(FilterName, Item.Inventory);
        FilterPageBuilder.ADdField(FilterName, Item."Net Change");

        FilterPageBuilder.AddRecord(FilterName2, RetailPriceLogEntry);
        FilterPageBuilder.ADdField(FilterName2, RetailPriceLogEntry."Date and Time");
        FilterPageBuilder.ADdField(FilterName2, RetailPriceLogEntry."Table No.");

        if not FilterPageBuilder.RunModal() then
            exit(false);

        SaveViewFromDynamicRequestPage(FilterPageBuilder);

        Item.SetView(FilterPageBuilder.GetView(FilterName, false));
        RetailPriceLogEntry.SetView(FilterPageBuilder.GetView(FilterName2, false));
        exit(true);
    end;

    local procedure GetTableName(TableID: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(TableID);
        exit(CopyStr(TableMetadata.Name, 1, 20));
    end;

    local procedure GetQueryPriceLogView(var FilterView: Text; var FilterView2: Text): Boolean
    var
        PageDataPersonalization: Record "Page Data Personalization";
        IStream: InStream;
        XmlDoc: XmlDocument;
        XNode: XmlNode;
    begin
        if not FindQueryPriceLogView(PageDataPersonalization) then
            exit(false);
        if not PageDataPersonalization.Value.HasValue() then
            exit(false);

        PageDataPersonalization.CalcFields(Value);
        PageDataPersonalization.Value.CreateInStream(IStream);

        XmlDocument.ReadFrom(IStream, XmlDoc);
        if not XmlDoc.SelectSingleNode('//DataItems/DataItem[@name="' + GetTableName(DATABASE::Item) + '"]', XNode) then begin
            exit(false);
        end;
        FilterView := XNode.AsXmlElement().InnerText;

        if not XmlDoc.SelectSingleNode('//DataItems/DataItem[@name="' + GetTableName(DATABASE::"NPR Retail Price Log Entry") + '"]', XNode) then
            exit(false);
        FilterView2 := XNode.AsXmlElement().InnerText;

        exit(true);
    end;

    local procedure SaveViewFromDynamicRequestPage(var FilterPageBuilder: FilterPageBuilder): Text
    var
        PageDataPersonalization: Record "Page Data Personalization";
        User: Record User;
        DataItemXmlNode: XmlElement;
        DataItemsXmlNode: XmlElement;
        ReportParametersXmlNode: XmlElement;
        XmlDoc: XmlDocument;
        OStream: OutStream;
    begin
        XmlDoc := XmlDocument.Create();

        xmlDoc.SetDeclaration(xmlDeclaration.Create('1.0', 'utf-8', 'yes'));

        ReportParametersXmlNode := XmlElement.Create('ReportParameters');
        XmlDoc.Add(ReportParametersXmlNode);

        DataItemsXmlNode := XmlElement.Create('DataItems');
        ReportParametersXmlNode.Add(DataItemsXmlNode);

        DataItemXmlNode := XmlElement.Create('DataItem', '', FilterPageBuilder.GetView(GetTableName(DATABASE::Item), false));
        DataItemXmlNode.SetAttribute('name', GetTableName(DATABASE::Item));
        DataItemsXmlNode.Add(DataItemXmlNode);

        DataItemXmlNode := XmlElement.Create('DataItem', '', FilterPageBuilder.GetView(GetTableName(DATABASE::"NPR Retail Price Log Entry"), false));
        DataItemXmlNode.SetAttribute('name', GetTableName(DATABASE::"NPR Retail Price Log Entry"));
        DataItemsXmlNode.Add(DataItemXmlNode);

        if not FindQueryPriceLogView(PageDataPersonalization) then begin
            User.SetRange("User Name", UserId);
            if not User.FindFirst() then
                exit;

            PageDataPersonalization.Init();
            PageDataPersonalization."User SID" := User."User Security ID";
            PageDataPersonalization."Object Type" := PageDataPersonalization."Object Type"::Page;
            PageDataPersonalization."Object ID" := PAGE::"NPR Retail Journal Header";
            PageDataPersonalization.ValueName := QueryPriceLogViewName();
            PageDataPersonalization.Insert(true);
            Commit();
        end;

        Clear(PageDataPersonalization.Value);
        PageDataPersonalization.Value.CreateOutStream(OStream);
        XmlDoc.WriteTo(OStream);
        PageDataPersonalization.Modify(true);
        Commit();
    end;

    local procedure FindQueryPriceLogView(var PageDataPersonalization: Record "Page Data Personalization"): Boolean
    begin
        Clear(PageDataPersonalization);
        PageDataPersonalization.SetRange("User ID", UserId);
        PageDataPersonalization.SetRange("Object Type", PageDataPersonalization."Object Type"::Page);
        PageDataPersonalization.SetRange("Object ID", PAGE::"NPR Retail Journal Header");
        PageDataPersonalization.SetRange(ValueName, QueryPriceLogViewName());
        exit(PageDataPersonalization.FindLast());
    end;

    local procedure QueryPriceLogViewName(): Code[40]
    begin
        exit('QUERY_RETAIL_PRICE_LOG');
    end;

    local procedure CopyAdditionalFieldsFromHeader(RetailJnlHeader: Record "NPR Retail Journal Header"; var RetailJnlLine: Record "NPR Retail Journal Line")
    begin
        RetailJnlLine."Calculation Date" := RetailJnlHeader."Date of creation";
        RetailJnlLine."Customer Price Group" := RetailJnlHeader."Customer Price Group";
        RetailJnlLine."Customer Disc. Group" := RetailJnlHeader."Customer Disc. Group";
        RetailJnlLine."Register No." := RetailJnlHeader."Register No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Price Log Setup", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertRetailUnitPriceLogSetup(var Rec: Record "NPR Retail Price Log Setup"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Price Log Activated" then
            EnablePriceLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Price Log Setup", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyRetailUnitPriceLogSetup(var Rec: Record "NPR Retail Price Log Setup"; var xRec: Record "NPR Retail Price Log Setup"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary then
            exit;

        if Rec."Price Log Activated" then
            EnablePriceLog(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        PriceLogSetup: Record "NPR Retail Price Log Setup";
    begin
        if not (PriceLogSetup.Get() and PriceLogSetup."Job Queue Activated") then
            exit;
        CreatePriceLogJobQueue('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = Codeunit::"NPR Retail Price Log Mgt.")
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;
}
