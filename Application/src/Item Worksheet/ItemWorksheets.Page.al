page 6060041 "NPR Item Worksheets"
{
    Caption = 'Item Worksheets';
    PageType = List;
    SourceTable = "NPR Item Worksheet";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Template Name"; Rec."Item Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Template Name field.';
                }
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
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
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
                field("Item Group"; Rec."Item Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Group field.';
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
                ApplicationArea = All;
                Caption = 'Edit Item Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Edit Item Worksheet action.';

                trigger OnAction()
                begin
                    ItemWorksheetManagement.TemplateSelectionFromBatch(Rec);
                end;
            }
            action("Registered Worksheets")
            {
                ApplicationArea = All;
                Caption = 'Registered Worksheets';
                Image = Registered;
                RunObject = Page "NPR Registered Item Worksh.";
                RunPageLink = "Worksheet Name" = FIELD(Name),
                              "Item Worksheet Template" = FIELD("Item Template Name");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
                ToolTip = 'Executes the Registered Worksheets action.';
            }
        }
        area(processing)
        {
            action("Field Setup")
            {
                ApplicationArea = All;
                Caption = 'Field Setup';
                Image = MapAccounts;
                ToolTip = 'Executes the Field Setup action.';

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

