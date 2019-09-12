table 6060041 "Item Worksheet"
{
    // NPR4.18/BR  /20160209  CASE 182391 Object Created
    // NPR5.22/BR  /20160321  CASE 182391 Added support for mapping an Excel file
    // NPR5.22/BR  /20160323  CASE 182391 Added support for Recommended Retail Price
    // NPR5.22/BR  /20160405  CASE 238374 Fix attributes not being deleted when deleteing
    // NPR5.23/BR  /20160602  CASE 240330 Added field Item No. Prefix and Prefix Code
    // NPR5.25/BR  /20160707  CASE 246088 Delete setup and any change fields
    // NPR5.25/BR  /20160708  CASE 246088 Added setup option
    // NPR5.25/BR  /20160718  CASE 246088 Added Parameter to CheckLines
    // NPR5.51/MHA /20190819  CASE 365377 Removed field 160 "GIM Import Document No."

    Caption = 'Item Worksheet Batch';
    DataCaptionFields = Name,Description;
    DrillDownPageID = "Item Worksheets";
    LookupPageID = "Item Worksheets";

    fields
    {
        field(1;"Item Template Name";Code[10])
        {
            Caption = 'Item Template Name';
            NotBlank = true;
            TableRelation = "Item Worksheet Template";
        }
        field(2;Name;Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
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
        field(16;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(35;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
                Currency: Record Currency;
                RecalculatePrice: Boolean;
            begin
            end;
        }
        field(50;"Print Labels";Boolean)
        {
            Caption = 'Print Labels';
        }
        field(96;"Prefix Code";Code[3])
        {
            Caption = 'Prefix Code';
            Description = 'NPR5.23';

            trigger OnValidate()
            begin
                //-NPR5.23
                ItemWorksheetTemplate.Get("Item Template Name");
                ItemWorksheetTemplate.TestField("Item No. Prefix",ItemWorksheetTemplate."Item No. Prefix"::"From Worksheet");
                //+NPR5.23
            end;
        }
        field(97;"No. Series";Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(150;"Show Variety Level";Option)
        {
            Caption = 'Show Variety Level';
            OptionCaption = 'Variety 1,Variety 1+2,Variety 1+2+3,Variety 1+2+3+4';
            OptionMembers = "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";

            trigger OnValidate()
            begin
                ItemWorksheetLine.LockTable;
                ItemWorksheetLine.SetRange("Worksheet Template Name","Item Template Name");
                ItemWorksheetLine.SetRange("Worksheet Name",Name);
                if ItemWorksheetLine.FindSet then
                  repeat
                    ItemWorksheetLine.RefreshVariants(0,true); //Update Headings
                  until ItemWorksheetLine.Next = 0;
            end;
        }
        field(400;"Sales Price Currency Code";Code[10])
        {
            Caption = 'Sales Price Currency Code';
            TableRelation = Currency;
        }
        field(410;"Purchase Price Currency Code";Code[10])
        {
            Caption = 'Purchase Price Currency Code';
            TableRelation = Currency;
        }
        field(500;"Excel Import from Line No.";Integer)
        {
            Caption = 'Excel Import from Line No.';
        }
        field(6014400;"Item Group";Code[10])
        {
            Caption = 'Item Group';
            TableRelation = "Item Group" WHERE (Blocked=CONST(false));

            trigger OnValidate()
            var
                ItemGroup: Record "Item Group";
            begin
                ItemWorksheetManagement.CheckItemGroupSetup("Item Group");
            end;
        }
    }

    keys
    {
        key(Key1;"Item Template Name",Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NPRAttributeKey: Record "NPR Attribute Key";
    begin
        ItemWorksheetLine.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name",Name);
        ItemWorksheetLine.DeleteAll;
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name",Name);
        ItemWorksheetVariantLine.DeleteAll;
        ItemWorksheetVarietyValue.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetVarietyValue.SetRange("Worksheet Name",Name);
        ItemWorksheetVarietyValue.DeleteAll;
        //-NPR5.22
        NPRAttributeKey.SetCurrentKey("Table ID","MDR Code PK","MDR Line PK","MDR Option PK");
        NPRAttributeKey.SetRange("Table ID",DATABASE::"Item Worksheet Line");
        NPRAttributeKey.SetRange("MDR Code PK", "Item Template Name");
        NPRAttributeKey.SetRange("MDR Code 2 PK", Name);
        NPRAttributeKey.DeleteAll(true);
        //+NPR5.22
        //-NPR5.25 [246088]
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name",Name);
        ItemWorksheetExcelColumn.DeleteAll;
        ItemWorksheetFieldSetup.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetFieldSetup.SetRange("Worksheet Name",Name);
        ItemWorksheetFieldSetup.DeleteAll;
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name",Name);
        ItemWorksheetFieldChange.DeleteAll;
        ItemWorksheetFieldMapping.SetRange("Worksheet Template Name",Name);
        ItemWorksheetFieldMapping.SetRange("Worksheet Name",Name);
        ItemWorksheetFieldMapping.DeleteAll;
        //+NPR5.25 [246088]
    end;

    trigger OnInsert()
    begin
        LockTable;
        ItemWorksheetTemplate.Get("Item Template Name");
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        Text1002: Label 'Checking lines        #2######';
        ItemWorksheetVarietyValue: Record "Item Worksheet Variety Value";
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";
        ItemWorksheetExcelColumn: Record "Item Worksheet Excel Column";
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
        ItemWorksheetFieldChange: Record "Item Worksheet Field Change";
        ItemWorksheetFieldMapping: Record "Item Worksheet Field Mapping";

    procedure SetupNewBatch()
    begin
        ItemWorksheetTemplate.Get("Item Template Name");
        "No. Series" := ItemWorksheetTemplate."No. Series";
    end;

    procedure ModifyLines(i: Integer)
    begin
        ItemWorksheetLine.LockTable;
        ItemWorksheetLine.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name",Name);
        if ItemWorksheetLine.FindSet then
          repeat
            case i of
            end;
            ItemWorksheetLine.Modify(true);
          until ItemWorksheetLine.Next = 0;
    end;

    procedure CheckLines(ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheetLine2: Record "Item Worksheet Line";
        Window: Dialog;
        LineCount: Integer;
        ItemWkshCheckLine: Codeunit "Item Wsht.-Check Line";
    begin
        if ItemWorksheetLine.IsEmpty then
          exit;

        if GuiAllowed then
          Window.Open(Text1002);
        LineCount := 0;
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine2.Reset;
        ItemWorksheetLine2.SetRange("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine2.SetRange("Worksheet Name",ItemWorksheetLine."Worksheet Name");
        if ItemWorksheetLine2.FindSet then
          repeat
            LineCount := LineCount + 1;
            if GuiAllowed then
              Window.Update(2,LineCount);
            case ItemWorksheetTemplate."Error Handling" of
              //-NPR5.25 [246088]
              // ItemWorksheetTemplate."Error Handling" :: StopOnFirst :
              //  ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,TRUE);
              // ItemWorksheetTemplate."Error Handling" :: SkipItem :
              //  ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,FALSE);
              // ItemWorksheetTemplate."Error Handling" :: SkipVariant :
              //  ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,FALSE);
              ItemWorksheetTemplate."Error Handling" :: StopOnFirst :
                ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,true,false);
              ItemWorksheetTemplate."Error Handling" :: SkipItem :
                ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,false,false);
              ItemWorksheetTemplate."Error Handling" :: SkipVariant :
                ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,false,false);
            //+NPR5.25 [246088]
            end;
          until ItemWorksheetLine2.Next = 0;

        if GuiAllowed then
          Window.Close;
    end;

    procedure UpdateSalesPriceAllLinesWithRRP()
    begin
        //-NPR5.22
        ItemWorksheetLine.Reset;
        ItemWorksheetLine.SetRange("Worksheet Template Name","Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name",Name);
        if ItemWorksheetLine.FindSet then repeat
          ItemWorksheetLine.UpdateSalesPriceWithRRP;
          ItemWorksheetLine.Modify;
        until ItemWorksheetLine.Next = 0;
        //+NPR5.22
    end;

    procedure InsertDefaultFieldSetup()
    var
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";
    begin
        //-NPR5.25 [246088]
        ItemWorksheetLine.Reset;
        ItemWorksheetLine.Init;
        ItemWorksheetLine."Worksheet Template Name" := "Item Template Name";
        ItemWorksheetLine."Worksheet Name" := Name;
        ItemWorksheetManagement.SetDefaultFieldSetupLines(ItemWorksheetLine,2);
        //+NPR5.25 [246088]
    end;
}

