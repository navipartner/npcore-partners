page 6151415 "Magento Item Group List"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.21/TR/20151023  CASE 225294 Function GetSelectionFilter created.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.02/BHR /20170222 CASE 264145 change property 'IndentationControls' from 'No.','Name' to 'No.'

    Caption = 'Item Groups';
    CardPageID = "Magento Item Group";
    Editable = false;
    PageType = List;
    SourceTable = "Magento Item Group";
    SourceTableView = SORTING(Path);

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                IndentationColumn = Level;
                IndentationControls = "No.";
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
                }
                field(Picture;Picture)
                {
                }
                field(Sorting;Sorting)
                {
                }
            }
        }
    }

    actions
    {
    }

    procedure GetSelectionFilter(): Text
    var
        ItemGroup: Record "Magento Item Group";
        MagentoSelectionFilterMgt: Codeunit "Magento Selection Filter Mgt.";
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

