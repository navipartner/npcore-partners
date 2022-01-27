codeunit 6150757 "NPR Front-End: SetImage" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _id: Text;
        _image: Text;

    procedure SetImage(Id: Text; ImageBase64: Text)
    begin
        _id := Id;
        _image := ImageBase64;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'SetImage');
        Json.Add('Id', _id);
        Json.Add('Image', 'data:image/png;base64,' + _image);
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
