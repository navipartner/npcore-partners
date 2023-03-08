table 6014672 "NPR MPOS Data View"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'MPOS Data View';

    fields
    {
        field(1; "Data View Type"; Enum "NPR MPOS Data View Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Data View Type';

            trigger OnValidate()
            begin
                IncrementIndentation(Rec.FieldName("Data View Type"));
            end;
        }
        field(2; "Data View Category"; Enum "NPR MPOS Data View Category")
        {
            DataClassification = CustomerContent;
            Caption = 'Data View Category';

            trigger OnValidate()
            begin
                IncrementIndentation(Rec.FieldName("Data View Category"));
            end;
        }
        field(3; "Data View Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Data View Code';

            trigger OnValidate()
            begin
                IncrementIndentation(Rec.FieldName("Data View Code"));
            end;

            trigger OnLookup()
            begin
                LookupDataViewCode();
            end;
        }
        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(5; Indent; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Indent';
        }
        field(6; "Category Default"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Category Default';

            trigger OnValidate()
            begin
                ClearDefaultCategory();
            end;
        }
        field(7; "Response Size"; Enum "NPR MPOS Response Size")
        {
            DataClassification = CustomerContent;
            Caption = 'Response Size';
        }
    }

    keys
    {
        key(Key1; "Data View Type", "Data View Category", "Data View Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DataViewMgt: Codeunit "NPR MPOS Data View Mgt.";
    begin
        DataViewMgt.DeleteIndentLevels(Rec.Indent, Rec."Data View Type", Rec."Data View Category");
    end;

    internal procedure InitRec(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category")
    begin
        Rec."Data View Type" := DataViewType;
        Rec."Data View Category" := DataViewCategory;
        Rec."Data View Code" := '';
    end;

    local procedure ClearDefaultCategory()
    var
        DataView: Record "NPR MPOS Data View";
    begin
        if not Rec."Category Default" then
            exit;
        DataView.SetRange("Data View Type", Rec."Data View Type");
        DataView.SetRange("Data View Category", Rec."Data View Category");
        DataView.SetRange("Category Default", true);
        if not DataView.IsEmpty() then
            DataView.ModifyAll("Category Default", false);
    end;

    local procedure IncrementIndentation(CalledFromFieldName: Text)
    begin
        case CalledFromFieldName of
            Rec.FieldName("Data View Type"):
                begin
                    Rec.Indent := 0;
                end;
            Rec.FieldName("Data View Category"):
                begin
                    Rec.Indent := 1;
                end;
            Rec.FieldName("Data View Code"):
                begin
                    Rec.Indent := 2;
                end;
        end;
    end;

    local procedure LookupDataViewCode()
    var
        DataViewMgt: Codeunit "NPR MPOS Data View Mgt.";
        DataViewCode: Text;
    begin
        if DataViewMgt.LookupDataView(Rec."Data View Type", DataViewCode) then begin
            Rec.Validate("Data View Code", DataViewCode);
        end;
    end;
}