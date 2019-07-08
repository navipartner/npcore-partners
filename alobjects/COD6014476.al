codeunit 6014476 "Retail Price Log Mgt."
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created


    trigger OnRun()
    begin
        UpdatePriceLog();
    end;

    local procedure "--- Price Log Setup"()
    begin
    end;

    procedure EnablePriceLog(RetailPriceLogSetup: Record "Retail Price Log Setup")
    begin
        if not RetailPriceLogSetup."Price Log Activated" then
          exit;

        EnableChangeLog();

        if RetailPriceLogSetup."Task Queue Activated" then
          EnableTaskQueue();

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
        EnableChangeLogSetupField(DATABASE::Item,Item.FieldNo("Unit Price"));
        EnableChangeLogSetupTable(DATABASE::Item);
    end;

    local procedure EnableSalesPriceLog()
    var
        SalesPrice: Record "Sales Price";
    begin
        EnableChangeLogSetupField(DATABASE::"Sales Price",SalesPrice.FieldNo("Unit Price"));
        EnableChangeLogSetupTable(DATABASE::"Sales Price");
    end;

    local procedure EnableSalesLineDiscountLog()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        EnableChangeLogSetupField(DATABASE::"Sales Line Discount",SalesLineDiscount.FieldNo("Line Discount %"));
        EnableChangeLogSetupTable(DATABASE::"Sales Line Discount");
    end;

    local procedure EnablePeriodDiscountLog()
    var
        PeriodDiscount: Record "Period Discount";
        PeriodDiscountLine: Record "Period Discount Line";
    begin
        EnableChangeLogSetupField(DATABASE::"Period Discount Line",PeriodDiscountLine.FieldNo("Campaign Unit Price"));
        EnableChangeLogSetupTable(DATABASE::"Period Discount Line");
    end;

    local procedure EnableTaskQueue()
    var
        TaskBatch: Record "Task Batch";
        TaskLine: Record "Task Line";
        TaskQueue: Record "Task Queue";
        TaskWorkerGroup: Record "Task Worker Group";
        LineNo: Integer;
        PrevRec: Text;
    begin
        TaskLine.SetRange("Object Type",TaskLine."Object Type"::Codeunit);
        TaskLine.SetRange("Object No.",CODEUNIT::"Retail Price Log Mgt.");
        if TaskLine.FindFirst then
          exit;

        TaskWorkerGroup.SetFilter("Max. Concurrent Threads",'>%1',0);
        if not TaskWorkerGroup.FindFirst then
          exit;

        if not TaskBatch.FindFirst then
          exit;

        TaskLine.Reset;
        TaskLine.SetRange("Journal Template Name",TaskBatch."Journal Template Name");
        TaskLine.SetRange("Journal Batch Name",TaskBatch.Name);
        if TaskLine.FindLast then;
        LineNo := TaskLine."Line No." + 10000;

        TaskLine.Init;
        TaskLine."Journal Template Name" := TaskBatch."Journal Template Name";
        TaskLine."Journal Batch Name" := TaskBatch.Name;
        TaskLine."Line No." := LineNo;
        TaskLine.Description := 'Retail Price Log update';
        TaskLine.Enabled := true;
        TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
        TaskLine."Object No." := CODEUNIT::"Retail Price Log Mgt.";
        TaskLine."Call Object With Task Record" := false;
        TaskLine.Priority := TaskLine.Priority::Medium;
        TaskLine."Task Worker Group" := TaskWorkerGroup.Code;
        TaskLine.Recurrence := TaskLine.Recurrence::Custom;
        TaskLine."Recurrence Interval" := 15 * 60 * 1000;
        TaskLine."Recurrence Method" := TaskLine."Recurrence Method"::Static;
        TaskLine."Recurrence Calc. Interval" := 0;
        TaskLine."Run on Monday" := true;
        TaskLine."Run on Tuesday" := true;
        TaskLine."Run on Wednesday" := true;
        TaskLine."Run on Thursday" := true;
        TaskLine."Run on Friday" := true;
        TaskLine."Run on Saturday" := true;
        TaskLine."Run on Sunday" := true;
        TaskLine.Insert(true);

        if not TaskQueue.Get(CompanyName,TaskLine."Journal Template Name",TaskLine."Journal Batch Name",TaskLine."Line No.") then begin
          TaskQueue.SetupNewLine(TaskLine,false);
          TaskQueue."Next Run time" := CurrentDateTime;
          TaskQueue.Insert;
        end else begin
          TaskQueue."Next Run time" := CurrentDateTime;
          TaskQueue.Modify;
        end;
    end;

    local procedure "--- Change Log"()
    begin
    end;

    local procedure EnableChangeLog()
    var
        ChangeLogSetup: Record "Change Log Setup";
        PrevRec: Text;
    begin
        if not ChangeLogSetup.Get then begin
          ChangeLogSetup.Init;
          ChangeLogSetup."Change Log Activated" := true;
          ChangeLogSetup.Insert;
        end;

        PrevRec := Format(ChangeLogSetup);

        ChangeLogSetup."Change Log Activated" := true;

        if PrevRec <> Format(ChangeLogSetup) then
          ChangeLogSetup.Modify;
    end;

    local procedure EnableChangeLogSetupField(TableNo: Integer;FieldNo: Integer)
    var
        ChangeLogSetupField: Record "Change Log Setup (Field)";
        PrevRec: Text;
    begin
        if not ChangeLogSetupField.Get(TableNo,FieldNo) then begin
          ChangeLogSetupField.Init;
          ChangeLogSetupField."Table No." := TableNo;
          ChangeLogSetupField."Field No." := FieldNo;
          ChangeLogSetupField."Log Insertion" := true;
          ChangeLogSetupField."Log Modification" := true;
          ChangeLogSetupField.Insert;
        end;

        PrevRec := Format(ChangeLogSetupField);

        ChangeLogSetupField."Log Insertion" := true;
        ChangeLogSetupField."Log Modification" := true;

        if PrevRec <> Format(ChangeLogSetupField) then
          ChangeLogSetupField.Modify;
    end;

    local procedure EnableChangeLogSetupTable(TableNo: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        PrevRec: Text;
    begin
        if not ChangeLogSetupTable.Get(TableNo) then begin
          ChangeLogSetupTable.Init;
          ChangeLogSetupTable."Table No." := TableNo;
          ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"Some Fields";
          ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"Some Fields";
          ChangeLogSetupTable.Insert;
        end;

        PrevRec := Format(ChangeLogSetupTable);

        if ChangeLogSetupTable."Log Insertion" = ChangeLogSetupTable."Log Insertion"::" " then
          ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"Some Fields";
        if ChangeLogSetupTable."Log Modification" = ChangeLogSetupTable."Log Modification"::" " then
          ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"Some Fields";

        if PrevRec <> Format(ChangeLogSetupTable) then
          ChangeLogSetupTable.Modify;
    end;

    local procedure "--- Price Log"()
    begin
    end;

    procedure UpdatePriceLog()
    var
        RetailPriceLogEntry: Record "Retail Price Log Entry";
        TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary;
    begin
        CleanPriceLog();

        if not FindNewPriceLogEntries(TempRetailPriceLogEntry) then
          exit;

        RetailPriceLogEntry.SetCurrentKey("Change Log Entry No.");
        repeat
          RetailPriceLogEntry.SetRange("Change Log Entry No.",TempRetailPriceLogEntry."Change Log Entry No.");
          if RetailPriceLogEntry.IsEmpty then begin
            RetailPriceLogEntry.Init;
            RetailPriceLogEntry := TempRetailPriceLogEntry;
            RetailPriceLogEntry."Entry No." := 0;
            RetailPriceLogEntry.Insert;
          end;
        until TempRetailPriceLogEntry.Next = 0;
    end;

    local procedure CleanPriceLog()
    var
        RetailPriceLogEntry: Record "Retail Price Log Entry";
        FilterDate: Date;
    begin
        RetailPriceLogEntry.SetCurrentKey("Date and Time");
        RetailPriceLogEntry.SetFilter("Date and Time",'<%1',GetDeleteLogAfter());
        if RetailPriceLogEntry.FindFirst then
          RetailPriceLogEntry.DeleteAll;
    end;

    local procedure GetDeleteLogAfter() DeleteLogAfter: DateTime
    var
        RetailPriceLogSetup: Record "Retail Price Log Setup";
    begin
        if RetailPriceLogSetup.Get then;
        if RetailPriceLogSetup."Delete Price Log Entries after" = 0 then
          RetailPriceLogSetup."Delete Price Log Entries after" := CreateDateTime(CalcDate('<+90D>',Today),0T) - CreateDateTime(Today,0T);

        DeleteLogAfter := CurrentDateTime - RetailPriceLogSetup."Delete Price Log Entries after";
        exit(DeleteLogAfter);
    end;

    local procedure FindNewPriceLogEntries(var TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary): Boolean
    var
        RetailPriceLogSetup: Record "Retail Price Log Setup";
    begin
        if not RetailPriceLogSetup.Get then
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

        exit(TempRetailPriceLogEntry.FindSet);
    end;

    local procedure SetChangeLogEntryFilter(LastChangeLogEntryNo: BigInteger;TableNoFilter: Text;FieldNoFilter: Text;var ChangeLogEntry: Record "Change Log Entry"): Boolean
    begin
        Clear(ChangeLogEntry);
        ChangeLogEntry.SetFilter("Entry No.",'>%1',LastChangeLogEntryNo);
        ChangeLogEntry.SetFilter("Table No.",TableNoFilter);
        ChangeLogEntry.SetFilter("Field No.",FieldNoFilter);
        ChangeLogEntry.SetFilter("Type of Change",'%1|%2',ChangeLogEntry."Type of Change"::Insertion,ChangeLogEntry."Type of Change"::Modification);
        ChangeLogEntry.SetFilter("Date and Time",'>=%1',GetDeleteLogAfter());
        exit(ChangeLogEntry.FindFirst);
    end;

    local procedure FindNewItemUnitPriceLogEntries(var TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        Item: Record Item;
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::Item);
        FieldNoFilter := Format(Item.FieldNo("Unit Price"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter,FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo,TableNoFilter,FieldNoFilter,ChangeLogEntry) then
          exit;

        ChangeLogEntry.FindSet;
        repeat
          i += 1;

          TempRetailPriceLogEntry.Init;
          TempRetailPriceLogEntry."Entry No." := i;
          ChangeLogEnty2PriceLogEntry(ChangeLogEntry,TempRetailPriceLogEntry);
          TempRetailPriceLogEntry."Item No." := ChangeLogEntry."Primary Key Field 1 Value";
          TempRetailPriceLogEntry."Variant Code" := '';
          if Evaluate(TempRetailPriceLogEntry."Old Value",ChangeLogEntry."Old Value",9) then;
          if Evaluate(TempRetailPriceLogEntry."New Value",ChangeLogEntry."New Value",9) then;
          TempRetailPriceLogEntry.Insert;
        until ChangeLogEntry.Next = 0;
    end;

    local procedure FindNewSalesPriceLogEntries(var TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        SalesPrice: Record "Sales Price";
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::"Sales Price");
        FieldNoFilter := Format(SalesPrice.FieldNo("Unit Price"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter,FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo,TableNoFilter,FieldNoFilter,ChangeLogEntry) then
          exit;

        ChangeLogEntry.FindSet;
        repeat
          i += 1;

          SalesPrice.SetPosition(ChangeLogEntry."Primary Key");
          if SalesPrice."Sales Type" = SalesPrice."Sales Type"::"All Customers" then begin
            TempRetailPriceLogEntry.Init;
            TempRetailPriceLogEntry."Entry No." := i;
            ChangeLogEnty2PriceLogEntry(ChangeLogEntry,TempRetailPriceLogEntry);
            TempRetailPriceLogEntry."Item No." := ChangeLogEntry."Primary Key Field 1 Value";
            TempRetailPriceLogEntry."Variant Code" := '';
            if Evaluate(TempRetailPriceLogEntry."Old Value",ChangeLogEntry."Old Value",9) then;
            if Evaluate(TempRetailPriceLogEntry."New Value",ChangeLogEntry."New Value",9) then;
            TempRetailPriceLogEntry.Insert;
          end;
        until ChangeLogEntry.Next = 0;
    end;

    local procedure FindNewSalesLineDiscountLogEntries(var TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        SalesLineDiscount: Record "Sales Line Discount";
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::"Sales Line Discount");
        FieldNoFilter := Format(SalesLineDiscount.FieldNo("Line Discount %"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter,FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo,TableNoFilter,FieldNoFilter,ChangeLogEntry) then
          exit;

        ChangeLogEntry.FindSet;
        repeat
          i += 1;

          SalesLineDiscount.SetPosition(ChangeLogEntry."Primary Key");
          if (SalesLineDiscount.Type = SalesLineDiscount.Type::Item) and (SalesLineDiscount."Sales Type" = SalesLineDiscount."Sales Type"::"All Customers") then begin
            TempRetailPriceLogEntry.Init;
            TempRetailPriceLogEntry."Entry No." := i;
            ChangeLogEnty2PriceLogEntry(ChangeLogEntry,TempRetailPriceLogEntry);
            TempRetailPriceLogEntry."Item No." := ChangeLogEntry."Primary Key Field 2 Value";
            TempRetailPriceLogEntry."Variant Code" := '';
            if Evaluate(TempRetailPriceLogEntry."Old Value",ChangeLogEntry."Old Value",9) then;
            if Evaluate(TempRetailPriceLogEntry."New Value",ChangeLogEntry."New Value",9) then;
            TempRetailPriceLogEntry.Insert;
          end;
        until ChangeLogEntry.Next = 0;
    end;

    local procedure FindNewPeriodDiscountLogEntries(var TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary)
    var
        ChangeLogEntry: Record "Change Log Entry";
        PeriodDiscountLine: Record "Period Discount Line";
        LastChangeLogEntryNo: BigInteger;
        FieldNoFilter: Text;
        TableNoFilter: Text;
        i: Integer;
    begin
        Clear(TempRetailPriceLogEntry);
        if TempRetailPriceLogEntry.FindLast then;
        i := TempRetailPriceLogEntry."Entry No.";

        TableNoFilter := Format(DATABASE::"Period Discount Line");
        FieldNoFilter := Format(PeriodDiscountLine.FieldNo("Campaign Unit Price"));
        LastChangeLogEntryNo := GetLastChangeLogEntryNo(TableNoFilter,FieldNoFilter);
        if not SetChangeLogEntryFilter(LastChangeLogEntryNo,TableNoFilter,FieldNoFilter,ChangeLogEntry) then
          exit;

        ChangeLogEntry.FindSet;
        repeat
          i += 1;

          TempRetailPriceLogEntry.Init;
          TempRetailPriceLogEntry."Entry No." := i;
          ChangeLogEnty2PriceLogEntry(ChangeLogEntry,TempRetailPriceLogEntry);
          TempRetailPriceLogEntry."Item No." := ChangeLogEntry."Primary Key Field 2 Value";
          TempRetailPriceLogEntry."Variant Code" := '';
          if Evaluate(TempRetailPriceLogEntry."Old Value",ChangeLogEntry."Old Value",9) then;
          if Evaluate(TempRetailPriceLogEntry."New Value",ChangeLogEntry."New Value",9) then;
          TempRetailPriceLogEntry.Insert;
        until ChangeLogEntry.Next = 0;
    end;

    local procedure ChangeLogEnty2PriceLogEntry(ChangeLogEntry: Record "Change Log Entry";var TempRetailPriceLogEntry: Record "Retail Price Log Entry" temporary)
    begin
        TempRetailPriceLogEntry."Date and Time" := ChangeLogEntry."Date and Time";
        TempRetailPriceLogEntry.Date := DT2Date(ChangeLogEntry."Date and Time");
        TempRetailPriceLogEntry.Time := ChangeLogEntry.Time;
        TempRetailPriceLogEntry."User ID" := ChangeLogEntry."User ID";
        TempRetailPriceLogEntry."Change Log Entry No." := ChangeLogEntry."Entry No.";
        TempRetailPriceLogEntry."Table No." := ChangeLogEntry."Table No.";
        TempRetailPriceLogEntry."Field No." := ChangeLogEntry."Field No.";
    end;

    local procedure GetLastChangeLogEntryNo(TableNoFilter: Text;FieldNoFilter: Text): BigInteger
    var
        RetailPriceLogEntry: Record "Retail Price Log Entry";
    begin
        RetailPriceLogEntry.SetCurrentKey("Table No.","Field No.","Change Log Entry No.");
        RetailPriceLogEntry.SetFilter("Table No.",TableNoFilter);
        RetailPriceLogEntry.SetFilter("Field No.",FieldNoFilter);
        if RetailPriceLogEntry.FindLast then;

        exit(RetailPriceLogEntry."Change Log Entry No.");
    end;

    local procedure "--- Retail Journal"()
    begin
    end;

    procedure RetailJnlImportFromPriceLog(RetailJnlHeader: Record "Retail Journal Header")
    var
        RetailJnlLine: Record "Retail Journal Line";
        TempItem: Record Item temporary;
        LineNo: Integer;
    begin
        if not QueryPriceLog(RetailJnlHeader,TempItem) then
          exit;

        RetailJnlLine.SetRange("No.",RetailJnlHeader."No.");
        if RetailJnlLine.FindLast then;
        LineNo := RetailJnlLine."Line No.";

        TempItem.FindSet;
        repeat
          LineNo += 10000;

          RetailJnlLine.Init;
          RetailJnlLine.Validate("No.",RetailJnlHeader."No.");
          RetailJnlLine."Line No." := LineNo;
          RetailJnlLine.Validate("Item No.",TempItem."No.");
          RetailJnlLine.Insert(true);
        until TempItem.Next = 0;
    end;

    local procedure QueryPriceLog(RetailJnlHeader: Record "Retail Journal Header";var TempItem: Record Item temporary): Boolean
    var
        Item: Record Item;
        RetailPriceLogEntry: Record "Retail Price Log Entry";
    begin
        if not RunDynamicRequestPage(Item,RetailPriceLogEntry) then
          exit(false);

        Item.FilterGroup(40);
        if RetailJnlHeader."Location Code" <> '' then
          Item.SetFilter("Location Filter",RetailJnlHeader."Location Code");
        if RetailJnlHeader."Date of creation" <> 0D then
          Item.SetFilter("Date Filter",'>=%1',RetailJnlHeader."Date of creation");
        if Item.IsEmpty then
          exit(false);

        if RetailPriceLogEntry.IsEmpty then
          exit(false);

        RetailPriceLogEntry.SetCurrentKey("Item No.","Variant Code");
        RetailPriceLogEntry.FilterGroup(40);
        Item.FindSet;
        repeat
          RetailPriceLogEntry.SetRange("Item No.",Item."No.");
          RetailPriceLogEntry.SetFilter("Variant Code",Item.GetFilter("Variant Filter"));
          if RetailPriceLogEntry.FindFirst then begin
            TempItem.Init;
            TempItem := Item;
            TempItem.Insert;
          end;
        until Item.Next = 0;

        exit(TempItem.FindFirst);
    end;

    local procedure RunDynamicRequestPage(var Item: Record Item;var RetailPriceLogEntry: Record "Retail Price Log Entry"): Boolean
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
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
        FilterPageBuilder.AddTable(FilterName,DATABASE::Item);

        FilterName2 := GetTableName(DATABASE::"Retail Price Log Entry");
        FilterPageBuilder.AddTable(FilterName2,DATABASE::"Retail Price Log Entry");

        if GetQueryPriceLogView(FilterView,FilterView2) then begin
          Item.SetView(FilterView);
          FilterPageBuilder.SetView(FilterName,FilterView);

          RetailPriceLogEntry.SetView(FilterView2);
          FilterPageBuilder.SetView(FilterName2,FilterView2);
        end;

        FilterPageBuilder.AddRecord(FilterName,Item);
        FilterPageBuilder.ADdField(FilterName,Item."No.");
        FilterPageBuilder.ADdField(FilterName,Item."Last Date Modified");
        FilterPageBuilder.ADdField(FilterName,Item."Item Group");
        FilterPageBuilder.ADdField(FilterName,Item."Item Disc. Group");
        FilterPageBuilder.ADdField(FilterName,Item.Description);
        FilterPageBuilder.ADdField(FilterName,Item.Inventory);
        FilterPageBuilder.ADdField(FilterName,Item."Net Change");

        FilterPageBuilder.AddRecord(FilterName2,RetailPriceLogEntry);
        FilterPageBuilder.ADdField(FilterName2,RetailPriceLogEntry."Date and Time");
        FilterPageBuilder.ADdField(FilterName2,RetailPriceLogEntry."Table No.");

        if not FilterPageBuilder.RunModal then
          exit(false);

        SaveViewFromDynamicRequestPage(FilterPageBuilder);

        Item.SetView(FilterPageBuilder.GetView(FilterName,false));
        RetailPriceLogEntry.SetView(FilterPageBuilder.GetView(FilterName2,false));
        exit(true);
    end;

    local procedure GetTableName(TableID: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(TableID);
        exit(CopyStr(TableMetadata.Name,1,20));
    end;

    local procedure GetQueryPriceLogView(var FilterView: Text;var FilterView2: Text): Boolean
    var
        PageDataPersonalization: Record "Page Data Personalization";
        XMLDOMMgt: Codeunit "XML DOM Management";
        InStream: InStream;
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
    begin
        if not FindQueryPriceLogView(PageDataPersonalization) then
          exit(false);
        if not PageDataPersonalization.Value.HasValue then
          exit(false);

        PageDataPersonalization.CalcFields(Value);
        PageDataPersonalization.Value.CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);

        if not XMLDOMMgt.FindNode(XmlDoc.DocumentElement,'DataItems/DataItem[@name="' + GetTableName(DATABASE::Item) + '"]',XmlElement) then
          exit(false);
        FilterView := XmlElement.InnerText;

        if not XMLDOMMgt.FindNode(XmlDoc.DocumentElement,'DataItems/DataItem[@name="' + GetTableName(DATABASE::"Retail Price Log Entry") + '"]',XmlElement) then
          exit(false);
        FilterView2 := XmlElement.InnerText;

        exit(true);
    end;

    local procedure SaveViewFromDynamicRequestPage(var FilterPageBuilder: FilterPageBuilder): Text
    var
        PageDataPersonalization: Record "Page Data Personalization";
        User: Record User;
        XMLDOMMgt: Codeunit "XML DOM Management";
        DataItemXmlNode: DotNet XmlNode;
        DataItemsXmlNode: DotNet XmlNode;
        XmlDoc: DotNet XmlDocument;
        ReportParametersXmlNode: DotNet XmlNode;
        OutStream: OutStream;
    begin
        XmlDoc := XmlDoc.XmlDocument;

        XMLDOMMgt.AddRootElement(XmlDoc,'ReportParameters',ReportParametersXmlNode);
        XMLDOMMgt.AddDeclaration(XmlDoc,'1.0','utf-8','yes');

        XMLDOMMgt.AddElement(ReportParametersXmlNode,'DataItems','','',DataItemsXmlNode);

        XMLDOMMgt.AddElement(DataItemsXmlNode,'DataItem',FilterPageBuilder.GetView(GetTableName(DATABASE::Item),false),'',DataItemXmlNode);
        XMLDOMMgt.AddAttribute(DataItemXmlNode,'name',GetTableName(DATABASE::Item));

        XMLDOMMgt.AddElement(DataItemsXmlNode,'DataItem',FilterPageBuilder.GetView(GetTableName(DATABASE::"Retail Price Log Entry"),false),'',DataItemXmlNode);
        XMLDOMMgt.AddAttribute(DataItemXmlNode,'name',GetTableName(DATABASE::"Retail Price Log Entry"));

        if not FindQueryPriceLogView(PageDataPersonalization) then begin
          User.SetRange("User Name",UserId);
          if not User.FindFirst then
            exit;

          PageDataPersonalization.Init;
          PageDataPersonalization."User SID" := User."User Security ID";
          PageDataPersonalization."Object Type" := PageDataPersonalization."Object Type"::Page;
          PageDataPersonalization."Object ID" := PAGE::"Retail Journal Header";
          PageDataPersonalization.ValueName := QueryPriceLogViewName();
          PageDataPersonalization.Insert(true);
          Commit;
        end;

        Clear(PageDataPersonalization.Value);
        PageDataPersonalization.Value.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
        PageDataPersonalization.Modify(true);
        Commit;
    end;

    local procedure FindQueryPriceLogView(var PageDataPersonalization: Record "Page Data Personalization"): Boolean
    begin
        Clear(PageDataPersonalization);
        PageDataPersonalization.SetRange("User ID",UserId);
        PageDataPersonalization.SetRange("Object Type",PageDataPersonalization."Object Type"::Page);
        PageDataPersonalization.SetRange("Object ID",PAGE::"Retail Journal Header");
        PageDataPersonalization.SetRange(ValueName,QueryPriceLogViewName());
        exit(PageDataPersonalization.FindLast);
    end;

    local procedure QueryPriceLogViewName(): Code[40]
    begin
        exit('QUERY_RETAIL_PRICE_LOG');
    end;

    local procedure "--- Triggers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014475, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertRetailUnitPriceLogSetup(var Rec: Record "Retail Price Log Setup";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;

        if Rec."Price Log Activated" then
          EnablePriceLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6014475, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyRetailUnitPriceLogSetup(var Rec: Record "Retail Price Log Setup";var xRec: Record "Retail Price Log Setup";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;

        if Rec."Price Log Activated" then
          EnablePriceLog(Rec);
    end;
}

