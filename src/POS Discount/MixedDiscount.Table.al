table 6014411 "NPR Mixed Discount"
{
    // Period Discount
    // //NPR sag 84805
    // NPR70.00.01.02/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR5.26/JC  /20160818  CASE 248285 Deleted fields 16Salesperson filter, 100Auto & applied code guidelines
    // NPR5.29/JC  /20170113  CASE 261710 Deleted function ValidateShortcutDimCode()
    // NPR5.31/MHA /20170109  CASE 262903 Option added to field 17 Discount Type: Discount Amount, added field 25 Discount Amount and Discount Calculation Functions
    // NPR5.31/MHA /20170110  CASE 262904 Added field 100 "Mix Type" to enabled multi layered Mix
    //                                    Deleted unused function CalcDiscPer()
    //                                    Renamed variables to English and moved non-setup Globals to Locals
    //                                    Added DecimalPlaces 0:5 to all Quantity fields
    // NPR5.31/MHA /20170113  CASE 263093 Added field 310 "Customer Disc. Group Filter" to be used as filter and changed DataType for field 316 and 317 from Code to Text
    // NPR5.31/MHA /20170120  CASE 262964 Option added to field 17 Discount Type: Lowest Unit Price Items per Min. Qty, added fields 30 Item Discount Qty. and 35 Item Discount %
    // NPR5.38/MHA /20171106  CASE 295330 Renamed Option "Balanced" to "Closed" for field 8 "Status"
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization.
    // NPR5.40/MHA /20180320  CASE 306304 Added field 40 "Total Amount Excl. VAT"
    // NPR5.45/MMV /20180904  CASE 327277 Update mix part parameters correctly.
    // NPR5.55/ALPO/20200714  CASE 412946 Support for multiple discount amount levels (option added to field 17 Discount Type: Multiple Discount Levels)

    Caption = 'Mixed Discount';
    LookupPageID = "NPR Mixed Discount List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';

            trigger OnValidate()
            var
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if Code <> xRec.Code then begin
                    NoSeriesMgt.TestManual("No. Serie");
                    "No. Serie" := '';
                end;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(4; "Min. Quantity"; Decimal)
        {
            Caption = 'Min. Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            MinValue = 1;
        }
        field(5; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Description = 'NPR5.31';
            MinValue = 0;
        }
        field(6; "Created the"; Date)
        {
            Caption = 'Created Date';
        }
        field(7; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            Description = 'NPR5.38';
            OptionCaption = 'Pending,Active,Closed';
            OptionMembers = Pending,Active,Closed;

            trigger OnValidate()
            var
                StdTableCode: Codeunit "NPR Std. Table Code";
            begin
                if Status = Status::Active then begin
                    TestField("Starting date");
                    TestField("Ending date");
                    //-NPR5.31 [262904]
                    //IF NOT "Quantity at line" THEN
                    //  TESTFIELD(Quantity);
                    //StdTableCode.TestMiksStatus(Code);
                    if (not Lot) and ("Mix Type" = 0) then
                        TestField("Min. Quantity");
                    TestStatus();
                    //+NPR5.31 [262904]
                end;
            end;
        }
        field(9; "Unit price incl VAT"; Boolean)
        {
            CalcFormula = Lookup ("NPR Retail Setup"."Prices Include VAT");
            Caption = 'Price Includes VAT';
            FieldClass = FlowField;

            trigger OnValidate()
            begin
                if "Unit price incl VAT" <> xRec."Unit price incl VAT" then
                    Error(Text1060000);
            end;
        }
        field(10; "No. Serie"; Code[20])
        {
            Caption = 'No. Series';
        }
        field(11; "Starting date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            var
                ErrDate: Label 'Invalid Starting Date';
            begin
                if "Ending date" <> 0D then
                    if "Ending date" < "Starting date" then
                        Error(ErrDate);
            end;
        }
        field(12; "Ending date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            var
                ErrDate: Label 'Invalid Closing Date';
            begin
                if "Starting date" <> 0D then
                    if "Ending date" < "Starting date" then
                        Error(ErrDate);
            end;
        }
        field(13; "Starting time"; Time)
        {
            Caption = 'Start Time';
        }
        field(14; "Ending time"; Time)
        {
            Caption = 'End Time';
        }
        field(15; Lot; Boolean)
        {
            Caption = 'Lot';
            Description = 'NPR5.31';

            trigger OnValidate()
            begin
                //-NPR5.55 [412946]
                if Lot and ("Discount Type" = "Discount Type"::"Multiple Discount Levels") then
                    FieldError("Discount Type");
                //+NPR5.55 [412946]
            end;
        }
        field(17; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR5.31,NPR5.55';
            OptionCaption = 'Total Amount per Min. Qty.,Total Discount %,Total Discount Amt. per Min. Qty.,Priority Discount per Min. Qty,Multiple Discount Levels';
            OptionMembers = "Total Amount per Min. Qty.","Total Discount %","Total Discount Amt. per Min. Qty.","Priority Discount per Min. Qty","Multiple Discount Levels";

            trigger OnValidate()
            begin
                //-NPR5.55 [412946]
                if "Discount Type" = "Discount Type"::"Multiple Discount Levels" then
                    Lot := false;
                //+NPR5.55 [412946]
            end;
        }
        field(18; "Total Discount %"; Decimal)
        {
            Caption = 'Total Discount %';
            Description = 'NPR5.31';
        }
        field(19; "Block Custom Discount"; Boolean)
        {
            Caption = 'Block Custom Discount';
        }
        field(20; "Max. Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
        }
        field(25; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            Description = 'NPR5.31';
        }
        field(30; "Item Discount Qty."; Decimal)
        {
            Caption = 'Item Discount Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
        }
        field(35; "Item Discount %"; Decimal)
        {
            Caption = 'Item Discount %';
            Description = 'NPR5.31';
        }
        field(40; "Total Amount Excl. VAT"; Boolean)
        {
            Caption = 'Total Amount Excl. VAT';
            Description = 'NPR5.40';
        }
        field(100; "Mix Type"; Option)
        {
            Caption = 'Mix Type';
            Description = 'NPR5.31';
            OptionCaption = 'Standard,Combination,Combination Part';
            OptionMembers = Standard,Combination,"Combination Part";
        }
        field(200; "Quantity sold"; Decimal)
        {
            CalcFormula = - Sum ("Item Ledger Entry".Quantity WHERE("NPR Discount Type" = CONST(Mixed),
                                                                   "NPR Discount Code" = FIELD(Code)));
            Caption = 'Sold Qty';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; Turnover; Decimal)
        {
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE("NPR Discount Type" = CONST(Mixed),
                                                                           "NPR Discount Code" = FIELD(Code)));
            Caption = 'Turnover';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "Customer Disc. Group Filter"; Text[250])
        {
            Caption = 'Customer Disc. Group Filter';
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                CustomerDiscountGroup: Record "Customer Discount Group";
            begin
                //-NPR5.31 [263093]
                "Customer Disc. Group Filter" := UpperCase("Customer Disc. Group Filter");
                CustomerDiscountGroup.SetFilter(Code, "Customer Disc. Group Filter");
                "Customer Disc. Group Filter" := CustomerDiscountGroup.GetFilter(Code);
                //+NPR5.31 [263093]
            end;
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
                Modify;
            end;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
                Modify;
            end;
        }
        field(318; "Campaign Ref."; Code[20])
        {
            Caption = 'Period Discount';
            TableRelation = "NPR Period Discount";

            trigger OnValidate()
            begin
                //-NPR5.31 [262904]
                // IF Periodrabat.GET("Campaign Ref.") THEN
                //  "Starting date" := Periodrabat."Starting Date";
                // "Ending date" := Periodrabat."Ending Date";
                //+NPR5.31 [262904]
            end;
        }
        field(500; "Actual Discount Amount"; Decimal)
        {
            Caption = 'Actual Discount Amount';
        }
        field(505; "Actual Item Qty."; Decimal)
        {
            Caption = 'Actual Item Qty.';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Starting date", "Starting time", "Ending date", "Ending time")
        {
        }
        key(Key3; "Ending date", "Ending time")
        {
        }
        key(Key4; "Actual Discount Amount", "Actual Item Qty.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        MixedDiscountLine.SetRange(Code, Code);
        MixedDiscountLine.DeleteAll(true);

        RecRef.GetTable(Rec);
        SyncCU.OnDelete(RecRef);

        //-NPR5.31 [262904]
        //RetailSetup.GET;
        MixedDiscountLine.SetRange(Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        MixedDiscountLine.SetRange("No.", Code);
        MixedDiscountLine.DeleteAll(true);
        //+NPR5.31 [262904]
        DimMgt.DeleteDefaultDim(DATABASE::"NPR Mixed Discount", Code);
    end;

    trigger OnInsert()
    var
        DatePeriod: Record Date;
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        "Created the" := Today;
        RetailSetup.Get;
        "Unit price incl VAT" := RetailSetup."Prices Include VAT";
        DatePeriod.SetRange("Period Type", DatePeriod."Period Type"::Date);
        "Starting date" := Today;
        if DatePeriod.FindLast then
            "Ending date" := DatePeriod."Period Start";

        if Code = '' then begin
            RetailSetup.Get;
            RetailSetup.TestField("Mixed Discount No. Management");
            NoSeriesMgt.InitSeries(RetailSetup."Mixed Discount No. Management", xRec."No. Serie", 0D, Code, "No. Serie");
        end;

        RecRef.GetTable(Rec);
        SyncCU.OnInsert(RecRef);

        //-NPR5.31 [262904]
        //RetailSetup.GET;
        //+NPR5.31 [262904]

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Mixed Discount", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");

        //-NPR5.40 [294655]
        UpdateLines();
        //-NPR5.40 [294655]
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        RecRef.GetTable(Rec);
        SyncCU.OnModify(RecRef);

        //-NPR5.40 [294655]
        UpdateLines();
        //-NPR5.40 [294655]
    end;

    var
        Text000: Label 'Checking Item No.: #1########\Mix Line:          #2######## of #3########';
        Text001: Label 'The following Lines are already active on other Mixed Discounts:\ %1\\Continue?';
        Text002: Label '\  - %1 %2 (%3)';
        Text1060000: Label 'This field cannot be changed. Modification is done via NPK Retail configuration!';
        RetailSetup: Record "NPR Retail Setup";
        StatusErr: Label 'Mix discount configuration not activated.';
        "//-SyncProfiles": Integer;
        SyncCU: Codeunit "NPR CompanySyncManagement";
        RecRef: RecordRef;
        "//+SyncProfiles": Integer;

    procedure Assistedit(MixedDiscount: Record "NPR Mixed Discount"): Boolean
    var
        MixedDiscount2: Record "NPR Mixed Discount";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        with MixedDiscount2 do begin
            MixedDiscount2 := Rec;
            RetailSetup.Get;
            RetailSetup.TestField("Mixed Discount No. Management");
            if NoSeriesMgt.SelectSeries(RetailSetup."Mixed Discount No. Management", MixedDiscount."No. Serie", "No. Serie") then begin
                RetailSetup.Get;
                RetailSetup.TestField("Mixed Discount No. Management");
                NoSeriesMgt.SetSeries(Code);
                Rec := MixedDiscount2;
                exit(true);
            end;
        end;
    end;

    procedure CalcMinQty() MinQty: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        //-NPR5.31 [262904]
        if "Mix Type" = "Mix Type"::Combination then begin
            MinQty := 0;
            MixedDiscountLine.SetRange(Code, Code);
            MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
            if MixedDiscountLine.IsEmpty then
                exit(0);

            MixedDiscountLine.FindSet;
            repeat
                if MixedDiscount.Get(MixedDiscountLine."No.") then
                    MinQty += MixedDiscount.CalcMinQty();
            until MixedDiscountLine.Next = 0;
            exit(MinQty);
        end;

        if not Lot then
            exit("Min. Quantity");

        MixedDiscountLine.SetRange(Code, Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item, MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        MixedDiscountLine.CalcSums(Quantity);
        exit(MixedDiscountLine.Quantity);
        //+NPR5.31 [262904]
    end;

    local procedure TestStatus()
    var
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        MixedDiscountLine2: Record "NPR Mixed Discount Line";
        TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary;
        Counter: Integer;
        Total: Integer;
        Window: Dialog;
        LineText: Text;
    begin
        //-NPR5.31 [262904]
        if not GuiAllowed then
            exit;

        MixedDiscountLine.SetRange(Code, Code);
        case "Mix Type" of
            "Mix Type"::Standard, "Mix Type"::"Combination Part":
                MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item, MixedDiscountLine."Disc. Grouping Type"::"Item Group");
            "Mix Type"::Combination:
                MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        end;
        if MixedDiscountLine.IsEmpty then
            exit;

        Counter := 0;
        Total := MixedDiscountLine.Count;
        Window.Open(Text000);
        Window.Update(3, Total);

        MixedDiscountLine.FindSet;
        repeat
            Counter += 1;
            Window.Update(1, MixedDiscountLine."No.");
            Window.Update(2, Counter);

            MixedDiscountLine2.SetFilter(Code, '<>%1', MixedDiscountLine.Code);
            MixedDiscountLine2.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type");
            MixedDiscountLine2.SetRange("No.", MixedDiscountLine."No.");
            MixedDiscountLine2.SetRange(Status, MixedDiscountLine2.Status::Active);
            if MixedDiscountLine2.FindSet then begin
                repeat
                    if (MixedDiscount.Get(MixedDiscountLine2.Code)) and (MixedDiscount."Starting date" <= Today) and (MixedDiscount."Ending date" >= Today) then begin
                        TempMixedDiscountLine.Init;
                        TempMixedDiscountLine := MixedDiscountLine2;
                        TempMixedDiscountLine.Insert;

                        MixedDiscountLine2.FindLast;
                    end;
                until MixedDiscountLine2.Next = 0;
            end;
        until MixedDiscountLine.Next = 0;
        Window.Close;

        if TempMixedDiscountLine.IsEmpty then
            exit;

        TempMixedDiscountLine.FindSet;
        repeat
            LineText += StrSubstNo(Text002, TempMixedDiscountLine."Disc. Grouping Type", TempMixedDiscountLine."No.", TempMixedDiscountLine.Code);
        until TempMixedDiscountLine.Next = 0;
        TempMixedDiscountLine.DeleteAll;

        if not Confirm(StrSubstNo(Text001, LineText), true) then
            Error(StatusErr);
        //+NPR5.31 [262904]
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        //-NPR5.31 [263093]
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Mixed Discount", Code, FieldNumber, ShortcutDimCode);
        Modify;
        //+NPR5.31 [263093]
    end;

    local procedure UpdateLines()
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        MixedDiscountPart: Record "NPR Mixed Discount";
    begin
        //-NPR5.40 [294655]
        if IsTemporary then
            exit;

        MixedDiscountLine.SetRange(Code, Code);
        if MixedDiscountLine.FindSet then
            repeat
                MixedDiscountLine."Starting Date" := "Starting date";
                MixedDiscountLine."Ending Date" := "Ending date";
                MixedDiscountLine.Status := Status;
                MixedDiscountLine."Starting Time" := "Starting time";
                MixedDiscountLine."Ending Time" := "Ending time";
                MixedDiscountLine.Modify;

                //-NPR5.45 [327277]
                if MixedDiscountLine."Disc. Grouping Type" = MixedDiscountLine."Disc. Grouping Type"::"Mix Discount" then begin
                    MixedDiscountPart.Get(MixedDiscountLine."No.");
                    MixedDiscountPart."Starting date" := "Starting date";
                    MixedDiscountPart."Ending date" := "Ending date";
                    MixedDiscountPart.Status := Status;
                    MixedDiscountPart."Starting time" := "Starting time";
                    MixedDiscountPart."Ending time" := "Ending time";
                    MixedDiscountPart.Modify(true);
                end;
            //+NPR5.45 [327277]
            until MixedDiscountLine.Next = 0;
        //+NPR5.40 [294655]
    end;
}

