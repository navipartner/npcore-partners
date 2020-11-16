table 6014439 "NPR Quantity Discount Header"
{
    // NPR4.01/JDH/20150309 CASE 201022 corrected Dimension update
    // NPR5.27/TS/20160809 CASE 248290 Removed fields SalesPerson Filter,Order Due,Delivery week, Valutering and Auto
    // NPR5.27/TJ/20160926 CASE 248290 Removing unused variables and fields, renaming fields and variables to use standard naming procedures

    Caption = 'Multiple Price Header';
    LookupPageID = "NPR Quantity Discount List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;
        }
        field(2; "Main No."; Code[20])
        {
            Caption = 'Main no.';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting date';
            DataClassification = CustomerContent;
        }
        field(5; "Closing Date"; Date)
        {
            Caption = 'Closing Date';
            DataClassification = CustomerContent;
        }
        field(6; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Await,Active,Balanced';
            OptionMembers = Await,Active,Balanced;
            DataClassification = CustomerContent;
        }
        field(7; "Creating Date"; Date)
        {
            Caption = 'Creating date';
            DataClassification = CustomerContent;
        }
        field(11; "Last Date Modified"; Date)
        {
            Caption = 'Modified Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20; Comment; Boolean)
        {
            CalcFormula = Exist ("NPR Retail Comment" WHERE("Table ID" = CONST(6014439),
                                                        "No." = FIELD("Item No."),
                                                        "No. 2" = FIELD("Main No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
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
        field(23; "Closing Time"; Time)
        {
            Caption = 'Closing Time';
            DataClassification = CustomerContent;
        }
        field(28; "Block Custom Discount"; Boolean)
        {
            Caption = 'Block Custom Discount';
            DataClassification = CustomerContent;
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
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
        field(318; "Campaign Ref."; Code[20])
        {
            Caption = 'Period Discount';
            TableRelation = "NPR Period Discount";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Main No.")
        {
        }
        key(Key2; "Item No.", Status, "Starting Date", "Closing Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        QtyDiscLine: Record "NPR Quantity Discount Line";
        RetailComment: Record "NPR Retail Comment";
    begin
        RetailSetup.Get;

        QtyDiscLine.SetRange("Item No.", "Item No.");
        QtyDiscLine.SetRange("Main no.", "Main No.");
        QtyDiscLine.DeleteAll;

        RetailComment.SetRange("Table ID", DATABASE::"NPR Quantity Discount Header");
        RetailComment.SetRange("No.", "Item No.");
        RetailComment.SetRange("No. 2", "Main No.");
        RetailComment.DeleteAll;

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnDelete(RecRef);

        DimMgt.DeleteDefaultDim(DATABASE::"NPR Quantity Discount Header", "Main No.");
    end;

    trigger OnInsert()
    var
        Date: Record Date;
    begin
        "Creating Date" := Today;

        if "Main No." = '' then begin
            RetailSetup.Get;
            RetailSetup.TestField("Quantity Discount Nos.");
            NoSeriesMgt.InitSeries(RetailSetup."Quantity Discount Nos.", xRec."No. Series", 0D, "Main No.", "No. Series");
        end;

        Date.SetRange("Period Type", Date."Period Type"::Date);
        "Starting Date" := Today;
        //-NPR5.27
        //IF DatoRec.FIND('+') THEN
        if Date.FindLast then
            //+NPR5.27
            "Closing Date" := Date."Period Start";

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnInsert(RecRef);

        RetailSetup.Get;

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Quantity Discount Header", "Main No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        RecRef.GetTable(Rec);
        CompanySyncMgt.OnModify(RecRef);
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CompanySyncMgt: Codeunit "NPR CompanySyncManagement";
        RecRef: RecordRef;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        //-NPR4.01
        //DimMgt.SaveDefaultDim(DATABASE::Customer,"Main no.",FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Quantity Discount Header", "Main No.", FieldNumber, ShortcutDimCode);
        //+NPR4.01
        Modify;
    end;

    procedure AssistEdit(QtyDiscHeader: Record "NPR Quantity Discount Header"): Boolean
    var
        QtyDiscHeader2: Record "NPR Quantity Discount Header";
    begin
        with QtyDiscHeader2 do begin
            QtyDiscHeader2 := Rec;
            RetailSetup.Get;
            RetailSetup.TestField("Quantity Discount Nos.");
            if NoSeriesMgt.SelectSeries(RetailSetup."Period Discount Management", QtyDiscHeader."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("Main No.");
                Rec := QtyDiscHeader2;
                exit(true);
            end;
        end;
    end;
}

