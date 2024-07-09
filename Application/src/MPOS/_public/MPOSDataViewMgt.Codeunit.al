codeunit 6059827 "NPR MPOS Data View Mgt."
{
    procedure LookUpDataView(DataViewType: Enum "NPR MPOS Data View Type"; var DataViewCode: Text): Boolean
    var
        IDataViewType: Interface "NPR MPOS IDataViewType";
    begin
        IDataViewType := DataViewType;
        exit(IDataViewType.LookupCode(DataViewCode));
    end;

    procedure GetViews(DataViewType: Enum "NPR MPOS Data View Type"): JsonToken
    var
        IDataViewType: Interface "NPR MPOS IDataViewType";
    begin
        IDataViewType := DataViewType;
        exit(IDataViewType.GetViews());
    end;

    procedure GetViews(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category"): JsonToken
    var
        IDataViewCategory: Interface "NPR MPOS IDataViewCategory";
    begin
        IDataViewCategory := DataViewCategory;
        exit(IDataViewCategory.GetViews(DataViewType, DataViewCategory));
    end;

    procedure GetView(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category"; DataViewCode: Code[20]; Request: JsonToken): JsonToken
    var
        IDataViewCategory: Interface "NPR MPOS IDataViewCategory";
    begin
        IDataViewCategory := DataViewCategory;
        exit(IDataViewCategory.GetView(DataViewType, DataViewCategory, DataViewCode, Request));
    end;

    [Obsolete('Use PreviewCategory(Enum "NPR MPOS Data View Category"; Guid)', '2023-06-28')]
#pragma warning disable AL0749
    procedure Preview(Rec: Record "NPR MPOS Data View")
#pragma warning restore AL0749
    var
        IDataViewCategory: Interface "NPR MPOS IDataViewCategory";
    begin
        IDataViewCategory := Rec."Data View Category";
        IDataViewCategory.Preveiw(Rec.SystemId);
    end;

    internal procedure Preview_(Rec: Record "NPR MPOS Data View")
    var
        IDataViewCategory: Interface "NPR MPOS IDataViewCategory";
    begin
        IDataViewCategory := Rec."Data View Category";
        IDataViewCategory.Preveiw(Rec.SystemId);
    end;

    procedure PreviewCategory(DataViewCategory: Enum "NPR MPOS Data View Category"; SystemId: Guid)
    var
        IDataViewCategory: Interface "NPR MPOS IDataViewCategory";
    begin
        IDataViewCategory := DataViewCategory;
        IDataViewCategory.Preveiw(SystemId);
    end;

    procedure FormatResultAsText(DataViews: JsonToken): Text
    var
        Result: Text;
    begin
        case true of
            DataViews.IsObject():
                begin
                    DataViews.AsObject().WriteTo(Result);
                end;
            DataViews.IsArray():
                begin
                    DataViews.AsArray().WriteTo(Result);
                end;
        end;
        exit(Result);
    end;

    internal procedure DeleteLevels(var Rec: Record "NPR MPOS Data View")
    var
        DataView: Record "NPR MPOS Data View";
    begin
        case Rec.Indent of
            0:
                begin
                    DataView.SetRange("Data View Type", Rec."Data View Type");
                    DataView.SetRange(Indent, 1);
                    if not DataView.IsEmpty() then
                        DataView.DeleteAll(true);
                end;
            1:
                begin
                    DataView.SetRange("Data View Type", Rec."Data View Type");
                    DataView.SetRange("Data View Category", Rec."Data View Category");
                    DataView.SetRange(Indent, 2);
                    if not DataView.IsEmpty() then
                        DataView.DeleteAll(true);
                end;
        end;
    end;

    procedure DeleteIndentLevels(Indent: Integer; DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category")
    var
        DataView: Record "NPR MPOS Data View";
    begin
        case Indent of
            0:
                begin
                    DataView.SetRange("Data View Type", DataViewType);
                    DataView.SetRange(Indent, 1);
                    if not DataView.IsEmpty() then
                        DataView.DeleteAll(true);
                end;
            1:
                begin
                    DataView.SetRange("Data View Type", DataViewType);
                    DataView.SetRange("Data View Category", DataViewCategory);
                    DataView.SetRange(Indent, 2);
                    if not DataView.IsEmpty() then
                        DataView.DeleteAll(true);
                end;
        end;
    end;
}
