page 6151416 "NPR Magento Categories"
{
    Caption = 'Magento Categories';
    CardPageID = "NPR Magento Category Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Category";
    SourceTableView = SORTING(Path);
    UsageCategory = Lists;
    ApplicationArea = All;

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Parent Category Id"; Rec."Parent Category Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Parent Category Id field';
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sorting field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Categories action';

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                begin
                    MagentoSetupMgt.TriggerSetupCategories();
                    Message(Text000);
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
                ToolTip = 'Executes the Display Config action';

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                begin
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                end;
            }
            action(Items)
            {
                Caption = 'Items';
                Image = Item;
                ApplicationArea = All;
                ToolTip = 'Executes the Items action';

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
        SetDisplayConfigVisible;
    end;

    var
        DisplayConfigVisible: Boolean;
        HasSetupCategories: Boolean;
        Text000: Label 'Category update initiated';

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}