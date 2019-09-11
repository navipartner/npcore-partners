codeunit 6059925 "IDS Event Subscriber"
{
    // --Codeunit 90 Purch.-Post--
    // IDS1.00/JDH/200514 CASE  Posting Of IDS orders can be sendt back to original database
    // 
    // --Codeunit 414 Release Sales Document--
    // IDS1.00/JDH/070514 CASE176703  Implemented IDS In onRelease Trigger
    // 
    // --Codeunit 415 Release Purchase Document--
    // IDS1.00/JDH/070514 CASE176703  Implemented IDS In onRelease Trigger
    // 
    // NPR5.23/BR/20160509 CASE 241073 Renumbered this codeunit (was 6059924) for 90 database because of conflict with IDS1.19 in 80
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion


    trigger OnRun()
    begin
    end;
}

