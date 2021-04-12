table 6014411 "NPR Mixed Discount"
{
    Caption = 'Mixed Discount';
    LookupPageID = "NPR Mixed Discount List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
        }
        field(4; "Min. Quantity"; Decimal)
        {
            Caption = 'Min. Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            MinValue = 1;
            DataClassification = CustomerContent;
        }
        field(5; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Description = 'NPR5.31';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(6; "Created the"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(7; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            Description = 'NPR5.38';
            OptionCaption = 'Pending,Active,Closed';
            OptionMembers = Pending,Active,Closed;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Status = Status::Active then begin
                    TestField("Starting date");
                    TestField("Ending date");
                    if (not Lot) and ("Mix Type" = 0) then
                        TestField("Min. Quantity");
                    TestStatus();
                end;
            end;
        }
        field(10; "No. Serie"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(11; "Starting date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
        }
        field(14; "Ending time"; Time)
        {
            Caption = 'End Time';
            DataClassification = CustomerContent;
        }
        field(15; Lot; Boolean)
        {
            Caption = 'Lot';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Lot and ("Discount Type" = "Discount Type"::"Multiple Discount Levels") then
                    FieldError("Discount Type");
            end;
        }
        field(17; "Discount Type"; Enum "NPR Mixed Discount Type")
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Discount Type" = "Discount Type"::"Multiple Discount Levels" then
                    Lot := false;
            end;
        }
        field(18; "Total Discount %"; Decimal)
        {
            Caption = 'Total Discount %';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(19; "Block Custom Discount"; Boolean)
        {
            Caption = 'Block Custom Discount';
            DataClassification = CustomerContent;
        }
        field(20; "Max. Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(25; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(30; "Item Discount Qty."; Decimal)
        {
            Caption = 'Item Discount Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(35; "Item Discount %"; Decimal)
        {
            Caption = 'Item Discount %';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(40; "Total Amount Excl. VAT"; Boolean)
        {
            Caption = 'Total Amount Excl. VAT';
            Description = 'NPR5.40';
            DataClassification = CustomerContent;
        }
        field(100; "Mix Type"; Option)
        {
            Caption = 'Mix Type';
            Description = 'NPR5.31';
            OptionCaption = 'Standard,Combination,Combination Part';
            OptionMembers = Standard,Combination,"Combination Part";
            DataClassification = CustomerContent;
        }
        field(200; "Quantity sold"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Item Ledger Entry".Quantity
                                WHERE(
                                    "Discount Type" = CONST(Mixed),
                                    "Discount Code" = FIELD(Code)));
            Caption = 'Sold Qty';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; Turnover; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Discount Type" = CONST(Mixed),
                                "Discount Code" = FIELD(Code)));
            Caption = 'Turnover';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "Customer Disc. Group Filter"; Text[250])
        {
            Caption = 'Customer Disc. Group Filter';
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CustomerDiscountGroup: Record "Customer Discount Group";
            begin
                "Customer Disc. Group Filter" := UpperCase("Customer Disc. Group Filter");
                CustomerDiscountGroup.SetFilter(Code, "Customer Disc. Group Filter");
                "Customer Disc. Group Filter" := CustomerDiscountGroup.GetFilter(Code);
            end;
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
                Modify();
            end;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
                Modify();
            end;
        }
        field(318; "Campaign Ref."; Code[20])
        {
            Caption = 'Period Discount';
            TableRelation = "NPR Period Discount";
            DataClassification = CustomerContent;
        }
        field(500; "Actual Discount Amount"; Decimal)
        {
            Caption = 'Actual Discount Amount';
            DataClassification = CustomerContent;
        }
        field(505; "Actual Item Qty."; Decimal)
        {
            Caption = 'Actual Item Qty.';
            DataClassification = CustomerContent;
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

        MixedDiscountLine.SetRange(Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        MixedDiscountLine.SetRange("No.", Code);
        MixedDiscountLine.DeleteAll(true);
        DimMgt.DeleteDefaultDim(DATABASE::"NPR Mixed Discount", Code);
    end;

    trigger OnInsert()
    var
        DatePeriod: Record Date;
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        "Created the" := Today();
        DatePeriod.SetRange("Period Type", DatePeriod."Period Type"::Date);
        "Starting date" := Today();
        if DatePeriod.FindLast() then
            "Ending date" := DatePeriod."Period Start";

        if Code = '' then
            NoSeriesMgt.InitSeries(GetNoSeries(), xRec."No. Serie", 0D, Code, "No. Serie");

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Mixed Discount", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");

        UpdateLines();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
        UpdateLines();
    end;

    var
        Text000: Label 'Checking Item No.: #1########\Mix Line:          #2######## of #3########';
        Text001: Label 'The following Lines are already active on other Mixed Discounts:\ %1\\Continue?';
        Text002: Label '\  - %1 %2 (%3)';
        StatusErr: Label 'Mix discount configuration not activated.';

    procedure Assistedit(MixedDiscount: Record "NPR Mixed Discount"): Boolean
    var
        MixedDiscount2: Record "NPR Mixed Discount";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        MixedDiscount2 := Rec;
        if NoSeriesMgt.SelectSeries(GetNoSeries(), MixedDiscount."No. Serie", MixedDiscount2."No. Serie") then begin
            NoSeriesMgt.SetSeries(MixedDiscount2.Code);
            Rec := MixedDiscount2;
            exit(true);
        end;
    end;

    local procedure GetNoSeries(): Code[20]
    var
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
    begin
        exit(MixedDiscountMgt.GetNoSeries());
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

            MixedDiscountLine.FindSet();
            repeat
                if MixedDiscount.Get(MixedDiscountLine."No.") then
                    MinQty += MixedDiscount.CalcMinQty();
            until MixedDiscountLine.Next() = 0;
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
        Total := MixedDiscountLine.Count();
        Window.Open(Text000);
        Window.Update(3, Total);

        MixedDiscountLine.FindSet();
        repeat
            Counter += 1;
            Window.Update(1, MixedDiscountLine."No.");
            Window.Update(2, Counter);

            MixedDiscountLine2.SetFilter(Code, '<>%1', MixedDiscountLine.Code);
            MixedDiscountLine2.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type");
            MixedDiscountLine2.SetRange("No.", MixedDiscountLine."No.");
            MixedDiscountLine2.SetRange(Status, MixedDiscountLine2.Status::Active);
            if MixedDiscountLine2.FindSet() then begin
                repeat
                    if (MixedDiscount.Get(MixedDiscountLine2.Code)) and (MixedDiscount."Starting date" <= Today) and (MixedDiscount."Ending date" >= Today) then begin
                        TempMixedDiscountLine.Init();
                        TempMixedDiscountLine := MixedDiscountLine2;
                        TempMixedDiscountLine.Insert();

                        MixedDiscountLine2.FindLast();
                    end;
                until MixedDiscountLine2.Next() = 0;
            end;
        until MixedDiscountLine.Next() = 0;
        Window.Close();

        if TempMixedDiscountLine.IsEmpty then
            exit;

        TempMixedDiscountLine.FindSet();
        repeat
            LineText += StrSubstNo(Text002, TempMixedDiscountLine."Disc. Grouping Type", TempMixedDiscountLine."No.", TempMixedDiscountLine.Code);
        until TempMixedDiscountLine.Next() = 0;
        TempMixedDiscountLine.DeleteAll();

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
        Modify();
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
        if MixedDiscountLine.FindSet() then
            repeat
                MixedDiscountLine."Starting Date" := "Starting date";
                MixedDiscountLine."Ending Date" := "Ending date";
                MixedDiscountLine.Status := Status;
                MixedDiscountLine."Starting Time" := "Starting time";
                MixedDiscountLine."Ending Time" := "Ending time";
                MixedDiscountLine.Modify();

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
            until MixedDiscountLine.Next() = 0;
        //+NPR5.40 [294655]
    end;
}

