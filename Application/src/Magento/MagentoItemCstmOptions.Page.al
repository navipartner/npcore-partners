page 6151428 "NPR Magento Item Cstm Options"
{
    Caption = 'Magento Item Custom Options';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Item Custom Option";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Item No."; Rec."Item No.")
            {
                ApplicationArea = All;
                Caption = 'Item No.';
                ToolTip = 'Specifies the value of the Item No. field';
            }
            group("Custom Options")
            {
                Caption = 'Custom Options';
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Custom Option No."; Rec."Custom Option No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Option No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Required; Rec.Required)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required field';
                }
                field("Max Length"; Rec."Max Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Type field';
                }
            }
            part(OptionValues; "NPR Magento Itm Cstm Opt.Value")
            {
                Caption = 'Values';
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Custom Option No." = FIELD("Custom Option No.");
                ApplicationArea = All;
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

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    procedure SetEnabledFilter()
    begin
        Rec.SetRange(Enabled, true);
    end;

    procedure SetSourceTable()
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