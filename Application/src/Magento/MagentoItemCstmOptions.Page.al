page 6151428 "NPR Magento Item Cstm Options"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Item Custom Options';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Item Custom Option";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Item No."; "Item No.")
            {
                ApplicationArea = All;
                Caption = 'Item No.';
                ToolTip = 'Specifies the value of the Item No. field';
            }
            group("Custom Options")
            {
                Caption = 'Custom Options';
                repeater(Control6150615)
                {
                    ShowCaption = false;
                    field(Enabled; Enabled)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enabled field';
                    }
                    field("Custom Option No."; "Custom Option No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Custom Option No. field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field(Type; Type)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Type field';
                    }
                    field(Required; Required)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Required field';
                    }
                    field("Max Length"; "Max Length")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Max Length field';
                    }
                    field(Position; Position)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Position field';
                    }
                    field(Price; Price)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Price field';
                    }
                    field("Price Type"; "Price Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Price Type field';
                    }
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

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.OptionValues.PAGE.SetSourceTable("Item No.", "Custom Option No.");
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
        EnabledForeColor: Integer;
        PriceForeColor: Integer;

    local procedure OnModifyTrigger()
    var
        ItemCustomOption: Record "NPR Magento Item Custom Option";
    begin
        if not Enabled then begin
            if ItemCustomOption.Get("Item No.", "Custom Option No.") then
                ItemCustomOption.Delete(true);
            exit;
        end;

        if ItemCustomOption.Get("Item No.", "Custom Option No.") then begin
            ItemCustomOption.TransferFields(Rec);
            ItemCustomOption.Modify(true);
            exit;
        end;

        ItemCustomOption.Init;
        ItemCustomOption := Rec;
        ItemCustomOption.Insert(true);
    end;

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    procedure SetEnabledFilter()
    begin
        SetRange(Enabled, true);
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
        RecRef.Close;

        DeleteAll;

        if not Item.Get(ItemNo) then
            exit;

        if not CustomOption.FindSet then
            exit;


        repeat
            Init;
            if ItemCustomOption.Get(ItemNo, CustomOption."No.") then
                Rec := ItemCustomOption
            else begin
                "Item No." := ItemNo;
                "Custom Option No." := CustomOption."No.";
                Enabled := false;
            end;
            Insert;
        until CustomOption.Next = 0;

        FindFirst;

        CurrPage.Update(false);
    end;

    local procedure UpdateForeColors()
    begin
        EnabledForeColor := 0;
        PriceForeColor := 0;

        if not (Type in [Type::SelectDropDown, Type::SelectRadioButtons, Type::SelectCheckbox, Type::SelectMultiple]) then
            exit;

        CalcFields("Enabled Option Values");

        PriceForeColor := 10061943; //Light Slate Gray 119-136-153
        if Enabled and ("Enabled Option Values" <= 0) then
            EnabledForeColor := 17919;  //Orange Red 255-69-0
    end;
}

