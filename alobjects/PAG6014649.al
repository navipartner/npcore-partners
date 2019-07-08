page 6014649 "Generic Filter Page"
{
    // NPR5.45/NPKNAV/20180903  CASE 318531 Transport NPR5.45 - 31 August 2018
    // NPR5.48/TJ    /20181130  CASE 318531 Additional features added

    Caption = 'Generic Filter Page';
    DataCaptionExpression = PageCaptionExpr;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
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
                    field(SortingKey;SortingKey)
                    {
                        Caption = 'Key';
                        Editable = false;
                        Lookup = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenericKeyList: Page "Generic Key List";
                            SelectedKeyIndex: Integer;
                            IntegerRec: Record "Integer";
                        begin
                            //-NPR5.48 [318531]
                            GenericKeyList.SetParameters(RecRef,SortingKey);
                            GenericKeyList.LookupMode := true;
                            if GenericKeyList.RunModal = ACTION::LookupOK then begin
                              GenericKeyList.GetRecord(IntegerRec);
                              SortingKey := GenericKeyList.GetSortingKey(IntegerRec.Number);
                            end;
                            //+NPR5.48 [318531]
                        end;
                    }
                    field("Descending";Descending)
                    {
                        Caption = 'Descending';
                    }
                }
            }
            repeater(Group)
            {
                field("No.";"No.")
                {
                    Editable = false;
                }
                field("Field Caption";"Field Caption")
                {
                    Editable = false;
                }
                field("Filter";FilterText)
                {
                    Caption = 'Filter';
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Variant: Variant;
                        RelationRecRef: RecordRef;
                        RelationKeyRef: KeyRef;
                        RelationFieldRef: FieldRef;
                        GenericMultipleCheckList: Page "Generic Multiple Check List";
                    begin
                        //-NPR5.48 [318531]
                        case true of
                          FldRef.Relation <> 0:
                            begin
                              RelationRecRef.Open(FldRef.Relation);
                              RelationKeyRef := RelationRecRef.KeyIndex(1);
                              if RelationKeyRef.FieldCount > 1 then
                                Error(OnlySimpleKeysSupportedErr);
                              Variant := RelationRecRef;
                              if PAGE.RunModal(0,Variant) = ACTION::LookupOK then begin
                                RelationRecRef := Variant;
                                RelationFieldRef := RelationKeyRef.FieldIndex(1);
                                FilterText := RelationFieldRef.Value;
                              end;
                            end;
                          FldRef.OptionString <> '':
                            begin
                              GenericMultipleCheckList.LookupMode := true;
                              GenericMultipleCheckList.SetOptions(FldRef.OptionString,FilterText);
                              if GenericMultipleCheckList.RunModal = ACTION::LookupOK then
                                FilterText := GenericMultipleCheckList.GetSelectedOption();
                            end;
                        end;
                        if FilterText <> '' then
                          FilterOnValidate();
                        //+NPR5.48 [318531]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [318531]
                        /*
                        GetFieldRef();
                        ResetFieldFilter();
                        IF FilterText <> '' THEN BEGIN
                          FldRef.SETFILTER(FilterText);
                          Include := TRUE;
                          MARK(TRUE);
                        END;
                        */
                        FilterOnValidate();
                        //+NPR5.48 [318531]

                    end;
                }
                field(Include;Include)
                {
                    Caption = 'Include';

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [318531]
                        GetFieldRef();
                        //+NPR5.48 [318531]
                        if not Include then begin
                          //-NPR5.48 [318531]
                          RemoveFieldFromRawFilter(FldRef.Name);
                          //+NPR5.48 [318531]
                          ResetFieldFilter();
                          FilterText := '';
                          //-NPR5.48 [318531]
                          Static := false;
                          //+NPR5.48 [318531]
                          Mark(false);
                        end;
                    end;
                }
                field(Static;Static)
                {
                    Caption = 'Static';

                    trigger OnValidate()
                    var
                        FilterValue: Text;
                    begin
                        //-NPR5.48 [318531]
                        if FilterText = '' then
                          exit;
                        GetFieldRef();
                        if not Static then begin
                          if not Confirm(ConfirmStaticDisable) then begin
                            Static := not Static;
                            exit;
                          end;
                          RemoveFieldFromRawFilter(FldRef.Name);
                          FldRef.SetFilter(FilterText);
                          FilterText := FldRef.GetFilter;
                          WriteRawFilter(FldRef.Name,FilterText);
                        end;
                        //+NPR5.48 [318531]
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    MarkedOnly(false);
                end;
            }
            action(ShowFilteredFields)
            {
                Caption = 'Show Filtered Fields';
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                PromotedCategory = Process;
                PromotedIsBig = true;

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
        //-NPR5.48 [318531]
        Static := false;
        //+NPR5.48 [318531]
        GetFieldRef();
        //-NPR5.48 [318531]
        ResetFieldFilter();
        RawFilter := ReadRawFilter(FldRef.Name);
        //IF FldRef.GETFILTER <> '' THEN BEGIN
        if RawFilter <> '' then begin
          FldRef.SetFilter(RawFilter);
        //+NPR5.48 [318531]
          FilterText := FldRef.GetFilter;
          Include := true;
          //-NPR5.48 [318531]
          Static := FilterText <> RawFilter;
          if Static then
            FilterText := RawFilter;
          //+NPR5.48 [318531]
        end;
    end;

    trigger OnOpenPage()
    begin
        FilterGroup := 2;
        SetRange(TableNo,RecRef.Number);
        FilterGroup := 0;
        //-NPR5.48 [318531]
        InitKeyWords();
        SetOrder();
        SetCurrKey();
        //+NPR5.48 [318531]
        ShowFilteredFields();
        PageCaptionExpr := RecRef.Caption;
    end;

    var
        FilterText: Text;
        TableID: Integer;
        RecRef: RecordRef;
        FldRef: FieldRef;
        Include: Boolean;
        PageCaptionExpr: Text;
        CompleteFilterText: Text;
        Static: Boolean;
        OriginalFilterText: Text;
        FilterKeyWord: Text;
        WhereKeyWord: Text;
        ConfirmStaticDisable: Label 'This will apply standard filter and static filter will be lost. Do you want to continue?';
        SortingKey: Text;
        "Descending": Boolean;
        SortingKeyWord: Text;
        DescendingKeyWord: Text;
        GenericFilterPageMgt: Codeunit "Generic Filter Page Mgt.";
        OnlySimpleKeysSupportedErr: Label 'Only related tables with simple primary keys are supported.';

    local procedure InitKeyWords()
    begin
        //-NPR5.48 [318531]
        FilterKeyWord := '=FILTER(';
        WhereKeyWord := ' WHERE(';
        SortingKeyWord := 'SORTING(';
        DescendingKeyWord := ') ORDER(Descending)';
        //+NPR5.48 [318531]
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
        FldRef := RecRef.Field("No.");
    end;

    local procedure ResetFieldFilter()
    begin
        FldRef.SetRange();
    end;

    local procedure ResetAllFilters()
    begin
        Reset;
        FilterGroup := 2;
        SetRange(TableNo,RecRef.Number);
        FilterGroup := 0;
        RecRef.Reset;
        FilterText := '';
        Include := false;
        //-NPR5.48 [318531]
        Static := false;
        CompleteFilterText := '';
        //+NPR5.48 [318531]
    end;

    local procedure ShowFilteredFields()
    var
        i: Integer;
    begin
        //-NPR5.48 [318531]
        //IF RecRef.HASFILTER THEN BEGIN
        if CompleteFilterText <> '' then begin
        //+NPR5.48 [318531]
          for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            //-NPR5.48 [318531]
            //IF FldRef.GETFILTER <> '' THEN BEGIN
            if ReadRawFilter(FldRef.Name) <> '' then begin
            //+NPR5.48 [318531]
              Get(RecRef.Number,FldRef.Number);
              Mark(true);
            end;
          end;
          MarkedOnly(true);
        end;
    end;

    local procedure ReadRawFilter(FieldName: Text) FilterValue: Text
    var
        Position: Integer;
    begin
        //-NPR5.48 [318531]
        Position := StrPos(CompleteFilterText,FieldName + FilterKeyWord);
        case true of
          Position = 0:
            exit('');
          Position > 1:
            if not (CompleteFilterText[Position - 1] in [',','(']) then
              exit('');
        end;
        Position := StrPos(CompleteFilterText,FieldName + FilterKeyWord) + StrLen(FieldName) + StrLen(FilterKeyWord);
        FilterValue := CopyStr(CompleteFilterText,Position);
        exit(CopyStr(FilterValue,1,StrPos(FilterValue,')') - 1));
        //+NPR5.48 [318531]
    end;

    local procedure WriteRawFilter(FieldName: Text;FilterValue: Text)
    begin
        //-NPR5.48 [318531]
        if CompleteFilterText <> '' then begin
          if CompleteFilterText[StrLen(CompleteFilterText)] = ')' then
            CompleteFilterText := CopyStr(CompleteFilterText,1,StrLen(CompleteFilterText) - 1);
          CompleteFilterText += ',';
        end;
        CompleteFilterText += FieldName + FilterKeyWord + FilterValue + '))';
        //+NPR5.48 [318531]
    end;

    local procedure RemoveFieldFromRawFilter(FieldName: Text)
    var
        FilterValue: Text;
        Position: Integer;
        Length: Integer;
    begin
        //-NPR5.48 [318531]
        FilterValue := ReadRawFilter(FieldName);
        if FilterValue = '' then
          exit;
        Position := StrPos(CompleteFilterText,FieldName + FilterKeyWord);
        Length := StrLen(FieldName) + StrLen(FilterKeyWord) + StrLen(FilterValue) + 1;
        if Position > 1 then
          if CompleteFilterText[Position - 1] = ',' then begin
            Position -= 1;
            Length += 1;
          end;
        CompleteFilterText := DelStr(CompleteFilterText,Position,Length);
        if CompleteFilterText[1] = ',' then
          CompleteFilterText := CopyStr(CompleteFilterText,2);
        if StrPos(CompleteFilterText,WhereKeyWord + ',') > 0 then
          CompleteFilterText := DelStr(CompleteFilterText,StrLen(WhereKeyWord + ','),1);
        //+NPR5.48 [318531]
    end;

    procedure ReturnRawFilter() "Filter": Text
    begin
        //-NPR5.48 [318531]
        Filter := CompleteFilterText;
        if (CompleteFilterText <> '') and (StrPos(CompleteFilterText,WhereKeyWord) = 0) then
          Filter := WhereKeyWord + CompleteFilterText ;
        if Descending then
          Filter := CopyStr(DescendingKeyWord,2) + Filter;
        Filter := SortingKeyWord + SortingKey + ')' + Filter;
        exit(Filter);
        //+NPR5.48 [318531]
    end;

    local procedure FilterOnValidate()
    begin
        //-NPR5.48 [318531]
        GetFieldRef();
        ResetFieldFilter();
        RemoveFieldFromRawFilter(FldRef.Name);
        if FilterText <> '' then begin
          FldRef.SetFilter(FilterText);
          WriteRawFilter(FldRef.Name,FilterText);
          Static := FilterText <> FldRef.GetFilter;
          Include := true;
          Mark(true);
        end else begin
          Include := false;
          Static := false;
          Mark(false);
        end;
        //+NPR5.48 [318531]
    end;

    local procedure SetCurrKey()
    var
        SortingKeyEndPos: Integer;
        FilterStartPosition: Integer;
        KeyRefHere: KeyRef;
        i: Integer;
        FieldRefHere: FieldRef;
    begin
        //-NPR5.48 [318531]
        if StrPos(CompleteFilterText,SortingKeyWord) <> 0 then begin
          case true of
            Descending:
              begin
                FilterStartPosition := StrPos(CompleteFilterText,DescendingKeyWord) + StrLen(DescendingKeyWord);
                if StrPos(CompleteFilterText,WhereKeyWord) <> 0 then
                  FilterStartPosition := StrPos(CompleteFilterText,WhereKeyWord) + StrLen(WhereKeyWord);
                SortingKeyEndPos := StrPos(CompleteFilterText,DescendingKeyWord) - 1;
              end;
            StrPos(CompleteFilterText,')' + WhereKeyWord) <> 0:
              begin
                FilterStartPosition := StrPos(CompleteFilterText,')' + WhereKeyWord) + StrLen(')' + WhereKeyWord);
                SortingKeyEndPos := StrPos(CompleteFilterText,')' + WhereKeyWord) - 1;
              end;
            else begin
              FilterStartPosition := StrLen(CompleteFilterText) + 1;
              SortingKeyEndPos := StrPos(CompleteFilterText,')') - 1;
            end;
          end;
          SortingKey := CopyStr(PadStr(CompleteFilterText,SortingKeyEndPos),StrLen(SortingKeyWord) + 1);
          CompleteFilterText := CopyStr(CompleteFilterText,FilterStartPosition);
        end else
          SortingKey := GenericFilterPageMgt.ReadKeyString(RecRef,1);
        //+NPR5.48 [318531]
    end;

    local procedure SetOrder()
    begin
        //-NPR5.48 [318531]
        Descending := StrPos(CompleteFilterText,DescendingKeyWord) <> 0;
        //+NPR5.48 [318531]
    end;

    procedure SetRawFilter(RawFilter: Text)
    begin
        //-NPR5.48 [318531]
        CompleteFilterText := RawFilter;
        //+NPR5.48 [318531]
    end;
}

