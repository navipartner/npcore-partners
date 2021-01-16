page 6060040 "NPR Item Worksheet Templates"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.22\BR\20160325  CASE 237658 Added field "Allow Web Service Update"
    // NPR5.23\BR\20160602  CASE 240330 Added field Item No. Prefix and Prefix Code
    // NPR5.23\BR\20160525  CASE 242498 Added Option Combine Variants to Item by
    // NPR5.23\BR\20160525  CASE 242498 Added Field "Create Vendor  Barcodes"
    // NPR5.25\BR \20160707 CASE 246088 Added Action Field Setup
    // NPR5.25\BR \20160718 CASE 234602 Added Item Info fields
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Action

    Caption = 'Item Worksheet Templates';
    CardPageID = "NPR Item Worksh. Template";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Item Worksh. Template";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Item No. Creation by"; "Item No. Creation by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Creation by field';
                }
                field("Item No. Prefix"; "Item No. Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Prefix field';
                }
                field("Prefix Code"; "Prefix Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix Code field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Error Handling"; "Error Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Handling field';
                }
                field("Test Validation"; "Test Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Validation field';
                }
                field("Create Internal Barcodes"; "Create Internal Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Internal Barcodes field';
                }
                field("Create Vendor  Barcodes"; "Create Vendor  Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Vendor  Barcodes field';
                }
                field("Sales Price Handling"; "Sales Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Handling field';
                }
                field("Purchase Price Handling"; "Purchase Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Handling field';
                }
                field("Combine Variants to Item by"; "Combine Variants to Item by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Combine Variants to Item by field';
                }
                field("Register Lines"; "Register Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Register Lines field';
                }
                field("Delete Processed Lines"; "Delete Processed Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Processed Lines field';
                }
                field("Delete Unvalidated Duplicates"; "Delete Unvalidated Duplicates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Unvalidated Duplicates field';
                }
                field("Allow Web Service Update"; "Allow Web Service Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Web Service Update field';
                }
                field("Item Info Query Name"; "Item Info Query Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Name field';
                }
                field("Item Info Query Type"; "Item Info Query Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Type field';
                }
                field("Item Info Query By"; "Item Info Query By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query By field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Worksheets)
            {
                Caption = 'Worksheets';
                Image = Worksheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Item Worksheets";
                RunPageLink = "Item Template Name" = FIELD(Name);
                RunPageView = SORTING("Item Template Name", Name)
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Worksheets action';
            }
            action("Field Setup")
            {
                Caption = 'Field Setup';
                Image = MapAccounts;
                ApplicationArea = All;
                ToolTip = 'Executes the Field Setup action';

                trigger OnAction()
                var
                    ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                    ItemWorksheetFieldSetupPage: Page "NPR Item Worksh. Field Setup";
                begin
                    InsertDefaultFieldSetup;
                    ItemWorksheetFieldSetup.Reset;
                    ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name", Name);
                    ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '');
                    ItemWorksheetFieldSetupPage.SetTableView(ItemWorksheetFieldSetup);
                    ItemWorksheetFieldSetupPage.Run;
                end;
            }
        }
    }
}

