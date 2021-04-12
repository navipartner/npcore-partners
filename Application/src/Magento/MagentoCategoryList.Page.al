page 6151415 "NPR Magento Category List"
{
    Caption = 'Magento Category List';
    CardPageID = "NPR Magento Category Card";
    Editable = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Category";
    SourceTableView = SORTING(Path);

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
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
    }

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
    end;

    var
        Text000: Label 'Category update initiated';
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