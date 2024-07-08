enum 6014432 "NPR Magento Miniature Picture"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; "SinglePicutre")
    {
        Caption = 'Single Picture';
    }
    value(2; "LinePicture")
    {
        Caption = 'Line Picture';
    }
    value(3; "SinglePicture+LinePicture")
    {
        Caption = 'Single Picture + Line Picture';
    }
}
