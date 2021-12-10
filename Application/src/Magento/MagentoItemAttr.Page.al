page 6151436 "NPR Magento Item Attr."
{
    UsageCategory = None;
    AutoSplitKey = true;
    Caption = 'Item Attributes';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Magento Item Attr.";
    SourceTableTemporary = true;
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

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Control6150617.PAGE.SetSourceTable(Rec."Attribute Set ID", Rec."Attribute ID", Rec."Item No.", Rec."Variant Code");
    end;

    trigger OnModifyRecord(): Boolean
    begin
        OnModifyTrigger();
    end;

    trigger OnOpenPage()
    begin
        SetSourceTable();
    end;

    var
        ItemNo: Code[20];
        AttributeSetID: Integer;
        VariantCode: Code[10];

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

    local procedure OnModifyTrigger()
    var
        MagentoItemAttr: Record "NPR Magento Item Attr.";
    begin
        if not Rec.Selected then begin
            if MagentoItemAttr.Get(Rec."Attribute Set ID", Rec."Attribute ID", Rec."Item No.", Rec."Variant Code") then
                MagentoItemAttr.Delete(true);
            exit;
        end;

        if MagentoItemAttr.Get(Rec."Attribute Set ID", Rec."Attribute ID", Rec."Item No.", Rec."Variant Code") then begin
            MagentoItemAttr.TransferFields(Rec);
            MagentoItemAttr.Modify(true);
            exit;
        end;

        MagentoItemAttr.Init();
        MagentoItemAttr := Rec;
        MagentoItemAttr.Insert(true);
    end;

    procedure SetValues(NewItemNo: Code[20]; NewAttributeSetID: Integer; NewVariantCode: Code[10])
    begin
        ItemNo := NewItemNo;
        AttributeSetID := NewAttributeSetID;
        VariantCode := NewVariantCode;
    end;

    procedure SetSourceTable()
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        MagentoAttribute: Record "NPR Magento Attribute";
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        Item: Record Item;
        MagentoItemAttr: Record "NPR Magento Item Attr.";
        RecRef: RecordRef;
    begin
        if ItemNo = '' then
            exit;

        RecRef.GetTable(Rec);
        if not RecRef.IsTemporary then
            exit;

        RecRef.Close();
        Rec.DeleteAll();

        if not Item.Get(ItemNo) then
            exit;

        Item.TestField("NPR Attribute Set ID");
        MagentoAttributeSetValue.SetRange("Attribute Set ID", Item."NPR Attribute Set ID");
        if MagentoAttributeSetValue.FindSet() then
            repeat
                MagentoAttribute.Get(MagentoAttributeSetValue."Attribute ID");
                if not MagentoItemAttribute.Get(MagentoAttributeSetValue."Attribute Set ID", MagentoAttributeSetValue."Attribute ID", Item."No.", VariantCode) then begin
                    MagentoItemAttribute.Init();
                    MagentoItemAttribute."Attribute Set ID" := Item."NPR Attribute Set ID";
                    MagentoItemAttribute."Attribute ID" := MagentoAttributeSetValue."Attribute ID";
                    MagentoItemAttribute."Item No." := Item."No.";
                    MagentoItemAttribute."Variant Code" := VariantCode;
                    MagentoItemAttribute.Insert(true);
                end;
            until MagentoAttributeSetValue.Next() = 0;

        MagentoItemAttribute.SetRange("Attribute Set ID", AttributeSetID);
        MagentoItemAttribute.SetRange("Item No.", ItemNo);
        MagentoItemAttribute.SetRange("Variant Code", VariantCode);
        if not MagentoItemAttribute.FindSet() then
            exit;

        repeat
            Rec.Init();
            if MagentoItemAttr.Get(AttributeSetID, MagentoItemAttribute."Attribute ID", ItemNo, VariantCode) then
                Rec := MagentoItemAttr
            else begin
                Rec."Item No." := MagentoItemAttribute."Item No.";
                Rec."Variant Code" := VariantCode;
                Rec."Attribute Set ID" := MagentoItemAttribute."Attribute Set ID";
                Rec."Attribute ID" := MagentoItemAttribute."Attribute ID";
                Rec.Selected := false;
            end;
            Rec.Insert();
        until MagentoItemAttribute.Next() = 0;

        Rec.FindFirst();

        CurrPage.Update(false);
    end;
}