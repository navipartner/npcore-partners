table 6014413 "NPR Period Discount"
{
    Caption = 'Period Discount';
    LookupPageID = "NPR Campaign Discount List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Code <> xRec.Code then begin
                    NoSeriesMgt.TestManual("No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Ending Date" <> 0D) and ("Ending Date" < "Starting Date") then
                    Error(Text1060002);
            end;
        }
        field(4; "Ending Date"; Date)
        {
            Caption = 'Closing Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Starting Date" <> 0D) and ("Ending Date" < "Starting Date") then
                    Error(Text1060002);
            end;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Await,Active,Closed';
            OptionMembers = Await,Active,Closed;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Starting Date");
                TestField("Ending Date");
                if Status <> xRec.Status then
                    if Status = Status::Active then begin
                        PeriodDiscountLine2.Reset();
                        PeriodDiscountLine2.SetRange(Status, Status::Active);
                        PeriodDiscountLine2.SetFilter("Starting Date", '<=%1', "Ending Date");
                        PeriodDiscountLine2.SetFilter("Ending Date", '>=%1', "Starting Date");
                        //-NPR5.29 [257922]
                        PeriodDiscountLine2.SetFilter("Starting Time", '<=%1', "Ending Time");
                        PeriodDiscountLine2.SetFilter("Ending Time", '>=%1', "Starting Time");
                        //+NPR5.29 [257922]
                        PeriodDiscountLine.Reset();
                        PeriodDiscountLine.SetRange(Code, Code);
                        if PeriodDiscountLine2.Find('-') then
                            repeat
                                if PeriodDiscountLine.Get(Code, PeriodDiscountLine2."Item No.") then
                                    if PeriodDiscountLine."Campaign Unit Price" <> PeriodDiscountLine2."Campaign Unit Price" then
                                        Message(Text1060005 +
                                              Text1060006 +
                                              Text1060007, PeriodDiscountLine."Item No.",
                                                                    PeriodDiscountLine2.Code,
                                                                    PeriodDiscountLine."Campaign Unit Price",
                                                                    PeriodDiscountLine2."Campaign Unit Price");
                            until PeriodDiscountLine2.Next() = 0;
                    end;
            end;
        }
        field(10; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11; "Last Date Modified"; Date)
        {
            Caption = 'Modified Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(22; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(23; "Ending Time"; Time)
        {
            Caption = 'Closing Time';
            DataClassification = CustomerContent;
        }
        field(28; "Block Custom Disc."; Boolean)
        {
            Caption = 'Block Custom Discount';
            DataClassification = CustomerContent;
        }
        field(100; "Period Type"; Option)
        {
            Caption = 'Period Type';
            Description = 'NPR5.42';
            OptionCaption = 'Every Day,Weekly';
            OptionMembers = "Every Day",Weekly;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(105; Monday; Boolean)
        {
            Caption = 'Monday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(110; Tuesday; Boolean)
        {
            Caption = 'Tuesday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(115; Wednesday; Boolean)
        {
            Caption = 'Wednesday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(120; Thursday; Boolean)
        {
            Caption = 'Thursday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(125; Friday; Boolean)
        {
            Caption = 'Friday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(130; Saturday; Boolean)
        {
            Caption = 'Saturday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(135; Sunday; Boolean)
        {
            Caption = 'Sunday';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.42 [315554]
                UpdatePeriodDescription();
                //+NPR5.42 [315554]
            end;
        }
        field(140; "Period Description"; Text[250])
        {
            Caption = 'Period Description';
            Description = 'NPR5.42';
            DataClassification = CustomerContent;
        }
        field(200; "Quantity Sold"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Item Ledger Entry".Quantity
                                WHERE(
                                    "Discount Type" = CONST(Period),
                                    "Discount Code" = FIELD(Code),
                                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Code"),
                                    "Global Dimension 2 Code" = FIELD("Global Dimension 2 Code")));
            Caption = 'Sold Qty';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; Turnover; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Discount Type" = CONST(Period),
                                "Discount Code" = FIELD(Code),
                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Code"),
                                "Global Dimension 2 Code" = FIELD("Global Dimension 2 Code")));
            Caption = 'Sold Amount';
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
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
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
            end;
        }
        field(318; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
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
        key(Key2; Description)
        {
        }
        key(Key3; Status)
        {
        }
        key(Key4; "Starting Date", "Starting Time", "Ending Date", "Ending Time")
        {
        }

        key(Key5; "Replication Counter")
        {
        }
    }

    fieldgroups
    {
    }


    trigger OnDelete()
    var
        CommentLine: Record "Comment Line";
        RetailComment: Record "NPR Retail Comment";
    begin
        PeriodDiscountLine.SetRange(Code, Code);
        PeriodDiscountLine.DeleteAll(true);

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::"Nonstock Item");
        CommentLine.SetRange("No.", Code);
        CommentLine.DeleteAll();

        RetailComment.SetRange("Table ID", 6014414);
        RetailComment.SetRange("No.", Code);
        RetailComment.DeleteAll();

        DimMgt.DeleteDefaultDim(DATABASE::"NPR Period Discount", Code);
    end;

    trigger OnInsert()
    var
        Date: Record Date;
    begin
        "Created Date" := Today();

        if Code = '' then
            NoSeriesMgt.InitSeries(GetNoSeries(), xRec."No. Series", 0D, Code, "No. Series");

        Date.SetRange("Period Type", Date."Period Type"::Date);
        "Starting Date" := Today();
        if Date.Find('+') then
            "Ending Date" := Date."Period Start";

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Period Discount", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");

        UpdateLines();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
        UpdateLines();
    end;

    trigger OnRename()
    var
        RetailComment: Record "NPR Retail Comment";
        RetailComment2: Record "NPR Retail Comment";
    begin
        "Last Date Modified" := Today();
        PeriodDiscountLine.SetRange(Code, Code);
        if PeriodDiscountLine.Find('-') then
            repeat
                PeriodDiscountLine.Code := Code;
            until PeriodDiscountLine.Next() = 0;

        RetailComment.SetRange("Table ID", 6014414);
        RetailComment.SetRange("No.", xRec.Code);
        if RetailComment.Find('-') then
            repeat
                RetailComment2.Copy(RetailComment);
                RetailComment2.Validate("No.", Code);
                if not RetailComment2.Insert(true) then
                    RetailComment2.Modify(true);
            until RetailComment.Next() = 0;
        RetailComment.DeleteAll();
    end;

    var
        Text1060002: Label 'You have entered a period where the starting date is later than the closing date!';
        Text1060005: Label 'Item %1 is a part of the active period management %1, but\';
        Text1060006: Label 'with a different offer.\\';
        Text1060007: Label 'Period price: %3 <> %4';
        PeriodDiscountLine: Record "NPR Period Discount Line";
        PeriodDiscountLine2: Record "NPR Period Discount Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PeriodDiscount: Record "NPR Period Discount";
        DimMgt: Codeunit DimensionManagement;

    internal procedure AssistEdit(PeriodDisc: Record "NPR Period Discount"): Boolean
    begin
        PeriodDiscount := Rec;
        if NoSeriesMgt.SelectSeries(GetNoSeries(), PeriodDisc."No. Series", PeriodDiscount."No. Series") then begin
            NoSeriesMgt.SetSeries(PeriodDiscount.Code);
            Rec := PeriodDiscount;
            exit(true);
        end;
    end;

    local procedure GetNoSeries(): Code[20]
    var
        PeriodDiscountMgt: Codeunit "NPR Period Discount Management";
    begin
        exit(PeriodDiscountMgt.GetNoSeries());
    end;

    internal procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        //-NPR5.29 [261710]
        //DimMgt.SaveDefaultDim(DATABASE::Customer,Code,FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Period Discount", Code, FieldNumber, ShortcutDimCode);
        //+NPR5.29 [261710]
        Modify();
    end;

    local procedure UpdateLines()
    var
        PeriodDiscountLines: Record "NPR Period Discount Line";
    begin
        //-NPR5.40 [294655]
        if IsTemporary then
            exit;

        PeriodDiscountLines.SetRange(Code, Code);
        if PeriodDiscountLines.FindSet() then
            repeat
                PeriodDiscountLines."Starting Date" := "Starting Date";
                PeriodDiscountLines."Ending Date" := "Ending Date";
                PeriodDiscountLines."Starting Time" := "Starting Time";
                PeriodDiscountLines."Ending Time" := "Ending Time";
                PeriodDiscountLines.Status := Status;
                PeriodDiscountLines.Modify();
            until PeriodDiscountLines.Next() = 0;
        //+NPR5.40 [294655]
    end;

    local procedure UpdatePeriodDescription()
    begin
        //-NPR5.42 [315554]
        "Period Description" := '';
        if "Period Type" = "Period Type"::"Every Day" then
            exit;

        if Monday then
            AppendPeriodDescription(FieldCaption(Monday));
        if Tuesday then
            AppendPeriodDescription(FieldCaption(Tuesday));
        if Wednesday then
            AppendPeriodDescription(FieldCaption(Wednesday));
        if Thursday then
            AppendPeriodDescription(FieldCaption(Thursday));
        if Friday then
            AppendPeriodDescription(FieldCaption(Friday));
        if Saturday then
            AppendPeriodDescription(FieldCaption(Saturday));
        if Sunday then
            AppendPeriodDescription(FieldCaption(Sunday));
        //+NPR5.42 [315554]
    end;

    local procedure AppendPeriodDescription(PeriodDescription: Text)
    begin
        //-NPR5.42 [315554]
        if PeriodDescription = '' then
            exit;

        if "Period Description" <> '' then
            "Period Description" := CopyStr("Period Description" + ',' + PeriodDescription, 1, MaxStrLen("Period Description"))
        else
            "Period Description" := CopyStr(PeriodDescription, 1, MaxStrLen("Period Description"));
        //+NPR5.42 [315554]
    end;
}

