﻿page 6059833 "NPR Event Res. Avail. Overview"
{
    Extensible = False;
    Caption = 'Event Resource Avail. Overview';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    ShowFilter = false;
    SourceTable = "NPR Event Plan. Line Buffer";
    SourceTableTemporary = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field(ResourceNoFilter; ResourceNoFilter)
                {

                    Caption = 'Resource No. Filter';
                    TableRelation = Resource;
                    ToolTip = 'Specifies the value of the Resource No. Filter field';
                    ApplicationArea = NPRRetail;
                }
                field(StartingDate; StartingDate)
                {

                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(EndingDate; EndingDate)
                {

                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRRetail;
                }
                field(StartingTime; StartingTime)
                {

                    Caption = 'Starting Time';
                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field(EndingTime; EndingTime)
                {

                    Caption = 'Ending Time';
                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field(TimeInterval; TimeInterval)
                {

                    Caption = 'Time Interval';
                    ToolTip = 'Duration in which time intervals should be shown in, for example, 1h=1 hour, 30m=30 minutes';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Control6014405)
            {
                Editable = false;
                FreezeColumn = "Ending Time";
                IndentationColumn = Rec."Line No.";
                IndentationControls = ResNoAndDesc;
                ShowAsTree = true;
                ShowCaption = false;
                field(ResNoAndDesc; ResNoAndDesc)
                {

                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[1]"; MatrixDataHolder[1])
                {

                    CaptionClass = '3,' + DateColumnCaption[1];
                    ShowCaption = false;
                    StyleExpr = StyleExpr1;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[1] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[2]"; MatrixDataHolder[2])
                {

                    CaptionClass = '3,' + DateColumnCaption[2];
                    ShowCaption = false;
                    StyleExpr = StyleExpr2;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[2] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[3]"; MatrixDataHolder[3])
                {

                    CaptionClass = '3,' + DateColumnCaption[3];
                    ShowCaption = false;
                    StyleExpr = StyleExpr3;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[3] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[4]"; MatrixDataHolder[4])
                {

                    CaptionClass = '3,' + DateColumnCaption[4];
                    ShowCaption = false;
                    StyleExpr = StyleExpr4;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[4] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[5]"; MatrixDataHolder[5])
                {

                    CaptionClass = '3,' + DateColumnCaption[5];
                    ShowCaption = false;
                    StyleExpr = StyleExpr5;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[5] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[6]"; MatrixDataHolder[6])
                {

                    CaptionClass = '3,' + DateColumnCaption[6];
                    ShowCaption = false;
                    StyleExpr = StyleExpr6;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[6] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[7]"; MatrixDataHolder[7])
                {

                    CaptionClass = '3,' + DateColumnCaption[7];
                    ShowCaption = false;
                    StyleExpr = StyleExpr7;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[7] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[8]"; MatrixDataHolder[8])
                {

                    CaptionClass = '3,' + DateColumnCaption[8];
                    ShowCaption = false;
                    StyleExpr = StyleExpr8;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[8] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[9]"; MatrixDataHolder[9])
                {

                    CaptionClass = '3,' + DateColumnCaption[9];
                    ShowCaption = false;
                    StyleExpr = StyleExpr9;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[9] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[10]"; MatrixDataHolder[10])
                {

                    CaptionClass = '3,' + DateColumnCaption[10];
                    ShowCaption = false;
                    StyleExpr = StyleExpr10;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[10] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[11]"; MatrixDataHolder[11])
                {

                    CaptionClass = '3,' + DateColumnCaption[11];
                    ShowCaption = false;
                    StyleExpr = StyleExpr11;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[11] field';
                    ApplicationArea = NPRRetail;
                }
                field("MatrixDataHolder[12]"; MatrixDataHolder[12])
                {

                    CaptionClass = '3,' + DateColumnCaption[12];
                    ShowCaption = false;
                    StyleExpr = StyleExpr12;
                    ToolTip = 'Specifies the value of the MatrixDataHolder[12] field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Show)
            {
                Caption = 'Show';
                Image = ShowMatrix;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Show action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    LoadData();
                end;
            }
            action(PreviousSet)
            {
                Caption = 'Previous Set';
                Enabled = PreviousSetEnabled;
                Image = PreviousSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Previous Set action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    FindDateSet(1);
                end;
            }
            action(NextSet)
            {
                Caption = 'Next Set';
                Enabled = NextSetEnabled;
                Image = NextSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Next Set action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    FindDateSet(0);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _Resource.Get(Rec."No.");
        ResNoAndDesc := Rec."No." + ' ' + _Resource.Name;
        SetMatrixData();
        SetStyle();
    end;

    var
        _Resource: Record Resource;
        ResourceNoFilter: Text;
        StartingDate: Date;
        EndingDate: Date;
        StartingTime: Time;
        EndingTime: Time;
        TimeInterval: Duration;
        DateTimeError: Label '%1 must be before %2.';
        DateTimeNotBlankErr: Label '%1 must not be blank.';
        TimeIntervalErr: Label 'Time Interval needs to be set.';
        DateColumnCaption: array[12] of Text;
        MatrixDataHolder: array[12] of Text;
        DateArray: array[12] of Date;
        EventPlanLineGroupingMgt: Codeunit "NPR Event Plan.Line Group. Mgt";
        StyleExpr1: Text;
        StyleExpr2: Text;
        StyleExpr3: Text;
        StyleExpr4: Text;
        StyleExpr5: Text;
        StyleExpr6: Text;
        StyleExpr7: Text;
        StyleExpr8: Text;
        StyleExpr9: Text;
        StyleExpr10: Text;
        StyleExpr11: Text;
        StyleExpr12: Text;
        ResNoAndDesc: Text;
        FreeText: Label 'Free';
        NotFreeText: Label 'Not Free';
        NextSetEnabled: Boolean;
        PreviousSetEnabled: Boolean;

    local procedure LoadData()
    var
        ResourceCounter: Integer;
        i: Integer;
        FromTime: Time;
    begin
        CheckDate();
        CheckTime();
        Rec.DeleteAll();
        if ResourceNoFilter <> '' then
            _Resource.SetFilter("No.", ResourceNoFilter);
        if _Resource.FindSet() then
            repeat
                FromTime := StartingTime;
                ResourceCounter += 10000;
                InsertRec(_Resource, ResourceCounter, 0, StartingTime, EndingTime);
                for i := 1 to MaxNoOfIntervals() do begin
                    InsertRec(_Resource, ResourceCounter + i, ResourceCounter, FromTime, FromTime + TimeInterval);
                    FromTime := FromTime + TimeInterval;
                end;
            until _Resource.Next() = 0;
        LoadDateArrays(StartingDate);
    end;

    local procedure LoadDateArrays(FromDate: Date)
    var
        i: Integer;
        UpperBound: Integer;
        RemDays: Integer;
        Date: Record Date;
        NoOfDaysLbl: Label '<%1D>', Locked = true;
    begin
        Clear(DateArray);
        Clear(DateColumnCaption);
        PreviousSetEnabled := FromDate <> StartingDate;
        UpperBound := ArrayLen(DateColumnCaption);
        RemDays := EndingDate - FromDate + 1;
        if RemDays < UpperBound then
            UpperBound := RemDays;
        for i := 1 to UpperBound do begin
            if i = 1 then
                DateArray[i] := FromDate
            else
                DateArray[i] := CalcDate(StrSubstNo(NoOfDaysLbl, i - 1), FromDate);
            Date.SetRange("Period Type", Date."Period Type"::Date);
            Date.SetRange("Period Start", DateArray[i]);
            Date.FindFirst();
            DateColumnCaption[i] := Format(DateArray[i]) + ' ' + Date."Period Name";
        end;
        NextSetEnabled := DateArray[UpperBound] <> EndingDate;
    end;

    local procedure SetMatrixData()
    var
        i: Integer;
    begin
        Clear(MatrixDataHolder);
        for i := 1 to ArrayLen(DateColumnCaption) do begin
            if (Rec."Line No." = 0) or (DateArray[i] = 0D) then
                MatrixDataHolder[i] := ''
            else begin
                Rec."Planning Date" := DateArray[i];
                Rec."Status Text" := '';
                EventPlanLineGroupingMgt.CheckCapAndTimeAvailabilityOnDemand(Rec, false);
                if Rec."Status Text" = '' then
                    MatrixDataHolder[i] := FreeText
                else
                    MatrixDataHolder[i] := NotFreeText;
            end;
        end;
    end;

    local procedure CheckDate()
    var
        Job: Record Job;
    begin
        if StartingDate = 0D then
            Error(DateTimeNotBlankErr, Job.FieldCaption("Starting Date"));
        if EndingDate = 0D then
            Error(DateTimeNotBlankErr, Job.FieldCaption("Ending Date"));
        if StartingDate > EndingDate then
            Error(DateTimeError, Job.FieldCaption("Starting Date"), Job.FieldCaption("Ending Date"));
    end;

    local procedure CheckTime()
    var
        Job: Record Job;
    begin
        if Format(TimeInterval) = '' then
            Error(TimeIntervalErr);
        if StartingTime = 0T then
            Error(DateTimeNotBlankErr, Job.FieldCaption("NPR Starting Time"));
        if EndingTime = 0T then
            Error(DateTimeNotBlankErr, Job.FieldCaption("NPR Ending Time"));
        if StartingTime >= EndingTime then
            Error(DateTimeError, Job.FieldCaption("NPR Starting Time"), Job.FieldCaption("NPR Ending Time"));
    end;

    local procedure MaxNoOfIntervals() Counter: Integer
    var
        FromTime: Time;
    begin
        FromTime := StartingTime;
        while FromTime < EndingTime do begin
            FromTime := FromTime + TimeInterval;
            Counter += 1;
        end;
        exit(Counter);
    end;

    local procedure InsertRec(Resource: Record Resource; LineNo: Integer; MainLineNo: Integer; FromTime: Time; ToTime: Time)
    begin
        Rec.Init();
        Rec."No." := Resource."No.";
        Rec."Job Planning Line No." := LineNo;
        Rec."Line No." := MainLineNo;
        Rec."Starting Time" := FromTime;
        Rec."Ending Time" := ToTime;
        Rec.Insert();
    end;

    local procedure SetStyle()
    var
        i: Integer;
        StyleExpr: Text;
    begin
        for i := 1 to ArrayLen(MatrixDataHolder) do begin
            case MatrixDataHolder[i] of
                '':
                    StyleExpr := 'Standard';
                FreeText:
                    StyleExpr := 'Favorable';
                NotFreeText:
                    StyleExpr := 'Unfavorable';
            end;
            case i of
                1:
                    StyleExpr1 := StyleExpr;
                2:
                    StyleExpr2 := StyleExpr;
                3:
                    StyleExpr3 := StyleExpr;
                4:
                    StyleExpr4 := StyleExpr;
                5:
                    StyleExpr5 := StyleExpr;
                6:
                    StyleExpr6 := StyleExpr;
                7:
                    StyleExpr7 := StyleExpr;
                8:
                    StyleExpr8 := StyleExpr;
                9:
                    StyleExpr9 := StyleExpr;
                10:
                    StyleExpr10 := StyleExpr;
                11:
                    StyleExpr11 := StyleExpr;
                12:
                    StyleExpr12 := StyleExpr;
            end;
        end;
    end;

    local procedure FindDateSet(Direction: Option Next,Previous)
    var
        FirstDate: Date;
        NoOfDaysLbl: Label '<-%1D>', Locked = true;
    begin
        case Direction of
            Direction::Next:
                FirstDate := CalcDate('<1D>', DateArray[ArrayLen(DateArray)]);
            Direction::Previous:
                begin
                    FirstDate := CalcDate(StrSubstNo(NoOfDaysLbl, ArrayLen(DateArray)), DateArray[1]);
                    if FirstDate < StartingDate then
                        FirstDate := StartingDate;
                end;
        end;
        LoadDateArrays(FirstDate);
    end;
}

