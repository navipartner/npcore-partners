﻿table 6014411 "NPR Mixed Discount"
{
    Access = Public;
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
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                NoSeriesMgt: Codeunit "No. Series";
#ELSE
                NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
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
                DateErr: Label 'Invalid Starting Date';
            begin
                if "Ending date" <> 0D then
                    if "Ending date" < "Starting date" then
                        Error(DateErr);
            end;
        }
        field(12; "Ending date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DateErr: Label 'Invalid Closing Date';
            begin
                if "Starting date" <> 0D then
                    if "Ending date" < "Starting date" then
                        Error(DateErr);
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
            CalcFormula = - Sum("NPR POS Entry Sales Line".Quantity
                                WHERE(
                                    "Discount Type" = CONST(Mix),
                                    "Discount Code" = FIELD(Code)));
            Caption = 'Sold Qty';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; Turnover; Decimal)
        {
            Caption = 'Turnover';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Aux Value Entry has been removed and this field directly reimplemented on references.';
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
                "Customer Disc. Group Filter" := CopyStr(CustomerDiscountGroup.GetFilter(Code), 1, MaxStrLen("Customer Disc. Group Filter"));
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

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
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

        key(Key5; "Replication Counter")
        {
        }
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
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
        NoSeries: Code[20];
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        "Created the" := Today();
        DatePeriod.SetRange("Period Type", DatePeriod."Period Type"::Date);
        "Starting date" := Today();
        if DatePeriod.FindLast() then
            "Ending date" := DatePeriod."Period Start";

        if Code = '' then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NoSeries := GetNoSeries();
            "No. Serie" := NoSeries;
            if NoSeriesMgt.AreRelated(NoSeries, xRec."No. Serie") then
                "No. Serie" := xRec."No. Serie";
            Code := NoSeriesMgt.GetNextNo("No. Serie");
#ELSE
            NoSeriesMgt.InitSeries(GetNoSeries(), xRec."No. Serie", 0D, Code, "No. Serie");
#ENDIF
        end;

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
        CheckingItemLbl: Label 'Checking Item No.: #1########\Mix Line:          #2######## of #3########';
        ActiveLinesQst: Label 'The following Lines are already active on other Mixed Discounts:\ %1\\Continue?', Comment = '%1 = Line description';
        LineTextlbl: Label '\  - %1 %2 (%3)';
        StatusErr: Label 'Mix discount configuration not activated.';

    procedure Assistedit(MixedDiscount: Record "NPR Mixed Discount"): Boolean
    var
        MixedDiscount2: Record "NPR Mixed Discount";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        MixedDiscount2 := Rec;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        if NoSeriesMgt.LookupRelatedNoSeries(GetNoSeries(), MixedDiscount."No. Serie", MixedDiscount2."No. Serie") then begin
            MixedDiscount2.Code := NoSeriesMgt.GetNextNo(MixedDiscount2."No. Serie");
#ELSE
        if NoSeriesMgt.SelectSeries(GetNoSeries(), MixedDiscount."No. Serie", MixedDiscount2."No. Serie") then begin
            NoSeriesMgt.SetSeries(MixedDiscount2.Code);
#ENDIF
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
        ExitLoop: Boolean;
    begin
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
        Window.Open(CheckingItemLbl);
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
                ExitLoop := false;
                repeat
                    if (MixedDiscount.Get(MixedDiscountLine2.Code)) and (MixedDiscount."Starting date" <= Today) and (MixedDiscount."Ending date" >= Today) then begin
                        TempMixedDiscountLine.Init();
                        TempMixedDiscountLine := MixedDiscountLine2;
                        TempMixedDiscountLine.Insert();

                        ExitLoop := true;
                    end;
                until (MixedDiscountLine2.Next() = 0) or ExitLoop;
            end;
        until MixedDiscountLine.Next() = 0;
        Window.Close();

        if TempMixedDiscountLine.IsEmpty then
            exit;

        TempMixedDiscountLine.FindSet();
        repeat
            LineText += StrSubstNo(LineTextlbl, TempMixedDiscountLine."Disc. Grouping Type", TempMixedDiscountLine."No.", TempMixedDiscountLine.Code);
        until TempMixedDiscountLine.Next() = 0;
        TempMixedDiscountLine.DeleteAll();

        if not Confirm(StrSubstNo(ActiveLinesQst, LineText), true) then
            Error(StatusErr);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Mixed Discount", Code, FieldNumber, ShortcutDimCode);
        Modify();
    end;

    local procedure UpdateLines()
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        MixedDiscountPart: Record "NPR Mixed Discount";
    begin
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

                if MixedDiscountLine."Disc. Grouping Type" = MixedDiscountLine."Disc. Grouping Type"::"Mix Discount" then begin
                    MixedDiscountPart.Get(MixedDiscountLine."No.");
                    MixedDiscountPart."Starting date" := "Starting date";
                    MixedDiscountPart."Ending date" := "Ending date";
                    MixedDiscountPart.Status := Status;
                    MixedDiscountPart."Starting time" := "Starting time";
                    MixedDiscountPart."Ending time" := "Ending time";
                    MixedDiscountPart.Modify(true);
                end;
            until MixedDiscountLine.Next() = 0;
    end;

    internal procedure AbsoluteAmountDiscount(): Boolean
    begin
        exit(
            "Discount Type" in
                ["Discount Type"::"Total Amount per Min. Qty.",
                 "Discount Type"::"Total Discount Amt. per Min. Qty.",
                 "Discount Type"::"Multiple Discount Levels"]);
    end;
}
