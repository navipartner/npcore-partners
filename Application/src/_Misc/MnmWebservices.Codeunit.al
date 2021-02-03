codeunit 6014698 "NPR Mnm Webservices"
{
    procedure GetNavObjects(var objects: XMLport "NPR Mnm Export Nav Objects")
    begin
        objects.Import();
        objects.Export();
    end;
}

