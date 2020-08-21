page 6060040 "Item Worksheet Templates"
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
    CardPageID = "Item Worksheet Template";
    Editable = false;
    PageType = List;
    SourceTable = "Item Worksheet Template";
    UsageCategory = Administration;

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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Item No. Creation by"; "Item No. Creation by")
                {
                    ApplicationArea = All;
                }
                field("Item No. Prefix"; "Item No. Prefix")
                {
                    ApplicationArea = All;
                }
                field("Prefix Code"; "Prefix Code")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Error Handling"; "Error Handling")
                {
                    ApplicationArea = All;
                }
                field("Test Validation"; "Test Validation")
                {
                    ApplicationArea = All;
                }
                field("Create Internal Barcodes"; "Create Internal Barcodes")
                {
                    ApplicationArea = All;
                }
                field("Create Vendor  Barcodes"; "Create Vendor  Barcodes")
                {
                    ApplicationArea = All;
                }
                field("Sales Price Handling"; "Sales Price Handling")
                {
                    ApplicationArea = All;
                }
                field("Purchase Price Handling"; "Purchase Price Handling")
                {
                    ApplicationArea = All;
                }
                field("Combine Variants to Item by"; "Combine Variants to Item by")
                {
                    ApplicationArea = All;
                }
                field("Register Lines"; "Register Lines")
                {
                    ApplicationArea = All;
                }
                field("Delete Processed Lines"; "Delete Processed Lines")
                {
                    ApplicationArea = All;
                }
                field("Delete Unvalidated Duplicates"; "Delete Unvalidated Duplicates")
                {
                    ApplicationArea = All;
                }
                field("Allow Web Service Update"; "Allow Web Service Update")
                {
                    ApplicationArea = All;
                }
                field("Item Info Query Name"; "Item Info Query Name")
                {
                    ApplicationArea = All;
                }
                field("Item Info Query Type"; "Item Info Query Type")
                {
                    ApplicationArea = All;
                }
                field("Item Info Query By"; "Item Info Query By")
                {
                    ApplicationArea = All;
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
                RunObject = Page "Item Worksheets";
                RunPageLink = "Item Template Name" = FIELD(Name);
                RunPageView = SORTING("Item Template Name", Name)
                              ORDER(Ascending);
            }
            action("Field Setup")
            {
                Caption = 'Field Setup';
                Image = MapAccounts;

                trigger OnAction()
                var
                    ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
                    ItemWorksheetFieldSetupPage: Page "Item Worksheet Field Setup";
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

