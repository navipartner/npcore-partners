codeunit 6151537 "NPR TM Client API"
{
    Access = Public;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    begin
        if (not Method.StartsWith('NPRetail.TM.')) then
            exit;

        Handled := true;
        FrontEnd.RespondToFrontEndMethod(Context, MethodDispatch(Method, Context), FrontEnd);
    end;

    procedure MethodDispatch(Method: Text; Request: JsonObject) Response: JsonObject
    var
        ClientApi: Codeunit "NPR TM Client API BL";
        JToken: JsonToken;
        JObject: JsonObject;
        RequestArray: JsonArray;
    begin
        if (not Request.Get(Method, JToken)) then
            Error('Request does not contain an object matching the method name: [%1]', Method);

        case true of
            JToken.IsObject():
                RequestArray.Add(JToken.AsObject());
            JToken.IsArray():
                RequestArray := JToken.AsArray();
            else
                Error('Invalid request.');
        end;

        case Method of
            'NPRetail.TM.GetTicketReservation':
                JObject.ReadFrom(ClientApi.GetReservationAction(RequestArray));
            'NPRetail.TM.CancelTicketReservation':
                JObject.ReadFrom(ClientApi.CancelRequestAction(RequestArray));
            'NPRetail.TM.PreConfirmTicketReservation':
                JObject.ReadFrom(ClientApi.PreConfirmRequestAction(RequestArray));
            'NPRetail.TM.MakeTicketReservation':
                JObject.ReadFrom(ClientApi.MakeReservationAction(RequestArray));
            'NPRetail.TM.GetAdmissionCapacity':
                JObject.ReadFrom(ClientApi.GetAdmissionCapacityAction(RequestArray));
            'NPRetail.TM.ConfirmTicketReservation':
                JObject.ReadFrom(ClientApi.ConfirmRequestAction(RequestArray));
        end;
        Response.Add(Method, JObject);
    end;

    internal procedure GetReservationRequest(Token: Text[100]): JsonObject
    var
        Payload: JsonObject;
        Request: JsonObject;
        Method: Label 'NPRetail.TM.GetTicketReservation', Locked = true;
    begin
        Payload.Add('token', Token);
        Request.Add(Method, Payload);
        exit(MethodDispatch(Method, Request));
    end;

    internal procedure CancelReservationRequest(Token: Text[100]): JsonObject
    var
        Payload: JsonObject;
        Request: JsonObject;
        Method: Label 'NPRetail.TM.CancelTicketReservation', Locked = true;
    begin
        Payload.Add('token', Token);
        Request.Add(Method, Payload);
        exit(MethodDispatch(Method, Request));
    end;

    internal procedure PreConfirmReservationRequest(Token: Text[100]): JsonObject
    var
        Payload: JsonObject;
        Request: JsonObject;
        Method: Label 'NPRetail.TM.PreConfirmTicketReservation', Locked = true;
    begin
        Payload.Add('token', Token);
        Request.Add(Method, Payload);
        exit(MethodDispatch(Method, Request));
    end;

    procedure ConfirmReservationRequest(Token: Text[100]; NotificationAddress: Text[80]; PaymentReference: Text[20]) Response: JsonObject
    var
        Request: JsonObject;
        Requests: JsonObject;
        RequestArray: JsonArray;
        Method: Label 'NPRetail.TM.ConfirmTicketReservation', Locked = true;
    begin
        Request.Add('token', Token);
        Request.Add('notificationAddress', NotificationAddress);
        Request.Add('paymentReference', PaymentReference);
        RequestArray.Add(Request);

        Requests.Add(Method, Request);
        exit(MethodDispatch(Method, Requests));
    end;

    procedure AdmissionCapacityRequest(RequestId: Text[20]; ItemReference: Code[50]; AdmissionCode: Code[20]; ReferenceDate: Date; CustomerCode: Code[20]; Quantity: Integer) Response: JsonObject
    var
        Request: JsonObject;
        Requests: JsonObject;
        RequestArray: JsonArray;
        Method: Label 'NPRetail.TM.GetAdmissionCapacity', Locked = true;
    begin
        Request.Add('requestId', RequestId);
        Request.Add('itemReference', ItemReference);
        Request.Add('admissionCode', AdmissionCode);
        Request.Add('referenceDate', ReferenceDate);
        Request.Add('customerNumber', CustomerCode);
        Request.Add('quantity', Quantity);
        RequestArray.Add(Request);

        Requests.Add(Method, Request);
        exit(MethodDispatch(Method, Requests));
    end;

    internal procedure ExportJsonToFile(Name: Text; JsonData: JsonObject)
    var
        IStream: InStream;
        OStream: OutStream;
        FileName: Text;
        JsonText: Text;
        TempBlob: Codeunit "Temp Blob";
        FileNameLbl: Label '%1.json', Locked = true;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        JsonData.WriteTo(JsonText);
        OStream.WriteText(JsonText);

        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        CopyStream(OStream, IStream);

        FileName := StrSubstNo(FileNameLbl, Name);
        DownloadFromStream(IStream, '', '', 'JSON File (*.json)|*.json', FileName);
    end;

}

