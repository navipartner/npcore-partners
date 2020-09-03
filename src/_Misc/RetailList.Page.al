page 6014579 "NPR Retail List"
{
    // NPR5.26/MMV /20160714 CASE 241549 Added support for multiple choice via field 'Chosen' if set.
    //                                   Added support for showing value column if set.
    //                                   Added function for setting/getting temp rec, since SETRECORD/GETRECORD on a Page variable cannot handle this.
    //                                   Removed Number column from page (visible property was hardcoded to false).
    //                                   Property InsertAllowed & DeleteAllowed set to No.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Choose';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "NPR Retail List";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Choice; Choice)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Chosen; Chosen)
                {
                    ApplicationArea = All;
                    ColumnSpan = 2;
                    Enabled = MultipleChoice;
                    Visible = MultipleChoice;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = ShowValue;
                    Visible = ShowValue;
                }
            }
        }
    }

    actions
    {
    }

    var
        MultipleChoice: Boolean;
        ShowValue: Boolean;

    procedure GetSelectionFilter(var lines: Record "NPR Retail List")
    var
        t001: Label 'No lines chosen';
        t002: Label 'Only one line chosen. Continue?';
        lines2: Record "NPR Retail List";
    begin
        // GetSelectionFilter
        CurrPage.SetSelectionFilter(lines);
    end;

    procedure SetMultipleChoiceMode(MultipleChoiceIn: Boolean)
    begin
        //-NPR5.26 [241549]
        MultipleChoice := MultipleChoiceIn;
        //+NPR5.26 [241549]
    end;

    procedure SetShowValue(ShowValueIn: Boolean)
    begin
        //-NPR5.26 [241549]
        ShowValue := ShowValueIn;
        //+NPR5.26 [241549]
    end;

    procedure SetRec(var TempRetailList: Record "NPR Retail List" temporary)
    begin
        //-NPR5.26 [241549]
        if not TempRetailList.IsTemporary then
            exit;

        Rec.Copy(TempRetailList, true);
        Rec.CopyFilters(TempRetailList);
        //+NPR5.26 [241549]
    end;

    procedure GetRec(var TempRetailListOut: Record "NPR Retail List" temporary)
    begin
        //-NPR5.26 [241549]
        if not TempRetailListOut.IsTemporary then
            exit;

        TempRetailListOut.Copy(Rec, true);
        TempRetailListOut.CopyFilters(Rec);
        //+NPR5.26 [241549]
    end;
}

