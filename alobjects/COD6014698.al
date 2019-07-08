codeunit 6014698 "Mnm Webservices"
{
    // NPR5.35/MHA /20170828  CASE 287440 Managed Nav Modules: Object created
    // NPR5.37/MHA /20171027  CASE 294593 Added import to GetNavObjects() to enabled Version List Filter


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetNavObjects(var objects: XMLport "Mnm Export Nav Objects")
    begin
        //-NPR5.37 [294593]
        //CLEAR(objects);
        objects.Import;
        //+NPR5.37 [294593]
        objects.Export;
    end;
}

