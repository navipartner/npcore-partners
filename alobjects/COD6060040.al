codeunit 6060040 "Item Worksheet Management"
{
    // NPR4.18/BR  /20160209  CASE 182391 Object Created
    // NPR4.19/BR  /20160209  CASE 182391 Added Functions InitializeMissingRecords
    // NPR5.22/BR  /20160315  CASE 182391 Fixed Combining new Variety Values
    // NPR5.22/BR  /20160411  CASE 182391 Combine lines only for lines that have Varieties
    // NPR5.23/BR  /20160519  CASE 241985 Fixed text of Danish version of Text Constant Text1002
    // NPR5.25/BR  /20160707  CASE 246088 Set default field mapping, added function AddMappedFieldsToExcel
    // NPR5.26/BR  /20160908  CASE 251600 Fix clearing item group from setup
    // NPR5.28/BR  /20161028  CASE 256588 Do not create new lines with same values when combining
    // NPR5.28/BR  /20161123  CASE 259210 Performance tuning
    // NPR5.38/MHA /20180105  CASE 301053 Deleted unused variables
    // NPR5.38/NPKNAV/20180126  CASE 268786-04 Transport NPR5.38 - 26 January 2018
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Permissions = TableData "Gen. Journal Template"=imd,
                  TableData "Gen. Journal Batch"=imd;

    trigger OnRun()
    begin
        InitializeMissingSetup(6060042);
    end;

    var
        Text004: Label 'DEFAULT';
        Text005: Label 'Default Journal';
        OpenFromBatch: Boolean;
        Text1002: Label 'Checking lines        @1@@@@@@@@@@@';
        LineCount: Integer;
        Text1003: Label 'Updating Headers  @1@@@@@@@@@@@';
        TxtOverwriteGeneral: Label 'Would you like to overwrite the general settings with the default settings? ';

    procedure TemplateSelection(FormID: Integer;var ItemWorksheetLine: Record "Item Worksheet Line";var JnlSelected: Boolean)
    var
        ItemWorksheetTemplate: Record "Item Worksheet Template";
    begin
        JnlSelected := true;

        ItemWorksheetTemplate.Reset;

        case ItemWorksheetTemplate.Count of
          0:
            begin
              ItemWorksheetTemplate.Init;
              ItemWorksheetTemplate.Insert;
              Commit;
            end;
          1:
            ItemWorksheetTemplate.FindFirst;
          else
            JnlSelected := PAGE.RunModal(0,ItemWorksheetTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
          ItemWorksheetLine.FilterGroup := 2;
          ItemWorksheetLine.SetRange("Worksheet Template Name",ItemWorksheetTemplate.Name);
          ItemWorksheetLine.FilterGroup := 0;
          if OpenFromBatch then begin
            ItemWorksheetLine."Worksheet Template Name" := '';
            PAGE.Run(PAGE::"Item Worksheet Page",ItemWorksheetLine);
          end;
        end;
    end;

    procedure TemplateSelectionFromBatch(var ItemWorksheet: Record "Item Worksheet")
    var
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetTemplate: Record "Item Worksheet Template";
    begin
        OpenFromBatch := true;
        ItemWorksheetTemplate.Get(ItemWorksheet."Item Template Name");
        ItemWorksheet.TestField(Name);

        ItemWorksheetLine.FilterGroup := 2;
        ItemWorksheetLine.SetRange("Worksheet Template Name",ItemWorksheetTemplate.Name);
        ItemWorksheetLine.FilterGroup := 0;

        ItemWorksheetLine."Worksheet Template Name" := '';
        ItemWorksheetLine."Worksheet Name" := ItemWorksheet.Name;
        PAGE.Run(PAGE::"Item Worksheet Page",ItemWorksheetLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10];var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        CheckTemplateName(ItemWorksheetLine.GetRangeMax("Worksheet Template Name"),CurrentJnlBatchName);
        ItemWorksheetLine.FilterGroup := 2;
        ItemWorksheetLine.SetRange("Worksheet Name",CurrentJnlBatchName);
        ItemWorksheetLine.FilterGroup := 0;
    end;

    procedure OpenJnlBatch(var ItemWorksheet: Record "Item Worksheet")
    var
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheetLine: Record "Item Worksheet Line";
        JnlSelected: Boolean;
    begin
        if ItemWorksheet.GetFilter("Item Template Name") <> '' then
          exit;
        ItemWorksheet.FilterGroup(2);
        if ItemWorksheet.GetFilter("Item Template Name") <> '' then begin
          ItemWorksheet.FilterGroup(0);
          exit;
        end;
        ItemWorksheet.FilterGroup(0);

        if not ItemWorksheet.FindFirst then begin
          if not ItemWorksheetTemplate.FindFirst then
            TemplateSelection(0,ItemWorksheetLine,JnlSelected);
          if ItemWorksheetTemplate.FindFirst then
            CheckTemplateName(ItemWorksheetTemplate.Name,ItemWorksheet.Name);
        end;
        ItemWorksheet.FindFirst;
        JnlSelected := true;
        if ItemWorksheet.GetFilter("Item Template Name") <> '' then
           ItemWorksheetTemplate.SetRange(Name,ItemWorksheet.GetFilter("Item Template Name"));
        case ItemWorksheetTemplate.Count of
          1:
            ItemWorksheetTemplate.FindFirst;
          else
            JnlSelected := PAGE.RunModal(0,ItemWorksheetTemplate) = ACTION::LookupOK;
        end;
        if not JnlSelected then
          Error('');

        ItemWorksheet.FilterGroup(0);
        ItemWorksheet.SetRange("Item Template Name",ItemWorksheetTemplate.Name);
        ItemWorksheet.FilterGroup(2);
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10];var CurrentJnlName: Code[10])
    var
        ItemWorksheet: Record "Item Worksheet";
    begin
        ItemWorksheet.SetRange("Item Template Name",CurrentJnlTemplateName);
        if not ItemWorksheet.Get(CurrentJnlTemplateName,CurrentJnlName) then begin
          if not ItemWorksheet.FindFirst then begin
            ItemWorksheet.Init;
            ItemWorksheet."Item Template Name" := CurrentJnlTemplateName;
            ItemWorksheet.SetupNewBatch;
            ItemWorksheet.Name := Text004;
            ItemWorksheet.Description := Text005;
            ItemWorksheet.Insert(true);
            Commit;
          end;
          CurrentJnlName := ItemWorksheet.Name
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10];var ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheet: Record "Item Worksheet";
    begin
        ItemWorksheet.Get(ItemWorksheetLine.GetRangeMax("Worksheet Template Name"),CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10];var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        ItemWorksheetLine.FilterGroup := 2;
        ItemWorksheetLine.SetRange("Worksheet Name",CurrentJnlBatchName);
        ItemWorksheetLine.FilterGroup := 0;
        if ItemWorksheetLine.FindFirst then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10];var ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheet: Record "Item Worksheet";
    begin
        Commit;
        ItemWorksheet."Item Template Name" := ItemWorksheetLine.GetRangeMax("Worksheet Template Name");
        ItemWorksheet.Name := ItemWorksheetLine.GetRangeMax("Worksheet Name");
        ItemWorksheet.FilterGroup(2);
        ItemWorksheet.SetRange("Item Template Name",ItemWorksheet."Item Template Name");
        ItemWorksheet.FilterGroup(0);
        if PAGE.RunModal(0,ItemWorksheet) = ACTION::LookupOK then begin
          CurrentJnlBatchName := ItemWorksheet.Name;
          SetName(CurrentJnlBatchName,ItemWorksheetLine);
        end;
    end;

    procedure PrintItemWizLine(var NewItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetTemplate: Record "Item Worksheet Template";
    begin
        ItemWorksheetLine.Copy(NewItemWorksheetLine);
        ItemWorksheetLine.SetRange("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name",ItemWorksheetLine."Worksheet Name");
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        //ItemWorksheetTemplate.TESTFIELD("Test Report ID");
        //REPORT.RUN(ItemWorksheetTemplate."Test Report ID",TRUE,FALSE,ItemWorksheetLine);
    end;

    procedure OnCloseForm(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        if ItemWorksheetLine.IsEmpty then
          exit;
    end;

    procedure CheckItemGroupSetup(ItemGroupCode: Code[10])
    var
        ItemGroup: Record "Item Group";
    begin
        //-NPR5.26 [251600]
        //ItemGroup.GET(ItemGroupCode);
        if not ItemGroup.Get(ItemGroupCode) then
          exit;
        //+NPR5.26 [251600]
        ItemGroup.TestField("VAT Bus. Posting Group");
        ItemGroup.TestField("Gen. Prod. Posting Group");
        ItemGroup.TestField("VAT Prod. Posting Group");
        ItemGroup.TestField("Inventory Posting Group");
        ItemGroup.TestField(Blocked,false);
        ItemGroup.TestField("Main Item Group", false);
        ItemGroup.Get(ItemGroupCode);
    end;

    procedure CombineLines(ItemWorksheet: Record "Item Worksheet")
    var
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        NoOfRecords: Integer;
        Window: Dialog;
        CombineBy: Option All,ItemNo,VendorItemNo,VendorBarCode,InternalBarCode;
    begin
        ItemWorksheetLine.Reset;
        //-NPR5.38 [268786]
        //ItemWorksheetLine.SETRANGE("Worksheet Template Name",ItemWorksheet."Item Template Name");
        //ItemWorksheetLine.SETRANGE("Worksheet Name",ItemWorksheet.Name);
        ItemWorksheetLine.SetFilter("Worksheet Template Name",'=%1',ItemWorksheet."Item Template Name");
        ItemWorksheetLine.SetFilter("Worksheet Name",'=%1',ItemWorksheet.Name);
        //+NPR5.38 [268786]
        //-NPR5.22
        //IF ItemWorksheetLine.FINDSET THEN REPEAT
        LineCount := 0;
        NoOfRecords :=  ItemWorksheetLine.Count;
        if GuiAllowed then
          Window.Open(Text1002);
        if ItemWorksheetLine.FindSet then repeat
          LineCount := LineCount + 1;
          //-NPR5.23 [242498]
          if LineCount = 1 then begin
            ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
            CombineBy := ItemWorksheetTemplate."Combine Variants to Item by";
          end;
          //+NPR5.23 [242498]
          if GuiAllowed then
            Window.Update(1,Round(LineCount / NoOfRecords * 10000,1));
          if (ItemWorksheetLine."Variety 1" <> '') or (ItemWorksheetLine."Variety 2" <> '') or
             (ItemWorksheetLine."Variety 3" <> '') or (ItemWorksheetLine."Variety 4" <> '') or
             (ItemWorksheetLine."Variety Group" <> '') then
          //+NPR5.22
          CombineLine(ItemWorksheetLine,CombineBy);
        until ItemWorksheetLine.Next =0;
        //+NPR5.22
        if GuiAllowed then
          Window.Close;

        //-NPR5.28 [259210]
        Commit;
        if GuiAllowed then begin
          NoOfRecords :=  ItemWorksheetLine.Count;
          Window.Open(Text1003);
        end;
        LineCount := 0;
        if ItemWorksheetLine.FindSet then repeat
          LineCount := LineCount + 1;
          if GuiAllowed then
            Window.Update(1,Round(LineCount / NoOfRecords * 10000,1));
          ItemWorksheetLine.RefreshVariants(0,true);
        until ItemWorksheetLine.Next =0;
        if GuiAllowed then
          Window.Close;
        //+NPR5.28 [259210]
        //+NPR5.22
    end;

    procedure CombineLine(ItemWorksheetLine: Record "Item Worksheet Line";CombineBy: Option All,ItemNo,VendorItemNo,VendorBarCode,InternalBarCode)
    var
        ItemWorksheetLine2: Record "Item Worksheet Line";
        ItemVariantLine: Record "Item Worksheet Variant Line";
        ItemVariantLine2: Record "Item Worksheet Variant Line";
        VariantLineNo: Integer;
        ItemWorksheetVarietyValue: Record "Item Worksheet Variety Value";
        ItemWorksheetVarietyValue2: Record "Item Worksheet Variety Value";
        SkipVariant: Boolean;
    begin
        //Find Last Variant Line No from original line
        VariantLineNo := 0;
        ItemVariantLine.Reset;
        ItemVariantLine.SetRange("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        ItemVariantLine.SetRange("Worksheet Name",ItemWorksheetLine."Worksheet Name");
        ItemVariantLine.SetRange("Worksheet Line No.",ItemWorksheetLine."Line No.");
        if ItemVariantLine.FindSet then  repeat
          if ItemVariantLine."Direct Unit Cost" = ItemWorksheetLine."Direct Unit Cost" then
            if  ItemVariantLine."Direct Unit Cost" <> 0 then
              ItemVariantLine.Validate("Direct Unit Cost",0);
          if ItemVariantLine."Sales Price" = ItemWorksheetLine."Sales Price" then
            if  ItemVariantLine."Sales Price" <> 0 then
              ItemVariantLine.Validate("Sales Price",0);
          //-NPR5.38 [268786]
          //ItemVariantLine.MODIFY(TRUE);
          ItemVariantLine.Modify;
          //+NPR5.38 [268786]
          VariantLineNo :=  ItemVariantLine."Line No.";
        until ItemVariantLine.Next = 0;

        ItemWorksheetLine2.Reset;
        ItemWorksheetLine2.SetRange("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine2.SetRange("Worksheet Name",ItemWorksheetLine."Worksheet Name");
        ItemWorksheetLine2.SetFilter("Line No.",'<>%1',ItemWorksheetLine."Line No.");
        ItemWorksheetLine2.SetRange("Existing Item No.",ItemWorksheetLine."Existing Item No.");
        case CombineBy of
          CombineBy :: All :
            begin
              ItemWorksheetLine2.SetRange("Item No.",ItemWorksheetLine."Item No.");
              ItemWorksheetLine2.SetRange("Vendor Item No.",ItemWorksheetLine."Vendor Item No.");
              ItemWorksheetLine2.SetRange("Vendors Bar Code",ItemWorksheetLine."Vendors Bar Code");
              ItemWorksheetLine2.SetRange("Internal Bar Code",ItemWorksheetLine."Internal Bar Code");
            end;
          CombineBy :: ItemNo :
            ItemWorksheetLine2.SetRange("Item No.",ItemWorksheetLine."Item No.");
          CombineBy :: VendorItemNo :
            ItemWorksheetLine2.SetRange("Vendor Item No.",ItemWorksheetLine."Vendor Item No.");
          CombineBy :: VendorBarCode :
            ItemWorksheetLine2.SetRange("Vendors Bar Code",ItemWorksheetLine."Vendors Bar Code");
          CombineBy :: InternalBarCode :
            ItemWorksheetLine2.SetRange("Internal Bar Code",ItemWorksheetLine."Internal Bar Code");
        end;
        if ItemWorksheetLine2.FindSet then repeat
          //Found worksheet lines belonging to the same item
          //Copy Varaint into sub line
          ItemVariantLine2.Reset;
          ItemVariantLine2.SetRange("Worksheet Template Name",ItemWorksheetLine2."Worksheet Template Name");
          ItemVariantLine2.SetRange(ItemVariantLine2."Worksheet Name",ItemWorksheetLine2."Worksheet Name");
          ItemVariantLine2.SetRange("Worksheet Line No.",ItemWorksheetLine2."Line No.");
          if ItemVariantLine2.FindSet then repeat
             //Found worksheet variant lines belonging to those worksheet lines
             //-NPR5.28 [256588]
             ItemVariantLine.Reset;
             ItemVariantLine.SetRange("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
             ItemVariantLine.SetRange("Worksheet Name",ItemWorksheetLine."Worksheet Name");
             ItemVariantLine.SetRange("Worksheet Line No.",ItemWorksheetLine."Line No.");
             ItemVariantLine.SetRange("Variety 1 Value",ItemVariantLine2."Variety 1 Value");
             ItemVariantLine.SetRange("Variety 2 Value",ItemVariantLine2."Variety 2 Value");
             ItemVariantLine.SetRange("Variety 3 Value",ItemVariantLine2."Variety 3 Value");
             ItemVariantLine.SetRange("Variety 4 Value",ItemVariantLine2."Variety 4 Value");
             SkipVariant := not ItemVariantLine.IsEmpty;
             //+NPR5.28 [256588]
              VariantLineNo := VariantLineNo + 10000;
             ItemVariantLine.Reset;
             ItemVariantLine.Init;
             ItemVariantLine := ItemVariantLine2;
             ItemVariantLine."Worksheet Template Name" := ItemWorksheetLine."Worksheet Template Name";
             ItemVariantLine."Worksheet Name" := ItemWorksheetLine."Worksheet Name";
             ItemVariantLine."Worksheet Line No." := ItemWorksheetLine."Line No.";
             ItemVariantLine."Line No." := VariantLineNo;
             if ItemVariantLine."Sales Price" = 0 then
                ItemVariantLine."Sales Price" := ItemWorksheetLine2."Sales Price";
             if ItemVariantLine."Direct Unit Cost" = 0 then
                ItemVariantLine."Direct Unit Cost" := ItemWorksheetLine2."Direct Unit Cost";
             //-NPR5.38 [268786]
             //ItemVariantLine.INSERT(TRUE);
             ItemVariantLine.Insert;
             //+NPR5.38 [268786]
             if ItemVariantLine."Sales Price" <>  ItemWorksheetLine."Sales Price" then
               ItemVariantLine.Validate("Sales Price")
             else
               ItemVariantLine.Validate("Sales Price",0);
             if ItemVariantLine."Direct Unit Cost" <>  ItemWorksheetLine."Direct Unit Cost" then
               ItemVariantLine.Validate("Direct Unit Cost")
             else
               ItemVariantLine.Validate("Direct Unit Cost",0);
             //-NPR5.28 [256588]
             if SkipVariant then begin
               ItemVariantLine.Validate(Action,ItemVariantLine.Action::Skip);
             end;
             //+NPR5.28 [256588]
             //-NPR5.38 [268786]
             //ItemVariantLine.MODIFY(TRUE);
             ItemVariantLine.Modify;
             //+NPR5.38 [268786]
          until ItemVariantLine2.Next =0;
          //-NPR5.22
          //Move Variety Values
          ItemWorksheetVarietyValue2.Reset;
          ItemWorksheetVarietyValue2.SetRange("Worksheet Template Name",ItemWorksheetLine2."Worksheet Template Name");
          ItemWorksheetVarietyValue2.SetRange("Worksheet Name",ItemWorksheetLine2."Worksheet Name");
          ItemWorksheetVarietyValue2.SetRange("Worksheet Line No.",ItemWorksheetLine2."Line No.");
          if ItemWorksheetVarietyValue2.FindSet then repeat
             ItemWorksheetVarietyValue.Reset;
             ItemWorksheetVarietyValue.Init;
             ItemWorksheetVarietyValue := ItemWorksheetVarietyValue2;
             ItemWorksheetVarietyValue."Worksheet Template Name" := ItemWorksheetVarietyValue2."Worksheet Template Name";
             ItemWorksheetVarietyValue."Worksheet Name" := ItemWorksheetVarietyValue2."Worksheet Name";
             ItemWorksheetVarietyValue."Worksheet Line No." := ItemWorksheetLine."Line No.";
             ItemWorksheetVarietyValue.Type := ItemWorksheetVarietyValue2.Type;
             ItemWorksheetVarietyValue.Table := ItemWorksheetVarietyValue2.Table;
             ItemWorksheetVarietyValue.Value := ItemWorksheetVarietyValue2.Value;
             if ItemWorksheetVarietyValue.Insert then;
          until ItemWorksheetVarietyValue2.Next =0;
          //+NPR5.22
        until ItemWorksheetLine2.Next =0;
        //MESSAGE(STRSUBSTNO(Text007),ItemWorksheetLine2.COUNT);
        //-NPR5.22
        LineCount := LineCount + ItemWorksheetLine2.Count;
        //+NPR5.22
        ItemWorksheetLine2.DeleteAll(true);
        //-NPR5.28 [259210]
        //ItemWorksheetLine.RefreshVariants(0,TRUE);
        //+NPR5.28 [259210]
    end;

    procedure InitializeMissingSetup(TableNo: Integer)
    var
        MissingSetupTable: Record "Missing Setup Table";
        MissingSetupRecord: Record "Missing Setup Record";
        ObjectRecord: Record "Object";
        "Key": Record "Key";
        RecRef: RecordRef;
        RelatedRecRef: RecordRef;
        FieldRecord: Record "Field";
        FieldR: FieldRef;
        RelatedFieldRef: FieldRef;
        ValueFound: Boolean;
        I: Integer;
        MultipleFieldsinPrimaryKey: Boolean;
        AllObj: Record AllObj;
    begin
        //-NPR4.19
        MissingSetupTable.DeleteAll;
        MissingSetupRecord.DeleteAll;
        //-NPR5.46 [322752]
        // ObjectRecord.SETRANGE(Type,ObjectRecord.Type::Table);
        // ObjectRecord.SETRANGE(ID,TableNo);
        // IF ObjectRecord.FINDFIRST THEN BEGIN
         AllObj.SetRange("Object Type",AllObj."Object Type"::Table);
         AllObj.SetRange("Object ID",TableNo);
         if AllObj.FindFirst then begin
        //+NPR5.46 [322752]
          FieldRecord.Reset;
        //-NPR5.46 [322752]
        //  FieldRecord.SETRANGE(TableNo,ObjectRecord.ID);
          FieldRecord.SetRange(TableNo,AllObj."Object ID");
        //+NPR5.46 [322752]
          if FieldRecord.FindSet then repeat
            if FieldRecord.RelationTableNo <> 0 then begin
              //Fields with Relation to other Tables
              Key.Reset;
              Key.SetRange(TableNo,FieldRecord.RelationTableNo);
              Key.FindFirst;
              MultipleFieldsinPrimaryKey := (StrPos(Key.Key,',') > 0); // THEN BEGIN //Only tables with one field in primary key supported
              MissingSetupTable.Init;
        //-NPR5.46 [322752]
        //      MissingSetupTable."Table ID" := ObjectRecord.ID;
              MissingSetupTable."Table ID" := AllObj."Object ID";
        //+NPR5.46 [322752]
              MissingSetupTable."Field No." := FieldRecord."No.";
              MissingSetupTable."Related Table ID" :=  FieldRecord.RelationTableNo;
              MissingSetupTable."Related Field No." :=  FieldRecord.RelationFieldNo;
              MissingSetupTable."Create New"  := not MultipleFieldsinPrimaryKey;
              if MissingSetupTable.Insert then;

        //-NPR5.46 [322752]
        //      RecRef.OPEN(ObjectRecord.ID);
              RecRef.Open(AllObj."Object ID");
        //+NPR5.46 [322752]
              if RecRef.FindSet then repeat
                //Loop through all records in the table
                RelatedRecRef.Open(FieldRecord.RelationTableNo);
                FieldR := RecRef.Field(FieldRecord."No.");
                if Format(FieldR.Value) <> '' then begin
                  ValueFound := false;
                  if RelatedRecRef.FindFirst then begin
                    if FieldRecord.RelationFieldNo <> 0 then begin
                      RelatedFieldRef := RelatedRecRef.Field(FieldRecord.RelationFieldNo);
                    end else begin
                      I := 0;
                      repeat
                        I := I + 1;
                        RelatedFieldRef := RelatedRecRef.FieldIndex(I);
                      until (I = RelatedRecRef.FieldCount) or (Format(RelatedFieldRef.Name) = Key.Key);
                    end;
                    repeat
                      if RelatedFieldRef.Value = FieldR.Value then
                        ValueFound := true;
                    until ValueFound or (RelatedRecRef.Next = 0);
                  end;
                  if not  ValueFound then begin
                    MissingSetupRecord.Init;
                    MissingSetupRecord."Table ID" := MissingSetupTable."Table ID";
                    MissingSetupRecord."Field No." :=  FieldRecord."No.";
                    MissingSetupRecord."Related Table ID" :=  FieldRecord.RelationTableNo;
                    MissingSetupRecord."Related Field No." := RelatedFieldRef.Number;
                    MissingSetupRecord.Value := FieldR.Value;
                    if MissingSetupRecord.Insert then;
                  end;
                end;
                RelatedRecRef.Close;
              until RecRef.Next = 0;
              RecRef.Close;
            end;
          until FieldRecord.Next=0;
        end;
        //+NPR4.19
    end;

    procedure CreateMissingSetup()
    var
        MissingSetupTable: Record "Missing Setup Table";
        MissingSetupRecord: Record "Missing Setup Record";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        //-NPR4.19
        MissingSetupTable.Reset;
        MissingSetupTable.SetRange("Create New",true);
        if MissingSetupTable.FindSet then repeat
          MissingSetupRecord.Reset;
          MissingSetupRecord.SetRange("Table ID",MissingSetupTable."Table ID");
          MissingSetupRecord.SetRange("Field No.",MissingSetupTable."Field No.");
          MissingSetupRecord.SetRange("Create New",true);
          if MissingSetupRecord.FindSet then repeat
            RecRef.Open(MissingSetupTable."Related Table ID");
            FldRef := RecRef.Field(MissingSetupRecord."Related Field No.");
            FldRef.Value :=  MissingSetupRecord.Value;
            RecRef.Insert(true);
          until MissingSetupRecord.Next = 0;
        until MissingSetupTable.Next = 0;
        //+NPR4.19
    end;

    procedure SetDefaultFieldSetupLines(ItemWorksheetLine: Record "Item Worksheet Line";SetLevel: Option All,Template,Worksheet)
    var
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
    begin
        //-NPR5.25 [246088]
        case SetLevel of
          SetLevel :: All :
            begin
              ItemWorksheetFieldSetup.Reset;
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name",'=%1','');
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Name",'=%1','');
              if ItemWorksheetFieldSetup.IsEmpty then begin
                InsertInitialSetupLines(ItemWorksheetLine,0);
              end else begin
                if Confirm(TxtOverwriteGeneral) then begin
                  ItemWorksheetFieldSetup.DeleteAll;
                  InsertInitialSetupLines(ItemWorksheetLine,0);
                end;
              end;
            end;
          SetLevel :: Template :
            begin
              ItemWorksheetFieldSetup.Reset;
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name",'=%1','');
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Name",'=%1','');
              if ItemWorksheetFieldSetup.IsEmpty then
                InsertInitialSetupLines(ItemWorksheetLine,0);
              ItemWorksheetFieldSetup.Reset;
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name",'=%1',ItemWorksheetLine."Worksheet Template Name");
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Name",'=%1','');
              if ItemWorksheetFieldSetup.IsEmpty then begin
                CopySetupLines(ItemWorksheetLine,1);
              end;
            end;
          SetLevel :: Worksheet :
            begin
              ItemWorksheetFieldSetup.Reset;
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name",'=%1',ItemWorksheetLine."Worksheet Template Name");
              ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Name",'=%1',ItemWorksheetLine."Worksheet Name");
              if ItemWorksheetFieldSetup.IsEmpty then begin
                CopySetupLines(ItemWorksheetLine,2);
              end;
            end;
        end;
    end;

    procedure InsertInitialSetupLines(ItemWorksheetLine: Record "Item Worksheet Line";SetLevel: Option All,Template,Worksheet)
    var
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
        ItemRecRef: RecordRef;
        ItemFldRef: FieldRef;
        ItemWorksheetRecRef: RecordRef;
        ItemWorksheetFldRef: FieldRef;
        I: Integer;
        J: Integer;
    begin
        //-NPR5.25 [246088]
        ItemWorksheetRecRef.Open(DATABASE::"Item Worksheet Line");
        ItemRecRef.Open(DATABASE::Item);
        I := 0;
        repeat
          I := I + 1;
          ItemWorksheetFldRef := ItemWorksheetRecRef.FieldIndex(I);
          if ItemWorksheetFldRef.Active then begin
            case ItemWorksheetFldRef.Number of
              17: //Direct Unit Cost
                begin
                  ItemFldRef := ItemRecRef.Field(22);
                  if ItemFldRef.Active then
                    InsertDefaultFieldSetupLine(ItemWorksheetLine,SetLevel,ItemWorksheetFldRef,ItemFldRef);
                end;
              18: //Sales Price
                begin
                  ItemFldRef := ItemRecRef.Field(18);
                  if ItemFldRef.Active then
                    InsertDefaultFieldSetupLine(ItemWorksheetLine,SetLevel,ItemWorksheetFldRef,ItemFldRef);
                end;

              else  //other fields matched by name
                begin
                  J := 0;
                  repeat
                    J := J + 1;
                    ItemFldRef := ItemRecRef.FieldIndex(J);
                    if ItemFldRef.Name = ItemWorksheetFldRef.Name then begin
                      if ItemFldRef.Active then
                        InsertDefaultFieldSetupLine(ItemWorksheetLine,SetLevel,ItemWorksheetFldRef,ItemFldRef);
                    end;
                  until (J = ItemRecRef.FieldCount) or (ItemFldRef.Name = ItemRecRef.Name);
                end;
            end;
          end;
        until I = ItemWorksheetRecRef.FieldCount;
        ItemWorksheetFieldSetup.Reset;
        if SetLevel = SetLevel :: All then
           ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",'')
        else
           ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        if SetLevel  = SetLevel :: Worksheet then
          ItemWorksheetFieldSetup.SetFilter("Worksheet Name",ItemWorksheetLine."Worksheet Name")
        else
          ItemWorksheetFieldSetup.SetFilter("Worksheet Name",'');
        ItemWorksheetFieldSetup.SetRange("Target Table No. Update",DATABASE::Item);
        if ItemWorksheetFieldSetup.FindFirst then repeat
          if IsWarnAndIgnoreField(ItemWorksheetFieldSetup."Target Field Number Update") then begin
            ItemWorksheetFieldSetup.Validate("Process Update",ItemWorksheetFieldSetup."Process Update"::"Warn and Ignore");
            ItemWorksheetFieldSetup.Modify(true);
          end;
        until ItemWorksheetFieldSetup.Next = 0;
        //+NPR5.25 [246088]
    end;

    local procedure IsWarnAndIgnoreField(TargetFieldNumber: Integer): Boolean
    var
        Item: Record Item;
    begin
        //-NPR5.25 [246088]
        if TargetFieldNumber in [
          Item.FieldNo("Inventory Posting Group"),
          Item.FieldNo("Costing Method"),
          Item.FieldNo("Unit Cost"),
          Item.FieldNo("Gen. Prod. Posting Group"),
          Item.FieldNo("VAT Prod. Posting Group"),
          Item.FieldNo("Item Tracking Code"),
          Item.FieldNo("Variety 1"),
          Item.FieldNo("Variety 1 Table"),
          Item.FieldNo("Variety 2"),
          Item.FieldNo("Variety 2 Table"),
          Item.FieldNo("Variety 3"),
          Item.FieldNo("Variety 3 Table"),
          Item.FieldNo("Variety 4"),
          Item.FieldNo("Variety 4 Table"),
          Item.FieldNo("Cross Variety No."),
          Item.FieldNo("Variety Group"),
          Item.FieldNo("Indirect Cost %"),
          Item.FieldNo("No. Series"),
          Item.FieldNo(Reserve),
          Item.FieldNo("Item Group")] then
          exit(true)
        else
          exit(false);
         //+NPR5.25 [246088]
    end;

    procedure IsDoNotMapField(TableNumber: Integer;FieldNumber: Integer): Boolean
    var
        Item: Record Item;
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
    begin
        //-NPR5.25 [246088]
        case TableNumber of
          DATABASE :: Item :
            if FieldNumber in [
              Item.FieldNo("Item Group")] then
              exit(true)
            else
              exit(false);
          DATABASE :: "Item Worksheet Line" :
            if FieldNumber in [
              ItemWorksheetLine.FieldNo("Worksheet Template Name"),
              ItemWorksheetLine.FieldNo("Worksheet Name"),
              ItemWorksheetLine.FieldNo("Line No."),
              ItemWorksheetLine.FieldNo(Action),
              ItemWorksheetLine.FieldNo("Existing Item No."),
              ItemWorksheetLine.FieldNo("Currency Code"),
              ItemWorksheetLine.FieldNo("Use Variant"),
              ItemWorksheetLine.FieldNo("Base Unit of Measure"),
              ItemWorksheetLine.FieldNo("No. Series"),
              ItemWorksheetLine.FieldNo("Global Dimension 1 Code"),
              ItemWorksheetLine.FieldNo("Global Dimension 2 Code")] then
                exit(true)
              else
                exit(false);
          DATABASE :: "Item Worksheet Variant Line" :
            if FieldNumber in [
              ItemWorksheetVariantLine.FieldNo("Worksheet Template Name"),
              ItemWorksheetVariantLine.FieldNo("Worksheet Name"),
              ItemWorksheetVariantLine.FieldNo("Worksheet Line No."),
              ItemWorksheetVariantLine.FieldNo("Line No."),
              ItemWorksheetVariantLine.FieldNo(Level),
              ItemWorksheetVariantLine.FieldNo(Action),
              ItemWorksheetVariantLine.FieldNo("Item No."),
              ItemWorksheetVariantLine.FieldNo("Existing Item No."),
              ItemWorksheetVariantLine.FieldNo("Existing Variant Code"),
              ItemWorksheetVariantLine.FieldNo("Variant Code"),
              ItemWorksheetVariantLine.FieldNo("Heading Text")] then
                exit(true)
              else
                exit(false);
        end;
        exit(false);
         //+NPR5.25 [246088]
    end;

    procedure CreateLookupFilter(TableNumber: Integer) FilterText: Text
    var
        FieldRec: Record "Field";
    begin
        FilterText := '*';
        FieldRec.Reset;
        FieldRec.SetRange(FieldRec.TableNo,TableNumber);
        FieldRec.SetRange(Class,FieldRec.Class::Normal);
        if FieldRec.FindSet then repeat
          if IsDoNotMapField(TableNumber,FieldRec."No.") then
            if FilterText = '*' then
              FilterText := '<>' + Format(FieldRec."No.")
            else
              FilterText := FilterText + '&<>'+ Format(FieldRec."No.");
        until FieldRec.Next = 0;
    end;

    procedure CopySetupLines(ItemWorksheetLine: Record "Item Worksheet Line";SetLevel: Option All,Template,Worksheet)
    var
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
        NewItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
    begin
        //-NPR5.25 [246088]
        ItemWorksheetFieldSetup.Reset;
        if SetLevel = SetLevel :: Worksheet then
          ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name")
        else
          ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",'=%1','');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name",'=%1','');
        if ItemWorksheetFieldSetup.FindSet then repeat
          NewItemWorksheetFieldSetup := ItemWorksheetFieldSetup;
          NewItemWorksheetFieldSetup."Worksheet Template Name" := ItemWorksheetLine."Worksheet Template Name";
          if SetLevel = SetLevel :: Worksheet then
            NewItemWorksheetFieldSetup."Worksheet Name" := ItemWorksheetLine."Worksheet Name"
          else
            NewItemWorksheetFieldSetup."Worksheet Name" := '';
          NewItemWorksheetFieldSetup.Insert(true);
        until ItemWorksheetFieldSetup.Next = 0;
        //+NPR5.25 [246088]
    end;

    local procedure InsertDefaultFieldSetupLine(ItemWorksheetLine: Record "Item Worksheet Line";SetLevel: Option All,Template,Worksheet;SourceFldRef: FieldRef;TargetFldRef: FieldRef)
    var
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
    begin
        //-NPR5.25 [246088]
        ItemWorksheetFieldSetup.Reset;
        if SetLevel = SetLevel :: All then
           ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",'')
        else
           ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        if SetLevel  = SetLevel :: Worksheet then
          ItemWorksheetFieldSetup.SetFilter("Worksheet Name",ItemWorksheetLine."Worksheet Name")
        else
          ItemWorksheetFieldSetup.SetFilter("Worksheet Name",'');
        ItemWorksheetFieldSetup.SetRange("Table No.",DATABASE::"Item Worksheet Line");
        ItemWorksheetFieldSetup.SetRange("Field Number",SourceFldRef.Number);
        if not ItemWorksheetFieldSetup.FindFirst then begin
          if not IsDoNotMapField(DATABASE::Item,TargetFldRef.Number) then begin
            ItemWorksheetFieldSetup.Reset;
            ItemWorksheetFieldSetup.Init;
            if SetLevel = SetLevel :: All then
              ItemWorksheetFieldSetup.Validate("Worksheet Template Name",'')
            else
              ItemWorksheetFieldSetup.Validate("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
            if SetLevel  = SetLevel :: Worksheet then
              ItemWorksheetFieldSetup.Validate("Worksheet Name",ItemWorksheetLine."Worksheet Name")
            else
              ItemWorksheetFieldSetup.Validate("Worksheet Name",'');
            ItemWorksheetFieldSetup.Validate("Table No.",DATABASE::"Item Worksheet Line");
            ItemWorksheetFieldSetup.Validate("Field Number",SourceFldRef.Number);
            ItemWorksheetFieldSetup.Validate("Target Table No. Create",DATABASE::Item);
            ItemWorksheetFieldSetup.Validate("Target Field Number Create",TargetFldRef.Number);
            ItemWorksheetFieldSetup.Validate("Target Table No. Update",DATABASE::Item);
            ItemWorksheetFieldSetup.Validate("Target Field Number Update",TargetFldRef.Number);
            ItemWorksheetFieldSetup.Insert(true);
          end;
        end;
        //+NPR5.25 [246088]
    end;

    procedure AddMappedFieldsToExcel(ItemWorksheetTemplate: Code[10];ItemWorksheetName: Code[10])
    var
        ItemWorksheetExcelColumn: Record "Item Worksheet Excel Column";
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
        ExcelColumnNo: Integer;
    begin
        //-NPR5.25 [246088]
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name",ItemWorksheetTemplate);
        ItemWorksheetExcelColumn.SetRange("Worksheet Name",ItemWorksheetName);
        if ItemWorksheetExcelColumn.FindLast then
          ExcelColumnNo := ItemWorksheetExcelColumn."Excel Column No." + 1
        else
          ExcelColumnNo := 1;

        ItemWorksheetFieldSetup.Reset;
        ItemWorksheetFieldSetup.Reset;
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name",'%1|%2',ItemWorksheetTemplate,'');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name",'%1|%2',ItemWorksheetName,'');
        ItemWorksheetFieldSetup.SetRange(ItemWorksheetFieldSetup."Table No.",DATABASE::"Item Worksheet Line");
        if ItemWorksheetFieldSetup.FindSet then repeat
          //Find the setup on Template, Worksheet or General
          ItemWorksheetFieldSetup.SetRange("Field Number",ItemWorksheetFieldSetup."Field Number");
          ItemWorksheetFieldSetup.FindLast;
          ItemWorksheetFieldSetup.SetRange("Field Number");
          ItemWorksheetExcelColumn.Reset;
          ItemWorksheetExcelColumn.SetRange("Worksheet Template Name",ItemWorksheetTemplate);
          ItemWorksheetExcelColumn.SetRange("Worksheet Name",ItemWorksheetName);
          ItemWorksheetExcelColumn.SetRange("Map to Table No.",DATABASE::"Item Worksheet Line");
          ItemWorksheetExcelColumn.SetRange("Map to Field Number",ItemWorksheetFieldSetup."Field Number");
          if not ItemWorksheetExcelColumn.FindFirst then begin
            ItemWorksheetExcelColumn.Init;
            ItemWorksheetExcelColumn.Validate("Worksheet Template Name",ItemWorksheetTemplate);
            ItemWorksheetExcelColumn.Validate("Excel Column No.",ExcelColumnNo);
            ItemWorksheetExcelColumn.Validate("Worksheet Name",ItemWorksheetName);
            ItemWorksheetExcelColumn.Validate("Process as",ItemWorksheetExcelColumn."Process as"  :: Item);
            ItemWorksheetExcelColumn.Validate("Map to Table No.",DATABASE::"Item Worksheet Line");
            ItemWorksheetExcelColumn.Validate("Map to Field Number",ItemWorksheetFieldSetup."Field Number");
            ItemWorksheetExcelColumn.Insert(true);
            ExcelColumnNo := ExcelColumnNo + 1;
          end;
        until ItemWorksheetFieldSetup.Next =0 ;
        //+NPR5.25 [246088]
    end;
}

