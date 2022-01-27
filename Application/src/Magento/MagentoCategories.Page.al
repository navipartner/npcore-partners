page 6151416 "NPR Magento Categories"
{
    Extensible = False;
    Caption = 'Magento Categories';
    CardPageID = "NPR Magento Category Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Category";
    SourceTableView = SORTING(Path);
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Id, Name;
                ShowAsTree = true;
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Category Id"; Rec."Parent Category Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Parent Category Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Picture; Rec.Picture)
                {

                    ToolTip = 'Specifies the value of the Picture field';
                    ApplicationArea = NPRRetail;
                }
                field("Sorting"; Rec.Sorting)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasSetupCategories;

                ToolTip = 'Executes the Setup Categories action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                    Window: Dialog;
                begin
                    Window.Open(Text000);
                    MagentoSetupMgt.TriggerSetupCategories(true);
                    Window.Close();
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

                ToolTip = 'Executes the Display Config action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                begin
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run();
                end;
            }
            action(Items)
            {
                Caption = 'Items';
                Image = Item;

                ToolTip = 'Executes the Items action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoCategoryMgt: Codeunit "NPR Magento Category Mgt.";
                begin
                    MagentoCategoryMgt.ItemCountDrillDown(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        SetDisplayConfigVisible();
    end;

    var
        DisplayConfigVisible: Boolean;
        HasSetupCategories: Boolean;
        Text000: Label 'Downloading...';

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        DisplayConfigVisible := MagentoSetup.Get() and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}
