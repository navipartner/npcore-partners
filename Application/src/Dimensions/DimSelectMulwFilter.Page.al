page 6014546 "NPR Dim. Select.Mul.w.Filter"
{
    // NPR5.53/ALPO/20191016 CASE 371478 Dimension filter selection page for report 60144441 "POS Item Sales with Dimensions"

    Caption = 'Dimension Selection';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    SourceTable = "Dimension Selection Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Selected; Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selected field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Dimension Value Filter"; "Dimension Value Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Value Filter field';
                }
            }
        }
    }

    actions
    {
    }

    procedure GetDimSelBuf(var TheDimSelectionBuf: Record "Dimension Selection Buffer")
    begin
        TheDimSelectionBuf.DeleteAll;
        if Find('-') then
            repeat
                TheDimSelectionBuf := Rec;
                TheDimSelectionBuf.Insert;
            until Next = 0;
    end;

    procedure InsertDimSelBuf(NewSelected: Boolean; NewCode: Text[30]; NewDescription: Text[30]; NewDimValueFilter: Text[250])
    var
        Dim: Record Dimension;
        GLAcc: Record "G/L Account";
        BusinessUnit: Record "Business Unit";
    begin
        if NewDescription = '' then
            if Dim.Get(NewCode) then
                NewDescription := Dim.GetMLName(GlobalLanguage);

        Init;
        Selected := NewSelected;
        Code := NewCode;
        Description := NewDescription;
        "Dimension Value Filter" := NewDimValueFilter;
        case Code of
            GLAcc.TableCaption:
                "Filter Lookup Table No." := DATABASE::"G/L Account";
            BusinessUnit.TableCaption:
                "Filter Lookup Table No." := DATABASE::"Business Unit";
        end;
        Insert;
    end;
}

