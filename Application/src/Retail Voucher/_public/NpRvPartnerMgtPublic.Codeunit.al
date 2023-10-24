codeunit 6060059 "NPR NpRv Partner Mgt. Public"
{
    procedure GetServiceName(NpRvPartner: Record "NPR NpRv Partner") ServiceName: Text
    var
        NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
    begin
        ServiceName := NpRvPartnerMgt.GetServiceName(NpRvPartner);
    end;
}
