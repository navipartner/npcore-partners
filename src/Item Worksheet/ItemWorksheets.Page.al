page 6060041 "NPR Item Worksheets"
{
    // NPR4.18/BR  /20160209  CASE 182391 Object Created
    // NPR5.23/BR  /20160602  CASE 240330 Added field Item No. Prefix and Prefix Code
    // NPR5.25/BR  /20160707  CASE 246088 Added Action Field Setup
    // NPR5.48/JDH /20181109  CASE 334163 Added Caption to Action
    // NPR5.51/MHA /20190819  CASE 365377 Removed field 160 "GIM Import Document No."

    Caption = 'Item Worksheets';
    PageType = List;
    SourceTable = "NPR Item Worksheet";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Template Name"; "Item Template Name")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
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
                field("Item Group"; "Item Group")
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
            action("Edit Item Worksheet")
            {
                Caption = 'Edit Item Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                ApplicationArea = All;
            }
        }
        area(processing)
        {
            action("Field Setup")
            {
                Caption = 'Field Setup';
                Image = MapAccounts;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                    ItemWorksheetFieldSetupPage: Page "NPR Item Worksh. Field Setup";
                begin
                    //-NPR5.25 [246088]
                    InsertDefaultFieldSetup;
                    ItemWorksheetFieldSetup.Reset;
                    ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name", "Item Template Name");
                    ItemWorksheetFieldSetup.SetFilter("Worksheet Name", Name);
                    ItemWorksheetFieldSetupPage.SetTableView(ItemWorksheetFieldSetup);
                    ItemWorksheetFieldSetupPage.Run;
                    //+NPR5.25 [246088]
                end;
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
}

