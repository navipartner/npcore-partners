page 6014546 "NPR Dim. Select.Mul.w.Filter"
{
    Caption = 'Dimension Selection';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Dimension Selection Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selected field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Dimension Value Filter"; Rec."Dimension Value Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Value Filter field';
                }
            }
        }
    }
    procedure GetDimSelBuf(var TheDimSelectionBuf: Record "Dimension Selection Buffer")
    begin
        TheDimSelectionBuf.DeleteAll;
        if Rec.FindSet() then
            repeat
                TheDimSelectionBuf := Rec;
                TheDimSelectionBuf.Insert;
            until Rec.Next = 0;
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

        Rec.Init;
        Rec.Selected := NewSelected;
        Rec.Code := NewCode;
        Rec.Description := NewDescription;
        Rec."Dimension Value Filter" := NewDimValueFilter;
        case Rec.Code of
            GLAcc.TableCaption:
                Rec."Filter Lookup Table No." := DATABASE::"G/L Account";
            BusinessUnit.TableCaption:
                Rec."Filter Lookup Table No." := DATABASE::"Business Unit";
        end;
        Rec.Insert;
    end;
}

