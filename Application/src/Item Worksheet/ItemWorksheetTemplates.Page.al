page 6060040 "NPR Item Worksheet Templates"
{
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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Creation by field.';
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Prefix field.';
                }
                field("Prefix Code"; Rec."Prefix Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix Code field.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field.';
                }
                field("Error Handling"; Rec."Error Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Handling field.';
                }
                field("Test Validation"; Rec."Test Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Validation field.';
                }
                field("Create Internal Barcodes"; Rec."Create Internal Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Internal Barcodes field.';
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Vendor  Barcodes field.';
                }
                field("Sales Price Handling"; Rec."Sales Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Handling field.';
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Handling field.';
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Combine Variants to Item by field.';
                }
                field("Register Lines"; Rec."Register Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Register Lines field.';
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Processed Lines field.';
                }
                field("Delete Unvalidated Duplicates"; Rec."Delete Unvalidated Duplicates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Unvalidated Duplicates field.';
                }
                field("Allow Web Service Update"; Rec."Allow Web Service Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Web Service Update field.';
                }
                field("Item Info Query Name"; Rec."Item Info Query Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Name field.';
                }
                field("Item Info Query Type"; Rec."Item Info Query Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Type field.';
                }
                field("Item Info Query By"; Rec."Item Info Query By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query By field.';
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Item Worksheets";
                RunPageLink = "Item Template Name" = FIELD(Name);
                RunPageView = SORTING("Item Template Name", Name)
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Worksheets action.';
            }
            action("Field Setup")
            {
                Caption = 'Field Setup';
                Image = MapAccounts;
                ApplicationArea = All;
                ToolTip = 'Executes the Field Setup action.';

                trigger OnAction()
                var
                    ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                    ItemWorksheetFieldSetupPage: Page "NPR Item Worksh. Field Setup";
                begin
                    Rec.InsertDefaultFieldSetup();
                    ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name", Rec.Name);
                    ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '');
                    ItemWorksheetFieldSetupPage.SetTableView(ItemWorksheetFieldSetup);
                    ItemWorksheetFieldSetupPage.Run();
                end;
            }
        }
    }
}

