page 6151416 "Magento Item Groups"
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

    Caption = 'Magento Item Groups';
    CardPageID = "Magento Item Group";
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Magento Item Group";
    SourceTableView = SORTING(Path);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "No.",Name;
                ShowAsTree = true;
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Parent Item Group No.";"Parent Item Group No.")
                {
                    Visible = false;
                }
                field(Picture;Picture)
                {
                }
                field(Sorting;Sorting)
                {
                    Visible = false;
                }
            }
            part(Control6150613;"Magento Item Group Links")
            {
                SubPageLink = "Item Group"=FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "Magento Display Config";
                    MagentoDisplayConfig: Record "Magento Display Config";
                begin
                    //-MAG1.21
                    MagentoDisplayConfig.SetRange(Type,MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                    //+MAG1.21
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-MAG1.21
        SetDisplayConfigVisible;
        //+MAG1.21
    end;

    var
        MagentoItemGroupMgt: Codeunit "Magento Item Group Mgt.";
        DisplayConfigVisible: Boolean;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "Magento Setup";
        MagentoWebsite: Record "Magento Website";
    begin
        //-MAG1.21
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
        //+MAG1.21
    end;
}

