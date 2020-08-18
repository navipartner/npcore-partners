table 6014410 "Item Group"
{
    // NPR70.00.00.02/JDH/20141010 CASE 189462 possible to choose if you want to block / unblock sublevels - possible to have different status on sublevels compared to upper level
    // NPR70.00.00.03/LS/20141222  CASE 201562 commented code onInsert toprevent creation of Item Group as Item
    // NPR70.00.01.01/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // VRT1.00/JDH/20150304 CASE 201022 Added field Variety Group
    // NPR4.11/BHR/20150424 CASE 211624 correct sorting issues.
    // NPR5.20/JDH/20160309 CASE 234014 Changed sorting to use new field "Sorting Key"
    // NPR5.23/THRO/20160509 CASE 240771 Added key Description (to allow sorting on description in dropdown)
    // NPR5.23/JDH /20160512 CASE 240916 Removed reference to old Color Size solution
    // NPR5.26/LS  /20160824 CASE 249735 Removed field 11 "Used"
    // NPR5.26/BHR/20160914 CASE 252128 change the 'lookuppageid'and 'DrilldownPageid' from "Item Group Page" to "Item Group List"
    // NPR5.27/MHA /20160929  CASE 253885 Replaced Sorting Key delimiter '-' with '/'
    // NPR5.29/BHR /20170124 CASE 264081 Removed checks on 'inventory posting group'
    // NPR5.30/TJ  /20170213 CASE 265534 Added field 80 Config. Template Header
    // NPR5.30/TJ  /20170213 CASE 265533 Removed unused fields
    //                                   Renamed some fields to follow naming standards
    // NPR5.31/MHA /20170110 CASE 262904 Added "Disc. Grouping Type" to CalcFormula of FlowField 600 "In Mix"
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.38/TJ  /20171218 CASE 225415 Renumbered fields from range 67xxx to range below 50000
    // NPR5.38/BR  /20180125  CASE 302803 Added Field "Tax Group Code"
    // NPR5.45/TJ  /20180801  CASE 323517 Changed LookupPageID and DrillDownPageID from Item Group List to Item Group Tree
    // NPR5.48/TJ  /20181106  CASE 331261 Changed Length property of fields Description and Search Description from 30 to 50
    // NPR5.48/TSA /20181102  CASE 334651 Renamed field "Sorting Key" to "Sorting-Key" since it conflicts in V2
    // NPR5.48/TS  /20181128  CASE 337806 Increased Length of GlobalDimension1Filter,Global Dimension 2 Filter,Tarrif No. and Item Discount Group to 20
    //                                    Reduced Location Code to 10
    // NPR5.48/BHR /20190107  CASE 334217 Create field Type(11)

    Caption = 'Item Group';
    DrillDownPageID = "Item Group Tree";
    LookupPageID = "Item Group Tree";

    fields
    {
        field(1;"No.";Code[10])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if (UpperCase("Search Description") = UpperCase(xRec.Description)) or ("Search Description" = '') then
                  "Search Description" := UpperCase(Description);

                if Description <> xRec.Description then begin
                  if Item.Get("No.") then
                    if Item."Group sale" then begin
                      Item.Description          := Description;
                      Item."Search Description" := UpperCase("Search Description");
                      Item.Modify(true);
                    end;
                end;
            end;
        }
        field(3;"Search Description";Text[50])
        {
            Caption = 'Search Description';
        }
        field(4;"Parent Item Group No.";Code[10])
        {
            Caption = 'Parent Item Group No.';
            TableRelation = "Item Group"."No.";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                //-NPR5.20
                //IF ("Belongs In Main Item Group" = "No.") AND
                //   ("Parent Item Group" <> '') THEN ERROR(Text1060003);
                //+NPR5.20

                if "Parent Item Group No." = "No." then Error(Text1060004);

                if (xRec."Parent Item Group No." <> '') then begin
                  if Confirm(Text1060011,true) then
                    CopyParentItemGroupSetup(Rec);
                end else
                  CopyParentItemGroupSetup(Rec);

                if "Parent Item Group No." = '' then begin
                  Level := 0;
                end;

                //-NPR5.20
                UpdateSortKey(Rec);
                //+NPR5.20

                //-NPR4.11
                // IF "Parent Item Group" = '0' THEN
                //   "Belongs In Main Item Group" := "No.";
                //+NPR4.11
            end;
        }
        field(5;"Belongs In Main Item Group";Code[10])
        {
            Caption = 'Belongs in Main Item Group';
            TableRelation = "Item Group"."No.";
            ValidateTableRelation = false;
        }
        field(7;"Sorting-Key";Text[250])
        {
            Caption = 'Sorting Key';
        }
        field(8;Blocked;Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            var
                ItemGroup: Record "Item Group";
            begin
                //-NPR5.20
                CheckItemGroup(FieldNo(Blocked));
                //+NPR5.20

                ItemGroup.Reset;
                ItemGroup.SetRange("Parent Item Group No.", "No.");
                if ItemGroup.IsEmpty then
                  exit;
                if not Confirm(Text1060012, true, FieldCaption(Blocked), Blocked) then
                  exit;
                //+NPR70.00.00.02

                BlockSubLevels("No.",Blocked);
            end;
        }
        field(9;"Created Date";Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(10;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(11;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Inventory,Service';
            OptionMembers = Inventory,Service;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
            end;
        }
        field(12;"VAT Prod. Posting Group";Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(14;"VAT Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(15;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                GenBusinessPostingGroup: Record "Gen. Business Posting Group";
            begin
                if "Gen. Bus. Posting Group" <> '' then begin
                  GenBusinessPostingGroup.Get("Gen. Bus. Posting Group");
                  Validate("VAT Bus. Posting Group",GenBusinessPostingGroup."Def. VAT Bus. Posting Group");
                end else
                  "VAT Bus. Posting Group" := '';

                //-NPR5.20
                CheckItemGroup(FieldNo("Gen. Bus. Posting Group"));
                //+NPR5.20
            end;
        }
        field(16;"Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            var
                GenProductPostingGroup: Record "Gen. Product Posting Group";
            begin
                if "Gen. Prod. Posting Group" <> '' then begin
                  GenProductPostingGroup.Get("Gen. Prod. Posting Group");
                  Validate("VAT Prod. Posting Group",GenProductPostingGroup."Def. VAT Prod. Posting Group");
                end else
                  "VAT Prod. Posting Group" := '';

                //-NPR5.20
                CheckItemGroup(FieldNo("Gen. Prod. Posting Group"));
                //+NPR5.20
            end;
        }
        field(17;"Inventory Posting Group";Code[10])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group";

            trigger OnValidate()
            begin
                //-NPR5.20
                CheckItemGroup(FieldNo("Inventory Posting Group"));
                //+NPR5.20
            end;
        }
        field(50;Level;Integer)
        {
            Caption = 'Level';
        }
        field(52;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(54;"Main Item Group";Boolean)
        {
            Caption = 'Main Item Group';
            Editable = true;
        }
        field(55;"Sales (Qty.)";Decimal)
        {
            CalcFormula = -Sum("Item Ledger Entry".Quantity WHERE ("Entry Type"=CONST(Sale),
                                                                   "Item Group No."=FIELD("No."),
                                                                   "Vendor No."=FIELD("Vendor Filter"),
                                                                   "Posting Date"=FIELD("Date Filter"),
                                                                   "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                   "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Sales (Qty.)';
            FieldClass = FlowField;
        }
        field(56;"Sales (LCY)";Decimal)
        {
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE ("Item Ledger Entry Type"=CONST(Sale),
                                                                           "Item Group No."=FIELD("No."),
                                                                           "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date"=FIELD("Date Filter"),
                                                                           "Vendor No."=FIELD("Vendor Filter"),
                                                                           "Salespers./Purch. Code"=FIELD("Salesperson Filter"),
                                                                           "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Sales (LCY)';
            FieldClass = FlowField;
        }
        field(57;"Global Dimension 1 Filter";Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            Description = 'NPR5.48';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(58;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(59;"Vendor Filter";Code[20])
        {
            Caption = 'Vendor Filter';
            FieldClass = FlowFilter;
            TableRelation = Vendor;
        }
        field(60;"Consumption (Amount)";Decimal)
        {
            CalcFormula = -Sum("Value Entry"."Cost Amount (Actual)" WHERE ("Item Ledger Entry Type"=CONST(Sale),
                                                                           "Item Group No."=FIELD("No."),
                                                                           "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date"=FIELD("Date Filter"),
                                                                           "Vendor No."=FIELD("Vendor Filter"),
                                                                           "Salespers./Purch. Code"=FIELD("Salesperson Filter"),
                                                                           "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Consumption (Amount)';
            FieldClass = FlowField;
        }
        field(61;"Salesperson Filter";Code[10])
        {
            Caption = 'Salesperson Filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(62;"Item Discount Group";Code[20])
        {
            Caption = 'Item Discount Group';
            Description = 'NPR5.48';
            TableRelation = "Item Discount Group".Code;

            trigger OnValidate()
            var
                VareLoc: Record Item;
                OldGroup: Text[30];
            begin
                VareLoc.SetRange("Item Group","No.");
                if VareLoc.Find('-') then begin
                  VareLoc.SetFilter("Item Disc. Group",'<> %1',xRec."Item Discount Group");
                  if VareLoc.Find('-') then begin
                    OldGroup := xRec."Item Discount Group";
                    if OldGroup = '' then
                      OldGroup := '<BLANK>';
                    if Confirm(
                      StrSubstNo(Text1060010,
                        TableCaption,
                        "No.",
                        OldGroup,
                        VareLoc.FieldCaption("Item Disc. Group"),
                        "Item Discount Group"
                        )) then begin
                      VareLoc.SetRange("Item Disc. Group");
                      VareLoc.ModifyAll("Item Disc. Group","Item Discount Group");
                    end else begin
                      VareLoc.SetRange("Item Disc. Group",xRec."Item Discount Group");
                      VareLoc.ModifyAll("Item Disc. Group","Item Discount Group");
                    end;
                  end else begin
                    VareLoc.ModifyAll("Item Disc. Group","Item Discount Group");
                  end;
                end;
            end;
        }
        field(63;"Warranty File";Option)
        {
            Caption = 'Warranty File';
            OptionCaption = ' ,Move to Warranty File';
            OptionMembers = " ","Flyt til garanti kar.";
        }
        field(64;"No. Series";Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(65;"Costing Method";Option)
        {
            Caption = 'Costing Method';
            InitValue = FIFO;
            OptionCaption = 'FIFO,LIFO,Specific,Average,Standard';
            OptionMembers = FIFO,LIFO,Specific,"Average",Standard;
        }
        field(66;Movement;Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Item Group No."=FIELD("No."),
                                                                  "Vendor No."=FIELD("Vendor Filter"),
                                                                  "Posting Date"=FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Movement';
            FieldClass = FlowField;
        }
        field(67;"Purchases (Qty.)";Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Entry Type"=CONST(Purchase),
                                                                  "Item Group No."=FIELD("No."),
                                                                  "Vendor No."=FIELD("Vendor Filter"),
                                                                  "Posting Date"=FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Purchases (Qty.)';
            FieldClass = FlowField;
        }
        field(68;"Purchases (LCY)";Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE ("Item Ledger Entry Type"=CONST(Purchase),
                                                                          "Item Group No."=FIELD("No."),
                                                                          "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                          "Posting Date"=FIELD("Date Filter"),
                                                                          "Vendor No."=FIELD("Vendor Filter"),
                                                                          "Salespers./Purch. Code"=FIELD("Salesperson Filter"),
                                                                          "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Purchases (LCY)';
            FieldClass = FlowField;
        }
        field(70;"Base Unit of Measure";Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(71;"Sales Unit of Measure";Code[10])
        {
            Caption = 'Sales Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(72;"Purch. Unit of Measure";Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(73;"Insurance Category";Code[50])
        {
            Caption = 'Insurance Category';
            TableRelation = "Insurance Category";
        }
        field(74;Warranty;Boolean)
        {
            Caption = 'Warranty';
        }
        field(80;"Config. Template Header";Code[10])
        {
            Caption = 'Config. Template Header';
            Description = 'NPR5.30';
            TableRelation = "Config. Template Header";
        }
        field(85;Picture;BLOB)
        {
            Caption = 'Picture';
            SubType = Bitmap;
        }
        field(86;"Picture Extention";Text[3])
        {
            Caption = 'Picture Extention';
        }
        field(90;"Inventory Value";Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE ("Item Group No."=FIELD("No."),
                                                                          "Vendor No."=FIELD("Vendor Filter"),
                                                                          "Posting Date"=FIELD("Date Filter"),
                                                                          "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Inventory Value';
            Description = 'Lagerværdi';
            FieldClass = FlowField;
        }
        field(98;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            Description = 'NPR5.38';
            TableRelation = "Tax Group";
        }
        field(310;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            Description = 'NPR5.48';
            TableRelation = Location;
        }
        field(316;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(317;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(318;"Global Dimension 2 Filter";Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            Description = 'NPR5.48';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(320;"Primary Key Length";Integer)
        {
            Caption = 'Primary Key Length';

            trigger OnValidate()
            begin
                "Primary Key Length" := StrLen("No.");
            end;
        }
        field(321;"Tarif No.";Code[20])
        {
            Caption = 'Tarif No.';
            Description = 'NPR5.48';
            TableRelation = "Tariff Number";
        }
        field(500;"Used Goods Group";Boolean)
        {
            Caption = 'Used Goods Group';

            trigger OnValidate()
            var
                ItemGroup: Record "Item Group";
            begin
                if not "Main Item Group" then begin
                  ItemGroup.SetRange("No.","Parent Item Group No.");
                  if ItemGroup.FindFirst then
                    if (ItemGroup."Used Goods Group") and ("Used Goods Group") then
                      Error(Text1060008,"No.");
                end;

                SetUsedOnSubLevels("No.","Used Goods Group");
            end;
        }
        field(600;"Mixed Discount Line Exists";Boolean)
        {
            CalcFormula = Exist("Mixed Discount Line" WHERE ("No."=FIELD("No."),
                                                             "Disc. Grouping Type"=CONST("Item Group")));
            Caption = 'Mixed Discount Line Exists';
            FieldClass = FlowField;
        }
        field(5440;"Reordering Policy";Option)
        {
            Caption = 'Reordering Policy';
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order","Lot-for-Lot";
        }
        field(6014607;"Size Dimension";Code[20])
        {
            Caption = 'Size Dimension';
        }
        field(6014608;"Color Dimension";Code[20])
        {
            Caption = 'Color Dimension';
        }
        field(6059982;"Variety Group";Code[20])
        {
            Caption = 'Variety Group';
            Description = 'VRT1.00';
            TableRelation = "Variety Group";
        }
        field(6060001;"Webshop Picture";Text[200])
        {
            Caption = 'Webshop Picture';
        }
        field(6060002;Internet;Boolean)
        {
            Caption = 'Internet';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Entry No.","Primary Key Length")
        {
        }
        key(Key3;"Parent Item Group No.")
        {
        }
        key(Key4;"Main Item Group")
        {
        }
        key(Key5;"Sorting-Key")
        {
        }
        key(Key6;Description)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"No.",Description,Blocked)
        {
        }
    }

    trigger OnDelete()
    var
        ItemGroup: Record "Item Group";
        ItemGroup2: Record "Item Group";
    begin
        //-NPR5.20
        ItemGroup.SetRange("Parent Item Group No.", "No.");
        if not ItemGroup.IsEmpty then begin
          if not Confirm(Text001, false, "No.") then
            Error(Text1060002);

            if ItemGroup.FindSet(false, false) then repeat
              ItemGroup2.Get(ItemGroup."No.");
              ItemGroup2."Parent Item Group No." := '';
              ItemGroup2.Modify;
            until ItemGroup.Next = 0;
          end;
        //+NPR5.20

        exit;
        //the Exit above has been here for ages -> code below will never be executed -> code outcommented, to let OMA know that its not used

        //RetailTable.VaregruppeOnDelete( Rec );

        //IF "No." <> '' THEN BEGIN
        //  Item.SETCURRENTKEY("Item Group");
        //  Item.SETRANGE("Item Group","No.");
        //  IF Item.FINDFIRST THEN
        //    ERROR(Text1060000,TABLECAPTION,"No.");

        //  ItemGroup.SETRANGE("Parent Item Group","No.");
        //  IF ItemGroup.FINDFIRST THEN BEGIN
        //    IF NOT CONFIRM(Text1060001,FALSE) THEN
        //      ERROR(Text1060002);

        //    Item.SETCURRENTKEY("Item Group");
        //    Item.SETRANGE("Item Group","No.");
        //    IF Item.FINDSET THEN
        //      ERROR(Text1060000,TABLECAPTION,"No.");
        //    REPEAT
        //      DeleteSubLevels(ItemGroup."No.");
        //      ItemGroup.DELETE(TRUE);
        //    UNTIL ItemGroup.NEXT =  0;
        //  END;
        //END;

        //RecRef.GETTABLE(Rec);
        //CompanySyncMgt.OnDelete(RecRef);

        //DimMgt.DeleteDefaultDim(DATABASE::"Item Group","No.");
    end;

    trigger OnInsert()
    var
        ItemGroup: Record "Item Group";
    begin
        "Created Date" := Today;
        "Primary Key Length" := StrLen("No.");
        
        //-NPR5.20
        if "Parent Item Group No." <> '' then begin
          if ItemGroup.Get("Parent Item Group No.") then begin
            Level                        := ItemGroup.Level + 1;
            //-NPR5.27 [253885]
            //"Sorting Key"                := ItemGroup."Sorting Key" + '-' + "No.";
            "Sorting-Key" := ItemGroup."Sorting-Key" + '/' + "No.";
            //+NPR5.27 [253885]
            "Belongs In Main Item Group" := ItemGroup."Belongs In Main Item Group";
            "Main Item Group"            := false;
          end;
        end else
          "Sorting-Key" := "No.";
        //+NPR5.20
        
        CopyParentItemGroupSetup(Rec);
        
        CreateNoSeries;
        
        RecRef.GetTable(Rec);
        CompanySyncMgt.OnInsert(RecRef);
        
        //-NPR70.00.00.03
        /*
        IF ("Parent Item Group" <> '') THEN
          RetailTable.VaregruppeOnInsert( Rec, FALSE ,0);
        */
        //+NPR70.00.00.03
        
        DimMgt.UpdateDefaultDim(
          DATABASE::"Item Group","No.",
          "Global Dimension 1 Code","Global Dimension 2 Code");

    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        "Primary Key Length" := StrLen("No.");

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnModify(RecRef);
    end;

    trigger OnRename()
    var
        ItemGroup: Record "Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.",xRec."No.");
        if ItemGroup.FindSet then repeat
          ItemGroup."Parent Item Group No.":="No.";
          ItemGroup.Modify;
        until ItemGroup.Next = 0;

        SoNoSeries;
    end;

    var
        Text1060002: Label 'Deletion cancelled!';
        Text1060004: Label 'The item group cannot be subgroup to itself!';
        Text1060008: Label 'The main groups to item group %1 must be activated to used goods groups!';
        RetailSetup: Record "Retail Setup";
        CompanySyncMgt: Codeunit CompanySyncManagement;
        DimMgt: Codeunit DimensionManagement;
        Text1060010: Label 'Items have been found belonging to %1 %2, but not having %3 in %4.\Edit these to %4 %5';
        Text1060011: Label 'You are about to move the relation to another item group, do you with to inherit the attributes?';
        Text1060012: Label 'Do you wish to set %1 to %2  on Item groups below this level?';
        RecRef: RecordRef;
        Text001: Label 'There is other Item groups that has a reference to Item Group %1.\Do you wish to delete it anyway?';

    procedure BlockSubLevels(ItemGroupCode: Code[10];BlockValue: Boolean)
    var
        ItemGroup: Record "Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.",ItemGroupCode);
        if ItemGroup.Find('-') then repeat
          if ItemGroup."Belongs In Main Item Group" = ItemGroup."No." then ItemGroup.Next;
          ItemGroup.Blocked := BlockValue;
          ItemGroup.Modify;
          BlockSubLevels(ItemGroup."No.",BlockValue);
        until ItemGroup.Next = 0;
    end;

    procedure DeleteSubLevels(ItemGroupCode: Code[10])
    var
        ItemGroup: Record "Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.",ItemGroupCode);
        if ItemGroup.FindSet then repeat
          if ItemGroup."Belongs In Main Item Group" = ItemGroup."No." then ItemGroup.Next;
          DeleteSubLevels(ItemGroup."No.");
          ItemGroup.Delete(true);
        until ItemGroup.Next = 0;
    end;

    procedure SetUsedOnSubLevels(ItemGroupcode: Code[10];UsedValue: Boolean)
    var
        ItemGroup: Record "Item Group";
    begin
        ItemGroup.SetRange("Belongs In Main Item Group",ItemGroupcode);
        if ItemGroup.FindSet then repeat
          if ItemGroup."Belongs In Main Item Group" = ItemGroup."No." then ItemGroup.Next;
          ItemGroup."Used Goods Group" := UsedValue;
          ItemGroup.Modify;
          BlockSubLevels(ItemGroup."No.",UsedValue);
        until ItemGroup.Next = 0;
    end;

    procedure CreateNoSeries()
    var
        ErrLength: Label 'No. Series is too long. Reduce the length on itemgroup or pre-itemgroup in setup';
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        Text0001: Label 'NoSeries for itemgroup';
    begin
        //OpretNrSerie
        RetailSetup.Get;
        if RetailSetup."Itemgroup Pre No. Serie" = '' then
          exit;

        "No. Series" := RetailSetup."Itemgroup Pre No. Serie" + "No.";

        if StrLen( RetailSetup."Itemgroup Pre No. Serie" + "No." ) > 10 then
          Error( ErrLength );

        NoSeries.Init;
        NoSeries.Code := "No. Series";
        NoSeries.Description := Text0001 + "No.";
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries."Date Order" := false;
        NoSeries.Insert( true );
        NoSeriesLine.Init;
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting Date" := CalcDate( '<-1D>', Today );
        NoSeriesLine."Starting No." := "No." + RetailSetup."Itemgroup No. Serie StartNo.";
        NoSeriesLine."Ending No." := "No." + RetailSetup."Itemgroup No. Serie EndNo.";
        NoSeriesLine."Warning No." := RetailSetup."Itemgroup No. Serie Warning";
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert;
    end;

    procedure SoNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if RetailSetup."Itemgroup Pre No. Serie" = '' then
          exit;

        if "No. Series" = xRec."No. Series" then
          exit;

        NoSeries.Get( xRec."No. Series" );
        NoSeries.Rename( "No. Series" );
        NoSeries.Validate( Description, 'Nummerserie til varegruppe ' + "No." );
        NoSeries.Modify;
        NoSeriesLine.Get( "No. Series", 10000 );
        NoSeriesLine."Starting No." := "No." + '00000';
        NoSeriesLine."Ending No." := "No." + '99999';
        NoSeriesLine."Warning No." := "No." + '99000';
        NoSeriesLine.Modify;

        "No. Series" := RetailSetup."Itemgroup Pre No. Serie" + "No.";
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::Customer,"No.",FieldNumber,ShortcutDimCode);
        Modify;
    end;

    procedure CopyParentItemGroupSetup(var ItemGroup: Record "Item Group")
    var
        ItemGroupParent: Record "Item Group";
    begin
        with ItemGroup do begin
          if (ItemGroupParent.Get("Parent Item Group No.")) then
          begin
            Level                        := ItemGroupParent.Level + 1;
            "VAT Prod. Posting Group"  := ItemGroupParent."VAT Prod. Posting Group";
            "VAT Bus. Posting Group"   := ItemGroupParent."VAT Bus. Posting Group";
            "Gen. Prod. Posting Group" := ItemGroupParent."Gen. Prod. Posting Group";
            "Gen. Bus. Posting Group"  := ItemGroupParent."Gen. Bus. Posting Group";
            "Inventory Posting Group"  := ItemGroupParent."Inventory Posting Group";
            "Base Unit of Measure"                := ItemGroupParent."Base Unit of Measure";
            "Sales Unit of Measure"               := ItemGroupParent."Sales Unit of Measure";
            "Purch. Unit of Measure"           := ItemGroupParent."Purch. Unit of Measure";
            "No. Series"            := ItemGroupParent."No. Series";
            "Location Code"            := ItemGroupParent."Location Code";
            "Global Dimension 1 Code"  := ItemGroupParent."Global Dimension 1 Code";
            "Global Dimension 2 Code"  := ItemGroupParent."Global Dimension 2 Code";
            //-NPR5.23 [240916]
            // "Size Group"               := ItemGroupParent."Size Group";
            //+NPR5.23 [240916]

            "Item Discount Group"           := ItemGroupParent."Item Discount Group";
            "Size Dimension"           := ItemGroupParent."Size Dimension";
            "Color Dimension"          := ItemGroupParent."Color Dimension";
        //-NPR4.11
        //    "Belongs In Main Item Group" := ItemGroupParent."Belongs In Main Item Group";
        //+NPR4.11
            //-NPR5.38 [302803]
            "Tax Group Code"           := ItemGroupParent."Tax Group Code";
            //+NPR5.38 [302803]
            //-NPR5.48 [334217]
            Type := ItemGroupParent.Type;
            //+NPR5.48 [334217]
          end;
        end;
    end;

    procedure UpdateSortKey(var ItemGroup: Record "Item Group"): Text[250]
    var
        ItemGroup2: Record "Item Group";
    begin
        //-NPR5.22
        //Update Me
        ItemGroup."Main Item Group" := (ItemGroup."Parent Item Group No." = '');
        if ItemGroup."Main Item Group" then begin
          ItemGroup.Level                        := 0;
          ItemGroup."Sorting-Key"                := ItemGroup."No.";
          ItemGroup."Belongs In Main Item Group" := ItemGroup."No.";
          ItemGroup."Main Item Group"            := true;
        end else begin
          ItemGroup2.Get(ItemGroup."Parent Item Group No.");
          ItemGroup.Level                        := ItemGroup2.Level + 1;
          //-NPR5.27 [253885]
          //ItemGroup."Sorting Key"                := ItemGroup2."Sorting Key" + '-' + ItemGroup."No.";
          ItemGroup."Sorting-Key" := ItemGroup2."Sorting-Key" + '/' + ItemGroup."No.";
          //+NPR5.27 [253885]
          ItemGroup."Belongs In Main Item Group" := ItemGroup2."Belongs In Main Item Group";
          ItemGroup."Main Item Group"            := false;
        end;
        ItemGroup.Modify;

        //Update Children
        ItemGroup2.SetCurrentKey("Parent Item Group No.");
        ItemGroup2.SetRange("Parent Item Group No.", ItemGroup."No.");
        if ItemGroup2.FindSet then repeat
          UpdateSortKey(ItemGroup2);
        until ItemGroup2.Next = 0;
        //+NPR5.22
    end;

    local procedure CheckItemGroup(CalledFromFieldNo: Integer)
    var
        ItemGroup2: Record "Item Group";
    begin
        //-NPR5.22
        if CalledFromFieldNo = FieldNo(Blocked) then begin
          if not Blocked then begin
            TestField("Gen. Prod. Posting Group");
            TestField("Gen. Bus. Posting Group");
            //-NPR5.29 [264081]
            //TESTFIELD("Inventory Posting Group");
            //+NPR5.29 [264081]
            ItemGroup2.Get("Parent Item Group No.");
          end;
        end else
          if ("Gen. Prod. Posting Group" = '') or
             ("Gen. Bus. Posting Group" = '') or
            //-NPR5.29 [264081]
            // ("Inventory Posting Group" = '') OR
            //+NPR5.29 [264081]
             (not ItemGroup2.Get("Parent Item Group No.")) then
            Blocked := true;
        //+NPR5.22
    end;
}

