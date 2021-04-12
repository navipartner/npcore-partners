page 6060155 "NPR Event Attribute Matrix"
{
    Caption = 'Event Attribute Matrix';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Attr. Row Value";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(TemplateName; TemplateName)
                {
                    ApplicationArea = All;
                    Caption = 'Template Name';
                    Editable = false;
                    TableRelation = "NPR Event Attribute Template".Name;
                    ToolTip = 'Specifies the value of the Template Name field';

                    trigger OnValidate()
                    begin
                        SetAttrTemplate(TemplateName);
                    end;
                }
                field(JobNo; JobNo)
                {
                    ApplicationArea = All;
                    Caption = 'Event No.';
                    Editable = false;
                    TableRelation = Job."No." WHERE("NPR Event" = CONST(true));
                    Visible = JobNoVisible;
                    ToolTip = 'Specifies the value of the Event No. field';
                }
            }
            repeater(Group)
            {
                FreezeColumn = Formula;
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Formula field';
                }
                field(AttrColumnValue1; AttrColumnValue[1])
                {
                    ApplicationArea = All;
                    CaptionClass = AttrColumnCaption1;
                    Editable = AttrColumnEditable;
                    Visible = AttrColumnVisible1;
                    ToolTip = 'Specifies the value of the AttrColumnValue[1] field';

                    trigger OnValidate()
                    begin
                        CheckAndUpdate(1);
                    end;
                }
                field(AttrColumnValue2; AttrColumnValue[2])
                {
                    ApplicationArea = All;
                    CaptionClass = AttrColumnCaption2;
                    Editable = AttrColumnEditable;
                    Visible = AttrColumnVisible2;
                    ToolTip = 'Specifies the value of the AttrColumnValue[2] field';

                    trigger OnValidate()
                    begin
                        CheckAndUpdate(2);
                    end;
                }
                field(AttrColumnValue3; AttrColumnValue[3])
                {
                    ApplicationArea = All;
                    CaptionClass = AttrColumnCaption3;
                    Editable = AttrColumnEditable;
                    Visible = AttrColumnVisible3;
                    ToolTip = 'Specifies the value of the AttrColumnValue[3] field';

                    trigger OnValidate()
                    begin
                        CheckAndUpdate(3);
                    end;
                }
                field(AttrColumnValue4; AttrColumnValue[4])
                {
                    ApplicationArea = All;
                    CaptionClass = AttrColumnCaption4;
                    Editable = AttrColumnEditable;
                    Visible = AttrColumnVisible4;
                    ToolTip = 'Specifies the value of the AttrColumnValue[4] field';

                    trigger OnValidate()
                    begin
                        CheckAndUpdate(4);
                    end;
                }
                field(AttrColumnValue5; AttrColumnValue[5])
                {
                    ApplicationArea = All;
                    CaptionClass = AttrColumnCaption5;
                    Editable = AttrColumnEditable;
                    Visible = AttrColumnVisible5;
                    ToolTip = 'Specifies the value of the AttrColumnValue[5] field';

                    trigger OnValidate()
                    begin
                        CheckAndUpdate(5);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Collumn)
            {
                Caption = 'Collumn';
                action(PreviousSet)
                {
                    Caption = 'Previous Set';
                    Enabled = PreviousColumnSetExists;
                    Image = PreviousSet;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Previous Set action';

                    trigger OnAction()
                    begin
                        GetColumnSetup(false);
                    end;
                }
                action(NextSet)
                {
                    Caption = 'Next Set';
                    Enabled = NextColumnSetExists;
                    Image = NextSet;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Next Set action';

                    trigger OnAction()
                    begin
                        GetColumnSetup(true);
                    end;
                }
                action(ShowEvents)
                {
                    Caption = 'Show Events In Filter';
                    Image = ShowList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Visible = FilterMode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Events In Filter action';

                    trigger OnAction()
                    begin
                        if not EventAttrMgt.ShowEventsInAttributesFilter(TemplateName, FilterName) then
                            Message(NoEventsInFilter);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ReadEventAttributes();
        SetColumnEditable();
    end;

    trigger OnOpenPage()
    begin
        GetColumnSetup(true);
    end;

    var
        AttrColumnCaption: array[5] of Text;
        AttrColumnCaption1: Text;
        AttrColumnCaption2: Text;
        AttrColumnCaption3: Text;
        AttrColumnCaption4: Text;
        AttrColumnCaption5: Text;
        AttrColumnVisible: array[5] of Boolean;
        [InDataSet]
        AttrColumnVisible1: Boolean;
        [InDataSet]
        AttrColumnVisible2: Boolean;
        [InDataSet]
        AttrColumnVisible3: Boolean;
        [InDataSet]
        AttrColumnVisible4: Boolean;
        [InDataSet]
        AttrColumnVisible5: Boolean;
        AttrColumnValue: array[5] of Text;
        AttrColumnLineNo: array[5] of Integer;
        AttrColumnEditable: Boolean;
        [InDataSet]
        JobNoVisible: Boolean;
        EventAttrTemplate: Record "NPR Event Attribute Template";
        TemplateName: Code[20];
        Job: Record Job;
        NoColValuesSet: Label 'There are no columns defined for template %1. Please set them and try again.';
        JobNo: Code[20];
        FirstColumnLineNoFetched: Integer;
        LastColumnLineNoFetched: Integer;
        [InDataSet]
        PreviousColumnSetExists: Boolean;
        [InDataSet]
        NextColumnSetExists: Boolean;
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        [InDataSet]
        FilterMode: Boolean;
        FilterName: Code[20];
        NoEventsInFilter: Label 'There are not events with these attribute filters.';

    procedure SetAttrTemplate(TemplateName2: Code[20])
    begin
        TemplateName := TemplateName2;
        EventAttrTemplate.Get(TemplateName);
        EventAttrTemplate.TestField("Row Template Name");
        EventAttrTemplate.TestField("Column Template Name");
        Rec.FilterGroup := 2;
        Rec.SetRange("Template Name", EventAttrTemplate."Row Template Name");
        Rec.FilterGroup := 0;
    end;

    procedure SetJob(JobNo2: Code[20])
    begin
        JobNo := JobNo2;
        Job.Get(JobNo);
        Clear(EventAttrTemplate);
        TemplateName := '';
        JobNoVisible := true;
    end;

    local procedure GetColumnSetup(Forward: Boolean)
    var
        i: Integer;
        EventAttrColValue: Record "NPR Event Attr. Column Value";
    begin
        NextColumnSetExists := false;
        PreviousColumnSetExists := false;
        EventAttrColValue.SetRange("Template Name", EventAttrTemplate."Column Template Name");
        if EventAttrColValue.IsEmpty then
            Error(NoColValuesSet, EventAttrTemplate."Column Template Name");
        if Forward then
            EventAttrColValue.SetFilter("Line No.", '>%1', LastColumnLineNoFetched)
        else
            EventAttrColValue.SetFilter("Line No.", '<%1', FirstColumnLineNoFetched);
        if EventAttrColValue.IsEmpty then
            exit;
        for i := 1 to ArrayLen(AttrColumnCaption) do begin
            AttrColumnCaption[i] := '';
            AttrColumnVisible[i] := false;
            AttrColumnLineNo[i] := 0;
            if i = 1 then begin
                AttrColumnVisible[i] := EventAttrColValue.FindSet();
                FirstColumnLineNoFetched := EventAttrColValue."Line No.";
            end else
                AttrColumnVisible[i] := EventAttrColValue.Next() <> 0;
            if AttrColumnVisible[i] then begin
                AttrColumnCaption[i] := EventAttrColValue.Description;
                AttrColumnLineNo[i] := EventAttrColValue."Line No.";
            end;
        end;
        LastColumnLineNoFetched := EventAttrColValue."Line No.";

        EventAttrColValue.SetFilter("Line No.", '>%1', LastColumnLineNoFetched);
        NextColumnSetExists := not EventAttrColValue.IsEmpty();
        EventAttrColValue.SetFilter("Line No.", '<%1', FirstColumnLineNoFetched);
        PreviousColumnSetExists := not EventAttrColValue.IsEmpty();
        SetColumnCaption();
        SetColumnVisibility();
    end;

    local procedure SetColumnCaption()
    begin
        AttrColumnCaption1 := AttrColumnCaption[1];
        AttrColumnCaption2 := AttrColumnCaption[2];
        AttrColumnCaption3 := AttrColumnCaption[3];
        AttrColumnCaption4 := AttrColumnCaption[4];
        AttrColumnCaption5 := AttrColumnCaption[5];
    end;

    local procedure SetColumnVisibility()
    begin
        AttrColumnVisible1 := AttrColumnVisible[1];
        AttrColumnVisible2 := AttrColumnVisible[2];
        AttrColumnVisible3 := AttrColumnVisible[3];
        AttrColumnVisible4 := AttrColumnVisible[4];
        AttrColumnVisible5 := AttrColumnVisible[5];
    end;

    local procedure SetColumnEditable()
    begin
        AttrColumnEditable := (Rec.Type = Rec.Type::" ") or FilterMode;
    end;

    local procedure ReadEventAttributes()
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to ArrayLen(AttrColumnLineNo) do
            EventAttrMgt.EventAttributeEntryAction(2, TemplateName, JobNo, Rec."Line No.", AttrColumnLineNo[ColumnNo], AttrColumnCaption[ColumnNo], AttrColumnValue[ColumnNo], FilterMode, FilterName);
    end;

    local procedure CheckAndUpdate(ColumnNo: Integer)
    begin
        EventAttrMgt.CheckAndUpdate(TemplateName, JobNo, Rec."Line No.", AttrColumnLineNo[ColumnNo], AttrColumnCaption[ColumnNo], AttrColumnValue[ColumnNo], FilterMode, FilterName);
        CurrPage.Update(false);
    end;

    procedure SetFilterMode(FilterName2: Code[20])
    begin
        FilterMode := true;
        FilterName := FilterName2;
    end;
}

