report 6014557 "NPR Transf.Ord. DataSource Ext"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'Transfer Order Ext. Field Location Setup';
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPreReport()
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
    begin
        DataSourceExtFieldSetup.FilterGroup(2);
        DataSourceExtFieldSetup.SetRange("Extension Module", DataSourceExtFieldSetup."Extension Module"::TransferOrder);
        DataSourceExtFieldSetup.FilterGroup(0);
        Page.Run(Page::"NPR POS DS Exten. Field Setup", DataSourceExtFieldSetup);
    end;
}
