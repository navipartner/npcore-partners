page 6014649 "NPR Generic Filter Page"
{
    Caption = 'Generic Filter Page';
    DataCaptionExpression = PageCaptionExpr;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            grid(Sorting)
            {
                Caption = 'Sorting';
                group(Control6014414)
                {
                    ShowCaption = false;
                    field(SortingKey; SortingKey)
                    {
                        ApplicationArea = All;
                        Caption = 'Key';
                        Editable = false;
                        Lookup = true;
                        ToolTip = 'Specifies the value of the Key field';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            IntegerRec: Record "Integer";
                            GenericKeyList: Page "NPR Generic Key List";
                            SelectedKeyIndex: Integer;
                        begin
                            GenericKeyList.SetParameters(RecRef, SortingKey);
                            GenericKeyList.LookupMode := true;
                            if GenericKeyList.RunModal = ACTION::LookupOK then begin
                                GenericKeyList.GetRecord(IntegerRec);
                                SortingKey := GenericKeyList.GetSortingKey(IntegerRec.Number);
                            end;
                        end;
                    }
                    field(Descending; Descending)
                    {
                        ApplicationArea = All;
                        Caption = 'Descending';
                        ToolTip = 'Specifies the value of the Descending field';
                    }
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
                field("Filter"; FilterText)
                {
                    ApplicationArea = All;
                    Caption = 'Filter';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GenericMultipleCheckList: Page "NPR Gen. Multiple Check List";
                        RelationRecRef: RecordRef;
                        RelationFieldRef: FieldRef;
                        RelationKeyRef: KeyRef;
                        Variant: Variant;
                    begin
                        case true of
                            FldRef.Relation <> 0:
                                begin
                                    RelationRecRef.Open(FldRef.Relation);
                                    RelationKeyRef := RelationRecRef.KeyIndex(1);
                                    if RelationKeyRef.FieldCount > 1 then
                                        Error(OnlySimpleKeysSupportedErr);
                                    Variant := RelationRecRef;
                                    if PAGE.RunModal(0, Variant) = ACTION::LookupOK then begin
                                        RelationRecRef := Variant;
                                        RelationFieldRef := RelationKeyRef.FieldIndex(1);
                                        FilterText := RelationFieldRef.Value;
                                    end;
                                end;
                            FldRef.OptionMembers <> '':
                                begin
                                    GenericMultipleCheckList.LookupMode := true;
                                    GenericMultipleCheckList.SetOptions(FldRef.OptionMembers, FilterText);
                                    if GenericMultipleCheckList.RunModal = ACTION::LookupOK then
                                        FilterText := GenericMultipleCheckList.GetSelectedOption();
                                end;
                        end;
                        if FilterText <> '' then
                            FilterOnValidate();
                    end;

                    trigger OnValidate()
                    begin
                        FilterOnValidate();
                    end;
                }
                field(Include; Include)
                {
                    ApplicationArea = All;
                    Caption = 'Include';
                    ToolTip = 'Specifies the value of the Include field';

                    trigger OnValidate()
                    begin
                        GetFieldRef();
                        if not Include then begin
                            RemoveFieldFromRawFilter(FldRef.Name);
                            ResetFieldFilter();
                            FilterText := '';
                            Static := false;
                            Mark(false);
                        end;
                    end;
                }
                field(Static; Static)
                {
                    ApplicationArea = All;
                    Caption = 'Static';
                    ToolTip = 'Specifies the value of the Static field';

                    trigger OnValidate()
                    var
                        FilterValue: Text;
                    begin
                        if FilterText = '' then
                            exit;
                        GetFieldRef();
                        if not Static then begin
                            if not Confirm(StaticDisableQst) then begin
                                Static := not Static;
                                exit;
                            end;
                            RemoveFieldFromRawFilter(FldRef.Name);
                            FldRef.SetFilter(FilterText);
                            FilterText := FldRef.GetFilter;
                            WriteRawFilter(FldRef.Name, FilterText);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowAllFields)
            {
                Caption = 'Show All Fields';
                Image = AllLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show All Fields action';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(false);
                end;
            }
            action(FilteredFields)
            {
                Caption = 'Show Filtered Fields';
                Image = FilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Filtered Fields action';

                trigger OnAction()
                begin
                    ShowFilteredFields();
                end;
            }
            action(RemoveAllFilters)
            {
                Caption = 'Remove All Filters';
                Image = RemoveFilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Remove All Filters action';

                trigger OnAction()
                begin
                    ResetAllFilters();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        RawFilter: Text;
    begin
        FilterText := '';
        Include := false;
        Static := false;
        GetFieldRef();
        ResetFieldFilter();
        RawFilter := ReadRawFilter(FldRef.Name);
        if RawFilter <> '' then begin
            FldRef.SetFilter(RawFilter);
            FilterText := FldRef.GetFilter;
            Include := true;
            Static := FilterText <> RawFilter;
            if Static then
                FilterText := RawFilter;
        end;
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup := 2;
        Rec.SetRange(TableNo, RecRef.Number);
        Rec.FilterGroup := 0;
        InitKeyWords();
        SetOrder();
        SetCurrKey();
        ShowFilteredFields();
        PageCaptionExpr := RecRef.Caption;
    end;

    var
        GenericFilterPageMgt: Codeunit "NPR Generic Filter Page Mgt.";
        RecRef: RecordRef;
        FldRef: FieldRef;
        "Descending": Boolean;
        Include: Boolean;
        Static: Boolean;
        TableID: Integer;
        OnlySimpleKeysSupportedErr: Label 'Only related tables with simple primary keys are supported.';
        StaticDisableQst: Label 'This will apply standard filter and static filter will be lost. Do you want to continue?';
        CompleteFilterText: Text;
        DescendingKeyWord: Text;
        FilterKeyWord: Text;
        FilterText: Text;
        OriginalFilterText: Text;
        PageCaptionExpr: Text;
        SortingKey: Text;
        SortingKeyWord: Text;
        WhereKeyWord: Text;

    local procedure InitKeyWords()
    begin
        FilterKeyWord := '=FILTER(';
        WhereKeyWord := ' WHERE(';
        SortingKeyWord := 'SORTING(';
        DescendingKeyWord := ') ORDER(Descending)';
    end;

    procedure SetRecRef(var RecRef2: RecordRef)
    begin
        RecRef := RecRef2;
    end;

    procedure GetRecRef(var FilteredRecRef: RecordRef)
    begin
        FilteredRecRef := RecRef;
    end;

    local procedure GetFieldRef()
    begin
        FldRef := RecRef.Field(Rec."No.");
    end;

    local procedure ResetFieldFilter()
    begin
        FldRef.SetRange();
    end;

    local procedure ResetAllFilters()
    begin
        Rec.Reset();
        Rec.FilterGroup := 2;
        Rec.SetRange(TableNo, RecRef.Number);
        Rec.FilterGroup := 0;
        RecRef.Reset();
        FilterText := '';
        Include := false;
        Static := false;
        CompleteFilterText := '';
    end;

    local procedure ShowFilteredFields()
    var
        i: Integer;
    begin
        if CompleteFilterText <> '' then begin
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if ReadRawFilter(FldRef.Name) <> '' then begin
                    Get(RecRef.Number, FldRef.Number);
                    Rec.Mark(true);
                end;
            end;
            Rec.MarkedOnly(true);
        end;
    end;

    local procedure ReadRawFilter(FieldName: Text) FilterValue: Text
    var
        Position: Integer;
    begin
        Position := StrPos(CompleteFilterText, FieldName + FilterKeyWord);
        case true of
            Position = 0:
                exit('');
            Position > 1:
                if not (CompleteFilterText[Position - 1] in [',', '(']) then
                    exit('');
        end;
        Position := StrPos(CompleteFilterText, FieldName + FilterKeyWord) + StrLen(FieldName) + StrLen(FilterKeyWord);
        FilterValue := CopyStr(CompleteFilterText, Position);
        exit(CopyStr(FilterValue, 1, StrPos(FilterValue, ')') - 1));
    end;

    local procedure WriteRawFilter(FieldName: Text; FilterValue: Text)
    begin
        if CompleteFilterText <> '' then begin
            if CompleteFilterText[StrLen(CompleteFilterText)] = ')' then
                CompleteFilterText := CopyStr(CompleteFilterText, 1, StrLen(CompleteFilterText) - 1);
            if CompleteFilterText <> '' then
                CompleteFilterText += ',';
        end;
        CompleteFilterText += FieldName + FilterKeyWord + FilterValue + '))';
    end;

    local procedure RemoveFieldFromRawFilter(FieldName: Text)
    var
        Length: Integer;
        Position: Integer;
        FilterValue: Text;
    begin
        FilterValue := ReadRawFilter(FieldName);
        if FilterValue = '' then
            exit;
        Position := StrPos(CompleteFilterText, FieldName + FilterKeyWord);
        Length := StrLen(FieldName) + StrLen(FilterKeyWord) + StrLen(FilterValue) + 1;
        if Position > 1 then
            if CompleteFilterText[Position - 1] = ',' then begin
                Position -= 1;
                Length += 1;
            end;
        CompleteFilterText := DelStr(CompleteFilterText, Position, Length);
        if CompleteFilterText[1] = ',' then
            CompleteFilterText := CopyStr(CompleteFilterText, 2);
        if StrPos(CompleteFilterText, WhereKeyWord + ',') > 0 then
            CompleteFilterText := DelStr(CompleteFilterText, StrLen(WhereKeyWord + ','), 1);
    end;

    procedure ReturnRawFilter() "Filter": Text
    begin
        Filter := CompleteFilterText;
        if (CompleteFilterText <> '') and (StrPos(CompleteFilterText, WhereKeyWord) = 0) then
            Filter := WhereKeyWord + CompleteFilterText;
        if Descending then
            Filter := CopyStr(DescendingKeyWord, 2) + Filter;
        Filter := SortingKeyWord + SortingKey + ')' + Filter;
        exit(Filter);
    end;

    local procedure FilterOnValidate()
    begin
        GetFieldRef();
        ResetFieldFilter();
        RemoveFieldFromRawFilter(FldRef.Name);
        if FilterText <> '' then begin
            FldRef.SetFilter(FilterText);
            WriteRawFilter(FldRef.Name, FilterText);
            Static := FilterText <> FldRef.GetFilter;
            Include := true;
            Rec.Mark(true);
        end else begin
            Include := false;
            Static := false;
            Rec.Mark(false);
        end;
    end;

    local procedure SetCurrKey()
    var
        FieldRefHere: FieldRef;
        FilterStartPosition: Integer;
        i: Integer;
        SortingKeyEndPos: Integer;
        KeyRefHere: KeyRef;
    begin
        if StrPos(CompleteFilterText, SortingKeyWord) <> 0 then begin
            case true of
                Descending:
                    begin
                        FilterStartPosition := StrPos(CompleteFilterText, DescendingKeyWord) + StrLen(DescendingKeyWord);
                        if StrPos(CompleteFilterText, WhereKeyWord) <> 0 then
                            FilterStartPosition := StrPos(CompleteFilterText, WhereKeyWord) + StrLen(WhereKeyWord);
                        SortingKeyEndPos := StrPos(CompleteFilterText, DescendingKeyWord) - 1;
                    end;
                StrPos(CompleteFilterText, ')' + WhereKeyWord) <> 0:
                    begin
                        FilterStartPosition := StrPos(CompleteFilterText, ')' + WhereKeyWord) + StrLen(')' + WhereKeyWord);
                        SortingKeyEndPos := StrPos(CompleteFilterText, ')' + WhereKeyWord) - 1;
                    end;
                else begin
                        FilterStartPosition := StrLen(CompleteFilterText) + 1;
                        SortingKeyEndPos := StrPos(CompleteFilterText, ')') - 1;
                    end;
            end;
            SortingKey := CopyStr(PadStr(CompleteFilterText, SortingKeyEndPos), StrLen(SortingKeyWord) + 1);
            CompleteFilterText := CopyStr(CompleteFilterText, FilterStartPosition);
        end else
            SortingKey := GenericFilterPageMgt.ReadKeyString(RecRef, 1);
    end;

    local procedure SetOrder()
    begin
        Descending := StrPos(CompleteFilterText, DescendingKeyWord) <> 0;
    end;

    procedure SetRawFilter(RawFilter: Text)
    begin
        CompleteFilterText := RawFilter;
    end;
}

