table 6060043 "Item Worksheet Variant Line"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160215 CASE 182391 Fix for propagation from Header lines
    // NPR5.22\JDH\20160222 CASE 234022 Changed validateVariety
    // NPR5.22\BR\20160323  CASE 182391 Added field Recommended Retail Price
    // NPR5.22\BR\20160420 CASE 182391 Fixed overwriting description of an existing variant
    // NPR5.23\BR\20160525  CASE 242498 Added support to "Create Vendor  Barcodes"
    // NPR5.25\BR\20160804  CASE 246088 Delete related Item Worksheet Field Changes
    // NPR5.28\BR\20161123  CASE 259210 Performance tuning
    // NPR5.29\BR\20162128  CASE 262068 Fixed TableRelation Name and Line No.
    // NPR5.29\BR\20161229  CASE 262068 Moved barcode checks to validation
    // NPR5.34\BR\20170727  CASE 268786 Prevent errors with blank Variety values
    // NPR5.37/BR/20170922  CASE 268786 Made Variety Value Editable
    // NPR5.37/BR/20171013  CASE 268786 Adjustments to stop error with updating Variety Values form Item Worksheet Line
    // NPR5.38/BR/20171112  CASE 268786 Fix for item worksheet
    // NPR5.43/JKL /20180530 CASE 314287  added new function + applied it to mapping feature
    // NPR5.48/BHR /20190111 CASE 341967 remove blank space from options
    // NPR5.50/BHR/20190408 CASE 347513 Added code that will skip incorrect variety. Increase size of fields

    Caption = 'Item Worksheet Variant Line';

    fields
    {
        field(1;"Worksheet Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Item Worksheet Template";
        }
        field(2;"Worksheet Name";Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
            TableRelation = "Item Worksheet".Name WHERE ("Item Template Name"=FIELD("Worksheet Template Name"));
        }
        field(3;"Worksheet Line No.";Integer)
        {
            Caption = 'Worksheet Line No.';
            TableRelation = "Item Worksheet Line"."Line No." WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                    "Worksheet Name"=FIELD("Worksheet Name"));
        }
        field(6;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(7;Level;Integer)
        {
            Caption = 'Level';
        }
        field(8;"Action";Option)
        {
            Caption = 'Action';
            InitValue = Undefined;
            OptionCaption = 'Skip,CreateNew,Update,Undefined';
            OptionMembers = Skip,CreateNew,Update,Undefined;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                  //Propagate to lower lines
                  SetPropagationFilter;
                  if ItemWorksheetVariantLine2.FindSet then repeat
                    ItemWorksheetVariantLine2.Validate(Action,Action);
                    ItemWorksheetVariantLine2.Modify;
                  until ItemWorksheetVariantLine2.Next = 0;
                  //-NPR4.19
                  //Action := Action :: " ";
                  //-NPR4.19
                  UpdateAllRemarks;
                end else begin
                  case Action of
                    Action :: CreateNew :
                      if  "Existing Variant Code" <> '' then begin
                        "Internal Bar Code" := '';
                        "Vendors Bar Code" := '';
                        "Existing Variant Code" := '';
                      end;
                    Action :: Update  :
                      //-NPR5.38 [268786]
                      //TESTFIELD ("Existing Variant Code");
                      begin
                        if "Existing Item No." <> '' then
                          Validate("Existing Variant Code",GetExistingVariantCode);
                        TestField ("Existing Variant Code");
                      end;
                      //+NPR5.38 [268786]
                  end;
                  if Action <> Action::Skip then begin
                    Validate("Variety 1 Value");
                    Validate("Variety 2 Value");
                    Validate("Variety 3 Value");
                    Validate("Variety 4 Value");
                  end;
                end;
            end;
        }
        field(9;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(15;"Existing Item No.";Code[20])
        {
            Caption = 'Existing Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                //To be implemented
                //IF NOT Create AND xRec.Create THEN
                //  IF NOT CheckIfDeleteIsOK() THEN
                //    ERROR(Text001, FIELDCAPTION(Create), Create);
                Validate("Existing Variant Code",GetExistingVariantCode);
            end;
        }
        field(16;"Existing Variant Code";Code[10])
        {
            Caption = 'Existing Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Existing Item No."));

            trigger OnValidate()
            begin
                if "Existing Variant Code" <> xRec."Existing Variant Code" then begin
                  if ItemVariant.Get("Existing Item No.","Existing Variant Code") then begin
                    CalcFields("Existing Variant Blocked");
                    Blocked := "Existing Variant Blocked";
                    Description := ItemVariant.Description;
                    GetLine;
                    "Sales Price" := GetExistingVariantPrice;
                    if "Sales Price" = ItemWorksheetLine."Sales Price" then
                       "Sales Price" := 0;
                    "Direct Unit Cost" := GetExistingVariantCost;
                    if "Direct Unit Cost" = ItemWorksheetLine."Direct Unit Cost" then
                       "Direct Unit Cost" := 0;
                  end;
                end;
            end;
        }
        field(21;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';

            trigger OnValidate()
            begin
                UpdateExistingItemAndVaraint;
            end;
        }
        field(22;"Internal Bar Code";Text[30])
        {
            Caption = 'Internal Bar Code';

            trigger OnValidate()
            begin
                //-NPR5.29 [262068]
                //ItemNumberManagement.CheckInternalBarCode("Internal Bar Code");
                //+NPR5.29 [262068]
                if "Heading Text" <> '' then begin
                  //Propagate to lower lines
                  SetPropagationFilter;
                  if ItemWorksheetVariantLine2.FindSet then repeat
                    ItemWorksheetVariantLine2.Validate("Internal Bar Code","Internal Bar Code");
                    ItemWorksheetVariantLine2.Modify;
                  until ItemWorksheetVariantLine2.Next = 0;
                  //-NPR4.19
                  //"Internal Bar Code" := '';
                  //+NPR4.19
                  UpdateAllRemarks;
                end else begin
                  UpdateExistingItemAndVaraint;
                end;
            end;
        }
        field(23;"Sales Price";Decimal)
        {
            Caption = 'Sales Price';

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                  //Propagate to lower lines
                  SetPropagationFilter;
                  if ItemWorksheetVariantLine2.FindSet then repeat
                    ItemWorksheetVariantLine2.Validate("Sales Price","Sales Price");
                    ItemWorksheetVariantLine2.Modify;
                  until ItemWorksheetVariantLine2.Next = 0;
                  //-NPR4.19
                  //"Sales Price" := 0;
                  //+NPR4.19
                  UpdateAllRemarks;
                end else begin
                  UpdateExistingItemAndVaraint;
                end;
            end;
        }
        field(24;"Direct Unit Cost";Decimal)
        {
            Caption = 'Direct Unit Cost';

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                  //Propagate to lower lines
                  SetPropagationFilter;
                  if ItemWorksheetVariantLine2.FindSet then repeat
                    ItemWorksheetVariantLine2.Validate("Direct Unit Cost","Direct Unit Cost");
                    ItemWorksheetVariantLine2.Modify;
                  until ItemWorksheetVariantLine2.Next = 0;
                  //-NPR4.19
                  //"Direct Unit Cost" := 0;
                  //+NPR4.19
                  UpdateAllRemarks;
                end else begin
                  UpdateExistingItemAndVaraint;
                end;
            end;
        }
        field(35;"Vendors Bar Code";Code[20])
        {
            Caption = 'Vendors Bar Code';

            trigger OnValidate()
            begin
                //-NPR5.29 [262068]
                //ItemNumberManagement.CheckExternalBarCode("Vendors Bar Code");
                //+NPR5.29 [262068]
            end;
        }
        field(160;"Heading Text";Text[50])
        {
            Caption = 'Heading Text';
            Editable = false;
        }
        field(170;"Existing Variant Blocked";Boolean)
        {
            CalcFormula = Lookup("Item Variant".Blocked WHERE ("Item No."=FIELD("Existing Item No."),
                                                               Code=FIELD("Existing Variant Code")));
            Caption = 'Existing Variant Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(190;Blocked;Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                  //Propagate to lower lines
                  SetPropagationFilter;
                  if ItemWorksheetVariantLine2.FindSet then repeat
                    ItemWorksheetVariantLine2.Blocked := Blocked;
                    ItemWorksheetVariantLine2.Modify;
                  until ItemWorksheetVariantLine2.Next = 0;
                  //-NPR4.19
                  //Blocked := FALSE;
                  //+NPR4.19
                  UpdateAllRemarks;
                end else begin
                  UpdateExistingItemAndVaraint;
                end;
            end;
        }
        field(260;"Recommended Retail Price";Decimal)
        {
            Caption = 'Recommended Retail Price';
        }
        field(6059980;"Variety 1";Code[10])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 1" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name"=FIELD("Worksheet Name"),
                                                                          "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 1';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059981;"Variety 1 Table";Code[40])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 1 Table (New)" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name"=FIELD("Worksheet Name"),
                                                                                      "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 1 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059982;"Variety 1 Value";Code[50])
        {
            Caption = 'Variety 1 Value';
            Description = 'VRT1.00';
            Editable = true;
            TableRelation = "Item Worksheet Variety Value".Value WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                        "Worksheet Name"=FIELD("Worksheet Name"),
                                                                        "Worksheet Line No."=FIELD("Worksheet Line No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                //-NPR4.19
                if "Heading Text" <> '' then begin
                  //Propagate to lower lines
                  SetPropagationFilter;
                  ItemWorksheetVariantLine2.SetCurrentKey("Worksheet Template Name","Worksheet Name","Worksheet Line No.","Line No.");
                  ItemWorksheetVariantLine2.SetRange("Variety 1 Value",xRec."Variety 1 Value");
                  if ItemWorksheetVariantLine2.FindSet then repeat
                    ItemWorksheetVariantLine2.Validate("Variety 1 Value","Variety 1 Value");
                    ItemWorksheetVariantLine2.Modify;
                  until ItemWorksheetVariantLine2.Next = 0;
                  UpdateAllRemarks;
                end else begin
                //+NPR4.19
                  if "Variety 1 Value" <> '' then begin
                    CalcFields("Variety 1 Table","Variety 1");
                    //-NPR5.37 [268786]
                    //ValidateVarietyValue(1,"Variety 1","Variety 1 Table","Variety 1 Value");
                    ValidateVarietyValue(1,"Variety 1","Variety 1 Table","Variety 1 Value",xRec."Variety 1 Value");
                    //+NPR5.37 [268786]
                  end;
                //-NPR4.19
                end;
                //+NPR4.19
            end;
        }
        field(6059983;"Variety 2";Code[10])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 2" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name"=FIELD("Worksheet Name"),
                                                                          "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 2';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059984;"Variety 2 Table";Code[40])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 2 Table (New)" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name"=FIELD("Worksheet Name"),
                                                                                      "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 2 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059985;"Variety 2 Value";Code[50])
        {
            Caption = 'Variety 2 Value';
            Description = 'VRT1.00';
            Editable = true;
            TableRelation = "Item Worksheet Variety Value".Value WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                        "Worksheet Name"=FIELD("Worksheet Name"),
                                                                        "Worksheet Line No."=FIELD("Worksheet Line No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Variety 2 Value" <> '' then begin
                  CalcFields("Variety 2 Table","Variety 2");
                  //-NPR5.37 [268786]
                  //ValidateVarietyValue(2,"Variety 2","Variety 2 Table","Variety 2 Value");
                  ValidateVarietyValue(2,"Variety 2","Variety 2 Table","Variety 2 Value",xRec."Variety 2 Value");
                  //+NPR5.37 [268786]
                end;
            end;
        }
        field(6059986;"Variety 3";Code[10])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 3" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name"=FIELD("Worksheet Name"),
                                                                          "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 3';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059987;"Variety 3 Table";Code[40])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 3 Table (New)" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name"=FIELD("Worksheet Name"),
                                                                                      "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 3 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059988;"Variety 3 Value";Code[50])
        {
            Caption = 'Variety 3 Value';
            Description = 'VRT1.00';
            Editable = true;
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            var
                VarValue: Code[20];
            begin
                CalcFields("Variety 3","Variety 3 Table");
                VarValue := "Variety 3 Value";
                //LookupVarValue("Variety 3","Variety 3 Table",VarValue);
                if VarValue <> "Variety 3 Value" then
                  Validate("Variety 3 Value",VarValue);
            end;

            trigger OnValidate()
            begin
                if "Variety 3 Value" <> '' then begin
                  CalcFields("Variety 3 Table","Variety 3");
                  //-NPR5.37 [268786]
                  //ValidateVarietyValue(3,"Variety 3","Variety 3 Table","Variety 3 Value");
                  ValidateVarietyValue(3,"Variety 3","Variety 3 Table","Variety 3 Value",xRec."Variety 3 Value");
                  //+NPR5.37 [268786]
                end;
            end;
        }
        field(6059989;"Variety 4";Code[10])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 4" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name"=FIELD("Worksheet Name"),
                                                                          "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 4';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059990;"Variety 4 Table";Code[40])
        {
            CalcFormula = Lookup("Item Worksheet Line"."Variety 4 Table (New)" WHERE ("Worksheet Template Name"=FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name"=FIELD("Worksheet Name"),
                                                                                      "Line No."=FIELD("Worksheet Line No.")));
            Caption = 'Variety 4 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059991;"Variety 4 Value";Code[50])
        {
            Caption = 'Variety 4 Value';
            Description = 'VRT1.00';
            Editable = true;
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            var
                VarValue: Code[20];
            begin
                CalcFields("Variety 4","Variety 4 Table");
                VarValue := "Variety 4 Value";
                //LookupVarValue("Variety 4","Variety 4 Table",VarValue);
                if VarValue <> "Variety 4 Value" then
                  Validate("Variety 4 Value",VarValue);
            end;

            trigger OnValidate()
            begin
                if "Variety 4 Value" <> '' then begin
                  CalcFields("Variety 4 Table","Variety 4");
                  //-NPR5.37 [268786]
                  //ValidateVarietyValue(4,"Variety 4","Variety 4 Table","Variety 4 Value");
                  ValidateVarietyValue(4,"Variety 3","Variety 4 Table","Variety 4 Value",xRec."Variety 4 Value");
                  //+NPR5.37 [268786]
                end;
            end;
        }
    }

    keys
    {
        key(Key1;"Worksheet Template Name","Worksheet Name","Worksheet Line No.","Line No.")
        {
        }
        key(Key2;"Worksheet Template Name","Worksheet Name","Worksheet Line No.","Variety 1 Value","Variety 2 Value","Variety 3 Value","Variety 4 Value")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemWorksheetFieldChange: Record "Item Worksheet Field Change";
    begin
        //TESTFIELD("Variant Code", '');
        if "Variant Code" <> '' then begin
          //the variant is created. test if
        end;

        //-NPR5.25 [246088]
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name","Worksheet Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name","Worksheet Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Line No.","Worksheet Line No.");
        ItemWorksheetFieldChange.SetRange("Worksheet Variant Line No.","Line No.");
        ItemWorksheetFieldChange.DeleteAll;
        //+NPR5.25 [246088]
    end;

    trigger OnInsert()
    begin
        UpdateLevel;
    end;

    trigger OnModify()
    begin
        UpdateLevel;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        Currency: Record Currency;
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheet: Record "Item Worksheet";
        ItemWorksheetLine: Record "Item Worksheet Line";
        Text001: Label 'You cannot put %1 to %2 because it has already been used';
        Text002: Label '%1 is not part of predefined variety set %2 %3. Do you still want to add it? Adding it will make a copy of variety table %3.';
        ItemWorksheetVariantLine2: Record "Item Worksheet Variant Line";
        Text003: Label 'Variety %1 Value %2 will be added to table copy.';
        Text004: Label 'Variety %1 Value %2 will be added to unlocked table.';
        ItemVariant: Record "Item Variant";
        VarietySetup: Record "Variety Setup";
        ItemNumberManagement: Codeunit "Item Number Management";
        Text005: Label 'Would you like to change all instances of this Variety Value to this value in this line?';
        Text006: Label 'Would you like to map the value >%1< to >%2< for all variety %3 table %4?';
        Text007: Label 'Value >%1< is mapped to value >%2< already. Would you like to reomve this mapping?';
        Text008: Label 'Would you like to apply the new mapping to all other lines in this Item Worksheet?';
        UpdateFromWorksheetLine: Boolean;
        StatusCommentText: Text;

    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
    end;

    procedure GetBatch()
    begin
        if (ItemWorksheet."Item Template Name" <> "Worksheet Template Name") or
           (ItemWorksheet.Name <> "Worksheet Name") then begin
          ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");

          if ItemWorksheet."Currency Code" = '' then
            Currency.InitRoundingPrecision
          else begin
            Currency.Get(ItemWorksheet."Currency Code");
            Currency.TestField("Amount Rounding Precision");
          end;
        end;
    end;

    procedure GetLine()
    begin
        //-NPR4.19
        if  "Worksheet Line No." = 0 then
          ItemWorksheetLine.Init
        else
        //+NPR4.19
        if ("Worksheet Template Name" <> ItemWorksheetLine."Worksheet Template Name") or
           ("Worksheet Name" <> ItemWorksheetLine."Worksheet Name") or
           ("Worksheet Line No." <> ItemWorksheetLine."Line No.") then
          ItemWorksheetLine.Get("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.");
    end;

    procedure SetLine(ItemWorksheetLineParm: Record "Item Worksheet Line")
    begin
        ItemWorksheetLine := ItemWorksheetLineParm;
    end;

    procedure CheckIfDeleteIsOK(): Boolean
    var
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        //Variant is not created yet. Delete is ok
        if "Variant Code" = '' then
          exit(true);

        if "Item No." = '' then
          exit(true);

        //Check if variant is used

        ItemLedgEntry.SetCurrentKey("Item No.",Open,"Variant Code");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
        if not ItemLedgEntry.IsEmpty then
          exit(false);

        PurchLine.SetCurrentKey(Type, "No.", "Variant Code");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", "Item No.");
        PurchLine.SetRange("Variant Code", "Variant Code");
        if not PurchLine.IsEmpty then
          exit(false);


        //variant is created, but not used yet
        exit(true);
    end;

    procedure GetUnitCost(): Decimal
    begin
        if "Direct Unit Cost" <> 0 then
          exit("Direct Unit Cost");

        GetLine;
        exit(ItemWorksheetLine."Direct Unit Cost");
    end;

    procedure GetUnitPrice(): Decimal
    begin
        if "Sales Price" <> 0 then
          exit("Sales Price");

        GetLine;
        exit(ItemWorksheetLine."Sales Price");
    end;

    local procedure GetExistingVariantPrice(): Decimal
    var
        SalesPrice: Record "Sales Price";
    begin
        SalesPrice.Reset;
        SalesPrice.SetRange("Item No.","Existing Item No.");
        SalesPrice.SetRange("Variant Code","Existing Variant Code");
        SalesPrice.SetRange("Sales Type",SalesPrice."Sales Type"::"All Customers");
        if SalesPrice.FindFirst then
          exit(SalesPrice."Unit Price")
        else
          exit(0);
    end;

    local procedure GetExistingVariantCost(): Decimal
    var
        PurchasePrice: Record "Purchase Price";
    begin
        PurchasePrice.Reset;
        PurchasePrice.SetRange("Item No.","Existing Item No.");
        PurchasePrice.SetRange("Variant Code","Existing Variant Code");
        PurchasePrice.SetRange("Vendor No.",ItemWorksheetLine."Vendor No.");
        if PurchasePrice.FindFirst then
          exit(PurchasePrice."Direct Unit Cost")
        else
          exit(0);
    end;

    procedure UpdateExistingItemAndVaraint()
    begin
        //TO BE IMPLEMENTED
    end;

    local procedure ValidateVarietyValue(VrtNo: Integer;VrtType: Code[10];VrtTable: Code[20];VrtValue: Code[20];OldVrtValue: Code[20])
    var
        NewCode: Code[20];
        VarietyGroup: Record "Variety Group";
        CopySetup: Integer;
        ItemWorksheetVarValue: Record "Item Worksheet Variety Value";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        VarietyValue: Record "Variety Value";
        I: Integer;
        AddCommentText: Text;
        NewVarExists: Boolean;
    begin
        GetLine();
        //-NPR5.37 [268786]
        ApplyVarietyMapping;
        //+NPR5.37 [268786]
        if Action  <> Action::Skip then begin
          //-NPR5.34 [268786]
          if (VrtTable <> '') and (VrtValue <> '') then begin
          //+NPR5.34 [268786]
            //-NPR5.38 [268786]
            //IF NOT ItemWorksheetVarValue.GET("Worksheet Template Name","Worksheet Name","Worksheet Line No.",VrtType,VrtTable,VrtValue) THEN BEGIN
            NewVarExists := ItemWorksheetVarValue.Get("Worksheet Template Name","Worksheet Name","Worksheet Line No.",VrtType,VrtTable,VrtValue);
            ///+NPR5.38 [268786]
              //-NPR5.37 [268786]
              if ItemWorksheetVarValue.Get("Worksheet Template Name","Worksheet Name","Worksheet Line No.",VrtType,VrtTable,OldVrtValue) then begin
                //-NPR5.38 [268786]
                if (VrtValue <> OldVrtValue) then begin
                //+NPR5.38 [268786]
                  if Confirm(Text005) then begin
                    //-NPR5.38 [268786]
                    //ItemWorksheetVarValue.RENAME("Worksheet Template Name","Worksheet Name","Worksheet Line No.",VrtType,VrtTable,VrtValue);
                    //+NPR5.38 [268786]
                    ItemWorksheetVariantLine.SetRange("Worksheet Template Name",ItemWorksheetVarValue."Worksheet Template Name");
                    ItemWorksheetVariantLine.SetRange("Worksheet Name",ItemWorksheetVarValue."Worksheet Name");
                    ItemWorksheetVariantLine.SetRange("Worksheet Line No.",ItemWorksheetVarValue."Worksheet Line No.");
                    I :=0;
                    repeat
                      I := I + 1;
                      case I of
                        1 :
                          begin
                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 1",ItemWorksheetVarValue.Type);
                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 1 Table",ItemWorksheetVarValue.Table);
                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 1 Value",OldVrtValue);
                          end;
                        2 :
                          begin
                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 2",ItemWorksheetVarValue.Type);
                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 2 Table",ItemWorksheetVarValue.Table);
                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 2 Value",OldVrtValue);
                          end;
                      3:
                        begin
                          ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 3",ItemWorksheetVarValue.Type);
                          ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 3 Table",ItemWorksheetVarValue.Table);
                          ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 3 Value",OldVrtValue);
                        end;
                      4 :
                        begin
                          ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 4",ItemWorksheetVarValue.Type);
                          ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 4 Table",ItemWorksheetVarValue.Table);
                          ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 4 Value",OldVrtValue);
                        end;
                      end;
                      if ItemWorksheetVariantLine.FindFirst then repeat
                        case I of
                          1: ItemWorksheetVariantLine."Variety 1 Value" := VrtValue;
                          2: ItemWorksheetVariantLine."Variety 2 Value" := VrtValue;
                          3: ItemWorksheetVariantLine."Variety 3 Value" := VrtValue;
                          4: ItemWorksheetVariantLine."Variety 4 Value" := VrtValue;
                        end;
                        ItemWorksheetVariantLine.Modify;
                      until  ItemWorksheetVariantLine.Next = 0;
                    until  I = 4;
                    //-NPR5.38 [268786]
                    if NewVarExists then
                      ItemWorksheetVarValue.Delete
                    else
                      ItemWorksheetVarValue.Rename("Worksheet Template Name","Worksheet Name","Worksheet Line No.",VrtType,VrtTable,VrtValue);
                    //+NPR5.38 [268786]
                  end;
                //-NPR5.38 [268786]
                end;
                //+NPR5.38 [268786]
              end;
              if (ItemWorksheetLine."Vendor No." <> '') and (OldVrtValue <> '') and (OldVrtValue <> VrtValue) then begin
                if Confirm(StrSubstNo(Text006,OldVrtValue,VrtValue,VrtType,VrtTable)) then begin
                  CreateVarietyMapping(VrtType,VrtTable,'','',ItemWorksheetLine."Vendor No.",OldVrtValue,VrtValue);
                  if Confirm(Text008) then begin
                    ItemWorksheetVariantLine.Reset;
                    ItemWorksheetVariantLine.SetRange("Worksheet Template Name","Worksheet Template Name");
                    ItemWorksheetVariantLine.SetRange("Worksheet Name","Worksheet Name");
                    //-NPR5.38 [268786]
                    ItemWorksheetVariantLine.SetFilter("Worksheet Line No.",'<>%1',ItemWorksheetVarValue."Worksheet Line No.");
                    //+NPR5.38 [268786]
                    if ItemWorksheetVariantLine.FindSet then repeat
                      if ItemWorksheetVariantLine.ApplyVarietyMapping then
                        ItemWorksheetVariantLine.Modify(true);
                    until ItemWorksheetVariantLine.Next = 0;
                  end;
                end;
              end else begin
              //-NPR5.38 [268786]
              if not NewVarExists then begin
              //+NPR5.38 [268786]
              //+NPR5.37 [268786]
              //-NPR5.22
              //IF ItemWorksheetLine.IsCopyVariety(VrtNo) OR (NOT ItemWorksheetLine.IsLockedVariety(VrtNo)) THEN BEGIN
              //+NPR5.22
                //Insert in the new value in Worksheet Value table
                  ItemWorksheetVarValue.Init;
                  ItemWorksheetVarValue.Validate("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
                  ItemWorksheetVarValue.Validate("Worksheet Name",ItemWorksheetLine."Worksheet Name");
                  ItemWorksheetVarValue.Validate("Worksheet Line No.",ItemWorksheetLine."Line No.");
                  ItemWorksheetVarValue.Validate(Type,VrtType);
                  ItemWorksheetVarValue.Validate(Table,VrtTable);
                  ItemWorksheetVarValue.Validate(Value,VrtValue);
                  ItemWorksheetVarValue.Insert(true);
                //-NPR5.37 [268786]
                end;
                //+NPR5.37 [268786]
                //-NPR5.22
                if not VarietyValue.Get(VrtType, VrtTable, VrtValue) and (StrLen(ItemWorksheetLine."Status Comment") < 247) then begin
                //+NPR5.22
                  //Make a comment on the Worksheet Line
                  //-NPR5.37 [268786]
                  if ItemWorksheetLine.IsCopyVariety(VrtNo) then
                    AddCommentText := StrSubstNo(Text003,VrtType,VrtValue)
                  else
                    AddCommentText := StrSubstNo(Text004,VrtType,VrtValue);
                  if UpdateFromWorksheetLine then begin
                    if StatusCommentText = '' then
                      StatusCommentText := ItemWorksheetLine."Status Comment";
                    if StatusCommentText <> '' then
                      StatusCommentText := StatusCommentText + ' - ';
                    StatusCommentText := StatusCommentText + AddCommentText;
                  end else begin
                    if ItemWorksheetLine."Status Comment" <> '' then
                      ItemWorksheetLine."Status Comment" := ItemWorksheetLine."Status Comment" + ' - ';
                    ItemWorksheetLine."Status Comment" := CopyStr(ItemWorksheetLine."Status Comment" + AddCommentText,1,MaxStrLen(ItemWorksheetLine."Status Comment"));
                    ItemWorksheetLine.Modify(true);
                  end;
                //IF ItemWorksheetLine."Status Comment" <> '' THEN
                //  ItemWorksheetLine."Status Comment" := ItemWorksheetLine."Status Comment" + ' - ';
                //IF ItemWorksheetLine.IsCopyVariety(VrtNo) THEN
                //  ItemWorksheetLine."Status Comment" := COPYSTR(ItemWorksheetLine."Status Comment" + STRSUBSTNO(Text003,VrtType,VrtValue),1,MAXSTRLEN(ItemWorksheetLine."Status Comment"))
                //ELSE
                //  ItemWorksheetLine."Status Comment" := COPYSTR(ItemWorksheetLine."Status Comment" + STRSUBSTNO(Text004,VrtType,VrtValue),1,MAXSTRLEN(ItemWorksheetLine."Status Comment"));
                //ItemWorksheetLine.MODIFY(TRUE);
                //+NPR5.37 [268786]
                //-NPR5.38 [268786]
                end;
               //+NPR5.38 [268786]
              end;
            //-NPR5.38 [268786]
            if GetExistingVariantCode <> "Variant Code" then
              Validate("Existing Variant Code",GetExistingVariantCode);
            //+NPR5.38 [268786]
          //-NPR5.34 [268786]
          end;
          //+NPR5.34 [268786]
        end;


          //IF NOT CONFIRM(STRSUBSTNO(Text002,VrtValue,VrtType,VrtTable)) THEN
          //  ERROR('');
          //NewCode := VrtTable + '-<NEWITEMNO>';
          //IF ItemWorksheetLine."Variety Group" <> '' THEN BEGIN
          //  VarietyGroup.GET(ItemWorksheetLine."Variety Group");
          //  CASE VrtNo OF
          //    1: CopySetup := VarietyGroup."Copy Naming Variety 1";
          //    2: CopySetup := VarietyGroup."Copy Naming Variety 2";
          //    3: CopySetup := VarietyGroup."Copy Naming Variety 3";
          //    4: CopySetup := VarietyGroup."Copy Naming Variety 4";
          //    ELSE
          //      ERROR('');
          //  END;
          //  CASE CopySetup OF
          //    0,1:; //0 is default option without a setup and 1 is Table + ItemNo so leave as it is
          //    2: //Table + NoSeries
          //      NewCode := VrtTable + '-<NEWNOSERIES>';
          //  END;
          //END;
    end;

    local procedure UpdateLevel()
    begin
        //-NPR5.28 [259210]
        // GetBatch;
        // CASE ItemWorksheet."Show Variety Level" OF
        //  ItemWorksheet."Show Variety Level" :: "Variety 1" :
        //    IF "Variety 4 Value" <> '' THEN
        //      Level := 3
        //    ELSE
        //      IF "Variety 3 Value" <> '' THEN
        //        Level := 2
        //      ELSE
        //        IF "Variety 2 Value" <> '' THEN
        //          Level := 1
        //        ELSE
        //          Level := 0;
        //  ItemWorksheet."Show Variety Level" :: "Variety 1+2" :
        //    IF "Variety 4 Value" <> '' THEN
        //      Level := 2
        //    ELSE
        //      IF "Variety 3 Value" <> '' THEN
        //        Level := 1
        //      ELSE
        //        Level := 0;
        //  ItemWorksheet."Show Variety Level" :: "Variety 1+2+3" :
        //    IF "Variety 4 Value" <> '' THEN
        //      Level := 1
        //    ELSE
        //      Level := 0;
        //  ItemWorksheet."Show Variety Level" :: "Variety 1+2+3+4" :
        //      Level := 0;
        // END;
        Level := CalcLevel;
        //+NPR5.28 [259210]
    end;

    procedure CalcLevel(): Integer
    var
        Lvl: Integer;
    begin
        //-NPR5.28 [259210]
        ItemWorksheet.Get("Worksheet Template Name","Worksheet Name");
        case ItemWorksheet."Show Variety Level" of
          ItemWorksheet."Show Variety Level" :: "Variety 1" :
            if "Variety 4 Value" <> '' then
              exit(3)
            else
              if "Variety 3 Value" <> '' then
                exit(2)
              else
                if "Variety 2 Value" <> '' then
                  exit(1)
                else
                  exit(0);
          ItemWorksheet."Show Variety Level" :: "Variety 1+2" :
            if "Variety 4 Value" <> '' then
              exit(2)
            else
              if "Variety 3 Value" <> '' then
                exit(1)
              else
                exit(0);
          ItemWorksheet."Show Variety Level" :: "Variety 1+2+3" :
            if "Variety 4 Value" <> '' then
              exit(1)
            else
              exit(0);
          ItemWorksheet."Show Variety Level" :: "Variety 1+2+3+4" :
              exit(0);
        end;
        //+NPR5.28 [259210]
    end;

    local procedure UpdateAllRemarks()
    begin
        GetLine;
        ItemWorksheetLine.UpdateVarietyHeadingText;
    end;

    procedure GetExistingVariantCode(): Code[20]
    var
        ItemVar: Record "Item Variant";
    begin
        //-NPR5.50 [347513]
        if StrLen("Variety 2 Value") > 20 then
          exit('');
        //+NPR5.50 [347513]
        if "Existing Item No." <> '' then begin
          ItemVar.Reset;
          ItemVar.SetRange("Item No.", "Existing Item No.");
          ItemVar.SetRange("Variety 1 Value","Variety 1 Value");
          ItemVar.SetRange("Variety 2 Value","Variety 2 Value");
          ItemVar.SetRange("Variety 3 Value","Variety 3 Value");
          ItemVar.SetRange("Variety 4 Value","Variety 4 Value");
          ItemVar.SetRange(Blocked,false);
          if ItemVar.FindFirst then begin
            exit(ItemVar.Code);
          end else begin
            ItemVar.SetRange(Blocked,true);
            if ItemVar.FindFirst then
              exit(ItemVar.Code);
          end;
        end;
    end;

    procedure UpdateBarcode()
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");
        //-NPR5.23 [242498]
        //IF "Internal Bar Code"  = '' THEN
        //  EXIT;
        if "Internal Bar Code"  <> '' then
        //-NPR5.23 [242498]
          case ItemWorksheetTemplate."Create Internal Barcodes" of
            ItemWorksheetTemplate."Create Internal Barcodes" :: "As Alt. No."  :
              begin
                ItemNumberManagement.UpdateBarcode("Item No.","Variant Code","Internal Bar Code",0);
              end;
            ItemWorksheetTemplate."Create Internal Barcodes" :: "As Cross Reference"  :
              begin
                ItemNumberManagement.UpdateBarcode("Item No.","Variant Code","Internal Bar Code",1);
              end;
          end;
        //-NPR5.23 [242498]
        if "Vendors Bar Code"  <> '' then
          case ItemWorksheetTemplate."Create Vendor  Barcodes" of
            ItemWorksheetTemplate."Create Vendor  Barcodes" :: "As Alt. No."  :
              begin
                ItemNumberManagement.UpdateBarcode("Item No.","Variant Code","Vendors Bar Code",0);
              end;
            ItemWorksheetTemplate."Create Vendor  Barcodes":: "As Cross Reference"  :
              begin
                ItemNumberManagement.UpdateBarcode("Item No.","Variant Code","Vendors Bar Code",1);
              end;
          end;
        //+NPR5.23 [242498]
    end;

    procedure FillDescription()
    var
        VarietyCloneData: Codeunit "Variety Clone Data";
        TempDesc: Text[250];
    begin
        CalcFields("Variety 1", "Variety 1 Table", "Variety 2", "Variety 2 Table",
          "Variety 3", "Variety 3 Table", "Variety 4", "Variety 4 Table");
        VarietyCloneData.GetVarietyDesc("Variety 1", "Variety 1 Table", "Variety 1 Value", TempDesc);
        VarietyCloneData.GetVarietyDesc("Variety 2", "Variety 2 Table", "Variety 2 Value", TempDesc);
        VarietyCloneData.GetVarietyDesc("Variety 3", "Variety 3 Table", "Variety 3 Value", TempDesc);
        VarietyCloneData.GetVarietyDesc("Variety 4", "Variety 4 Table", "Variety 4 Value", TempDesc);
        //-NPR5.22
        if "Existing Variant Code" = '' then
        //+NPR5.22
          Description := CopyStr(TempDesc, 1, MaxStrLen(Description));
    end;

    local procedure SetPropagationFilter()
    begin
        ItemWorksheetVariantLine2.Reset;
        //-NPR4.19
        //ItemWorksheetVariantLine2.SETCURRENTKEY("Worksheet Template Name","Worksheet Name","Worksheet Line No.","Variety 1 Value","Variety 2 Value","Variety 3 Value","Variety 4 Value");
        //+NPR4.19
        ItemWorksheetVariantLine2.SetRange("Worksheet Template Name","Worksheet Template Name");
        ItemWorksheetVariantLine2.SetRange("Worksheet Name","Worksheet Name");
        ItemWorksheetVariantLine2.SetRange("Worksheet Line No.","Worksheet Line No.");
        ItemWorksheetVariantLine2.SetFilter("Line No.",'<>%1',"Line No.");
        //-NPR4.19
        //ItemWorksheetVariantLine2.SETFILTER("Heading Text",'%1','');
        ItemWorksheetVariantLine2.SetFilter("Heading Text",'%1','');
        //+NPR4.19
        if "Variety 4 Value" <> '' then
          ItemWorksheetVariantLine2.SetRange("Variety 4 Value","Variety 4 Value");
        if "Variety 3 Value" <> '' then
          ItemWorksheetVariantLine2.SetRange("Variety 3 Value","Variety 3 Value");
        if "Variety 2 Value" <> '' then
          ItemWorksheetVariantLine2.SetRange("Variety 2 Value","Variety 2 Value");
        ItemWorksheetVariantLine2.SetRange("Variety 1 Value","Variety 1 Value");
    end;

    local procedure CreateVarietyMapping(VrtType: Code[10];VrtTable: Code[20];WorksheetTemplate: Code[10];WorksheetName: Code[10];VendorNo: Code[20];OldVrtValue: Code[20];NewValue: Code[20])
    var
        ItemWorksheetVarietyMapping: Record "Item Worksheet Variety Mapping";
        ItemWorksheetVarietyMapping2: Record "Item Worksheet Variety Mapping";
    begin
        //-NPR5.37 [268786]
        if (VrtType =  '') or (VrtTable  = '') then
          exit;

        ItemWorksheetVarietyMapping.SetRange(Variety,VrtType);
        ItemWorksheetVarietyMapping.SetRange("Variety Table",VrtTable);
        ItemWorksheetVarietyMapping.SetRange("Worksheet Template Name",WorksheetTemplate);
        ItemWorksheetVarietyMapping.SetRange("Worksheet Name",WorksheetName);
        ItemWorksheetVarietyMapping.SetRange("Vendor No.",VendorNo);

        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value",NewValue);
        //Check whether the New value is mapped iteself
        if ItemWorksheetVarietyMapping.FindFirst then
          if Confirm(StrSubstNo(Text007,NewValue,ItemWorksheetVarietyMapping."Variety Value")) then
            ItemWorksheetVarietyMapping.Delete(true)
          else
            exit;

        //Update or New insert Mapping
        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value",OldVrtValue);
        if not ItemWorksheetVarietyMapping.FindFirst then begin
          ItemWorksheetVarietyMapping.Init;
          ItemWorksheetVarietyMapping.Validate(Variety,VrtType);
          ItemWorksheetVarietyMapping.Validate("Variety Table",VrtTable);
          ItemWorksheetVarietyMapping.Validate("Worksheet Template Name",WorksheetTemplate);
          ItemWorksheetVarietyMapping.Validate("Worksheet Name",WorksheetName);
          ItemWorksheetVarietyMapping.Validate("Vendor No.",VendorNo);
          ItemWorksheetVarietyMapping.Validate("Vendor Variety Value",OldVrtValue);
          ItemWorksheetVarietyMapping.Insert(true);
        end;
        ItemWorksheetVarietyMapping.Validate("Variety Value",NewValue);
        ItemWorksheetVarietyMapping.Modify(true);

        //Update any mapping that results in the Old value
        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value");
        ItemWorksheetVarietyMapping.SetRange("Variety Value",OldVrtValue);
        if ItemWorksheetVarietyMapping.FindSet then repeat
          ItemWorksheetVarietyMapping."Variety Value" := NewValue;
          ItemWorksheetVarietyMapping.Modify;
        until ItemWorksheetVarietyMapping.Next = 0;
        //+NPR5.37 [268786]
    end;

    procedure ApplyVarietyMapping() VariantModified: Boolean
    var
        ItemWorksheetVarietyMapping: Record "Item Worksheet Variety Mapping";
        I: Integer;
    begin
        //-NPR5.37 [268786]
        GetLine;
        ItemWorksheetVarietyMapping.Reset;
        ItemWorksheetVarietyMapping.SetFilter("Worksheet Template Name",'%1|%2',ItemWorksheetLine."Worksheet Template Name",'');
        ItemWorksheetVarietyMapping.SetFilter("Worksheet Name",'%1|%2',ItemWorksheetLine."Worksheet Name",'');
        ItemWorksheetVarietyMapping.SetFilter("Vendor No.",'%1|%2',ItemWorksheetLine."Vendor No.",'');
        I :=0;
        repeat
          I := I + 1;
          case I of
            1 :
              if "Variety 1 Value" <> '' then begin
                ItemWorksheetVarietyMapping.SetRange(Variety,ItemWorksheetLine."Variety 1");
                ItemWorksheetVarietyMapping.SetFilter("Variety Table",'%1|%2',ItemWorksheetLine."Variety 1 Table (New)",'');
                ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value","Variety 1 Value");

                //-NPR5.43 [314287]
                SetExtraVarityFilter(ItemWorksheetLine,ItemWorksheetVarietyMapping);
                //+NPR5.43 [314287]

                if ItemWorksheetVarietyMapping.FindFirst then begin
                  "Variety 1 Value" := ItemWorksheetVarietyMapping."Variety Value";
                  VariantModified := true;
                end;
              end;
            2 :
              if "Variety 2 Value" <> '' then begin
                ItemWorksheetVarietyMapping.SetRange(Variety,ItemWorksheetLine."Variety 2");
                ItemWorksheetVarietyMapping.SetFilter("Variety Table",'%1|%2',ItemWorksheetLine."Variety 2 Table (New)",'');
                ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value","Variety 2 Value");

                //-NPR5.43 [314287]
                SetExtraVarityFilter(ItemWorksheetLine,ItemWorksheetVarietyMapping);
                //+NPR5.43 [314287]

                if ItemWorksheetVarietyMapping.FindFirst then begin
                  "Variety 2 Value" := ItemWorksheetVarietyMapping."Variety Value";
                  VariantModified := true;
                end;
              end;
            3 :
              if "Variety 3 Value" <> '' then begin
                ItemWorksheetVarietyMapping.SetRange(Variety,ItemWorksheetLine."Variety 3");
                ItemWorksheetVarietyMapping.SetFilter("Variety Table",'%1|%2',ItemWorksheetLine."Variety 3 Table (New)",'');
                ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value","Variety 3 Value");

                //-NPR5.43 [314287]
                SetExtraVarityFilter(ItemWorksheetLine,ItemWorksheetVarietyMapping);
                //+NPR5.43 [314287]

                if ItemWorksheetVarietyMapping.FindFirst then begin
                  "Variety 3 Value" := ItemWorksheetVarietyMapping."Variety Value";
                  VariantModified := true;
                end;
              end;
            4 :
              if "Variety 4 Value" <> '' then begin
                ItemWorksheetVarietyMapping.SetRange(Variety,ItemWorksheetLine."Variety 4");
                ItemWorksheetVarietyMapping.SetFilter("Variety Table",'%1|%2',ItemWorksheetLine."Variety 4 Table (New)",'');
                ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value","Variety 4 Value");

                //-NPR5.43 [314287]
                SetExtraVarityFilter(ItemWorksheetLine,ItemWorksheetVarietyMapping);
                //+NPR5.43 [314287]

                if ItemWorksheetVarietyMapping.FindFirst then begin
                  "Variety 4 Value" := ItemWorksheetVarietyMapping."Variety Value";
                  VariantModified := true;
                end;
              end;
          end;
        until  (I = 4);
        //+NPR5.37 [268786]
    end;

    procedure SetUpdateFromWorksheetLine(VarUpdateFromWorksheetLine: Boolean)
    begin
        //-NPR5.37 [268786]
        UpdateFromWorksheetLine := VarUpdateFromWorksheetLine;
        //+NPR5.37 [268786]
    end;

    procedure GetStatusCommentText(): Text
    begin
        //-NPR5.37 [268786]
        exit(StatusCommentText);
        //+NPR5.37 [268786]
    end;

    local procedure SetExtraVarityFilter(var ItemWorksheetLine: Record "Item Worksheet Line";var ItemWorksheetVarietyMapping: Record "Item Worksheet Variety Mapping")
    var
        ItemWorksheetVarietyMapping2: Record "Item Worksheet Variety Mapping";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        //-NPR5.43 [314287]
        ItemWorksheetVarietyMapping2.CopyFilters(ItemWorksheetVarietyMapping);
        ItemWorksheetVarietyMapping2.SetFilter("Item Wksh. Maping Field",'>%1',0);
        if ItemWorksheetVarietyMapping2.FindSet then begin
          repeat
            RecRef.GetTable(ItemWorksheetLine);
            FldRef := RecRef.Field(1);
            FldRef.SetFilter('%1',ItemWorksheetLine."Worksheet Template Name");
            FldRef := RecRef.Field(2);
            FldRef.SetFilter('%1',ItemWorksheetLine."Worksheet Name");
            FldRef := RecRef.Field(3);
            FldRef.SetFilter('%1',ItemWorksheetLine."Line No.");
            FldRef := RecRef.Field(ItemWorksheetVarietyMapping2."Item Wksh. Maping Field");
            FldRef.SetFilter('%1',ItemWorksheetVarietyMapping2."Item Wksh. Maping Field Value");
            if RecRef.FindFirst then begin
              ItemWorksheetVarietyMapping.SetRange("Item Wksh. Maping Field",ItemWorksheetVarietyMapping2."Item Wksh. Maping Field");
              ItemWorksheetVarietyMapping.SetRange("Item Wksh. Maping Field Value",ItemWorksheetVarietyMapping2."Item Wksh. Maping Field Value");
            end;
          until ItemWorksheetVarietyMapping2.Next = 0;
        end;
        //+NPR5.43 [314287]
    end;
}

