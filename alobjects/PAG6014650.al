page 6014650 "Generic Multiple Check List"
{
    // NPR5.48/TJ  /20181129 CASE 318531 New object

    Caption = 'Select options';
    LinksAllowed = false;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            field("BooleanArr[1]"; BooleanArr[1])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[1];
                Visible = BooleanVisible1;
            }
            field("BooleanArr[2]"; BooleanArr[2])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[2];
                Visible = BooleanVisible2;
            }
            field("BooleanArr[3]"; BooleanArr[3])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[3];
                Visible = BooleanVisible3;
            }
            field("BooleanArr[4]"; BooleanArr[4])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[4];
                Visible = BooleanVisible4;
            }
            field("BooleanArr[5]"; BooleanArr[5])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[5];
                Visible = BooleanVisible5;
            }
            field("BooleanArr[6]"; BooleanArr[6])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[6];
                Visible = BooleanVisible6;
            }
            field("BooleanArr[7]"; BooleanArr[7])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[7];
                Visible = BooleanVisible7;
            }
            field("BooleanArr[8]"; BooleanArr[8])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[8];
                Visible = BooleanVisible8;
            }
            field("BooleanArr[9]"; BooleanArr[9])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[9];
                Visible = BooleanVisible9;
            }
            field("BooleanArr[10]"; BooleanArr[10])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[10];
                Visible = BooleanVisible10;
            }
            field("BooleanArr[11]"; BooleanArr[11])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[11];
                Visible = BooleanVisible11;
            }
            field("BooleanArr[12]"; BooleanArr[12])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[12];
                Visible = BooleanVisible12;
            }
            field("BooleanArr[13]"; BooleanArr[13])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[13];
                Visible = BooleanVisible13;
            }
            field("BooleanArr[14]"; BooleanArr[14])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[14];
                Visible = BooleanVisible14;
            }
            field("BooleanArr[15]"; BooleanArr[15])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[15];
                Visible = BooleanVisible15;
            }
            field("BooleanArr[16]"; BooleanArr[16])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[16];
                Visible = BooleanVisible16;
            }
            field("BooleanArr[17]"; BooleanArr[17])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[17];
                Visible = BooleanVisible17;
            }
            field("BooleanArr[18]"; BooleanArr[18])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[18];
                Visible = BooleanVisible18;
            }
            field("BooleanArr[19]"; BooleanArr[19])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[19];
                Visible = BooleanVisible19;
            }
            field("BooleanArr[20]"; BooleanArr[20])
            {
                ApplicationArea = All;
                CaptionClass = '3,' + BooleanCaptionArr[20];
                Visible = BooleanVisible20;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if OptionString = '' then
            Error(Text001);
        PrepareArray();
        SetVisible();
        ReadFilter();
    end;

    var
        BooleanArr: array[20] of Boolean;
        BooleanSetArr: array[20] of Boolean;
        BooleanCaptionArr: array[20] of Text;
        BooleanVisible1: Boolean;
        BooleanVisible2: Boolean;
        BooleanVisible3: Boolean;
        BooleanVisible4: Boolean;
        BooleanVisible5: Boolean;
        BooleanVisible6: Boolean;
        BooleanVisible7: Boolean;
        BooleanVisible8: Boolean;
        BooleanVisible9: Boolean;
        BooleanVisible10: Boolean;
        BooleanVisible11: Boolean;
        BooleanVisible12: Boolean;
        BooleanVisible13: Boolean;
        BooleanVisible14: Boolean;
        BooleanVisible15: Boolean;
        BooleanVisible16: Boolean;
        BooleanVisible17: Boolean;
        BooleanVisible18: Boolean;
        BooleanVisible19: Boolean;
        BooleanVisible20: Boolean;
        OptionString: Text;
        Text001: Label 'You need to call function SetOption before running this page!';
        OptionFilter: Text;
        TypeHelper: Codeunit "Type Helper";

    procedure SetOptions(OptionStringHere: Text; OptionFilterHere: Text)
    begin
        OptionString := OptionStringHere;
        OptionFilter := OptionFilterHere;
    end;

    local procedure PrepareArray()
    var
        i: Integer;
        OptionNo: Integer;
    begin
        for i := 1 to TypeHelper.GetNumberOfOptions(OptionString) + 1 do begin
            BooleanCaptionArr[i] := SelectStr(i, OptionString);
            BooleanSetArr[i] := true;
        end;
    end;

    local procedure SetVisible()
    begin
        BooleanVisible1 := BooleanSetArr[1];
        BooleanVisible2 := BooleanSetArr[2];
        BooleanVisible3 := BooleanSetArr[3];
        BooleanVisible4 := BooleanSetArr[4];
        BooleanVisible5 := BooleanSetArr[5];
        BooleanVisible6 := BooleanSetArr[6];
        BooleanVisible7 := BooleanSetArr[7];
        BooleanVisible8 := BooleanSetArr[8];
        BooleanVisible9 := BooleanSetArr[9];
        BooleanVisible10 := BooleanSetArr[10];
        BooleanVisible11 := BooleanSetArr[11];
        BooleanVisible12 := BooleanSetArr[12];
        BooleanVisible13 := BooleanSetArr[13];
        BooleanVisible14 := BooleanSetArr[14];
        BooleanVisible15 := BooleanSetArr[15];
        BooleanVisible16 := BooleanSetArr[16];
        BooleanVisible17 := BooleanSetArr[17];
        BooleanVisible18 := BooleanSetArr[18];
        BooleanVisible19 := BooleanSetArr[19];
        BooleanVisible20 := BooleanSetArr[20];
    end;

    local procedure ReadFilter()
    var
        i: Integer;
        ActualOptionNo: Integer;
    begin
        if OptionFilter = '' then
            exit;
        OptionFilter := ConvertStr(OptionFilter, '|', ',');
        for i := 1 to TypeHelper.GetNumberOfOptions(OptionFilter) + 1 do begin
            ActualOptionNo := TypeHelper.GetOptionNo(SelectStr(i, OptionFilter), OptionString) + 1;
            BooleanArr[ActualOptionNo] := true;
        end;
    end;

    procedure GetSelectedOption() NewFilter: Text
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(BooleanArr) do begin
            if BooleanArr[i] then
                if NewFilter <> '' then
                    NewFilter := NewFilter + '|' + BooleanCaptionArr[i]
                else
                    NewFilter := BooleanCaptionArr[i];
        end;
    end;
}

