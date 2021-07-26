interface "NPR Replication API IAuthorization"
{

    procedure IsEnabled(Rec: Variant; SearchForFieldName: Text; CompareAgainstValue: Text): Boolean;
    procedure CheckMandatoryValues(ServiceSetup: Record "NPR Replication Service Setup");
    procedure GetAuthorizationValue(ServiceSetup: Record "NPR Replication Service Setup"): Text;

}
