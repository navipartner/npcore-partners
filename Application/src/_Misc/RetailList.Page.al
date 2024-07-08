﻿page 6014579 "NPR Retail List"
{
    Extensible = False;
    Caption = 'Choose';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;

    SourceTable = "NPR Retail List";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Choice; Rec.Choice)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Choice field';
                    ApplicationArea = NPRRetail;
                }
                field("Package Description"; Rec."Package Description")
                {
                    Editable = false;
                    ToolTip = 'Provides a brief description of rapidstart package.';
                    ApplicationArea = NPRRetail;
                }
                field(Chosen; Rec.Chosen)
                {

                    ColumnSpan = 2;
                    Enabled = MultipleChoice;
                    Visible = MultipleChoice;
                    ToolTip = 'Specifies the value of the Chosen field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    Editable = false;
                    Enabled = ShowValue;
                    Visible = ShowValue;
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    var
        MultipleChoice: Boolean;
        ShowValue: Boolean;

    procedure GetSelectionFilter(var lines: Record "NPR Retail List")
    begin
        CurrPage.SetSelectionFilter(lines);
    end;

    procedure SetMultipleChoiceMode(MultipleChoiceIn: Boolean)
    begin
        MultipleChoice := MultipleChoiceIn;
    end;

    procedure SetShowValue(ShowValueIn: Boolean)
    begin
        ShowValue := ShowValueIn;
    end;

    procedure SetRec(var TempRetailList: Record "NPR Retail List" temporary)
    begin
        if not TempRetailList.IsTemporary then
            exit;

        Rec.Copy(TempRetailList, true);
        Rec.CopyFilters(TempRetailList);
    end;

    procedure GetRec(var TempRetailListOut: Record "NPR Retail List" temporary)
    begin
        if not TempRetailListOut.IsTemporary then
            exit;

        TempRetailListOut.Copy(Rec, true);
        TempRetailListOut.CopyFilters(Rec);
    end;
}

