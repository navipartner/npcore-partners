codeunit 6060155 "NPR Event Attribute Mgt."
{
    var
        EventAttributeFound: Label 'You can''t change %1 as it is already part of template (or is a template) which has assigned values. If you wish to change it, create new template and do changes on it.';
        EventAttributeTemplateOnReport: Record "NPR Event Attribute Template";
        EventAttrColumnValueOnReport: Record "NPR Event Attr. Column Value";

    procedure RowValueFormulaAssistEdit(var Rec: Record "NPR Event Attr. Row Value")
    var
        EventAttributeRowValue: Record "NPR Event Attr. Row Value";
        EventAttributeRowValues: Page "NPR Event Attr. Row Values";
        NewFormula: Text;
    begin
        if Rec.Type = Rec.Type::" " then
            exit;
        EventAttributeRowValue.SetRange("Template Name", Rec."Template Name");
        EventAttributeRowValue.SetRange(Type, EventAttributeRowValue.Type::" ");
        EventAttributeRowValue.SetFilter("Line No.", '<>%1', Rec."Line No.");
        EventAttributeRowValues.SetTableView(EventAttributeRowValue);
        EventAttributeRowValues.SetVisibility();
        EventAttributeRowValues.LookupMode := true;
        EventAttributeRowValues.Editable := false;
        if EventAttributeRowValues.RunModal() = ACTION::LookupOK then begin
            EventAttributeRowValues.SetSelection(EventAttributeRowValue);
            NewFormula := RowValueConcatenateLineNo(EventAttributeRowValue);
            if NewFormula <> '' then begin
                Rec.Validate(Formula, NewFormula);
                Rec.Modify(true);
            end;
        end;
    end;

    local procedure RowValueConcatenateLineNo(var EventAttributeRowValue: Record "NPR Event Attr. Row Value") Lines: Text[250]
    begin
        if EventAttributeRowValue.FindSet() then
            repeat
                if Lines <> '' then
                    Lines := Lines + ',';
                Lines := Lines + Format(EventAttributeRowValue."Line No.");
            until EventAttributeRowValue.Next() = 0;
        exit(Lines);
    end;

    procedure TemplateHasEntries(Type: Option Row,Column,Template; Name: Code[20])
    var
        EventAttributeTemplate: Record "NPR Event Attribute Template";
        EventAttributeEntry: Record "NPR Event Attribute Entry";
        TableCaption: Text;
        EventAttributeRowValue: Record "NPR Event Attr. Row Value";
        EventAttributeColumnValue: Record "NPR Event Attr. Column Value";
    begin
        case Type of
            Type::Row:
                begin
                    EventAttributeTemplate.SetRange("Row Template Name", Name);
                    TableCaption := EventAttributeRowValue.TableCaption;
                end;
            Type::Column:
                begin
                    EventAttributeTemplate.SetRange("Column Template Name", Name);
                    TableCaption := EventAttributeColumnValue.TableCaption;
                end;
            Type::Template:
                begin
                    EventAttributeTemplate.SetRange(Name, Name);
                    TableCaption := EventAttributeTemplate.TableCaption;
                end;
        end;
        if EventAttributeTemplate.IsEmpty then
            exit;
        EventAttributeTemplate.FindSet();
        repeat
            EventAttributeEntry.SetRange("Template Name", EventAttributeTemplate.Name);
            if not EventAttributeEntry.IsEmpty then
                Error(EventAttributeFound, TableCaption);
        until EventAttributeTemplate.Next() = 0;
    end;

    procedure ExcludeRowFromFormula(Rec: Record "NPR Event Attr. Row Value")
    var
        EventAttributeRowValue: Record "NPR Event Attr. Row Value";
        EventAttributeRowValue2: Record "NPR Event Attr. Row Value";
        TotalNoOfFields: Integer;
        OptionNo: Integer;
        NewFormulaValue: Text;
        TypeHelper: Codeunit "Type Helper";
    begin
        SetFormulaSearchFilter(Rec."Template Name", Rec."Line No.", EventAttributeRowValue);
        if EventAttributeRowValue.FindSet() then
            repeat
                TotalNoOfFields := TypeHelper.GetNumberOfOptions(EventAttributeRowValue.Formula);
                OptionNo := TypeHelper.GetOptionNo(Format(Rec."Line No."), EventAttributeRowValue.Formula);
                case true of
                    (OptionNo = 0) and (OptionNo = TotalNoOfFields):
                        NewFormulaValue := '';
                    (OptionNo = 0) and (OptionNo < TotalNoOfFields):
                        NewFormulaValue := CopyStr(EventAttributeRowValue.Formula, StrLen(Format(Rec."Line No.") + ',') + 1);
                    (OptionNo > 0) and (OptionNo < TotalNoOfFields):
                        NewFormulaValue := CopyStr(EventAttributeRowValue.Formula, 1, StrPos(EventAttributeRowValue.Formula, Format(Rec."Line No.")) - 1) +
                                            CopyStr(EventAttributeRowValue.Formula, StrPos(EventAttributeRowValue.Formula, Format(Rec."Line No.") + ',') + StrLen(Format(Rec."Line No.") + ','));
                    (OptionNo = TotalNoOfFields):
                        NewFormulaValue := CopyStr(EventAttributeRowValue.Formula, 1, StrPos(EventAttributeRowValue.Formula, ',' + Format(Rec."Line No.")) - 1);
                end;
                EventAttributeRowValue2.Get(EventAttributeRowValue."Template Name", EventAttributeRowValue."Line No.");
                EventAttributeRowValue2.Formula := NewFormulaValue;
                EventAttributeRowValue2.Modify(true);
            until EventAttributeRowValue.Next() = 0;
    end;

    local procedure SetEventAttributeEntryFilter(TemplateName: Code[20]; JobNo: Code[20]; RowLineNo: Integer; ColumnLineNo: Integer; var EventAttributeEntry: Record "NPR Event Attribute Entry")
    begin
        Clear(EventAttributeEntry);
        EventAttributeEntry.SetRange("Template Name", TemplateName);
        EventAttributeEntry.SetRange("Job No.", JobNo);
        EventAttributeEntry.SetRange("Row Line No.", RowLineNo);
        EventAttributeEntry.SetRange("Column Line No.", ColumnLineNo);
    end;

    local procedure SetFormulaSearchFilter(RowTemplateName: Code[20]; RowLineNo: Integer; var EventAttrRowValue: Record "NPR Event Attr. Row Value")
    begin
        Clear(EventAttrRowValue);
        EventAttrRowValue.SetRange("Template Name", RowTemplateName);
        EventAttrRowValue.SetFilter(Type, '<>%1', EventAttrRowValue.Type::" ");
        EventAttrRowValue.SetFilter(Formula, '%1', StrSubstNo('*%1*', Format(RowLineNo)));
    end;

    procedure EventAttributeEntryAction(ActionHere: Option "Insert/Modify",Delete,Read; TemplateName: Code[20]; JobNo: Code[20]; RowLineNo: Integer; ColumnLineNo: Integer; ColumnCaption: Text; var Value: Text; FilterMode: Boolean; FilterName: Code[20])
    var
        EntryNo: Integer;
        EventAttrTemplate: Record "NPR Event Attribute Template";
        EventAttributeEntry: Record "NPR Event Attribute Entry";
        ValueDec: Decimal;
        EventAttrColValue: Record "NPR Event Attr. Column Value";
        WrongDataType: Label 'Column %1 is of type %2 and only values of that type can be entered.';
    begin
        if EventAttributeEntry.FindLast() then
            EntryNo := EventAttributeEntry."Entry No.";
        SetEventAttributeEntryFilter(TemplateName, JobNo, RowLineNo, ColumnLineNo, EventAttributeEntry);
        EventAttributeEntry.SetRange(Filter, FilterMode);
        EventAttributeEntry.SetRange("Filter Name", FilterName);
        EventAttrTemplate.Get(TemplateName);
        case ActionHere of
            ActionHere::"Insert/Modify":
                begin
                    if not FilterMode then begin
                        EventAttrColValue.Get(EventAttrTemplate."Column Template Name", ColumnLineNo);
                        case EventAttrColValue.Type of
                            EventAttrColValue.Type::Decimal:
                                if not Evaluate(ValueDec, Value) then
                                    Error(WrongDataType, ColumnCaption, EventAttrColValue.Type);
                        end;
                    end;
                    if EventAttributeEntry.FindFirst() then begin
                        EventAttributeEntry."Value Text" := Value;
                        EventAttributeEntry."Value Decimal" := ValueDec;
                        EventAttributeEntry.Modify();
                    end else begin
                        EventAttributeEntry."Entry No." := EntryNo + 1;
                        EventAttributeEntry."Template Name" := TemplateName;
                        EventAttributeEntry."Job No." := JobNo;
                        EventAttributeEntry."Row Line No." := RowLineNo;
                        EventAttributeEntry."Column Line No." := ColumnLineNo;
                        EventAttributeEntry."Value Text" := Value;
                        EventAttributeEntry."Value Decimal" := ValueDec;
                        EventAttributeEntry.Filter := FilterMode;
                        EventAttributeEntry."Filter Name" := FilterName;
                        EventAttributeEntry.Insert();
                    end;
                end;
            ActionHere::Delete:
                EventAttributeEntry.DeleteAll();
            ActionHere::Read:
                begin
                    Value := '';
                    if EventAttributeEntry.FindFirst() then
                        Value := EventAttributeEntry."Value Text";
                end;
        end;
    end;

    local procedure CalculateSum(TemplateName: Code[20]; JobNo: Code[20]; ColumnLineNo: Integer; Formula: Text) TotalSum: Decimal
    var
        TypeHelper: Codeunit "Type Helper";
        NoOfLines: Integer;
        i: Integer;
        RowLineNo: Integer;
        EventAttributeEntry: Record "NPR Event Attribute Entry";
    begin
        NoOfLines := TypeHelper.GetNumberOfOptions(Formula) + 1;
        for i := 1 to NoOfLines do begin
            Evaluate(RowLineNo, SelectStr(i, Formula));
            SetEventAttributeEntryFilter(TemplateName, JobNo, RowLineNo, ColumnLineNo, EventAttributeEntry);
            if EventAttributeEntry.FindFirst() then
                TotalSum += EventAttributeEntry."Value Decimal";
        end;
    end;

    local procedure UpdateFormulaResult(TemplateName: Code[20]; JobNo: Code[20]; RowLineNo: Integer; ColumnLineNo: Integer; ColumnCaption: Text)
    var
        EventAttributeTemplate: Record "NPR Event Attribute Template";
        EventAttrRowValue: Record "NPR Event Attr. Row Value";
        EventAttrColValue: Record "NPR Event Attr. Column Value";
        NewValue: Text;
        ActionHere: Integer;
    begin
        EventAttributeTemplate.Get(TemplateName);
        SetFormulaSearchFilter(EventAttributeTemplate."Row Template Name", RowLineNo, EventAttrRowValue);
        if EventAttrRowValue.FindSet() then
            repeat
                case EventAttrRowValue.Type of
                    EventAttrRowValue.Type::Sum:
                        begin
                            if EventAttrColValue.Get(EventAttributeTemplate."Column Template Name", ColumnLineNo) and
                                (EventAttrColValue.Type = EventAttrColValue.Type::Decimal) and
                                EventAttrColValue."Include in Formula" then
                                NewValue := Format(CalculateSum(TemplateName, JobNo, ColumnLineNo, EventAttrRowValue.Formula));
                            if CheckDelete(TemplateName, ColumnLineNo, NewValue, false) then
                                ActionHere := 1;
                            EventAttributeEntryAction(ActionHere, TemplateName, JobNo, EventAttrRowValue."Line No.", ColumnLineNo, ColumnCaption, NewValue, false, '');
                        end;
                end;
            until EventAttrRowValue.Next() = 0;
    end;

    procedure CheckAndUpdate(TemplateName: Code[20]; JobNo: Code[20]; RowLineNo: Integer; ColumnLineNo: Integer; ColumnCaption: Text; AttributeValue: Text; FilterMode: Boolean; FilterName: Code[20])
    var
        ActionHere: Integer;
    begin
        if CheckDelete(TemplateName, ColumnLineNo, AttributeValue, FilterMode) then
            ActionHere := 1;
        EventAttributeEntryAction(ActionHere, TemplateName, JobNo, RowLineNo, ColumnLineNo, ColumnCaption, AttributeValue, FilterMode, FilterName);
        if not FilterMode then
            UpdateFormulaResult(TemplateName, JobNo, RowLineNo, ColumnLineNo, ColumnCaption);
    end;

    local procedure CheckDelete(TemplateName: Code[20]; ColumnLineNo: Integer; AttributeValue: Text; FilterMode: Boolean): Boolean
    var
        EventAttributeTemplate: Record "NPR Event Attribute Template";
        EventAttrColValue: Record "NPR Event Attr. Column Value";
    begin
        EventAttributeTemplate.Get(TemplateName);
        EventAttrColValue.Get(EventAttributeTemplate."Column Template Name", ColumnLineNo);
        case EventAttrColValue.Type of
            EventAttrColValue.Type::Text:
                exit(AttributeValue = '');
            EventAttrColValue.Type::Decimal:
                if FilterMode then
                    exit(AttributeValue = '')
                else
                    exit(AttributeValue in ['0', '']);
        end;
    end;

    procedure CopyAttributes(FromTemplateName: Code[20]; FromEventNo: Code[20]; ToEventNo: Code[20]; var ReturnMsg: Text): Boolean
    var
        EventAttributeEntryFrom: Record "NPR Event Attribute Entry";
        EventAttributeEntryTo: Record "NPR Event Attribute Entry";
        NextEntryNo: Integer;
        NothingToCopyTxt: Label 'There was nothing to copy.';
        EventAttributeFrom: Record "NPR Event Attribute";
        EventAttributeTo: Record "NPR Event Attribute";
    begin
        if FromEventNo <> '' then begin
            EventAttributeFrom.SetRange("Job No.", FromEventNo);
            if FromTemplateName <> '' then
                EventAttributeFrom.SetRange("Template Name", FromTemplateName);
            if EventAttributeFrom.FindSet() then
                repeat
                    EventAttributeTo.Init();
                    EventAttributeTo := EventAttributeFrom;
                    EventAttributeTo."Job No." := ToEventNo;
                    if not EventAttributeTo.Insert() then
                        Clear(EventAttributeTo);
                until EventAttributeFrom.Next() = 0;
        end;

        if EventAttributeEntryTo.FindLast() then
            NextEntryNo := EventAttributeEntryTo."Entry No.";

        if FromTemplateName <> '' then
            EventAttributeEntryFrom.SetRange("Template Name", FromTemplateName);
        EventAttributeEntryFrom.SetRange("Job No.", FromEventNo);
        if EventAttributeEntryFrom.FindSet() then begin
            repeat
                NextEntryNo += 1;
                EventAttributeEntryTo.Init();
                EventAttributeEntryTo := EventAttributeEntryFrom;
                EventAttributeEntryTo."Entry No." := NextEntryNo;
                EventAttributeEntryTo."Job No." := ToEventNo;
                EventAttributeEntryTo.Insert();
            until EventAttributeEntryFrom.Next() = 0;
            exit(true);
        end;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    procedure FindEventsInAttributesFilter(TemplateName: Code[20]; FilterName: Code[20]; var Job: Record Job): Boolean
    var
        EventAttributeEntry: Record "NPR Event Attribute Entry";
        EventAttrTemplate: Record "NPR Event Attribute Template";
        EventAttributeEntryFiltered: Record "NPR Event Attribute Entry";
        FilterCount: Integer;
        TempJob: Record Job temporary;
        EventAttrColValue: Record "NPR Event Attr. Column Value";
    begin
        EventAttrTemplate.Get(TemplateName);
        EventAttributeEntry.SetRange("Template Name", TemplateName);
        EventAttributeEntry.SetRange(Filter, true);
        EventAttributeEntry.SetRange("Filter Name", FilterName);
        if not EventAttributeEntry.FindSet() then
            exit(false);
        repeat
            FilterCount += 1;
            EventAttrColValue.Get(EventAttrTemplate."Column Template Name", EventAttributeEntry."Column Line No.");
            EventAttributeEntryFiltered.SetRange("Template Name", TemplateName);
            EventAttributeEntryFiltered.SetFilter("Job No.", '<>%1', '');
            EventAttributeEntryFiltered.SetRange(Filter, false);
            EventAttributeEntryFiltered.SetRange("Row Line No.", EventAttributeEntry."Row Line No.");
            EventAttributeEntryFiltered.SetRange("Column Line No.", EventAttributeEntry."Column Line No.");
            case EventAttrColValue.Type of
                EventAttrColValue.Type::Decimal:
                    EventAttributeEntryFiltered.SetFilter("Value Decimal", EventAttributeEntry."Value Text");
                EventAttrColValue.Type::Text:
                    EventAttributeEntryFiltered.SetFilter("Value Text", EventAttributeEntry."Value Text");
            end;
            if not EventAttributeEntryFiltered.FindSet() then
                exit(false);
            if FilterCount = 1 then
                repeat
                    if not TempJob.Get(EventAttributeEntryFiltered."Job No.") then begin
                        TempJob."No." := EventAttributeEntryFiltered."Job No.";
                        TempJob.Insert();
                    end;
                until EventAttributeEntryFiltered.Next() = 0
            else begin
                if TempJob.FindSet() then
                    repeat
                        EventAttributeEntryFiltered.SetRange("Job No.", TempJob."No.");
                        if EventAttributeEntryFiltered.IsEmpty then
                            TempJob.Delete();
                    until TempJob.Next() = 0
                else
                    exit(false);
            end;
            EventAttributeEntryFiltered.SetRange("Value Decimal");
            EventAttributeEntryFiltered.SetRange("Value Text");
        until EventAttributeEntry.Next() = 0;
        if TempJob.FindSet() then
            repeat
                Job.Get(TempJob."No.");
                Job.Mark(true);
            until TempJob.Next() = 0;
        Job.MarkedOnly(true);
        exit(true);
    end;

    procedure ShowEventsInAttributesFilter(TemplateName: Code[20]; FilterName: Code[20]): Boolean
    var
        EventList: Page "NPR Event List";
        Job: Record Job;
    begin
        if not FindEventsInAttributesFilter(TemplateName, FilterName, Job) then
            exit(false);
        EventList.SetTableView(Job);
        EventList.RunModal();
        exit(true);
    end;

    procedure EventTemplateReportEventAttributeSetOnPreDataItem(TemplateName: Code[20]; var EventAttributeRowValue: Record "NPR Event Attr. Row Value"): Boolean
    begin
        if TemplateName = '' then
            exit(false);
        Clear(EventAttributeTemplateOnReport);
        Clear(EventAttrColumnValueOnReport);
        EventAttributeTemplateOnReport.Get(TemplateName);
        EventAttributeRowValue.SetRange("Template Name", EventAttributeTemplateOnReport."Row Template Name");
        EventAttributeRowValue.SetRange(Promote, true);
        EventAttrColumnValueOnReport.SetRange("Template Name", EventAttributeTemplateOnReport."Column Template Name");
        EventAttrColumnValueOnReport.SetRange(Promote, true);
        exit(not EventAttributeRowValue.IsEmpty());
    end;

    procedure EventTemplateReportEventAttributeSetOnAfterGetRecord(EventAttributeRowValue: Record "NPR Event Attr. Row Value"; var AttributeValue: array[5] of Text; var ColumnCaption: array[5] of Text; JobNo: Code[20])
    var
        i: Integer;
    begin
        if EventAttrColumnValueOnReport.FindSet() then
            repeat
                i += 1;
                AttributeValue[i] := '';
                ColumnCaption[i] := EventAttrColumnValueOnReport.Description;
                EventAttributeEntryAction(2, EventAttributeTemplateOnReport.Name, JobNo, EventAttributeRowValue."Line No.", EventAttrColumnValueOnReport."Line No.", EventAttrColumnValueOnReport.Description, AttributeValue[i], false, '');
            until (EventAttrColumnValueOnReport.Next() = 0) or (i = ArrayLen(AttributeValue));
    end;
}

