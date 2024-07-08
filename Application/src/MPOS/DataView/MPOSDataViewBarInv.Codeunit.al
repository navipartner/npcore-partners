codeunit 6059825 "NPR MPOS Data View - Bar. Inv." implements "NPR MPOS IDataViewCategory"
{
    Access = Internal;

    var
        ApplicableMsg: Label 'applicable', Locked = true;
        MessageMsg: Label 'message', Locked = true;
        NotApplicableMsg: Label 'N/A', Locked = true;

    procedure Preveiw(SystemId: Guid)
    var
        Rec: Record "NPR MPOS Data View";
        InputDialog: Page "NPR Input Dialog";
        MPOSWebservice: codeunit "NPR MPOS Webservice";
        EnterBarcodeLbl: Label 'Enter barcode';
        Barcode: Code[50];
    begin
        Rec.GetBySystemId(SystemId);
        case Rec.Indent of
            0:
                begin
                    Message(MPOSWebservice.GetNaviConnectViews());
                end;
            1:
                begin
                    Message(MPOSWebservice.GetBarcodeInventoryViews());
                end;
            2:
                begin
                    InputDialog.SetInput(1, Barcode, EnterBarcodeLbl);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal() <> ACTION::LookupOK then
                        exit;
                    InputDialog.InputCodeValue(1, Barcode);

                    Message(MPOSWebservice.GetBarcodeInventoryView(Rec."Data View Code", Barcode));
                end;
        end;
    end;

    procedure GetViews(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category"): JsonToken
    var
        DataView: Record "NPR MPOS Data View";
        IDataViewType: Interface "NPR MPOS IDataViewType";
        DataViewsResponse: JsonArray;
        DataViewResponse: JsonObject;
        DataViewsNotFoundMsg: Label 'Data views not found in %1', Comment = '%1=DataView.TableCaption()';
    begin
        DataView.SetRange("Data View Type", DataViewType);
        DataView.SetRange("Data View Category", DataViewCategory);
        if not DataView.FindSet() then begin
            DataViewResponse.Add(ApplicableMsg, NotApplicableMsg);
            DataViewResponse.Add(MessageMsg, StrSubstNo(DataViewsNotFoundMsg, DataView.TableCaption()));
            exit(DataViewResponse.AsToken());
        end;

        repeat
            IDataViewType := DataView."Data View Type";
            if IDataViewType.IsActive(DataView."Data View Code") then begin
                Clear(DataViewResponse);
                DataViewResponse.Add(DataView.FieldName("Data View Type"), Format(DataView."Data View Type"));
                DataViewResponse.Add(DataView.FieldName("Data View Category"), Format(DataView."Data View Category"));
                DataViewResponse.Add(DataView.FieldName("Data View Code"), Format(DataView."Data View Code"));
                DataViewResponse.Add(DataView.FieldName(Description), Format(DataView.Description));
                DataViewsResponse.Add(DataViewResponse);
            end;
        until DataView.next() = 0;
        exit(DataViewsResponse.AsToken());
    end;

    procedure GetView(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category";
                                        DataViewCode: Code[20];
                                        Request: JsonToken): JsonToken
    var
        IDataViewType: Interface "NPR MPOS IDataViewType";
    begin
        IDataViewType := DataViewType;
        exit(IDataViewType.ProcessView(DataViewCode, Request));
    end;
}