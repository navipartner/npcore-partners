page 6151436 "NPR Magento Item Attr."
{
    UsageCategory = None;
    AutoSplitKey = true;
    Caption = 'Item Attributes';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Magento Item Attr.";
    PageType = List;
    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Attribute Description"; Rec."Attribute Description")
                {

                    ToolTip = 'Specifies the value of the Attribute field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; GetValue())
                {

                    Caption = 'Value';
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6150617; "NPR Magento Item Attr. Values")
            {
                SubPageLink = "Attribute ID" = FIELD("Attribute ID"),
                              "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code");
                ApplicationArea = NPRRetail;

            }
        }
    }

    procedure GetValue() Value: Text
    var
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
    begin
        Value := '';
        MagentoItemAttributeValue.SetRange("Attribute ID", Rec."Attribute ID");
        MagentoItemAttributeValue.SetRange("Item No.", Rec."Item No.");
        MagentoItemAttributeValue.SetRange("Variant Code", Rec."Variant Code");
        MagentoItemAttributeValue.SetRange(Selected, true);
        if MagentoItemAttributeValue.FindSet() then
            repeat
                MagentoItemAttributeValue.CalcFields(Value);
                if Value <> '' then
                    Value += ',';
                Value += MagentoItemAttributeValue.Value;
            until MagentoItemAttributeValue.Next() = 0;

        exit(Value);
    end;
}