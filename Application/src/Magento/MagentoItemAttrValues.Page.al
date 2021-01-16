page 6151437 "NPR Magento Item Attr. Values"
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MHA /20150201  CASE 199932 Removed "Long Value" and added Text Aread functionality
    // MAG1.13/MHA /20150414  CASE 211422 Change update for Single value selections
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.09/MHA /20171201  CASE 292926 Added FIND to Selected - OnValidate() for support in NAV2017

    Caption = 'Item Attribute Values';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR Magento Item Attr. Value";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Selected; Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selected field';

                    trigger OnValidate()
                    var
                        MagentoAttribute: Record "NPR Magento Attribute";
                    begin
                        MagentoAttribute.Get("Attribute ID");
                        if Selected then begin
                            if MagentoAttribute.Type in [MagentoAttribute.Type::Single, MagentoAttribute.Type::"Text Area (single)"] then begin
                                ModifyAll(Selected, false);
                                //-MAG1.13
                                //FIND;
                                CurrPage.Update(false);
                                //+MAG1.13
                                //-MAG2.09 [292926]
                                Find;
                                //+MAG2.09 [292926]
                                Selected := true;
                                Modify(true);
                            end;
                        end;
                        CurrPage.Update;
                    end;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field';
                }
            }
        }
    }

    actions
    {
    }

    var
        Err001: Label 'Item %1 is an internet item and this attribute is used for defining configurable products and must have a value.\If you wish to change the value choose the new value on the list.';
}

