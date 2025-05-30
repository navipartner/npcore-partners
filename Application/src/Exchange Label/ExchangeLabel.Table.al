﻿table 6014498 "NPR Exchange Label"
{
    Access = Internal;
    Caption = 'Exchange Label';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store ID"; Code[3])
        {
            Caption = 'Store ID';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[7])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(3; Barcode; Code[13])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(4; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(8; "Packaged Batch"; Boolean)
        {
            Caption = 'Packaged Batch';
            DataClassification = CustomerContent;
        }
        field(10; "Valid From"; Date)
        {
            Caption = 'Valid From';
            DataClassification = CustomerContent;
        }
        field(11; "Valid To"; Date)
        {
            Caption = 'Valid To';
            DataClassification = CustomerContent;
        }
        field(15; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(20; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit";
            DataClassification = CustomerContent;
        }
        field(21; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(22; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(23; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(24; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(31; "Sales Price Incl. Vat"; Decimal)
        {
            Caption = 'Sales Price Incl. Vat';
            DataClassification = CustomerContent;
        }
        field(32; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(35; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DecimalPlaces = 2 : 2;
            Description = 'NPR5.49';
            DataClassification = CustomerContent;
        }
        field(41; "Sales Header Type"; Option)
        {
            BlankZero = true;
            Caption = 'Sales Header Type';
            OptionCaption = ',,Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = ,,Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(42; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            DataClassification = CustomerContent;
        }
        field(50; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(60; "Printed Date"; DateTime)
        {
            Caption = 'Printed Date';
            DataClassification = CustomerContent;
        }
        field(70; "Retail Cross Reference No."; Code[50])
        {
            Caption = 'POS Cross Reference No.';
            TableRelation = "NPR POS Cross Reference"."Reference No.";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Store ID", "No.", "Batch No.")
        {
        }
        key(Key2; "Register No.", "Sales Ticket No.", "Sales Line No.")
        {
        }
        key(Key3; "Register No.", "Sales Ticket No.", "Batch No.")
        {
        }
        key(Key4; "No.")
        {
        }
        key(Key5; Barcode)
        {
        }
    }

    trigger OnInsert()
    var
        ExchangeLabelMgt: Codeunit "NPR Exchange Label Mgt.";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesCode: Code[20];
#ELSE
        NewNo: Code[20];
#ENDIF
    begin
        if "No." = '' then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NoSeriesCode := GetNoSeriesCode();
            "No. Series" := NoSeriesCode;
            if NoSeriesMgt.AreRelated(NoSeriesCode, xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := CopyStr(NoSeriesMgt.GetNextNo("No. Series"), 1, MaxStrLen("No."));
#ELSE
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", 0D, NewNo, "No. Series");
            "No." := CopyStr(NewNo, 1, MaxStrLen("No."));
#ENDIF
        end;

        TestField("Store ID");

        Barcode := ExchangeLabelMgt.GetLabelBarcode(Rec);
        "Printed Date" := CurrentDateTime;

        if "Table No." <> Database::"Sales Line" then
            exit;

        InsertExchLabelBarcode(Barcode);
    end;

    local procedure InsertExchLabelBarcode(ParamBarcode: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Sales Header No.") then
            exit;
        SalesHeader."NPR Exchange Label Barcode" := ParamBarcode;
        SalesHeader.Modify();
    end;

    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF

    procedure GetNoSeriesCode(): Code[20]
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
    begin
        ExchangeLabelSetup.Get();
        exit(ExchangeLabelSetup."Exchange Label  No. Series");
    end;
}

