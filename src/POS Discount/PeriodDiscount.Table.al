table 6014413 "NPR Period Discount"
{
    // Ohm - 05.10.04 - IF Status = Status::Aktiv // alle steder
    // //+NPR Sag 84805 opdater start og slut dato miksrabat.
    // NPR70.00.01.00/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR4.14/MHA /20150818  CASE 220972 Deleted deprecated Web fields
    // NPR5.27/TJ  /20160926  CASE 248282 Removing unused variables and fields, renaming fields and variables to use standard naming procedures
    // NPR5.29/BHR /20161119  CASE 257922 Filter on time
    // NPR5.29/JC  /20160110  CASE 261710 Fixed issue with Dimenison wrong table
    // NPR5.31/MHA /20170213  CASE 265229 Added field 310 "Customer Disc. Group Filter" to be used as filter
    // NPR5.38/MHA /20171106  CASE 295330 Renamed Option "Balanced" to "Closed" for field 5 "Status"
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization
    // NPR5.42/MHA /20180521  CASE 315554 Added Period Fields to enable Weekly Condition

    Caption = 'Period Discount';
    LookupPageID = "NPR Campaign Discount List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';

            trigger OnValidate()
            begin
                //IF Status = Status::Aktiv THEN ERROR(Text1060001);

                if Code <> xRec.Code then begin
                    NoSeriesMgt.TestManual("No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Ending Date" <> 0D) and ("Ending Date" < "Starting Date") then
                    Error(Text1060002);
                //IF Status = Status::Aktiv THEN ERROR(Text1060003);
                //-NPR5.31 [265229]
                // //+NPR Sag 84805
                // MixedDiscount.SETRANGE("Campaign Ref.",Code);
                // IF MixedDiscount.FIND('-') THEN
                //  REPEAT
                //    MixedDiscount."Starting date":= "Starting Date";
                //    MixedDiscount.MODIFY;
                //  UNTIL MixedDiscount.NEXT=0;
                // //-NPR Sag 84805
                //+NPR5.31 [265229]
            end;
        }
        field(4; "Ending Date"; Date)
        {
            Caption = 'Closing Date';

            trigger OnValidate()
            begin
                if ("Starting Date" <> 0D) and ("Ending Date" < "Starting Date") then
                    Error(Text1060002);

                //IF Status = Status::Aktiv THEN ERROR(Text1060004);
                //-NPR5.31 [265229]
                // //+NPR Sag 84805
                // MixedDiscount.SETRANGE("Campaign Ref.",Code);
                // IF MixedDiscount.FIND('-') THEN
                //  REPEAT
                //    MixedDiscount."Ending date":= "Ending Date";
                //    MixedDiscount.MODIFY;
                //  UNTIL MixedDiscount.NEXT=0;
                // //-NPR Sag 84805
                //+NPR5.31 [265229]
            end;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Await,Active,Closed';
            OptionMembers = Await,Active,Closed;

            trigger OnValidate()
            begin
                TestField("Starting Date");
                TestField("Ending Date");
                if Status <> xRec.Status then
                    if Status = Status::Active then begin
                        PeriodDiscountLine2.Reset;
                        PeriodDiscountLine2.SetRange(Status, Status::Active);
                        PeriodDiscountLine2.SetFilter("Starting Date", '<=%1', "Ending Date");
                        PeriodDiscountLine2.SetFilter("Ending Date", '>=%1', "Starting Date");
                        //-NPR5.29 [257922]
                        PeriodDiscountLine2.SetFilter("Starting Time", '<=%1', "Ending Time");
                        PeriodDiscountLine2.SetFilter("Ending Time", '>=%1', "Starting Time");
                        //+NPR5.29 [257922]
                        PeriodDiscountLine.Reset;
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
                            until PeriodDiscountLine2.Next = 0;
                    end;
            end;
        }
        field(10; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(11; "Last Date Modified"; Date)
        {
            Caption = 'Modified Date';
            Editable = false;
        }
        field(20; Comment; Boolean)
        {
            CalcFormula = Exist ("NPR Retail Comment" WHERE("Table ID" = CONST(6014413),
                                                        "No." = FIELD(Code)));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
        field(22; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
        }
        field(23; "Ending Time"; Time)
        {
            Caption = 'Closing Time';
        }
        field(28; "Block Custom Disc."; Boolean)
        {
            Caption = 'Block Custom Discount';
        }
        field(100; "Period Type"; Option)
        {
            Caption = 'Period Type';
            Description = 'NPR5.42';
            OptionCaption = 'Every Day,Weekly';
            OptionMembers = "Every Day",Weekly;

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
        }
        field(200; "Quantity Sold"; Decimal)
        {
            CalcFormula = - Sum ("Item Ledger Entry".Quantity WHERE("NPR Discount Type" = CONST(Period),
                                                                   "NPR Discount Code" = FIELD(Code),
                                                                   "Global Dimension 1 Code" = FIELD("Global Dimension 1 Code"),
                                                                   "Global Dimension 2 Code" = FIELD("Global Dimension 2 Code")));
            Caption = 'Sold Qty';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; Turnover; Decimal)
        {
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE("NPR Discount Type" = CONST(Period),
                                                                           "NPR Discount Code" = FIELD(Code),
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
            end;
        }
        field(318; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
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
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        CommentLine: Record "Comment Line";
        RetailComment: Record "NPR Retail Comment";
    begin
        RetailSetup.Get;
        PeriodDiscountLine.SetRange(Code, Code);
        PeriodDiscountLine.DeleteAll(true);

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::"Nonstock Item");
        CommentLine.SetRange("No.", Code);
        CommentLine.DeleteAll;

        //+NPR-2.1

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnDelete(RecRef);

        RetailComment.SetRange("Table ID", 6014414);
        RetailComment.SetRange("No.", Code);
        RetailComment.DeleteAll;

        DimMgt.DeleteDefaultDim(DATABASE::"NPR Period Discount", Code);

        //-NPR70.00.01.00
        //RecRef.GETTABLE(Rec);
        //Changelog.OnDelete(RecRef);
        //+NPR70.00.01.00
    end;

    trigger OnInsert()
    var
        Date: Record Date;
    begin
        "Created Date" := Today;

        if Code = '' then begin
            RetailSetup.Get;
            RetailSetup.TestField("Period Discount Management");
            NoSeriesMgt.InitSeries(RetailSetup."Period Discount Management", xRec."No. Series", 0D, Code, "No. Series");
        end;

        Date.SetRange("Period Type", Date."Period Type"::Date);
        "Starting Date" := Today;
        if Date.Find('+') then
            "Ending Date" := Date."Period Start";

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnInsert(RecRef);

        RetailSetup.Get;

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Period Discount", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");

        //-NPR5.40 [294655]
        UpdateLines();
        //+NPR5.40 [294655]
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnModify(RecRef);

        //-NPR5.40 [294655]
        UpdateLines();
        //+NPR5.40 [294655]
    end;

    trigger OnRename()
    var
        RetailComment: Record "NPR Retail Comment";
        RetailComment2: Record "NPR Retail Comment";
    begin
        //IF Status = Status::Aktiv THEN ERROR(Text1060000);
        "Last Date Modified" := Today;
        PeriodDiscountLine.SetRange(Code, Code);
        if PeriodDiscountLine.Find('-') then
            repeat
                PeriodDiscountLine.Code := Code;
            until PeriodDiscountLine.Next = 0;

        RetailComment.SetRange("Table ID", 6014414);
        RetailComment.SetRange("No.", xRec.Code);
        if RetailComment.Find('-') then
            repeat
                RetailComment2.Copy(RetailComment);
                RetailComment2.Validate("No.", Code);
                if not RetailComment2.Insert(true) then
                    RetailComment2.Modify(true);
            until RetailComment.Next = 0;
        RetailComment.DeleteAll;

        //-NPR70.00.01.00
        //RecRef.GETTABLE(Rec);
        //xRecRef.GETTABLE(xRec);
        //Changelog.OnRename(RecRef,xRecRef);
        //+NPR70.00.01.00
    end;

    var
        Text1060002: Label 'You have entered a period where the starting date is later than the closing date!';
        Text1060005: Label 'Item %1 is a part of the active period management %1, but\';
        Text1060006: Label 'with a different offer.\\';
        Text1060007: Label 'Period price: %3 <> %4';
        PeriodDiscountLine: Record "NPR Period Discount Line";
        PeriodDiscountLine2: Record "NPR Period Discount Line";
        MixedDiscount: Record "NPR Mixed Discount";
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PeriodDiscount: Record "NPR Period Discount";
        DimMgt: Codeunit DimensionManagement;
        CompanySyncMgt: Codeunit "NPR CompanySyncManagement";
        RecRef: RecordRef;

    procedure AssistEdit(PeriodDisc: Record "NPR Period Discount"): Boolean
    begin
        with PeriodDiscount do begin
            PeriodDiscount := Rec;
            RetailSetup.Get;
            RetailSetup.TestField("Period Discount Management");
            if NoSeriesMgt.SelectSeries(RetailSetup."Period Discount Management", PeriodDisc."No. Series", "No. Series") then begin
                RetailSetup.Get;
                RetailSetup.TestField("Period Discount Management");
                NoSeriesMgt.SetSeries(Code);
                Rec := PeriodDiscount;
                exit(true);
            end;
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        //-NPR5.29 [261710]
        //DimMgt.SaveDefaultDim(DATABASE::Customer,Code,FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Period Discount", Code, FieldNumber, ShortcutDimCode);
        //+NPR5.29 [261710]
        Modify;
    end;

    local procedure UpdateLines()
    var
        PeriodDiscountLines: Record "NPR Period Discount Line";
    begin
        //-NPR5.40 [294655]
        if IsTemporary then
            exit;

        PeriodDiscountLines.SetRange(Code, Code);
        if PeriodDiscountLines.FindSet then
            repeat
                PeriodDiscountLines."Starting Date" := "Starting Date";
                PeriodDiscountLines."Ending Date" := "Ending Date";
                PeriodDiscountLines."Starting Time" := "Starting Time";
                PeriodDiscountLines."Ending Time" := "Ending Time";
                PeriodDiscountLines.Status := Status;
                PeriodDiscountLines.Modify;
            until PeriodDiscountLines.Next = 0;
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

