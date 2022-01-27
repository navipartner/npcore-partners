interface "NPR API IAuthorization"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure IsEnabled(AuthTypeValue: Text; CompareAgainstValue: Text): Boolean;
    procedure CheckMandatoryValues(AuthParamBuff: Record "NPR Auth. Param. Buffer");
    internal procedure GetAuthorizationValue(AuthParamBuff: Record "NPR Auth. Param. Buffer"): Text;
    procedure SetAuthorizationValue(var Headers: HttpHeaders; AuthParamBuff: Record "NPR Auth. Param. Buffer")
}
