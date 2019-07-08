page 6060025 "GIM - Import Buffer Matrix"
{
    Caption = 'GIM - Import Buffer Matrix';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Import Buffer Detail";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Part of Primary Key";
                field("Row No.";"Row No.")
                {
                    Editable = false;
                }
                field("Skip Row";"Skip Row")
                {
                }
                field("Prepare Imp. Entity";"Prepare Imp. Entity")
                {
                    Editable = false;
                }
                field("Part of Primary Key";"Part of Primary Key")
                {
                    Caption = 'Valid';
                }
                field(Field1;MatrixData[1])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[1];
                    Style = Unfavorable;
                    StyleExpr = Emphasize1;
                    Visible = Field1Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(1);
                        ApplyWarnFormat(1);
                    end;
                }
                field(Field2;MatrixData[2])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[2];
                    Style = Unfavorable;
                    StyleExpr = Emphasize2;
                    Visible = Field2Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(2);
                        ApplyWarnFormat(2);
                    end;
                }
                field(Field3;MatrixData[3])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[3];
                    Style = Unfavorable;
                    StyleExpr = Emphasize3;
                    Visible = Field3Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(3);
                        ApplyWarnFormat(3);
                    end;
                }
                field(Field4;MatrixData[4])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[4];
                    Style = Unfavorable;
                    StyleExpr = Emphasize4;
                    Visible = Field4Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(4);
                        ApplyWarnFormat(4);
                    end;
                }
                field(Field5;MatrixData[5])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[5];
                    Style = Unfavorable;
                    StyleExpr = Emphasize5;
                    Visible = Field5Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(5);
                        ApplyWarnFormat(5);
                    end;
                }
                field(Field6;MatrixData[6])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[6];
                    Style = Unfavorable;
                    StyleExpr = Emphasize6;
                    Visible = Field6Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(6);
                        ApplyWarnFormat(6);
                    end;
                }
                field(Field7;MatrixData[7])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[7];
                    Style = Unfavorable;
                    StyleExpr = Emphasize7;
                    Visible = Field7Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(7);
                        ApplyWarnFormat(7);
                    end;
                }
                field(Field8;MatrixData[8])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[8];
                    Style = Unfavorable;
                    StyleExpr = Emphasize8;
                    Visible = Field8Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(8);
                        ApplyWarnFormat(8);
                    end;
                }
                field(Field9;MatrixData[9])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[9];
                    Style = Unfavorable;
                    StyleExpr = Emphasize9;
                    Visible = Field9Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(9);
                        ApplyWarnFormat(9);
                    end;
                }
                field(Field10;MatrixData[10])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[10];
                    Style = Unfavorable;
                    StyleExpr = Emphasize10;
                    Visible = Field10Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(10);
                        ApplyWarnFormat(10);
                    end;
                }
                field(Field11;MatrixData[11])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[11];
                    Style = Unfavorable;
                    StyleExpr = Emphasize11;
                    Visible = Field11Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(11);
                        ApplyWarnFormat(11);
                    end;
                }
                field(Field12;MatrixData[12])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[12];
                    Style = Unfavorable;
                    StyleExpr = Emphasize12;
                    Visible = Field12Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(12);
                        ApplyWarnFormat(12);
                    end;
                }
                field(Field13;MatrixData[13])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[13];
                    Style = Unfavorable;
                    StyleExpr = Emphasize13;
                    Visible = Field13Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(13);
                        ApplyWarnFormat(13);
                    end;
                }
                field(Field14;MatrixData[14])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[14];
                    Style = Unfavorable;
                    StyleExpr = Emphasize14;
                    Visible = Field14Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(14);
                        ApplyWarnFormat(14);
                    end;
                }
                field(Field15;MatrixData[15])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[15];
                    Style = Unfavorable;
                    StyleExpr = Emphasize15;
                    Visible = Field15Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(15);
                        ApplyWarnFormat(15);
                    end;
                }
                field(Field16;MatrixData[16])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[16];
                    Style = Unfavorable;
                    StyleExpr = Emphasize16;
                    Visible = Field16Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(16);
                        ApplyWarnFormat(16);
                    end;
                }
                field(Field17;MatrixData[17])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[17];
                    Style = Unfavorable;
                    StyleExpr = Emphasize17;
                    Visible = Field17Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(17);
                        ApplyWarnFormat(17);
                    end;
                }
                field(Field18;MatrixData[18])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[18];
                    Style = Unfavorable;
                    StyleExpr = Emphasize18;
                    Visible = Field18Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(18);
                        ApplyWarnFormat(18);
                    end;
                }
                field(Field19;MatrixData[19])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[19];
                    Style = Unfavorable;
                    StyleExpr = Emphasize19;
                    Visible = Field19Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(19);
                        ApplyWarnFormat(19);
                    end;
                }
                field(Field20;MatrixData[20])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[20];
                    Style = Unfavorable;
                    StyleExpr = Emphasize20;
                    Visible = Field20Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(20);
                        ApplyWarnFormat(20);
                    end;
                }
                field(Field21;MatrixData[21])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[21];
                    Style = Unfavorable;
                    StyleExpr = Emphasize21;
                    Visible = Field21Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(21);
                        ApplyWarnFormat(21);
                    end;
                }
                field(Field22;MatrixData[22])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[22];
                    Style = Unfavorable;
                    StyleExpr = Emphasize22;
                    Visible = Field22Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(22);
                        ApplyWarnFormat(22);
                    end;
                }
                field(Field23;MatrixData[23])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[23];
                    Style = Unfavorable;
                    StyleExpr = Emphasize23;
                    Visible = Field23Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(23);
                        ApplyWarnFormat(23);
                    end;
                }
                field(Field24;MatrixData[24])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[24];
                    Style = Unfavorable;
                    StyleExpr = Emphasize24;
                    Visible = Field24Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(24);
                        ApplyWarnFormat(24);
                    end;
                }
                field(Field25;MatrixData[25])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[25];
                    Style = Unfavorable;
                    StyleExpr = Emphasize25;
                    Visible = Field25Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(25);
                        ApplyWarnFormat(25);
                    end;
                }
                field(Field26;MatrixData[26])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[26];
                    Style = Unfavorable;
                    StyleExpr = Emphasize26;
                    Visible = Field26Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(26);
                        ApplyWarnFormat(26);
                    end;
                }
                field(Field27;MatrixData[27])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[27];
                    Style = Unfavorable;
                    StyleExpr = Emphasize27;
                    Visible = Field27Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(27);
                        ApplyWarnFormat(27);
                    end;
                }
                field(Field28;MatrixData[28])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[28];
                    Style = Unfavorable;
                    StyleExpr = Emphasize28;
                    Visible = Field28Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(28);
                        ApplyWarnFormat(28);
                    end;
                }
                field(Field29;MatrixData[29])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[29];
                    Style = Unfavorable;
                    StyleExpr = Emphasize29;
                    Visible = Field29Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(29);
                        ApplyWarnFormat(29);
                    end;
                }
                field(Field30;MatrixData[30])
                {
                    BlankZero = true;
                    CaptionClass = '3,' + MatrixColumnCaptions[30];
                    Style = Unfavorable;
                    StyleExpr = Emphasize30;
                    Visible = Field30Visible;

                    trigger OnValidate()
                    begin
                        FieldValidate(30);
                        ApplyWarnFormat(30);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdateMatrixData();
    end;

    trigger OnOpenPage()
    var
        ImpBufferDetail: Record "GIM - Import Buffer Detail";
    begin
        ImpBufferDetail.SetRange("Document No.",DocNo);
        if ImpBufferDetail.FindSet then
          repeat
            MapTableLine.Get(ImpBufferDetail."Document No.",ImpBufferDetail."Column No.",ImpBufferDetail."Table ID");
            if MapTableLine."Look for Existant Data" then begin
              SetRange("Row No.",ImpBufferDetail."Row No.");
              if not FindFirst then begin
                Init;
                "Entry No." := ImpBufferDetail."Entry No.";
                "Document No." := DocNo;
                "Row No." := ImpBufferDetail."Row No.";
                "Skip Row" := GetSkipRow(ImpBufferDetail."Row No.");
                "Prepare Imp. Entity" := ImpBufferDetail."Prepare Imp. Entity";
                "Part of Primary Key" := IsValidRow(ImpBufferDetail."Row No.");
                Insert;
              end;
            end;
          until ImpBufferDetail.Next = 0;
        Reset;

        NoOfRecords := ArrayLen(MatrixColumnCaptions);
        Field1Visible := 1 <= NoOfRecords;
        Field2Visible := 2 <= NoOfRecords;
        Field3Visible := 3 <= NoOfRecords;
        Field4Visible := 4 <= NoOfRecords;
        Field5Visible := 5 <= NoOfRecords;
        Field6Visible := 6 <= NoOfRecords;
        Field7Visible := 7 <= NoOfRecords;
        Field8Visible := 8 <= NoOfRecords;
        Field9Visible := 9 <= NoOfRecords;
        Field10Visible := 10 <= NoOfRecords;
        Field11Visible := 11 <= NoOfRecords;
        Field12Visible := 12 <= NoOfRecords;
        Field13Visible := 13 <= NoOfRecords;
        Field14Visible := 14 <= NoOfRecords;
        Field15Visible := 15 <= NoOfRecords;
        Field16Visible := 16 <= NoOfRecords;
        Field17Visible := 17 <= NoOfRecords;
        Field18Visible := 18 <= NoOfRecords;
        Field19Visible := 19 <= NoOfRecords;
        Field20Visible := 20 <= NoOfRecords;
        Field21Visible := 21 <= NoOfRecords;
        Field22Visible := 22 <= NoOfRecords;
        Field23Visible := 23 <= NoOfRecords;
        Field24Visible := 24 <= NoOfRecords;
        Field25Visible := 25 <= NoOfRecords;
        Field26Visible := 26 <= NoOfRecords;
        Field27Visible := 27 <= NoOfRecords;
        Field28Visible := 28 <= NoOfRecords;
        Field29Visible := 29 <= NoOfRecords;
        Field30Visible := 30 <= NoOfRecords;
    end;

    var
        DocNo: Code[20];
        MapTableLine: Record "GIM - Mapping Table Line";
        MatrixData: array [30] of Text;
        MatrixColumnCaptions: array [30] of Text[50];
        NoOfRecords: Integer;
        [InDataSet]
        Field1Visible: Boolean;
        [InDataSet]
        Field2Visible: Boolean;
        [InDataSet]
        Field3Visible: Boolean;
        [InDataSet]
        Field4Visible: Boolean;
        [InDataSet]
        Field5Visible: Boolean;
        [InDataSet]
        Field6Visible: Boolean;
        [InDataSet]
        Field7Visible: Boolean;
        [InDataSet]
        Field8Visible: Boolean;
        [InDataSet]
        Field9Visible: Boolean;
        [InDataSet]
        Field10Visible: Boolean;
        [InDataSet]
        Field11Visible: Boolean;
        [InDataSet]
        Field12Visible: Boolean;
        [InDataSet]
        Field13Visible: Boolean;
        [InDataSet]
        Field14Visible: Boolean;
        [InDataSet]
        Field15Visible: Boolean;
        [InDataSet]
        Field16Visible: Boolean;
        [InDataSet]
        Field17Visible: Boolean;
        [InDataSet]
        Field18Visible: Boolean;
        [InDataSet]
        Field19Visible: Boolean;
        [InDataSet]
        Field20Visible: Boolean;
        [InDataSet]
        Field21Visible: Boolean;
        [InDataSet]
        Field22Visible: Boolean;
        [InDataSet]
        Field23Visible: Boolean;
        [InDataSet]
        Field24Visible: Boolean;
        [InDataSet]
        Field25Visible: Boolean;
        [InDataSet]
        Field26Visible: Boolean;
        [InDataSet]
        Field27Visible: Boolean;
        [InDataSet]
        Field28Visible: Boolean;
        [InDataSet]
        Field29Visible: Boolean;
        [InDataSet]
        Field30Visible: Boolean;
        Emphasize1: Boolean;
        Emphasize2: Boolean;
        Emphasize3: Boolean;
        Emphasize4: Boolean;
        Emphasize5: Boolean;
        Emphasize6: Boolean;
        Emphasize7: Boolean;
        Emphasize8: Boolean;
        Emphasize9: Boolean;
        Emphasize10: Boolean;
        Emphasize11: Boolean;
        Emphasize12: Boolean;
        Emphasize13: Boolean;
        Emphasize14: Boolean;
        Emphasize15: Boolean;
        Emphasize16: Boolean;
        Emphasize17: Boolean;
        Emphasize18: Boolean;
        Emphasize19: Boolean;
        Emphasize20: Boolean;
        Emphasize21: Boolean;
        Emphasize22: Boolean;
        Emphasize23: Boolean;
        Emphasize24: Boolean;
        Emphasize25: Boolean;
        Emphasize26: Boolean;
        Emphasize27: Boolean;
        Emphasize28: Boolean;
        Emphasize29: Boolean;
        Emphasize30: Boolean;

    local procedure GetSkipRow(RowNo: Integer): Boolean
    var
        RecCount: Integer;
        ImpBufferDetailHere: Record "GIM - Import Buffer Detail";
    begin
        ImpBufferDetailHere.SetRange("Document No.",DocNo);
        ImpBufferDetailHere.SetRange("Row No.",RowNo);
        RecCount := ImpBufferDetailHere.Count;
        ImpBufferDetailHere.SetRange("Skip Row",true);
        exit(RecCount = ImpBufferDetailHere.Count);
    end;

    local procedure SetSkipRow(RowNo: Integer)
    var
        ImpBufferDetailHere: Record "GIM - Import Buffer Detail";
    begin
        ImpBufferDetailHere.SetRange("Document No.",DocNo);
        ImpBufferDetailHere.SetRange("Row No.",RowNo);
        ImpBufferDetailHere.ModifyAll("Skip Row","Skip Row");
    end;

    local procedure IsValidRow(RowNo: Integer): Boolean
    var
        ImpBufferDetailHere: Record "GIM - Import Buffer Detail";
    begin
        ImpBufferDetailHere.SetRange("Document No.",DocNo);
        ImpBufferDetailHere.SetRange("Row No.",RowNo);
        ImpBufferDetailHere.SetFilter("Fail Reason",'<>%1','');
        exit(not ImpBufferDetailHere.FindFirst);
    end;

    local procedure ApplyWarnFormat(ColumnNo: Integer): Boolean
    var
        ImpBufferDetailHere: Record "GIM - Import Buffer Detail";
        i: Integer;
    begin
        ImpBufferDetailHere.Reset;
        ImpBufferDetailHere.SetRange("Document No.",DocNo);
        ImpBufferDetailHere.SetRange("Column ID",ColumnNo);
        ImpBufferDetailHere.SetRange("Row No.","Row No.");
        ImpBufferDetailHere.SetFilter("Fail Reason",'<>%1','');
        case ColumnNo of
          1: Emphasize1 := ImpBufferDetailHere.FindFirst;
          2: Emphasize2 := ImpBufferDetailHere.FindFirst;
          3: Emphasize3 := ImpBufferDetailHere.FindFirst;
          4: Emphasize4 := ImpBufferDetailHere.FindFirst;
          5: Emphasize5 := ImpBufferDetailHere.FindFirst;
          6: Emphasize6 := ImpBufferDetailHere.FindFirst;
          7: Emphasize7 := ImpBufferDetailHere.FindFirst;
          8: Emphasize8 := ImpBufferDetailHere.FindFirst;
          9: Emphasize9 := ImpBufferDetailHere.FindFirst;
          10: Emphasize10 := ImpBufferDetailHere.FindFirst;
          11: Emphasize11 := ImpBufferDetailHere.FindFirst;
          12: Emphasize12 := ImpBufferDetailHere.FindFirst;
          13: Emphasize13 := ImpBufferDetailHere.FindFirst;
          14: Emphasize14 := ImpBufferDetailHere.FindFirst;
          15: Emphasize15 := ImpBufferDetailHere.FindFirst;
          16: Emphasize16 := ImpBufferDetailHere.FindFirst;
          17: Emphasize17 := ImpBufferDetailHere.FindFirst;
          18: Emphasize18 := ImpBufferDetailHere.FindFirst;
          19: Emphasize19 := ImpBufferDetailHere.FindFirst;
          20: Emphasize20 := ImpBufferDetailHere.FindFirst;
          21: Emphasize21 := ImpBufferDetailHere.FindFirst;
          22: Emphasize22 := ImpBufferDetailHere.FindFirst;
          23: Emphasize23 := ImpBufferDetailHere.FindFirst;
          24: Emphasize24 := ImpBufferDetailHere.FindFirst;
          25: Emphasize25 := ImpBufferDetailHere.FindFirst;
          26: Emphasize26 := ImpBufferDetailHere.FindFirst;
          27: Emphasize27 := ImpBufferDetailHere.FindFirst;
          28: Emphasize28 := ImpBufferDetailHere.FindFirst;
          29: Emphasize29 := ImpBufferDetailHere.FindFirst;
          30: Emphasize30 := ImpBufferDetailHere.FindFirst;
        end;
    end;

    local procedure FieldValidate(ColumnNo: Integer)
    var
        ImpBufferHere: Record "GIM - Import Buffer";
    begin
        ImpBufferHere.SetRange("Document No.",DocNo);
        ImpBufferHere.SetRange("Column No.",ColumnNo);
        ImpBufferHere.SetRange("Row No.","Row No.");
        if ImpBufferHere.FindFirst then begin
          ImpBufferHere.Validate("Parsed Text",MatrixData[ColumnNo]);
          ImpBufferHere.Modify;
        end;
    end;

    procedure SetDocNo(DocNoHere: Code[20])
    begin
        DocNo := DocNoHere;
    end;

    local procedure UpdateMatrixData()
    var
        i: Integer;
        ImpBufferHere: Record "GIM - Import Buffer";
    begin
        Clear(MatrixData);
        ImpBufferHere.SetRange("Document No.",DocNo);
        ImpBufferHere.SetRange("Row No.","Row No.");
        for i := 1 to ArrayLen(MatrixColumnCaptions) do begin
          ImpBufferHere.SetRange("Column No.",i);
          if ImpBufferHere.FindFirst then
            MatrixData[i] := ImpBufferHere."Parsed Text";
          ApplyWarnFormat(i);
        end;
    end;

    procedure SetMatrixColumnCaptions(MatrixColumnCaptionsHere: array [30] of Text[50])
    begin
        CopyArray(MatrixColumnCaptions,MatrixColumnCaptionsHere,1);
    end;
}

