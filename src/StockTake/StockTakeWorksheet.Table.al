table 6014662 "NPR Stock-Take Worksheet"
{
    // NPR4.16/TS/20150518  CASE 213313 Created Table
    // NPR4.16/TSA/20150917 CASE 222486 Original Primary Key SQL Datatype of Variant was retained on previsous table definition, changed to default
    // NPR5.48/CLVA/20181024 CASE 332846 Added field "Topup Worksheet"

    Caption = 'Stock-Take Worksheet';
    LookupPageID = "NPR Stock-Take Worksheets";

    fields
    {
        field(1; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            TableRelation = "NPR Stock-Take Configuration".Code;
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(100; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Ready to Transfer,Partially Transferred,Complete';
            OptionMembers = OPEN,READY_TO_TRANSFER,PARTIALLY_TRANSFERRED,COMPLETE;
        }
        field(212; "Item Group Filter"; Text[200])
        {
            Caption = 'Item Group Filter';
            TableRelation = "NPR Item Group"."No.";
            ValidateTableRelation = false;
        }
        field(213; "Vendor Code Filter"; Text[200])
        {
            Caption = 'Vendor Code Filter';
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(214; "Global Dimension 1 Code Filter"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = true;
        }
        field(215; "Global Dimension 2 Code Filter"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = true;
        }
        field(226; "Allow User Modification"; Boolean)
        {
            Caption = 'Allow User Modification';
        }
        field(301; "Conf Calc. Date"; Date)
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Inventory Calc. Date" WHERE(Code = FIELD("Stock-Take Config Code")));
            Caption = 'Inventory Calc. Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(311; "Conf Location Code"; Code[20])
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Location Code" WHERE(Code = FIELD("Stock-Take Config Code")));
            Caption = 'Location Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Location.Code;
        }
        field(312; "Conf Item Group Filter"; Text[200])
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Item Group Filter" WHERE(Code = FIELD("Stock-Take Config Code")));
            Caption = 'Item Group Filter';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "NPR Item Group"."No.";
            ValidateTableRelation = false;
        }
        field(313; "Conf Vendor Code Filter"; Text[200])
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Vendor Code Filter" WHERE(Code = FIELD("Stock-Take Config Code")));
            Caption = 'Vendor Code Filter';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(314; "Conf Global Dim. 1 Code Filter"; Code[20])
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Global Dimension 1 Code" WHERE(Code = FIELD("Stock-Take Config Code")));
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code Filter';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = true;
        }
        field(315; "Conf Global Dim. 2 Code Filter"; Code[20])
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Global Dimension 2 Code" WHERE(Code = FIELD("Stock-Take Config Code")));
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code Filter';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = true;
        }
        field(338; "Conf Stock Take Method"; Option)
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Stock Take Method" WHERE(Code = FIELD("Stock-Take Config Code")));
            Caption = 'Stock Take Method';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'By Area,By Product,By Dimension';
            OptionMembers = "AREA",PRODUCT,DIMENSION;
        }
        field(339; "Conf Adjustment Method"; Option)
        {
            CalcFormula = Lookup ("NPR Stock-Take Configuration"."Adjustment Method" WHERE(Code = FIELD("Stock-Take Config Code")));
            Caption = 'Adjustment Method';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Stock-Take,Adjustment,Purchase (Adjmt.)';
            OptionMembers = STOCKTAKE,ADJUSTMENT,PURCHASE;
        }
        field(340; "Topup Worksheet"; Boolean)
        {
            Caption = 'Topup Worksheet';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Stock-Take Config Code", Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField(Status, Status::COMPLETE);

        WorksheetLine.SetRange("Stock-Take Config Code", "Stock-Take Config Code");
        WorksheetLine.SetRange("Worksheet Name", Name);
        WorksheetLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin

        TestField("Stock-Take Config Code");
        TestField(Name);

        StockTakeConfig.Get("Stock-Take Config Code");
        TransferFields(StockTakeConfig);
    end;

    trigger OnModify()
    begin
        TestField("Stock-Take Config Code");
        TestField(Name);
    end;

    trigger OnRename()
    begin
        TestField("Stock-Take Config Code");
        TestField(Name);

        StockTakeConfig.Get("Stock-Take Config Code");
        TransferFields(StockTakeConfig);
    end;

    var
        StockTakeConfig: Record "NPR Stock-Take Configuration";
        WorksheetLine: Record "NPR Stock-Take Worksheet Line";
}

