page 6060034 "GIM - Card Template"
{
    Caption = 'GIM - Card Template';
    Editable = false;
    PageType = Card;
    SourceTable = "GIM - Data Template";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Field 1 Value";"Field 1 Value")
                {
                    CaptionClass = '3,'+FieldCap[1];
                    Visible = Field1Visible;
                }
                field("Field 2 Value";"Field 2 Value")
                {
                    CaptionClass = '3,'+FieldCap[2];
                    Visible = Field2Visible;
                }
                field("Field 3 Value";"Field 3 Value")
                {
                    CaptionClass = '3,'+FieldCap[3];
                    Visible = Field3Visible;
                }
                field("Field 4 Value";"Field 4 Value")
                {
                    CaptionClass = '3,'+FieldCap[4];
                    Visible = Field4Visible;
                }
                field("Field 5 Value";"Field 5 Value")
                {
                    CaptionClass = '3,'+FieldCap[5];
                    Visible = Field5Visible;
                }
                field("Field 6 Value";"Field 6 Value")
                {
                    CaptionClass = '3,'+FieldCap[6];
                    Visible = Field6Visible;
                }
                field("Field 7 Value";"Field 7 Value")
                {
                    CaptionClass = '3,'+FieldCap[7];
                    Visible = Field7Visible;
                }
                field("Field 8 Value";"Field 8 Value")
                {
                    CaptionClass = '3,'+FieldCap[8];
                    Visible = Field8Visible;
                }
                field("Field 9 Value";"Field 9 Value")
                {
                    CaptionClass = '3,'+FieldCap[9];
                    Visible = Field9Visible;
                }
                field("Field 10 Value";"Field 10 Value")
                {
                    CaptionClass = '3,'+FieldCap[10];
                    Visible = Field10Visible;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Field1Visible := "Field 1 Value" <> '';
        Field2Visible := "Field 2 Value" <> '';
        Field3Visible := "Field 3 Value" <> '';
        Field4Visible := "Field 4 Value" <> '';
        Field5Visible := "Field 5 Value" <> '';
        Field6Visible := "Field 6 Value" <> '';
        Field7Visible := "Field 7 Value" <> '';
        Field8Visible := "Field 8 Value" <> '';
        Field9Visible := "Field 9 Value" <> '';
        Field10Visible := "Field 10 Value" <> '';

        if Field1Visible then begin
          Fields.Get("Table ID","Field 1 ID");
          FieldCap[1] := Fields."Field Caption";
        end;

        if Field2Visible then begin
          Fields.Get("Table ID","Field 2 ID");
          FieldCap[2] := Fields."Field Caption";
        end;

        if Field3Visible then begin
          Fields.Get("Table ID","Field 3 ID");
          FieldCap[3] := Fields."Field Caption";
        end;

        if Field4Visible then begin
          Fields.Get("Table ID","Field 4 ID");
          FieldCap[4] := Fields."Field Caption";
        end;

        if Field5Visible then begin
          Fields.Get("Table ID","Field 5 ID");
          FieldCap[5] := Fields."Field Caption";
        end;

        if Field6Visible then begin
          Fields.Get("Table ID","Field 6 ID");
          FieldCap[6] := Fields."Field Caption";
        end;

        if Field7Visible then begin
          Fields.Get("Table ID","Field 7 ID");
          FieldCap[7] := Fields."Field Caption";
        end;

        if Field8Visible then begin
          Fields.Get("Table ID","Field 8 ID");
          FieldCap[8] := Fields."Field Caption";
        end;

        if Field9Visible then begin
          Fields.Get("Table ID","Field 9 ID");
          FieldCap[9] := Fields."Field Caption";
        end;

        if Field10Visible then begin
          Fields.Get("Table ID","Field 10 ID");
          FieldCap[10] := Fields."Field Caption";
        end;
    end;

    var
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
        FieldCap: array [10] of Text;
        "Fields": Record "Field";
}

