page 6150624 "NPR POS Dimension Value"
{
    Caption = 'Dimension Value List';
    Editable = true;
    SourceTable = "Dimension Value";
    PageType = List;
    UsageCategory = Lists;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {

            field(SearchBox; SearchBox)
            {
                Editable = true;
                ApplicationArea = NPRRetail;

                trigger OnValidate();
                begin
                    FilterList;
                    Clear(SearchBox);
                    if CurrentClientType in [ClientType::Phone, ClientType::Tablet] then
                        CurrPage.SetFieldFocus.SetFocusOnFieldPhone('SearchBox')
                    else
                        CurrPage.SetFieldFocus.SetFocusOnField('SearchBox');
                end;
            }

            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Dimensions;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the code for the dimension value.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Dimensions;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies a descriptive name for the dimension value.';
                }
            }
            usercontrol(SetFieldFocus; "NPR Dimensions SearchFocus")
            {
                ApplicationArea = all;
                trigger SearchDimensions()
                begin
                    if CurrentClientType in [ClientType::Phone, ClientType::Tablet] then
                        CurrPage.SetFieldFocus.SetFocusOnFieldPhone('SearchBox')
                    else
                        CurrPage.SetFieldFocus.SetFocusOnField('SearchBox');
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        NameIndent := 0;
        //FormatLines;
    end;

    trigger OnOpenPage()
    begin
        GLSetup.Get();
    end;

    local procedure FilterList()
    var
        DimValue: Record "Dimension Value";
    begin
        Rec.Reset();
        Rec.ClearMarks();
        Rec.MarkedOnly(false);
        if (SearchBox = '') then begin
            CurrPage.Update(false);
            exit;
        end;

        SearchDim(SearchBox, DimValue);

        Rec.Copy(DimValue);
        Rec.SetLoadFields();
        Rec.MarkedOnly(true);
        CurrPage.Update(false);
    end;

    local procedure SearchDim(SearchBox: Text; var DimValue: Record "Dimension Value")
    var
        DimFound: Boolean;
    begin
        DimValue.FilterGroup := -1;
        ApplyMemberFilter(SearchBox, DimValue);
        DimValue.SetLoadFields(Code);

        if (DimValue.GetFilters() <> '') then begin
            DimFound := DimValue.FindSet();
            if (DimFound) then
                repeat
                    DimValue.Mark(true);
                until (DimValue.Next() = 0);
        end;
        DimValue.FilterGroup := 0;
    end;

    local procedure ApplyMemberFilter(SearchBox: Text; var DimValue: Record "Dimension Value")
    begin
        if (StrLen(SearchBox) <= MaxStrLen(DimValue.Code)) then
            DimValue.SetFilter(Code, '%1', UpperCase(SearchBox));

        if (StrLen(SearchBox) <= MaxStrLen(DimValue.Name)) then
            DimValue.SetFilter(Name, '%1', '@' + ConvertSpaceToWildcard(SearchBox));
    end;

    local procedure ConvertSpaceToWildcard(SearchBox: Text): Text
    var
    begin
        exit(ConvertStr(SearchBox, ' ', '*') + '*');
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Text000: Label 'Shortcut Dimension %1';
        [InDataSet]
        Emphasize: Boolean;
        [InDataSet]
        NameIndent: Integer;
        SearchBox: Text;

    procedure GetSelectionFilter(): Text
    var
        DimVal: Record "Dimension Value";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(DimVal);
        exit(SelectionFilterManagement.GetSelectionFilterForDimensionValue(DimVal));
    end;

    procedure SetSelection(var DimVal: Record "Dimension Value")
    begin
        CurrPage.SetSelectionFilter(DimVal);
    end;
}