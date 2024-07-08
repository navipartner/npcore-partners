codeunit 6014423 "NPR Open POS Page"
{
    Access = Internal;
    trigger OnRun();
    var
        Url: Text;
    begin
        Url := GetUrl(ClientType::Current, CompanyName(), ObjectType::Page, Page::"NPR POS (Dragonglass)");
        Hyperlink(Url);
    end;
}
