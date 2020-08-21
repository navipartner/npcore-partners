page 6151436 "Magento Item Attributes"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150201  CASE 199932 Changed GetValue()
    // MAG1.04/MH/20150206  CASE 199932 Added View for setting up WebVariant Configurable Products
    // MAG1.21/MHA/20151120  CASE 227734 Field 300 Enabled deleted and function SetVisible() deleted [MAG1.04]
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    AutoSplitKey = true;
    Caption = 'Item Attributes';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Magento Item Attribute";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Attribute Description"; "Attribute Description")
                {
                    ApplicationArea = All;
                }
                field("GetValue()"; GetValue())
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                }
            }
            part(Control6150617; "Magento Item Attribute Values")
            {
                SubPageLink = "Attribute ID" = FIELD("Attribute ID"),
                              "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code");
            }
        }
    }

    actions
    {
    }

    procedure GetValue() Value: Text
    var
        MagentoItemAttributeValue: Record "Magento Item Attribute Value";
    begin
        Value := '';
        MagentoItemAttributeValue.SetRange("Attribute ID", "Attribute ID");
        MagentoItemAttributeValue.SetRange("Item No.", "Item No.");
        MagentoItemAttributeValue.SetRange("Variant Code", "Variant Code");
        MagentoItemAttributeValue.SetRange(Selected, true);
        if MagentoItemAttributeValue.FindSet then
            repeat
                MagentoItemAttributeValue.CalcFields(Value);
                if Value <> '' then
                    Value += ',';
                Value += MagentoItemAttributeValue.Value;
            until MagentoItemAttributeValue.Next = 0;

        exit(Value);
    end;
}

