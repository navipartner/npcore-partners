page 6151415 "NPR Magento Category List"
{
    Caption = 'Magento Category List';
    CardPageID = "NPR Magento Category Card";
    Editable = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Category";
    SourceTableView = SORTING(Path);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Id;
                ShowCaption = false;
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
                field("Sorting"; Rec.Sorting)
                {

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
    }

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
    end;

    var
        Text000: Label 'Downloading...';
        HasSetupCategories: Boolean;

    procedure GetSelectionFilter(): Text
    var
        ItemGroup: Record "NPR Magento Category";
        MagentoSelectionFilterMgt: Codeunit "NPR Magento Select. Filt. Mgt.";
    begin
        CurrPage.SetSelectionFilter(ItemGroup);
        exit(MagentoSelectionFilterMgt.GetSelectionFilterForItemGroup(ItemGroup));
    end;
}