codeunit 6184987 "NPR ES Retrieve Software JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        ESOrganization: Record "NPR ES Organization";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
    begin
        ESOrganization.SetRange("Taxpayer Created", true);
        ESOrganization.SetRange(Disabled, false);

        if ESOrganization.FindSet(true) then
            repeat
                ESFiskalyCommunication.RetrieveSoftware(ESOrganization);
            until ESOrganization.Next() = 0;
    end;
}