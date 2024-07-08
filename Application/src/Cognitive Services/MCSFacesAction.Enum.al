enum 6014443 "NPR MCS Faces Action"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF

    value(0; CaptureImage)
    {
        Caption = 'Capture Image';
    }
    value(1; CaptureAndIdentifyFaces)
    {
        Caption = 'Capture And Identify Faces';
    }
    value(2; IdentifyFaces)
    {
        Caption = 'Identify Faces';
    }

}
