page 6150846 "NPR NPCamera"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Camera';

    layout
    {
        area(Content)
        {
            usercontrol("Camera Page"; "NPR NPCamera")
            {
                ApplicationArea = NPRRetail;

                trigger Ready()
                begin
                    CurrPage."Camera Page".Initialize(InitJson());
                end;

                trigger UsePhoto(ImageObj: JsonObject)
                begin
                    ImageJson := ImageObj;
                    GotPhoto := true;
                    CurrPage.Close();
                end;

                trigger Cancel()
                begin
                    GotPhoto := false;
                    CurrPage.Close();
                end;
            }
        }
    }

    /// <summary>
    /// Provides an easy way to take a picture with the camera. Will use default values unless a profile has code DEFAULT, then it will use that.
    /// Default values are PixelX=30000, PixelY=30000, Quality=0.5, ImageType=jpeg 
    /// </summary>
    /// <param name="ImageStream">Will insert the image bytes into the stream.</param>
    /// <returns>Boolean indicating if it has a picture</returns>
    internal procedure TakePicture(ImageStream: InStream): Boolean
    var
        NPCameraProf: Record "NPR NPCamera Profile";
    begin
        if (NPCameraProf.Get('DEFAULT')) then
            SetConfJson(NPCameraProf."Pixel X", NPCameraProf."Pixel Y", Format(NPCameraProf."Quality Option"), NPCameraProf."Quality Value", Format(NPCameraProf."File Type"))
        else
            //Pixel values will find closest possilbe ot ideal 30000 is to get max resolution.
            SetConfJson(30000, 30000, 'Low', 0.4, 'JPEG');
        exit(GetPhoto(ImageStream));
    end;

    /// <summary>
    /// Provides an easy way to take a picture with the camera based on a profile.
    /// </summary>
    /// <param name="ImageStream">Will insert the image bytes into the stream.</param>
    /// <returns>Boolean indicating if it has a picture</returns>
    internal procedure TakePicture(ImageStream: InStream; Profile: Record "NPR NPCamera Profile"): Boolean
    begin
        SetConfJson(Profile."Pixel X", Profile."Pixel Y", Format(Profile."Quality Option"), Profile."Quality Value", Format(Profile."File Type"));
        exit(GetPhoto(ImageStream));
    end;

    /// <summary>
    /// Provides an easy way to take a picture with the camera based on specific values.
    /// </summary>
    /// <param name="ImageStream">Will insert the image bytes into the stream.</param>
    /// <returns>Boolean indicating if it has a picture</returns>
    internal procedure TakePicture(ImageStream: InStream; "Pixel X": Integer; "Pixel Y": Integer; "Quality Option": Text; "Quality Value": Decimal; "File Type": Text): Boolean
    begin
        SetConfJson("Pixel X", "Pixel Y", "Quality Option", "Quality Value", "File Type");
        if (("Quality Value" < 0.0) or ("Quality Value" > 1.00)) then Error('Quality needs to be between 0.0-1.0');
        if (not (("File Type".ToUpper() = 'PNG') or ("File Type".ToUpper() = 'JPEG'))) then Error('File type needs to be either PNG or JPEG');
        exit(GetPhoto(ImageStream));
    end;

    local procedure GetPhoto(ImageStream: InStream): Boolean
    var
        token: JsonToken;
        base64: Codeunit "Base64 Convert";
        outStream: OutStream;
    begin
        CurrPage.RunModal();
        if (GotPhoto and ImageJson.Get('base64', token)) then begin
            blob.CreateOutStream(outStream);
            base64.FromBase64(token.AsValue().AsText(), outStream);
            blob.CreateInStream(ImageStream);
            exit(True);
        end else begin
            exit(False);
        end;
    end;

    local procedure InitJson(): JsonObject
    var
        json: JsonObject;
    begin
        json.Add('label_use', UseLabel);
        json.Add('label_retake', RetakeLabel);
        json.Add('label_restart', RestartLabel);
        json.Add('label_cancel', CancelLabel);
        json.Add('label_saving', SavingLabel);
        json.Add('label_camErr', CamErrorLabel);
        json.Add('config', ProfileJson);
        exit(json);
    end;

    local procedure SetConfJson(pixelX: Integer; pixelY: Integer; qualityOpt: Text; qualityVal: Decimal; imageType: Text);
    begin
        ProfileJson.Add('qualityOption', qualityOpt);
        ProfileJson.Add('qualityValue', qualityVal);
        ProfileJson.Add('imageType', imageType);
        ProfileJson.Add('resX', pixelX);
        ProfileJson.Add('resY', pixelY);
    end;

    var
        UseLabel: Label 'Use';
        RetakeLabel: Label 'Retake';
        RestartLabel: Label 'Restart Camera';
        CancelLabel: Label 'Cancel';
        SavingLabel: Label 'Saving image';
        CamErrorLabel: Label 'Camera can''t be accessed, make sure it has permission and is not being used by another process.';
        ProfileJson: JsonObject;
        ImageJson: JsonObject;
        GotPhoto: Boolean;
        blob: Codeunit "Temp Blob";
}
