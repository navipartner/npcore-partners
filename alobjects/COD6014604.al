codeunit 6014604 ItemWizardJnlManagement
{
    // NPKWiz1.03/JDH/290414 Added function to delete journal lines when exiting journal
    // NPR5.48/JDH /20181108 CASE 334163 Adding missing Captions, and a general cleanup
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Permissions = TableData "Gen. Journal Template"=imd,
                  TableData "Gen. Journal Batch"=imd;

    trigger OnRun()
    begin
    end;
}

