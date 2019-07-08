page 6060036 "GIM - Subpage Template"
{
    Caption = 'GIM - Subpage Template';
    Editable = false;
    PageType = ListPart;
    SourceTable = "GIM - Data Template";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
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
        ImpEntity: Record "GIM - Import Entity";
        TableID: Integer;
        DocNo: Code[20];
        LastRow: Integer;
        ImpEntValue: Text[250];
        RowCount: Integer;
        EntryNo: Integer;
        ImpDoc: Record "GIM - Import Document";
        DocType: Record "GIM - Document Type";
        i: Integer;

    procedure SetEntity(ImpDocHere: Record "GIM - Import Document";TableIDHere: Integer)
    begin
        ImpDoc := ImpDocHere;
        TableID := TableIDHere;

        ImpEntity.SetCurrentKey("Row No.");
        ImpEntity.SetRange("Document No.",ImpDoc."No.");
        ImpEntity.SetRange("Table ID",TableID);
        ImpEntity.SetRange("Part of Primary Key",false);
        if ImpEntity.FindLast then
          LastRow := ImpEntity."Row No.";

        DocType.Get(ImpDoc."Document Type",ImpDoc."Sender ID");

        for RowCount := 1 to LastRow do begin
          i := 0;
          EntryNo += 1;
          Init;
          "Entry No." := EntryNo;
          "Document No." := ImpDoc."No.";
          "Table ID" := TableID;
          Insert;
          ImpEntity.SetRange("Row No.",RowCount);
          if DocType."Preview Provided Data Only" then
            ImpEntity.SetFilter("Column ID",'<>0'); //this way only data provided with user file will be shown, remove this if we want to show data from file + mapping results
          if ImpEntity.FindSet then
            repeat
              if ImpEntity."Current Value" <> '' then
                ImpEntValue := ImpEntity."Current Value"
              else
                ImpEntValue := ImpEntity."New Value";
              i += 1;
              AssignValue(i);
              Modify;
            until ImpEntity.Next = 0;
        end;
    end;

    local procedure AssignValue(IndexHere: Integer)
    begin
        case IndexHere of
          1:
            begin
              "Field 1 Value" := ImpEntValue;
              "Field 1 ID" := ImpEntity."Field ID";
              Field1Visible := true;
            end;
          2:
            begin
              "Field 2 Value" := ImpEntValue;
              "Field 2 ID" := ImpEntity."Field ID";
              Field2Visible := true;
            end;
          3:
            begin
              "Field 3 Value" := ImpEntValue;
              "Field 3 ID" := ImpEntity."Field ID";
              Field3Visible := true;
            end;
          4:
            begin
              "Field 4 Value" := ImpEntValue;
              "Field 4 ID" := ImpEntity."Field ID";
              Field4Visible := true;
            end;
          5:
            begin
              "Field 5 Value" := ImpEntValue;
              "Field 5 ID" := ImpEntity."Field ID";
              Field5Visible := true;
            end;
          6:
            begin
              "Field 6 Value" := ImpEntValue;
              "Field 6 ID" := ImpEntity."Field ID";
              Field6Visible := true;
            end;
          7:
            begin
              "Field 7 Value" := ImpEntValue;
              "Field 7 ID" := ImpEntity."Field ID";
              Field7Visible := true;
            end;
          8:
            begin
              "Field 8 Value" := ImpEntValue;
              "Field 8 ID" := ImpEntity."Field ID";
              Field8Visible := true;
            end;
          9:
            begin
              "Field 9 Value" := ImpEntValue;
              "Field 9 ID" := ImpEntity."Field ID";
              Field9Visible := true;
            end;
          10:
            begin
              "Field 10 Value" := ImpEntValue;
              "Field 10 ID" := ImpEntity."Field ID";
              Field10Visible := true;
            end;
        end;
        ImpEntity.CalcFields("Field Caption");
        FieldCap[IndexHere] := ImpEntity."Field Caption";
    end;
}

