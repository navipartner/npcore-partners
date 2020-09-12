page 6151416 "NPR Magento Categories"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150115  CASE 199932 Added Shortkey F5 to Action, Setup Item Group Tree
    // MAG1.04/MH/20150217  CASE 199932 Changed sorting from Entry No. to "No." (default) - Tree View is now controlled on No. assignment
    // MAG1.05/TR/20150217  CASE 206156 Added function GetSelectionFilter()
    // MAG1.12/MH/20150409  CASE 210904 Changed sorting to Path
    // MAG1.14/MH/20150415  CASE 211498 Set RefreshOnActivate = Yes
    // MAG1.17/TS/20150527  CASE 210909 Added Part(6059863) to display Item Group Link
    // MAG1.21/TR/20151023  CASE 225294 Function GetSelectionFilter has been moved to page 6059854
    // MAG1.21/TR/20151028  CASE 225601 Shortcut to Display Config added
    // MAG1.22/MHA/20151120 CASE 227359 Removed InsertAllowed, changed sorting to Path and added Indentation based on Level
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Magento Categories';
    CardPageID = "NPR Magento Category Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Category";
    SourceTableView = SORTING(Path);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = Id, Name;
                ShowAsTree = true;
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Parent Category Id"; "Parent Category Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Categories")
            {
                Caption = 'Setup Categories';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasSetupCategories;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                begin
                    //-MAG2.26 [404580]
                    MagentoSetupMgt.TriggerSetupCategories();
                    Message(Text000);
                    //+MAG2.26 [404580]
                end;
            }
        }
        area(navigation)
        {
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                begin
                    //-MAG1.21
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                    //+MAG1.21
                end;
            }
            action(Items)
            {
                Caption = 'Items';
                Image = Item;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MagentoCategoryMgt: Codeunit "NPR Magento Category Mgt.";
                begin
                    //-MAG2.26 [404580]
                    MagentoCategoryMgt.ItemCountDrillDown(Rec);
                    //+MAG2.26 [404580]
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        //+MAG2.26 [404580]
        //-MAG1.21
        SetDisplayConfigVisible;
        //+MAG1.21
    end;

    var
        DisplayConfigVisible: Boolean;
        HasSetupCategories: Boolean;
        Text000: Label 'Category update initiated';

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoWebsite: Record "NPR Magento Website";
    begin
        //-MAG1.21
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
        //+MAG1.21
    end;
}

