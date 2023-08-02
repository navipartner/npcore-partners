page 6060040 "NPR Item Worksheet Templates"
{
    Extensible = False;
    Caption = 'Item Worksheet Templates';
    ContextSensitiveHelpPage = 'docs/retail/item_worksheet/reference/template/template_ref/';
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
                    ToolTip = 'Specifies the name of the item worksheet template';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the item worksheet template.';
                    ApplicationArea = NPRRetail;
                }
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {
                    ToolTip = 'Specifies how the item numbers should be created';
                    ApplicationArea = NPRRetail;
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {
                    ToolTip = 'Specifies where to get the prefix for item numbers if the prefix is needed for item numbering';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Code"; Rec."Prefix Code")
                {
                    ToolTip = 'Specifies the prefix code used on the item number';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ToolTip = 'Specifies the number series used for item numbering.';
                    ApplicationArea = NPRRetail;
                }
                field("Error Handling"; Rec."Error Handling")
                {
                    ToolTip = 'Specifies how the errors are going to be handled during item import';
                    ApplicationArea = NPRRetail;
                }
                field("Test Validation"; Rec."Test Validation")
                {
                    ToolTip = 'Specifies if and where the test validation should be performed before the item import.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Internal Barcodes"; Rec."Create Internal Barcodes")
                {
                    ToolTip = 'Specifies if internal barcodes should be created or not. If yes, the manner in which they are created also needs to be specified.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {
                    ToolTip = 'Specifies if vendor barcodes should be created or not. If yes, the manner in which they are created also needs to be specified.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Handling"; Rec."Sales Price Handling")
                {
                    ToolTip = 'Specifies how the sales prices are going to be handled';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handling")
                {
                    ToolTip = 'Specifies how the purchase prices are going to be handled';
                    ApplicationArea = NPRRetail;
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {
                    ToolTip = 'Specifies how the variants are going to be combined for each item';
                    ApplicationArea = NPRRetail;
                }
                field("Combine as Background Task"; Rec."Combine as Background Task")
                {
                    ToolTip = 'Specifies whether combining variants process should be executed as a background task.';
                    ApplicationArea = NPRRetail;
                }
                field("Register Lines"; Rec."Register Lines")
                {
                    ToolTip = 'Create a Registered Item Worksheet record and the associated records when the lines are registered successfully.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {
                    ToolTip = 'Delete the lines in the Item Worksheet as soon as they are registered successfully.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Unvalidated Duplicates"; Rec."Delete Unvalidated Duplicates")
                {
                    ToolTip = 'Delete all non-validated duplicates.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Web Service Update"; Rec."Allow Web Service Update")
                {
                    ToolTip = 'Specifies if the item worksheet template will allow web service update or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query Name"; Rec."Item Info Query Name")
                {
                    ToolTip = 'Specifies the item info query name of the item worksheet template';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query Type"; Rec."Item Info Query Type")
                {
                    ToolTip = 'Specifies the item info query type of the item worksheet template';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query By"; Rec."Item Info Query By")
                {
                    ToolTip = 'Specifies how the web service should do the query for items';
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

                ToolTip = 'Displays all the worksheets for the seletem item worksheet template';
                ApplicationArea = NPRRetail;
            }
            action("Field Setup")
            {
                Caption = 'Field Setup';
                Image = MapAccounts;

                ToolTip = 'Displays the field setup for the selected item worksheet template';
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

