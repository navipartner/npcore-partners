page 6151431 "NPR Magento Attributes"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150115  CASE 199932 Updated Layout.
    // MAG1.02/MH/20150204  CASE 1999332 Added UsedByAttributeSetDrillDown(), UsedByItemDrillDown() and Changed layout by adding Blank Text Field to control width of the Repeater Group.
    // MAG1.03/MH/20150205  CASE 199932 Deleted "Show Option Images Is Frontend".
    // MAG1.04/MH/20150206  CASE 199932 field 200 Configurable which is used for WebVariant.
    // MAG1.17/MH/20150619  CASE 216851 Magento Setup separated from NaviConnect Setup.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.19/LS  /2019020  CASE 344251 Added field 15 Visible

    AutoSplitKey = true;
    Caption = 'Attributes';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Attribute";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            grid(Attributes)
            {
                Caption = 'Attributes';
                group(Control6150627)
                {
                    ShowCaption = false;
                    repeater(Control6150613)
                    {
                        ShowCaption = false;
                        field(Description; Description)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Description field';
                        }
                        field(Type; Type)
                        {
                            ApplicationArea = All;
                            Editable = TypeEditable;
                            ToolTip = 'Specifies the value of the Type field';
                        }
                        field(Position; Position)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Position field';
                        }
                        field(Filterable; Filterable)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Filterable field';
                        }
                        field("Use in Product Listing"; "Use in Product Listing")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Use in Product Listing field';
                        }
                        field("Used by Attribute Set"; "Used by Attribute Set")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Used by Attribute Set field';

                            trigger OnDrillDown()
                            begin
                                //-MAG1.02
                                UsedByAttributeSetDrillDown();
                                //+199932
                            end;
                        }
                        field("Used by Items"; "Used by Items")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Used by Items field';

                            trigger OnDrillDown()
                            begin
                                //-MAG1.02
                                UsedByItemDrillDown();
                                //+MAG1.02
                            end;
                        }
                        field(Visible; Visible)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Visible field';
                        }
                    }
                    field(WidthControl; '')
                    {
                        ApplicationArea = All;
                        Caption = '                                                                                                                                                             ';
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                }
                group(Control6150623)
                {
                    ShowCaption = false;
                    part(AttributeLabels; "NPR Magento Attr. Labels")
                    {
                        Caption = 'Labels';
                        ShowFilter = false;
                        SubPageLink = "Attribute ID" = FIELD("Attribute ID");
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        TypeEditable := not MagentoAttribute.Get("Attribute ID");
        CurrPage.AttributeLabels.PAGE.SetTextFieldVisible(Type = Type::"Text Area (single)");
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TestField(Description);
        if not Confirm(StrSubstNo(Text001, Format(Type)), false) then
            exit(false);
    end;

    trigger OnOpenPage()
    begin
        //-MAG1.17
        //NaviConnectSetup.GET;
        //NaviConnectSetup.TESTFIELD("Attributes Enabled",TRUE);
        MagentoSetup.Get;
        MagentoSetup.TestField("Attributes Enabled", true);
        //+MAG1.17

        SetVisible();
    end;

    var
        Text001: Label 'The Type is: %1\\Type can not be changed after Creation\\Create Attribute?';
        MagentoSetup: Record "NPR Magento Setup";
        MagentoVisibleWebVariant: Boolean;
        TypeEditable: Boolean;

    procedure UsedByAttributeSetDrillDown()
    var
        AttributeSet: Record "NPR Magento Attribute Set";
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        TempAttributeSet: Record "NPR Magento Attribute Set" temporary;
    begin
        //-MAG1.02
        TempAttributeSet.DeleteAll;
        MagentoAttributeSetValue.SetRange("Attribute ID", "Attribute ID");
        if MagentoAttributeSetValue.FindSet then
            repeat
                if AttributeSet.Get(MagentoAttributeSetValue."Attribute Set ID") then begin
                    TempAttributeSet.Init;
                    TempAttributeSet := AttributeSet;
                    TempAttributeSet.Insert;
                end;
            until MagentoAttributeSetValue.Next = 0;
        PAGE.Run(PAGE::"NPR Magento Attribute Set List", TempAttributeSet);
        //+MAG1.02
    end;

    procedure UsedByItemDrillDown()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
    begin
        //-MAG1.02
        TempItem.DeleteAll;
        MagentoItemAttribute.SetRange("Attribute ID", "Attribute ID");
        MagentoItemAttribute.SetFilter("Variant Code", '=%1', '');
        if MagentoItemAttribute.FindSet then
            repeat
                if not TempItem.Get(MagentoItemAttribute."Item No.") then begin
                    if Item.Get(MagentoItemAttribute."Item No.") then begin
                        TempItem.Init;
                        TempItem := Item;
                        TempItem.Insert;
                    end;
                end;
            until MagentoItemAttribute.Next = 0;
        PAGE.Run(PAGE::"Item List", TempItem);
        //+MAG1.02
    end;

    procedure SetVisible()
    begin
        //-MAG1.17
        //MagentoVisibleWebVariant := NaviConnectSetup."Magento Enabled";
        MagentoVisibleWebVariant := MagentoSetup."Magento Enabled";
        //+MAG1.17
    end;
}

