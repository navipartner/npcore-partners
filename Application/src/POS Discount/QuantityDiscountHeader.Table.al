﻿table 6014439 "NPR Quantity Discount Header"
{
    Access = Internal;
    Caption = 'Multiple Price Header';
    LookupPageID = "NPR Quantity Discount List";
    DataClassification = CustomerContent;
    DataCaptionFields = "Item No.", "Item Description";

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
            CalcFormula = Exist("NPR Retail Comment" WHERE("Table ID" = CONST(6014439),
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
        field(29; "Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
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
        QtyDiscLine.SetRange("Item No.", "Item No.");
        QtyDiscLine.SetRange("Main no.", "Main No.");
        QtyDiscLine.DeleteAll();

        RetailComment.SetRange("Table ID", DATABASE::"NPR Quantity Discount Header");
        RetailComment.SetRange("No.", "Item No.");
        RetailComment.SetRange("No. 2", "Main No.");
        RetailComment.DeleteAll();

        DimMgt.DeleteDefaultDim(DATABASE::"NPR Quantity Discount Header", "Main No.");
    end;

    trigger OnInsert()
    var
        Date: Record Date;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSerie: Code[20];
#ENDIF
    begin
        "Creating Date" := Today();

        if "Main No." = '' then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NoSerie := GetNoSeries();
            "No. Series" := NoSerie;
            if NoSeriesMgt.AreRelated(NoSerie, xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Main No." := NoSeriesMgt.GetNextNo("No. Series");
#ELSE
            NoSeriesMgt.InitSeries(GetNoSeries(), xRec."No. Series", 0D, "Main No.", "No. Series");
#ENDIF
        end;

        Date.SetRange("Period Type", Date."Period Type"::Date);
        "Starting Date" := Today();
        if Date.FindLast() then
            "Closing Date" := Date."Period Start";

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Quantity Discount Header", "Main No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
    end;

    var
        DimMgt: Codeunit DimensionManagement;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Quantity Discount Header", "Main No.", FieldNumber, ShortcutDimCode);
        Modify();
    end;

    procedure AssistEdit(QtyDiscHeader: Record "NPR Quantity Discount Header"): Boolean
    var
        QtyDiscHeader2: Record "NPR Quantity Discount Header";
    begin
        QtyDiscHeader2 := Rec;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        if NoSeriesMgt.LookupRelatedNoSeries(GetNoSeries(), QtyDiscHeader."No. Series", QtyDiscHeader2."No. Series") then begin
            QtyDiscHeader2."Main No." := NoSeriesMgt.GetNextNo(QtyDiscHeader2."No. Series");
#ELSE
        if NoSeriesMgt.SelectSeries(GetNoSeries(), QtyDiscHeader."No. Series", QtyDiscHeader2."No. Series") then begin
            NoSeriesMgt.SetSeries(QtyDiscHeader2."Main No.");
#ENDIF
            Rec := QtyDiscHeader2;
            exit(true);
        end;
    end;

    local procedure GetNoSeries(): Code[20]
    var
        QuantityDiscountMgt: Codeunit "NPR Quantity Discount Mgt.";
    begin
        exit(QuantityDiscountMgt.GetNoSeries());
    end;
}

