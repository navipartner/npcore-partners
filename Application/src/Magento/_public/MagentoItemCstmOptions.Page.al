page 6151428 "NPR Magento Item Cstm Options"
{
    Caption = 'Magento Item Custom Options';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Magento Item Custom Option";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Item No."; Rec."Item No.")
            {

                Caption = 'Item No.';
                ToolTip = 'Specifies the value of the Item No. field';
                ApplicationArea = NPRRetail;
            }
            group("Custom Options")
            {
                Caption = 'Custom Options';
                repeater(Control6150615)
                {
                    field(Enabled; Rec.Enabled)
                    {

                        ToolTip = 'Specifies the value of the Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Custom Option No."; Rec."Custom Option No.")
                    {

                        ToolTip = 'Specifies the value of the Custom Option No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Type; Rec.Type)
                    {

                        ToolTip = 'Specifies the value of the Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Required; Rec.Required)
                    {

                        ToolTip = 'Specifies the value of the Required field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Max Length"; Rec."Max Length")
                    {

                        ToolTip = 'Specifies the value of the Max Length field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Position; Rec.Position)
                    {

                        ToolTip = 'Specifies the value of the Position field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Price; Rec.Price)
                    {

                        ToolTip = 'Specifies the value of the Price field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Price Type"; Rec."Price Type")
                    {

                        ToolTip = 'Specifies the value of the Price Type field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(OptionValues; "NPR Magento Itm Cstm Opt.Value")
            {
                Caption = 'Values';
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Custom Option No." = FIELD("Custom Option No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.OptionValues.PAGE.SetSourceTable(Rec."Item No.", Rec."Custom Option No.");
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateForeColors();
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

    local procedure OnModifyTrigger()
    var
        ItemCustomOption: Record "NPR Magento Item Custom Option";
    begin
        if not Rec.Enabled then begin
            if ItemCustomOption.Get(Rec."Item No.", Rec."Custom Option No.") then
                ItemCustomOption.Delete(true);
            exit;
        end;

        if ItemCustomOption.Get(Rec."Item No.", Rec."Custom Option No.") then begin
            ItemCustomOption.TransferFields(Rec);
            ItemCustomOption.Modify(true);
            exit;
        end;

        ItemCustomOption.Init();
        ItemCustomOption := Rec;
        ItemCustomOption.Insert(true);
    end;

    internal procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    internal procedure SetEnabledFilter()
    begin
        Rec.SetRange(Enabled, true);
    end;

    internal procedure SetSourceTable()
    var
        CustomOption: Record "NPR Magento Custom Option";
        Item: Record Item;
        ItemCustomOption: Record "NPR Magento Item Custom Option";
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

        if not CustomOption.FindSet() then
            exit;


        repeat
            Rec.Init();
            if ItemCustomOption.Get(ItemNo, CustomOption."No.") then
                Rec := ItemCustomOption
            else begin
                Rec."Item No." := ItemNo;
                Rec."Custom Option No." := CustomOption."No.";
                Rec.Enabled := false;
            end;
            Rec.Insert();
        until CustomOption.Next() = 0;

        Rec.FindFirst();

        CurrPage.Update(false);
    end;

    local procedure UpdateForeColors()
    begin

        if not (Rec.Type in [Rec.Type::SelectDropDown, Rec.Type::SelectRadioButtons, Rec.Type::SelectCheckbox, Rec.Type::SelectMultiple]) then
            exit;

        Rec.CalcFields("Enabled Option Values");

    end;
}
