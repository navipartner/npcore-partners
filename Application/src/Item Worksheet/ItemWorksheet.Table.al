table 6060041 "NPR Item Worksheet"
{
    Caption = 'Item Worksheet Batch';
    DataCaptionFields = Name, Description;
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Item Worksheets";
    LookupPageID = "NPR Item Worksheets";
    fields
    {
        field(1; "Item Template Name"; Code[10])
        {
            Caption = 'Item Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksh. Template";
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin
                Vend.Get("Vendor No.");
                "Prices Including VAT" := Vend."Prices Including VAT";
                "Currency Code" := Vend."Currency Code";
            end;
        }
        field(16; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
            end;
        }
        field(50; "Print Labels"; Boolean)
        {
            Caption = 'Print Labels';
            DataClassification = CustomerContent;
        }
        field(96; "Prefix Code"; Code[3])
        {
            Caption = 'Prefix Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';

            trigger OnValidate()
            begin
                ItemWorksheetTemplate.Get("Item Template Name");
                ItemWorksheetTemplate.TestField("Item No. Prefix", ItemWorksheetTemplate."Item No. Prefix"::"From Worksheet");
            end;
        }
        field(97; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(150; "Show Variety Level"; Option)
        {
            Caption = 'Show Variety Level';
            DataClassification = CustomerContent;
            OptionCaption = 'Variety 1,Variety 1+2,Variety 1+2+3,Variety 1+2+3+4';
            OptionMembers = "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";

            trigger OnValidate()
            begin
                ItemWorksheetLine.LockTable();
                ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Template Name");
                ItemWorksheetLine.SetRange("Worksheet Name", Name);
                if ItemWorksheetLine.FindSet() then
                    repeat
                        ItemWorksheetLine.RefreshVariants(0, true); //Update Headings
                    until ItemWorksheetLine.Next() = 0;
            end;
        }
        field(400; "Sales Price Currency Code"; Code[10])
        {
            Caption = 'Sales Price Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(410; "Purchase Price Currency Code"; Code[10])
        {
            Caption = 'Purchase Price Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(500; "Excel Import from Line No."; Integer)
        {
            Caption = 'Excel Import from Line No.';
            DataClassification = CustomerContent;
        }
        field(6014400; "Item Group"; Code[20])
        {
            Caption = 'Item Category';
            DataClassification = CustomerContent;
            TableRelation = "Item Category" WHERE("NPR Blocked" = CONST(false));
        }
    }

    keys
    {
        key(Key1; "Item Template Name", Name)
        {
        }
    }

    trigger OnDelete()
    var
        NPRAttributeKey: Record "NPR Attribute Key";
    begin
        ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", Name);
        ItemWorksheetLine.DeleteAll();
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", Name);
        ItemWorksheetVariantLine.DeleteAll();
        ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetVarietyValue.SetRange("Worksheet Name", Name);
        ItemWorksheetVarietyValue.DeleteAll();
        NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK", "MDR Line PK", "MDR Option PK");
        NPRAttributeKey.SetRange("Table ID", DATABASE::"NPR Item Worksheet Line");
        NPRAttributeKey.SetRange("MDR Code PK", "Item Template Name");
        NPRAttributeKey.SetRange("MDR Code 2 PK", Name);
        NPRAttributeKey.DeleteAll(true);
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", Name);
        ItemWorksheetExcelColumn.DeleteAll();
        ItemWorksheetFieldSetup.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetFieldSetup.SetRange("Worksheet Name", Name);
        ItemWorksheetFieldSetup.DeleteAll();
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name", Name);
        ItemWorksheetFieldChange.DeleteAll();
        ItemWorksheetFieldMapping.SetRange("Worksheet Template Name", Name);
        ItemWorksheetFieldMapping.SetRange("Worksheet Name", Name);
        ItemWorksheetFieldMapping.DeleteAll();
    end;

    trigger OnInsert()
    begin
        LockTable();
        ItemWorksheetTemplate.Get("Item Template Name");
    end;

    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
        ItemWorksheetFieldMapping: Record "NPR Item Worksh. Field Mapping";
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
        CheckingLinesLbl: Label 'Checking lines        #2######';

    procedure SetupNewBatch()
    begin
        ItemWorksheetTemplate.Get("Item Template Name");
        "No. Series" := ItemWorksheetTemplate."No. Series";
    end;

    procedure ModifyLines(i: Integer)
    begin
        ItemWorksheetLine.LockTable();
        ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", Name);
        if ItemWorksheetLine.FindSet() then
            repeat
                case i of
                end;
                ItemWorksheetLine.Modify(true);
            until ItemWorksheetLine.Next() = 0;
    end;

    procedure CheckLines(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ItemWorksheetLine2: Record "NPR Item Worksheet Line";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
        Window: Dialog;
        LineCount: Integer;
    begin
        if ItemWorksheetLine.IsEmpty then
            exit;

        if GuiAllowed then
            Window.Open(CheckingLinesLbl);
        LineCount := 0;
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine2.Reset();
        ItemWorksheetLine2.SetRange("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine2.SetRange("Worksheet Name", ItemWorksheetLine."Worksheet Name");
        if ItemWorksheetLine2.FindSet() then
            repeat
                LineCount := LineCount + 1;
                if GuiAllowed then
                    Window.Update(2, LineCount);
                case ItemWorksheetTemplate."Error Handling" of
                    ItemWorksheetTemplate."Error Handling"::StopOnFirst:
                        ItemWkshCheckLine.RunCheck(ItemWorksheetLine2, true, false);
                    ItemWorksheetTemplate."Error Handling"::SkipItem:
                        ItemWkshCheckLine.RunCheck(ItemWorksheetLine2, false, false);
                    ItemWorksheetTemplate."Error Handling"::SkipVariant:
                        ItemWkshCheckLine.RunCheck(ItemWorksheetLine2, false, false);
                end;
            until ItemWorksheetLine2.Next() = 0;

        if GuiAllowed then
            Window.Close();
    end;

    procedure UpdateSalesPriceAllLinesWithRRP()
    begin
        ItemWorksheetLine.Reset();
        ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", Name);
        if ItemWorksheetLine.FindSet() then
            repeat
                ItemWorksheetLine.UpdateSalesPriceWithRRP();
                ItemWorksheetLine.Modify();
            until ItemWorksheetLine.Next() = 0;
    end;

    procedure InsertDefaultFieldSetup()
    var
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
    begin
        ItemWorksheetLine.Reset();
        ItemWorksheetLine.Init();
        ItemWorksheetLine."Worksheet Template Name" := "Item Template Name";
        ItemWorksheetLine."Worksheet Name" := Name;
        ItemWorksheetManagement.SetDefaultFieldSetupLines(ItemWorksheetLine, 2);
    end;
}

