page 6151415 "NPR Magento Category List"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.21/TR/20151023  CASE 225294 Function GetSelectionFilter created.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.02/BHR /20170222 CASE 264145 change property 'IndentationControls' from 'No.','Name' to 'No.'
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Magento Category List';
    CardPageID = "NPR Magento Category Card";
    Editable = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Category";
    SourceTableView = SORTING(Path);

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                IndentationColumn = Level;
                IndentationControls = Id;
                ShowCaption = false;
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
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
    }

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        //+MAG2.26 [404580]
    end;

    var
        Text000: Label 'Category update initiated';
        HasSetupCategories: Boolean;

    procedure GetSelectionFilter(): Text
    var
        ItemGroup: Record "NPR Magento Category";
        MagentoSelectionFilterMgt: Codeunit "NPR Magento Select. Filt. Mgt.";
    begin
        //-MAG1.21
        CurrPage.SetSelectionFilter(ItemGroup);
        //-MAG2.00
        //EXIT(MagentoFunctions.GetSelectionFilterForItemGroup(ItemGroup));
        exit(MagentoSelectionFilterMgt.GetSelectionFilterForItemGroup(ItemGroup));
        //+MAG2.00
        //+MAG1.21
    end;
}

