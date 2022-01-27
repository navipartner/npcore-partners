page 6060040 "NPR Item Worksheet Templates"
{
    Extensible = False;
    Caption = 'Item Worksheet Templates';
    CardPageID = "NPR Item Worksh. Template";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Item Worksh. Template";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {

                    ToolTip = 'Specifies the value of the Item No. Creation by field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {

                    ToolTip = 'Specifies the value of the Item No. Prefix field.';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Code"; Rec."Prefix Code")
                {

                    ToolTip = 'Specifies the value of the Prefix Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field.';
                    ApplicationArea = NPRRetail;
                }
                field("Error Handling"; Rec."Error Handling")
                {

                    ToolTip = 'Specifies the value of the Error Handling field.';
                    ApplicationArea = NPRRetail;
                }
                field("Test Validation"; Rec."Test Validation")
                {

                    ToolTip = 'Specifies the value of the Test Validation field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Internal Barcodes"; Rec."Create Internal Barcodes")
                {

                    ToolTip = 'Specifies the value of the Create Internal Barcodes field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {

                    ToolTip = 'Specifies the value of the Create Vendor  Barcodes field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Handling"; Rec."Sales Price Handling")
                {

                    ToolTip = 'Specifies the value of the Sales Price Handling field.';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handling")
                {

                    ToolTip = 'Specifies the value of the Purchase Price Handling field.';
                    ApplicationArea = NPRRetail;
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {

                    ToolTip = 'Specifies the value of the Combine Variants to Item by field.';
                    ApplicationArea = NPRRetail;
                }
                field("Register Lines"; Rec."Register Lines")
                {

                    ToolTip = 'Specifies the value of the Register Lines field.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {

                    ToolTip = 'Specifies the value of the Delete Processed Lines field.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Unvalidated Duplicates"; Rec."Delete Unvalidated Duplicates")
                {

                    ToolTip = 'Specifies the value of the Delete Unvalidated Duplicates field.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Web Service Update"; Rec."Allow Web Service Update")
                {

                    ToolTip = 'Specifies the value of the Allow Web Service Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query Name"; Rec."Item Info Query Name")
                {

                    ToolTip = 'Specifies the value of the Item Info Query Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query Type"; Rec."Item Info Query Type")
                {

                    ToolTip = 'Specifies the value of the Item Info Query Type field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query By"; Rec."Item Info Query By")
                {

                    ToolTip = 'Specifies the value of the Item Info Query By field.';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Worksheets action.';
                ApplicationArea = NPRRetail;
            }
            action("Field Setup")
            {
                Caption = 'Field Setup';
                Image = MapAccounts;

                ToolTip = 'Executes the Field Setup action.';
                ApplicationArea = NPRRetail;

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

