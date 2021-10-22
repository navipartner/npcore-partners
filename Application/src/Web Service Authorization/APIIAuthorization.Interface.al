interface "NPR API IAuthorization"
{
    procedure IsEnabled(Rec: Variant; SearchForFieldName: Text; CompareAgainstValue: Text): Boolean;
    procedure CheckMandatoryValues(AuthDetailsDict: Dictionary of [Text, Text]);
    procedure GetAuthorizationValue(AuthDetailsDict: Dictionary of [Text, Text]): Text;

    //Used Preprocessor directives so when we end BC17 releases we can remove all BC17 code and use the better version of code
#IF BC17
    procedure GetAuthorizationDetailsDict(BasicUserName: Code[50]; BasicPassword: Text; OAuthSetupCode: Code[20]; var AuthDetailsDict: Dictionary of [Text, Text]);
#ELSE
    procedure GetAuthorizationDetailsDict(BasicUserName: Code[50]; BasicPassword: Text; OAuthSetupCode: Code[20]) AuthDetailsDict: Dictionary of [Text, Text];
#ENDIF
}
