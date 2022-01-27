page 6014650 "NPR Gen. Multiple Check List"
{
    Extensible = False;
    Caption = 'Select options';
    LinksAllowed = false;
    ShowFilter = false;
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            field("BooleanArr[1]"; BooleanArr[1])
            {

                CaptionClass = '3,' + BooleanCaptionArr[1];
                Visible = BooleanVisible1;
                ToolTip = 'Specifies the value of the BooleanArr[1] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[2]"; BooleanArr[2])
            {

                CaptionClass = '3,' + BooleanCaptionArr[2];
                Visible = BooleanVisible2;
                ToolTip = 'Specifies the value of the BooleanArr[2] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[3]"; BooleanArr[3])
            {

                CaptionClass = '3,' + BooleanCaptionArr[3];
                Visible = BooleanVisible3;
                ToolTip = 'Specifies the value of the BooleanArr[3] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[4]"; BooleanArr[4])
            {

                CaptionClass = '3,' + BooleanCaptionArr[4];
                Visible = BooleanVisible4;
                ToolTip = 'Specifies the value of the BooleanArr[4] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[5]"; BooleanArr[5])
            {

                CaptionClass = '3,' + BooleanCaptionArr[5];
                Visible = BooleanVisible5;
                ToolTip = 'Specifies the value of the BooleanArr[5] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[6]"; BooleanArr[6])
            {

                CaptionClass = '3,' + BooleanCaptionArr[6];
                Visible = BooleanVisible6;
                ToolTip = 'Specifies the value of the BooleanArr[6] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[7]"; BooleanArr[7])
            {

                CaptionClass = '3,' + BooleanCaptionArr[7];
                Visible = BooleanVisible7;
                ToolTip = 'Specifies the value of the BooleanArr[7] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[8]"; BooleanArr[8])
            {

                CaptionClass = '3,' + BooleanCaptionArr[8];
                Visible = BooleanVisible8;
                ToolTip = 'Specifies the value of the BooleanArr[8] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[9]"; BooleanArr[9])
            {

                CaptionClass = '3,' + BooleanCaptionArr[9];
                Visible = BooleanVisible9;
                ToolTip = 'Specifies the value of the BooleanArr[9] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[10]"; BooleanArr[10])
            {

                CaptionClass = '3,' + BooleanCaptionArr[10];
                Visible = BooleanVisible10;
                ToolTip = 'Specifies the value of the BooleanArr[10] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[11]"; BooleanArr[11])
            {

                CaptionClass = '3,' + BooleanCaptionArr[11];
                Visible = BooleanVisible11;
                ToolTip = 'Specifies the value of the BooleanArr[11] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[12]"; BooleanArr[12])
            {

                CaptionClass = '3,' + BooleanCaptionArr[12];
                Visible = BooleanVisible12;
                ToolTip = 'Specifies the value of the BooleanArr[12] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[13]"; BooleanArr[13])
            {

                CaptionClass = '3,' + BooleanCaptionArr[13];
                Visible = BooleanVisible13;
                ToolTip = 'Specifies the value of the BooleanArr[13] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[14]"; BooleanArr[14])
            {

                CaptionClass = '3,' + BooleanCaptionArr[14];
                Visible = BooleanVisible14;
                ToolTip = 'Specifies the value of the BooleanArr[14] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[15]"; BooleanArr[15])
            {

                CaptionClass = '3,' + BooleanCaptionArr[15];
                Visible = BooleanVisible15;
                ToolTip = 'Specifies the value of the BooleanArr[15] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[16]"; BooleanArr[16])
            {

                CaptionClass = '3,' + BooleanCaptionArr[16];
                Visible = BooleanVisible16;
                ToolTip = 'Specifies the value of the BooleanArr[16] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[17]"; BooleanArr[17])
            {

                CaptionClass = '3,' + BooleanCaptionArr[17];
                Visible = BooleanVisible17;
                ToolTip = 'Specifies the value of the BooleanArr[17] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[18]"; BooleanArr[18])
            {

                CaptionClass = '3,' + BooleanCaptionArr[18];
                Visible = BooleanVisible18;
                ToolTip = 'Specifies the value of the BooleanArr[18] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[19]"; BooleanArr[19])
            {

                CaptionClass = '3,' + BooleanCaptionArr[19];
                Visible = BooleanVisible19;
                ToolTip = 'Specifies the value of the BooleanArr[19] field';
                ApplicationArea = NPRRetail;
            }
            field("BooleanArr[20]"; BooleanArr[20])
            {

                CaptionClass = '3,' + BooleanCaptionArr[20];
                Visible = BooleanVisible20;
                ToolTip = 'Specifies the value of the BooleanArr[20] field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if OptionString = '' then
            Error(SetOptionErr);
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
        SetOptionErr: Label 'You need to call function SetOption before running this page!';
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

