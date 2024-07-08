﻿page 6151429 "NPR Magento Itm Cstm Opt.Value"
{
    Caption = 'Magento Item Custom Option Value';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Itm Cstm Opt.Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Option No."; Rec."Custom Option No.")
                {

                    ToolTip = 'Specifies the value of the Custom Option No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Option Value Line No."; Rec."Custom Option Value Line No.")
                {

                    ToolTip = 'Specifies the value of the Custom Option Value Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
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
    }

    trigger OnModifyRecord(): Boolean
    begin
        OnModifyTrigger();
    end;

    local procedure OnModifyTrigger()
    var
        ItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        if not Rec.Enabled then begin
            if ItemCustomOptValue.Get(Rec."Item No.", Rec."Custom Option No.", Rec."Custom Option Value Line No.") then
                ItemCustomOptValue.Delete(true);
            exit;
        end;

        if ItemCustomOptValue.Get(Rec."Item No.", Rec."Custom Option No.", Rec."Custom Option Value Line No.") then begin
            ItemCustomOptValue.TransferFields(Rec);
            ItemCustomOptValue.Modify(true);
            exit;
        end;

        ItemCustomOptValue.Init();
        ItemCustomOptValue := Rec;
        ItemCustomOptValue.Insert(true);
    end;

    internal procedure SetSourceTable(ItemNo: Code[20]; CustomOptionNo: Code[20])
    var
        CustomOption: Record "NPR Magento Custom Option";
        CustomOptionValue: Record "NPR Magento Custom Optn. Value";
        ItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (not CustomOption.Get(CustomOptionNo)) or
           not (CustomOption.Type in [CustomOption.Type::SelectDropDown, CustomOption.Type::SelectRadioButtons,
                                            CustomOption.Type::SelectCheckbox, CustomOption.Type::SelectMultiple]) then begin
            CurrPage.Update(false);
            exit;
        end;

        CustomOptionValue.SetRange("Custom Option No.", CustomOptionNo);
        if CustomOptionValue.FindSet() then
            repeat
                Rec.Init();
                if ItemCustomOptValue.Get(ItemNo, CustomOptionValue."Custom Option No.", CustomOptionValue."Line No.") then
                    Rec := ItemCustomOptValue
                else begin
                    Rec.Init();
                    Rec."Item No." := ItemNo;
                    Rec."Custom Option No." := CustomOptionValue."Custom Option No.";
                    Rec."Custom Option Value Line No." := CustomOptionValue."Line No.";
                    Rec.Enabled := false;
                end;
                Rec.Insert();
            until CustomOptionValue.Next() = 0;

        CurrPage.Update(false);
    end;
}
