table 6060040 "Item Worksheet Template"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.22\BR\20160325  CASE 237658 Added field "Allow Web Service Update"
    // NPR5.22\BR\20160405  CASE 238374 Fix attributes not being deleted when deleteing
    // NPR5.23\BR\20160602  CASE 240330 Added field Item No. Prefix and Prefix Code
    // NPR5.23\BR\20160525  CASE 242498 Added Options Item+Date and  Item+Variant+Date to price handling
    // NPR5.23\BR\20160525  CASE 242498 Added Field Combine Variants to Item by
    // NPR5.23\BR\20160525  CASE 242498 Added Field Create Vendor Barcodes
    // NPR5.25\BR \20160704 CASE 246088 Delete Any old line after import
    // NPR5.25\BR \20160707 CASE 246088 Added function InsertDefaultFieldSetup
    // NPR5.25\BR \20160707 CASE 246088 Delete setup and any change fields
    // NPR5.25\BR \20160718 CASE 246088 Added field Test Validation
    // NPR5.25\BR \20160718 CASE 234602 Created Item Info fields
    // NPR5.29\BR \20161215 CASE 261123 Added field "Match by Item No. Only"
    // NPR5.37\BR \20170821 CASE 268786 Added field "Leave Skipped line on Register"
    // NPR5.42/RA/20180507  CASE 310681 Added fiedl 301
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 5

    Caption = 'Item Worksheet Template';
    DataClassification = CustomerContent;
    DrillDownPageID = "Item Worksheet Templates";
    LookupPageID = "Item Worksheet Templates";

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Test Report ID"; Integer)
        {
            Caption = 'Test Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(70; "Register Lines"; Boolean)
        {
            Caption = 'Register Lines';
            DataClassification = CustomerContent;
        }
        field(75; "Delete Processed Lines"; Boolean)
        {
            Caption = 'Delete Processed Lines';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.37 [268786]
                if (not "Delete Processed Lines") and "Leave Skipped Line on Register" then
                    Validate("Leave Skipped Line on Register", false);
                //+NPR5.37 [268786]
            end;
        }
        field(76; "Leave Skipped Line on Register"; Boolean)
        {
            Caption = 'Leave Skipped Line on Register';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
        }
        field(90; "Item No. Creation by"; Option)
        {
            Caption = 'Item No. Creation by';
            DataClassification = CustomerContent;
            OptionCaption = 'No. Series In Worksheet,No. Series On Processing,Vendors Item no.,Manually';
            OptionMembers = NoSeriesInWorksheet,NoSeriesOnProcessing,VendorItemNo,Manually;
        }
        field(95; "Item No. Prefix"; Option)
        {
            Caption = 'Item No. Prefix';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
            OptionCaption = 'None,From Template,From Worksheet,Vendor No.';
            OptionMembers = "None","From Template","From Worksheet","Vendor No.";

            trigger OnValidate()
            var
                TxtClearAllWorksheetPrefixes: Label 'This will clear all Prefixes on the associated Worksheets.';
                TxtStopped: Label 'Stopped on account of the warning.';
            begin
                //-NPR5.23
                if "Item No. Prefix" <> "Item No. Prefix"::"From Worksheet" then begin
                    "Prefix Code" := '';
                    ItemWorksheet.Reset;
                    ItemWorksheet.SetRange("Item Template Name", Name);
                    ItemWorksheet.SetFilter("Prefix Code", '<>%1', '');
                    if ItemWorksheet.Count > 1 then begin
                        if not Confirm(TxtClearAllWorksheetPrefixes) then
                            Error(TxtStopped)
                        else begin
                            if ItemWorksheet.FindSet then
                                repeat
                                    ItemWorksheet."Prefix Code" := '';
                                    ItemWorksheet.Modify;
                                until ItemWorksheet.Next = 0;
                        end;
                    end;
                end;
                if "Item No. Prefix" <> "Item No. Prefix"::"From Template" then begin
                    "Prefix Code" := '';
                end;
                //+NPR5.23
            end;
        }
        field(96; "Prefix Code"; Code[3])
        {
            Caption = 'Prefix Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';

            trigger OnValidate()
            begin
                //-NPR5.23
                TestField("Item No. Prefix", "Item No. Prefix"::"From Template");
                //+NPR5.23
            end;
        }
        field(97; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(100; "Error Handling"; Option)
        {
            Caption = 'Error Handling';
            DataClassification = CustomerContent;
            OptionCaption = 'Stop on First Error,Skip Item,Skip Variant';
            OptionMembers = StopOnFirst,SkipItem,SkipVariant;

            trigger OnValidate()
            begin
                if "Error Handling" = "Error Handling"::SkipVariant then
                    Error(TextNotImplemented);
            end;
        }
        field(105; "Test Validation"; Option)
        {
            Caption = 'Test Validation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,On Check,On Check and On Register';
            OptionMembers = No,"On Check","On Check and On Register";
        }
        field(110; "Create Internal Barcodes"; Option)
        {
            Caption = 'Create Internal Barcodes';
            DataClassification = CustomerContent;
            OptionCaption = 'None,As Alt. No.,As Cross Reference';
            OptionMembers = "None","As Alt. No.","As Cross Reference";
        }
        field(112; "Create Vendor  Barcodes"; Option)
        {
            Caption = 'Create Vendor  Barcodes';
            DataClassification = CustomerContent;
            OptionCaption = 'None,As Alt. No.,As Cross Reference';
            OptionMembers = "None","As Alt. No.","As Cross Reference";
        }
        field(120; "Sales Price Handling"; Option)
        {
            Caption = 'Sales Price Handling';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Item+Variant,Item+Date,Item+Variant+Date';
            OptionMembers = Item,"Item+Variant","Item+Date","Item+Variant+Date";
        }
        field(130; "Purchase Price Handling"; Option)
        {
            Caption = 'Purchase Price Handling';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Item+Variant,Item+Date,Item+Variant+Date';
            OptionMembers = Item,"Item+Variant","Item+Date","Item+Variant+Date";
        }
        field(140; "Combine Variants to Item by"; Option)
        {
            Caption = 'Combine Variants to Item by';
            DataClassification = CustomerContent;
            OptionCaption = 'All,Item No.,Vendor Item No.,Vendor Bar Code,Internal Bar Code';
            OptionMembers = All,ItemNo,VendorItemNo,VendorBarCode,InternalBarCode;
        }
        field(150; "Match by Item No. Only"; Boolean)
        {
            Caption = 'Match by Item No. Only';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(200; "Allow Web Service Update"; Boolean)
        {
            Caption = 'Allow Web Service Update';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemWorksheetTemplate: Record "Item Worksheet Template";
                TextWebServiceTemplateExists: Label '%1 is already activated on %2. Only one %3 can be active.';
            begin
                //-NPR5.22
                if "Allow Web Service Update" then begin
                    ItemWorksheetTemplate.Reset;
                    ItemWorksheetTemplate.SetRange("Allow Web Service Update", true);
                    ItemWorksheetTemplate.SetFilter(Name, '<>%1', Name);
                    if ItemWorksheetTemplate.FindFirst then
                        Error(TextWebServiceTemplateExists, FieldCaption("Allow Web Service Update"), ItemWorksheetTemplate.Description, TableCaption);
                end;

                //+NPR5.22
            end;
        }
        field(210; "Item Info Query Name"; Text[30])
        {
            Caption = 'Item Info Query Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(211; "Item Info Query Type"; Option)
        {
            Caption = 'Item Info Query Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'Item,Item Worksheet';
            OptionMembers = Item,"Item Worksheet";
        }
        field(212; "Item Info Query By"; Option)
        {
            Caption = 'Item Info Query By';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'Vendor No. and Vendor Item No.,Vendor Item No. Only';
            OptionMembers = "Vendor No. and Vendor Item No.","Vendor Item No. Only";
        }
        field(300; "Delete Unvalidated Duplicates"; Boolean)
        {
            Caption = 'Delete Unvalidated Duplicates';
            DataClassification = CustomerContent;
        }
        field(301; "Do not Apply Internal Barcode"; Boolean)
        {
            Caption = 'Do not apply Internal Barcode';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
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
        ItemWorksheet.SetRange("Item Template Name", Name);
        ItemWorksheet.DeleteAll;
        ItemWorksheetLine.SetRange("Worksheet Template Name", Name);
        ItemWorksheetLine.DeleteAll;
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", Name);
        ItemWorksheetVariantLine.DeleteAll;
        ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", Name);
        ItemWorksheetVarietyValue.DeleteAll;
        //-NPR5.22
        NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK", "MDR Line PK", "MDR Option PK");
        NPRAttributeKey.SetRange("Table ID", DATABASE::"Item Worksheet Line");
        NPRAttributeKey.SetRange("MDR Code PK", Name);
        NPRAttributeKey.DeleteAll(true);
        //+NPR5.22
        //-NPR5.25 [246088]
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", Name);
        ItemWorksheetExcelColumn.DeleteAll;
        ItemWorksheetFieldSetup.SetRange("Worksheet Template Name", Name);
        ItemWorksheetFieldSetup.DeleteAll;
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", Name);
        ItemWorksheetFieldChange.DeleteAll;
        ItemWorksheetFieldMapping.SetRange("Worksheet Template Name", Name);
        ItemWorksheetFieldMapping.DeleteAll;
        //+NPR5.25 [246088]
    end;

    var
        ItemWorksheet: Record "Item Worksheet";
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        ItemWorksheetVarietyValue: Record "Item Worksheet Variety Value";
        TextNotImplemented: Label 'This feature is not implemented yet.';
        ItemWorksheetExcelColumn: Record "Item Worksheet Excel Column";
        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
        ItemWorksheetFieldChange: Record "Item Worksheet Field Change";
        ItemWorksheetFieldMapping: Record "Item Worksheet Field Mapping";

    procedure InsertDefaultFieldSetup()
    var
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";
    begin
        //-NPR5.25 [246088]
        ItemWorksheetLine.Reset;
        ItemWorksheetLine.Init;
        ItemWorksheetLine."Worksheet Template Name" := Name;
        ItemWorksheetManagement.SetDefaultFieldSetupLines(ItemWorksheetLine, 1);
        //+NPR5.25 [246088]
    end;
}

