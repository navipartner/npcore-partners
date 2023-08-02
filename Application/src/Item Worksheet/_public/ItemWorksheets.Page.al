page 6060041 "NPR Item Worksheets"
{
    Caption = 'Item Worksheets';
    ContextSensitiveHelpPage = 'docs/retail/item_worksheet/intro/';
    PageType = List;
    SourceTable = "NPR Item Worksheet";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Template Name"; Rec."Item Template Name")
                {

                    ToolTip = 'Specifies the item template name.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the name of the worksheet.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the worksheet.';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the vendor number suggested for this line.';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Code"; Rec."Prefix Code")
                {

                    ToolTip = 'Specifies the prefix code.';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the number of series used for this line.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Group"; Rec."Item Group")
                {

                    ToolTip = 'Specifies the item group of the item.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Edit Item Worksheet")
            {

                Caption = 'Edit Item Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the related item worksheet.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    ItemWorksheetManagement.TemplateSelectionFromBatch(Rec);
                end;
            }
            action("Registered Worksheets")
            {

                Caption = 'Registered Worksheets';
                Image = Registered;
                RunObject = Page "NPR Registered Item Worksh.";
                RunPageLink = "Worksheet Name" = FIELD(Name),
                              "Item Worksheet Template" = FIELD("Item Template Name");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
                ToolTip = 'View the registered worksheets.';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            action("Field Setup")
            {

                Caption = 'Field Setup';
                Image = MapAccounts;
                ToolTip = 'View the field setup for the selected line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                    ItemWorksheetFieldSetupPage: Page "NPR Item Worksh. Field Setup";
                begin
                    Rec.InsertDefaultFieldSetup();
                    ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name", Rec."Item Template Name");
                    ItemWorksheetFieldSetup.SetFilter("Worksheet Name", Rec.Name);
                    ItemWorksheetFieldSetupPage.SetTableView(ItemWorksheetFieldSetup);
                    ItemWorksheetFieldSetupPage.Run();
                end;
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
}

