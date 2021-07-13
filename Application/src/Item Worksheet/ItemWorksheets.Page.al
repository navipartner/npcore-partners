page 6060041 "NPR Item Worksheets"
{
    Caption = 'Item Worksheets';
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

                    ToolTip = 'Specifies the value of the Item Template Name field.';
                    ApplicationArea = NPRRetail;
                }
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
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field.';
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
                field("Item Group"; Rec."Item Group")
                {

                    ToolTip = 'Specifies the value of the Item Group field.';
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
                ToolTip = 'Executes the Edit Item Worksheet action.';
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
                ToolTip = 'Executes the Registered Worksheets action.';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
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

